import 'dart:async';
import 'dart:io';

import 'package:pixiv_dart_api/utils/io_extension.dart';
import 'package:sqlite3/sqlite3.dart';

import '../model/illust.dart';
import 'PDio.dart';
import 'bases.dart' show BasePath;
import 'download_task.dart';
import 'settings.dart';

class DownloadedIllust {
  final int illustId;
  final String title;
  final String author;
  final int imageCount;

  DownloadedIllust({
    required this.illustId,
    required this.title,
    required this.author,
    required this.imageCount,
  });
}

class DownloadManager {
  factory DownloadManager() => instance ??= DownloadManager._();

  static DownloadManager? instance;

  DownloadManager._() {
    init();
  }

  late Database _db;

  int _currentBytes = 0;
  int _bytesPerSecond = 0;

  int get bytesPerSecond => _bytesPerSecond;

  Timer? _loop;

  static PDio dio = PDio();

  var tasks = <DownloadIllustTask>[];

  void Function()? uiUpdateCallback;

  void registerUiUpdater(void Function() callback) {
    uiUpdateCallback = callback;
  }

  void removeUiUpdater() {
    uiUpdateCallback = null;
  }

  void init() {
    _db = sqlite3.open(BasePath.downloadDbPath);
    _db.execute('''
      create table if not exists download (
        illust_id integer primary key not null,
        title text not null,
        author text not null,
        imageCount int not null
      );
    ''');
    _db.execute('''
      create table if not exists images (
        illust_id integer not null,
        image_index integer not null,
        path text not null,
        primary key (illust_id, image_index)
      );
    ''');
  }

  void saveInfo(Illust illust, List<String> imagePaths) {
    _db.execute('''
      insert into download (illust_id, title, author, imageCount)
      values (?, ?, ?, ?)
    ''', [illust.id, illust.title, illust.author.name, imagePaths.length]);
    for (var i = 0; i < imagePaths.length; i++) {
      _db.execute('''
        insert into images (illust_id, image_index, path)
        values (?, ?, ?)
      ''', [illust.id, i, imagePaths[i]]);
    }
  }

  File? getImage(int illustId, int index) {
    var res = _db.select('''
      select * from images
      where illust_id = ? and image_index = ?;
    ''', [illustId, index]);
    if (res.isEmpty) return null;
    var file = File(res.first["path"] as String);
    if (!file.existsSync()) return null;
    return file;
  }

  bool checkDownloaded(int illustId) {
    var res = _db.select('''
      select * from download
      where illust_id = ?;
    ''', [illustId]);
    return res.isNotEmpty;
  }

  bool checkDownloading(int illustId) {
    return tasks.any((element) => element.illust.id == illustId);
  }

  List<DownloadedIllust> listAll() {
    var res = _db.select('''
      select * from download;
    ''');
    return res
        .map((e) => DownloadedIllust(
              illustId: e["illust_id"] as int,
              title: e["title"] as String,
              author: e["author"] as String,
              imageCount: e["imageCount"] as int,
            ))
        .toList();
  }

  void addDownloadingTask(Illust illust) {
    if (checkDownloading(illust.id) || checkDownloaded(illust.id)) return;
    var task = DownloadIllustTask(illust, receiveBytesCallback: receiveBytes,
        onCompleted: (task) {
      saveInfo(illust, task.imagePaths);
      tasks.remove(task);
    });
    tasks.add(task);
    run();
  }

  void receiveBytes(int bytes) {
    _currentBytes += bytes;
  }

  int get maxConcurrentTasks => settings.maxParallels;

  bool _paused = false;

  bool get paused => _paused;

  void pause() {
    _paused = true;
    for (var task in tasks) {
      task.pause();
    }
  }

  void run() {
    _loop ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_paused) return;
      _bytesPerSecond = _currentBytes;
      _currentBytes = 0;
      uiUpdateCallback?.call();
      for (int i = 0; i < maxConcurrentTasks; i++) {
        var task = tasks.elementAtOrNull(i);
        if (task != null && task.stop && task.error == null) {
          task.start();
        }
      }
      if (tasks.isEmpty) {
        timer.cancel();
        _loop = null;
        _currentBytes = 0;
        _bytesPerSecond = 0;
      }
    });
  }

  void delete(DownloadedIllust illust) {
    _db.execute('''
      delete from download
      where illust_id = ?;
    ''', [illust.illustId]);
    var images = _db.select('''
      select * from images
      where illust_id = ?;
    ''', [illust.illustId]);
    for (var image in images) {
      File(image["path"] as String).deleteIgnoreError();
    }
    _db.execute('''
      delete from images
      where illust_id = ?;
    ''', [illust.illustId]);
  }

  List<String> getImagePaths(int illustId) {
    var res = _db.select('''
      select * from images
      where illust_id = ?;
    ''', [illustId]);
    return res.map((e) => e["path"] as String).toList();
  }

  Future<void> batchDownload(List<Illust> illusts, int maxCount) async {
    int i = 0;
    for (var illust in illusts) {
      if (i > maxCount) return;
      addDownloadingTask(illust);
      i++;
    }
  }

  Future<void> checkAndClearInvalidItems() async {
    var illusts = listAll();
    var shouldDelete = <DownloadedIllust>[];
    for (var item in illusts) {
      var paths = getImagePaths(item.illustId);
      var validPaths = <String>[];
      for (var path in paths) {
        if (await File(path).exists()) {
          validPaths.add(path);
        }
      }
      if (validPaths.isEmpty) {
        shouldDelete.add(item);
      }
    }
    for (var item in shouldDelete) {
      delete(item);
    }
  }

  void resume() {
    _paused = false;
  }
}
