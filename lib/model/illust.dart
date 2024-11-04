import 'package:skana_pix/utils/filters.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import 'author.dart' show Author;
import 'tag.dart' show Tag;

class IllustImage {
  final String squareMedium;
  final String medium;
  final String large;
  final String original;

  const IllustImage(this.squareMedium, this.medium, this.large, this.original);
  IllustImage.fromJson(Map<String, dynamic> json)
      : squareMedium = json['square_medium'] ?? "",
        medium = json['medium'] ?? "",
        large = json['large'] ?? "",
        original = json['original'] ?? "";
}

class Illust {
  final int id;
  final String title;
  final String type;
  final List<IllustImage> images;
  final String caption;
  final int restrict;
  final Author author;
  final List<Tag> tags;
  final DateTime createDate;
  final int pageCount;
  final int width;
  final int height;
  final int totalView;
  final int totalBookmarks;
  bool isBookmarked;
  final bool isAi;
  final bool isUgoira;
  final bool isMuted;

  bool get isR18 => tags.contains(const Tag("R-18", null));

  bool get isR18G => tags.contains(const Tag("R-18G", null));

  bool get isBlocked => isMuted || (checkIllusts([this]).isEmpty);

  Illust.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        type = json['type'],
        images = (() {
          List<IllustImage> images = [];
          for (var i in json['meta_pages']) {
            images.add(IllustImage(
                i['image_urls']['square_medium'],
                i['image_urls']['medium'],
                i['image_urls']['large'],
                i['image_urls']['original']));
          }
          if (images.isEmpty) {
            images.add(IllustImage(
                json['image_urls']['square_medium'],
                json['image_urls']['medium'],
                json['image_urls']['large'],
                json['meta_single_page']['original_image_url']));
          }
          return images;
        }()),
        caption = json['caption'],
        restrict = json['restrict'],
        author = Author(
            json['user']['id'],
            json['user']['name'],
            json['user']['account'],
            json['user']['profile_image_urls']['medium'],
            json['user']['is_followed'] ?? false),
        tags = (json['tags'] as List)
            .map((e) => Tag(e['name'], e['translated_name']))
            .toList(),
        createDate = DateTime.parse(json['create_date']),
        pageCount = json['page_count'],
        width = json['width'],
        height = json['height'],
        totalView = json['total_view'],
        totalBookmarks = json['total_bookmarks'],
        isBookmarked = json['is_bookmarked'],
        isAi = json['illust_ai_type'] == 2,
        isUgoira = json['type'] == "ugoira",
        isMuted = json['is_muted'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'images': images.map((e) => {
            'square_medium': e.squareMedium,
            'medium': e.medium,
            'large': e.large,
            'original': e.original
          }),
      'caption': caption,
      'restrict': restrict,
      'author': author.toJson(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'create_date': createDate.toIso8601String(),
      'page_count': pageCount,
      'width': width,
      'height': height,
      'total_view': totalView,
      'total_bookmarks': totalBookmarks,
      'is_bookmarked': isBookmarked,
      'is_ai': isAi,
      'is_ugoira': isUgoira,
      'is_muted': isMuted
    };
  }

  @override
  String toString() {
    return 'Illust{id: $id, title: $title, type: $type, images: $images, caption: $caption, restrict: $restrict, author: $author, tags: $tags, createDate: $createDate, pageCount: $pageCount, width: $width, height: $height, totalView: $totalView, totalBookmarks: $totalBookmarks, isBookmarked: $isBookmarked, isAi: $isAi, isUgoira: $isUgoira, isMuted: $isMuted}';
  }
}

class IllustHistory {
  int? id;
  int illustId;
  int userId;
  String pictureUrl;
  String? userName;
  String? title;
  int time;

  IllustHistory(
      {this.id,
      required this.illustId,
      required this.userId,
      required this.pictureUrl,
      required this.time,
      required this.title,
      required this.userName});

  factory IllustHistory.fromJson(Map<String, dynamic> json) => IllustHistory(
        id: (json['id'] as num?)?.toInt(),
        illustId: (json['illust_id'] as num).toInt(),
        userId: (json['user_id'] as num).toInt(),
        pictureUrl: json['picture_url'] as String,
        time: (json['time'] as num).toInt(),
        title: json['title'] as String?,
        userName: json['user_name'] as String?,
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'illust_id': illustId,
        'user_id': userId,
        'picture_url': pictureUrl,
        'user_name': userName,
        'title': title,
        'time': time,
      };
}

const String illustHisTable = 'IllustHis';
const String cid = "id";
const String cillust_id = "illust_id";
const String cuser_id = "user_id";
const String cpicture_url = "picture_url";
const String ctitle = "title";
const String cuser_name = "user_name";
const String ctime = "time";

class IllustHistoryProvider {
  late Database db;

  void _createTable(Batch batch) {
    batch.execute('''
create table $illustHisTable ( 
  $cid integer primary key autoincrement, 
  $cillust_id integer not null,
  $cuser_id integer not null,
  $cpicture_url text not null,
  $ctitle text,
  $cuser_name text,
    $ctime integer not null
  )
''');
  }

  Future open() async {
    String databasesPath = (await getDatabasesPath());
    String path = join(databasesPath, 'IllustHis.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        var batch = db.batch();
        _createTable(batch);
        await batch.commit();
      },
    );
  }

  Future<IllustHistory> insert(IllustHistory todo) async {
    final result = await getIllust(todo.illustId);
    if (result != null) {
      todo.id = result.id;
    }
    todo.id = await db.insert(illustHisTable, todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return todo;
  }

  Future<IllustHistory?> getIllust(int illustId) async {
    List<Map<String, dynamic>> maps = await db.query(illustHisTable,
        columns: [cid, cillust_id, cuser_id, cpicture_url, ctime],
        where: '$cillust_id = ?',
        whereArgs: [illustId]);
    if (maps.isNotEmpty) {
      return IllustHistory.fromJson(maps.first);
    }
    return null;
  }

  Future<List<IllustHistory>> getLikeIllusts(String word) async {
    List<IllustHistory> result = [];
    List<Map<String, dynamic>> maps = await db.query(illustHisTable,
        columns: [
          cid,
          cillust_id,
          cuser_id,
          cpicture_url,
          ctime,
          cuser_name,
          ctitle
        ],
        where: '$ctitle LIKE ? or $cuser_name LIKE ?',
        whereArgs: ["%$word%", "%$word%"],
        orderBy: "$ctime DESC");

    if (maps.isNotEmpty) {
      for (var f in maps) {
        result.add(IllustHistory.fromJson(f));
      }
    }
    return result;
  }

  Future<List<IllustHistory>> getAllIllusts({int? limit, int? offset}) async {
    List<IllustHistory> result = [];
    List<Map<String, dynamic>> maps = await db.query(illustHisTable,
        columns: [
          cid,
          cillust_id,
          cuser_id,
          cpicture_url,
          ctime,
          cuser_name,
          ctitle
        ],
        orderBy: ctime,limit: limit, offset: offset);

    if (maps.isNotEmpty) {
      for (var f in maps) {
        result.add(IllustHistory.fromJson(f));
      }
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(illustHisTable, where: '$cillust_id = ?', whereArgs: [id]);
  }

  Future<int> update(IllustHistory todo) async {
    return await db.update(illustHisTable, todo.toJson(),
        where: '$cid = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();

  Future deleteAll() async {
    return await db.delete(illustHisTable);
  }
}
