import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/model/history_models.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite backed store for the illustration/novel browsing history.
///
/// Replaces the former objectbox store: objectbox ships no native library for
/// HarmonyOS, while `sqlite3` has an OHOS port (see `dependency_overrides` in
/// pubspec.yaml). The public API mirrors the old store one to one, so callers
/// did not have to change.
class HistoryStore {
  static const String _illustTable = "illust_history";
  static const String _novelTable = "novel_history";

  /// Folder used by the previous objectbox store; kept so the data sits in the
  /// same place for every platform.
  static const String _folder = "skana_pix_history";

  final Database _db;

  HistoryStore._(this._db);

  static Future<HistoryStore> create() async {
    final dir =
        p.join((await getApplicationDocumentsDirectory()).path, _folder);
    Directory(dir).createSync(recursive: true);
    final store = HistoryStore._(sqlite3.open(p.join(dir, "history.db")));
    store._migrate();
    return store;
  }

  void _migrate() {
    _db.execute('''
      create table if not exists $_illustTable (
        illust_id integer primary key not null,
        user_id integer not null,
        picture_url text not null,
        title text,
        user_name text,
        time integer not null
      );
      create index if not exists idx_${_illustTable}_time
        on $_illustTable (time);

      create table if not exists $_novelTable (
        novel_id integer primary key not null,
        user_id integer not null,
        picture_url text not null,
        title text not null,
        user_name text not null,
        time integer not null,
        last_read real not null default 0
      );
      create index if not exists idx_${_novelTable}_time
        on $_novelTable (time);
    ''');
  }

  /// Inserts the entry, or refreshes it when that illust was already visited.
  Future<IllustHistory> addIllust(IllustHistory item) async {
    _db.execute('''
      insert into $_illustTable
        (illust_id, user_id, picture_url, title, user_name, time)
      values (?, ?, ?, ?, ?, ?)
      on conflict(illust_id) do update set
        user_id = excluded.user_id,
        picture_url = excluded.picture_url,
        title = excluded.title,
        user_name = excluded.user_name,
        time = excluded.time
    ''', [
      item.illustId,
      item.userId,
      item.pictureUrl,
      item.title,
      item.userName,
      item.time,
    ]);
    return item;
  }

  /// Inserts the entry, or refreshes it (including the read position) when that
  /// novel was already visited.
  Future<NovelHistory> addNovel(NovelHistory item) async {
    _db.execute('''
      insert into $_novelTable
        (novel_id, user_id, picture_url, title, user_name, time, last_read)
      values (?, ?, ?, ?, ?, ?, ?)
      on conflict(novel_id) do update set
        user_id = excluded.user_id,
        picture_url = excluded.picture_url,
        title = excluded.title,
        user_name = excluded.user_name,
        time = excluded.time,
        last_read = excluded.last_read
    ''', [
      item.novelId,
      item.userId,
      item.pictureUrl,
      item.title,
      item.userName,
      item.time,
      item.lastRead,
    ]);
    return item;
  }

  Future<NovelHistory?> getNovelHistoryByNovelId(int novelId) async {
    final rows =
        _db.select('select * from $_novelTable where novel_id = ?', [novelId]);
    if (rows.isEmpty) return null;
    return _novelFromRow(rows.first);
  }

  Future<List<IllustHistory>> getAllIllust() async {
    return _db
        .select('select * from $_illustTable order by time desc')
        .map(_illustFromRow)
        .toList();
  }

  Future<List<NovelHistory>> getAllNovel() async {
    return _db
        .select('select * from $_novelTable order by time desc')
        .map(_novelFromRow)
        .toList();
  }

  Future<List<IllustHistory>> getIllustHistory(int offset, int limit) async {
    return _db
        .select(
            'select * from $_illustTable order by time desc limit ? offset ?',
            [limit, offset])
        .map(_illustFromRow)
        .toList();
  }

  Future<List<NovelHistory>> getNovelHistory(int offset, int limit) async {
    return _db
        .select(
            'select * from $_novelTable order by time desc limit ? offset ?',
            [limit, offset])
        .map(_novelFromRow)
        .toList();
  }

  /// [id] is the pixiv illust id, as before.
  Future<void> removeIllust(int id) async {
    _db.execute('delete from $_illustTable where illust_id = ?', [id]);
  }

  Future<void> removeIllustByIllustId(int illustId) => removeIllust(illustId);

  /// [id] is the pixiv novel id, as before.
  Future<void> removeNovel(int id) async {
    _db.execute('delete from $_novelTable where novel_id = ?', [id]);
  }

  Future<void> removeNovelByNovelId(int novelId) => removeNovel(novelId);

  /// Returns how many entries were deleted.
  int removeAllIllustHistory() {
    _db.execute('delete from $_illustTable');
    return _db.updatedRows;
  }

  /// Returns how many entries were deleted.
  int removeAllNovelHistory() {
    _db.execute('delete from $_novelTable');
    return _db.updatedRows;
  }

  void close() => _db.dispose();

  static IllustHistory _illustFromRow(Row row) => IllustHistory(
        illustId: row['illust_id'] as int,
        userId: row['user_id'] as int,
        pictureUrl: row['picture_url'] as String,
        time: row['time'] as int,
        title: row['title'] as String?,
        userName: row['user_name'] as String?,
      );

  static NovelHistory _novelFromRow(Row row) => NovelHistory(
        novelId: row['novel_id'] as int,
        userId: row['user_id'] as int,
        pictureUrl: row['picture_url'] as String,
        time: row['time'] as int,
        title: row['title'] as String,
        userName: row['user_name'] as String,
        lastRead: (row['last_read'] as num).toDouble(),
      );
}
