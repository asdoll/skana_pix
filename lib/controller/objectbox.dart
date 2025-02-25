


import 'package:objectbox/objectbox.dart';
import 'package:skana_pix/model/objectbox_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:skana_pix/objectbox.g.dart';

class ObjectBox {
  late final Store _store;

  late final Box<IllustHistory> illustBox;
  late final Box<NovelHistory> novelBox;

  ObjectBox._create(this._store) {
    illustBox = Box<IllustHistory>(_store);
    novelBox = Box<NovelHistory>(_store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory: p.join((await getApplicationDocumentsDirectory()).path,
            "skana_pix_history"),
        macosApplicationGroup: "skana.pix.history");
    return ObjectBox._create(store);
  }

  Future<IllustHistory> addIllust(IllustHistory item) async {
    final history = illustBox
        .query(IllustHistory_.illustId.equals(item.illustId))
        .build()
        .findFirst();
    if (history == null) {
      illustBox.put(item);
      return item;
    } else {
      illustBox.put(item..id = history.id);
      return history;
    }
  }

  Future<NovelHistory> addNovel(NovelHistory item) async {
    final history = novelBox
        .query(NovelHistory_.novelId.equals(item.novelId))
        .build()
        .findFirst();
    if (history == null) {
      novelBox.put(item);
      return item;
    } else {
      novelBox.put(item..id = history.id);
      return history;
    }
  }

  Future<List<IllustHistory>> getAllIllust() async {
    return illustBox
            .query()
            .order(IllustHistory_.time, flags: Order.descending)
            .build()
        .find();
  }

  Future<List<NovelHistory>> getAllNovel() async {
    return novelBox
            .query()
            .order(NovelHistory_.time, flags: Order.descending)
            .build()
        .find();
  }

  Future<List<IllustHistory>> getIllustHistory(
      int offset, int limit) async {
    return (illustBox
            .query()
            .order(IllustHistory_.time, flags: Order.descending)
            .build()
          ..offset = offset
          ..limit = limit)
        .find();
  }

  Future<List<NovelHistory>> getNovelHistory(
      int offset, int limit) async {
    return (novelBox
            .query()
            .order(NovelHistory_.time, flags: Order.descending)
            .build()
          ..offset = offset
          ..limit = limit)
        .find();
  }

  Future<void> removeIllust(int id) => illustBox.removeAsync(id);

  Future<void> removeIllustByIllustId(int illustId) {
    final history = illustBox
        .query(IllustHistory_.illustId.equals(illustId))
        .build()
        .find();
    if (history.isNotEmpty) {
      return illustBox.removeManyAsync(history.map((e) => e.id).toList());
    }
    return Future.value();
  }

  Future<void> removeNovel(int id) => novelBox.removeAsync(id);

  Future<void> removeNovelByNovelId(int novelId) {
    final history = novelBox
        .query(NovelHistory_.novelId.equals(novelId))
        .build()
        .find();
    if (history.isNotEmpty) {
      return novelBox.removeManyAsync(history.map((e) => e.id).toList());
    }
    return Future.value();
  }

  int removeAllIllustHistory() => illustBox.removeAll();
  int removeAllNovelHistory() => novelBox.removeAll();
  
}