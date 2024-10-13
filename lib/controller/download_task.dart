import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../model/illust.dart';
import '../utils/io_extension.dart';
import 'bases.dart';
import 'downloader.dart';
import 'logging.dart';

class DownloadIllustTask {
  final Illust illust;

  void Function(int)? receiveBytesCallback;

  void Function(DownloadIllustTask)? onCompleted;

  DownloadIllustTask(this.illust,
      {this.receiveBytesCallback, this.onCompleted});

  int _downloadingIndex = 0;

  int get totalImages => illust.images.length;

  int get downloadedImages => _downloadingIndex;

  bool _stop = true;

  bool get stop => _stop;

  String? error;

  void start() {
    _stop = false;
    _download();
  }

  void cancel() {
    _stop = true;
    DownloadManager().tasks.remove(this);
    for (var path in imagePaths) {
      File(path).deleteIfExists();
    }
  }

  List<String> imagePaths = [];

  void _download() async {
    try {
      while (_downloadingIndex < illust.images.length) {
        if (_stop) return;
        var url = illust.images[_downloadingIndex].original;
        var ext = url.split('.').last;
        if (!["jpg", "png", "gif", "webp", "jpeg", "avif"].contains(ext)) {
          ext = "jpg";
        }
        var path = _generateFilePath(illust, _downloadingIndex, ext);
        final time =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
        final hash =
            md5.convert(utf8.encode(time + BaseClient.hashSalt)).toString();
        var res = await DownloadManager.dio.get<ResponseBody>(url,
            options: Options(
              responseType: ResponseType.stream,
              headers: {
                "referer": "https://app-api.pixiv.net/",
                "user-agent": "PixivAndroidApp/5.0.234 (Android 14; Pixes)",
                "x-client-time": time,
                "x-client-hash": hash,
                "accept-enconding": "gzip",
              },
            ));
        var file = File(path);
        if (!file.existsSync()) {
          file.createSync(recursive: true);
        }
        await for (var data in res.data!.stream) {
          await file.writeAsBytes(data, mode: FileMode.append);
          receiveBytesCallback?.call(data.length);
        }
        imagePaths.add(path);
        _downloadingIndex++;
        _retryCount = 0;
      }
      onCompleted?.call(this);
    } catch (e, s) {
      _handleError(e);
      loggerError("Download error: $e\n$s");
    }
  }

  int _retryCount = 0;

  void _handleError(Object error) async {
    _retryCount++;
    if (_retryCount > 3) {
      _stop = true;
      error = error.toString();
      return;
    }
    await Future.delayed(Duration(seconds: 1 << _retryCount));
    _download();
  }

  static String _generateFilePath(Illust illust, int index, String ext) {
    final String downloadPath = BasePath.downloadPath;
    String subPathPatten = BasePath.downloadSubPath;
    subPathPatten = subPathPatten.replaceAll(r"${id}", illust.id.toString());
    subPathPatten = subPathPatten.replaceAll(r"${title}", illust.title);
    subPathPatten = subPathPatten.replaceAll(r"${author}", illust.author.name);
    subPathPatten = subPathPatten.replaceAll(r"${index}", index.toString());
    subPathPatten = subPathPatten.replaceAll(
        r"${page}", illust.images.length == 1 ? "" : "-p$index");
    subPathPatten = subPathPatten.replaceAll(r"${ext}", ext);
    subPathPatten = subPathPatten.replaceAll(r"${AI}", illust.isAi ? "AI" : "");
    List<String> extractTags(String input) {
      final regex = RegExp(r'\$\{tag\((.*?)\)\}');
      final matches = regex.allMatches(input);
      return matches.map((match) => match.group(1)!).toList();
    }

    var tags = extractTags(subPathPatten);
    for (var tag in tags) {
      if (illust.tags
          .where((e) => e.name == tag || e.translatedName == tag)
          .isNotEmpty) {
        subPathPatten = subPathPatten.replaceAll("\${tag($tag)}", tag);
      }
    }
    return _cleanFilePath("$downloadPath$subPathPatten");
  }

  static String _cleanFilePath(String filePath) {
    const invalidChars = ['*', '?', '"', '<', '>', '|'];

    String cleanedPath =
        filePath.replaceAll(RegExp('[${invalidChars.join(' ')}]'), '');

    cleanedPath = cleanedPath.replaceAll(RegExp(r'[/\\]+'), '/');

    return cleanedPath;
  }

  void retry() {
    error = null;
    _stop = false;
    _download();
  }

  void pause() {
    _stop = true;
  }
}

class DownloadNovelTask {}
