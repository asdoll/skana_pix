import 'package:skana_pix/model/novel.dart' show Novel;

/// Browsing history of an illustration.
///
/// Plain data class: it used to be an objectbox entity, but the store is now
/// SQLite (see `HistoryStore`), because objectbox ships no native library for
/// HarmonyOS.
class IllustHistory {
  int illustId;
  int userId;
  String pictureUrl;
  String? userName;
  String? title;
  int time;

  IllustHistory({
    required this.illustId,
    required this.userId,
    required this.pictureUrl,
    required this.time,
    required this.title,
    required this.userName,
  });

  factory IllustHistory.fromMap(Map<String, dynamic> map) => IllustHistory(
        illustId: map['illust_id'] as int,
        userId: map['user_id'] as int,
        pictureUrl: map['picture_url'] as String,
        time: map['time'] as int,
        title: map['title'] as String?,
        userName: map['user_name'] as String?,
      );

  /// Snake case keys on purpose: they match what `M.importIllustData` reads, so
  /// an exported file can be imported again.
  Map<String, dynamic> toJson() => {
        'illust_id': illustId,
        'user_id': userId,
        'picture_url': pictureUrl,
        'time': time,
        'title': title,
        'user_name': userName,
      };
}

/// Browsing history of a novel, including the read position.
class NovelHistory {
  int novelId;
  int userId;
  String pictureUrl;
  int time;
  String title;
  String userName;
  double lastRead;

  NovelHistory({
    required this.novelId,
    required this.userId,
    required this.pictureUrl,
    required this.time,
    required this.title,
    required this.userName,
    this.lastRead = 0,
  });

  factory NovelHistory.fromMap(Map<String, dynamic> map) => NovelHistory(
        novelId: map['novel_id'] as int,
        userId: map['user_id'] as int,
        pictureUrl: map['picture_url'] as String,
        time: map['time'] as int,
        title: map['title'] as String,
        userName: map['user_name'] as String,
        lastRead: (map['last_read'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'novel_id': novelId,
        'user_id': userId,
        'picture_url': pictureUrl,
        'time': time,
        'title': title,
        'user_name': userName,
        'last_read': lastRead,
      };

  factory NovelHistory.convert(Novel novel) {
    return NovelHistory(
        novelId: novel.id,
        userId: novel.author.id,
        pictureUrl: novel.image.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: novel.title,
        userName: novel.author.name,
        lastRead: 0);
  }
}
