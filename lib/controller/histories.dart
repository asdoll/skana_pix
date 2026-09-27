import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/history_store.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/model/history_models.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/loading_indicator.dart';

import '../utils/safplugin.dart';

class M {
  static HistoryStore? _o;

  /// True once the local history database has been opened successfully.
  ///
  /// When opening fails (for example on a platform without an objectbox native
  /// library) every method below degrades to a no-op instead of throwing, so a
  /// missing history store can never break the UI.
  static bool get available => _o != null;

  static Future<void> init() async {
    try {
      _o = await HistoryStore.create();
    } catch (e, s) {
      log.e("history database unavailable: $e", error: "$s");
    }
  }

  static Future<void> addIllust(Illust illust) async {
    var illustHis = IllustHistory(
        illustId: illust.id,
        userId: illust.author.id,
        pictureUrl: illust.images.first.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.author.name);
    await _o?.addIllust(illustHis);
  }

  static Future<NovelHistory> addNovel(Novel novel,
      {double lastRead = 0}) async {
    var novelHis = NovelHistory(
        novelId: novel.id,
        userId: novel.author.id,
        title: novel.title,
        userName: novel.author.name,
        time: DateTime.now().millisecondsSinceEpoch,
        pictureUrl: novel.image.squareMedium,
        lastRead: lastRead);
    final o = _o;
    if (o == null) return novelHis;
    return await o.addNovel(novelHis);
  }

  static Future<NovelHistory?> getNovelHistoryByNovelId(int novelId) async {
    return await _o?.getNovelHistoryByNovelId(novelId);
  }

  static Future<List<IllustHistory>> getAllIllusts() async {
    return await _o?.getAllIllust() ?? [];
  }

  static Future<List<NovelHistory>> getAllNovels() async {
    return await _o?.getAllNovel() ?? [];
  }

  static Future<void> removeIllust(int illustId) async {
    await _o?.removeIllust(illustId);
  }

  static Future<void> removeNovel(int novelId) async {
    await _o?.removeNovel(novelId);
  }

  static Future<void> clearIllusts() async {
    _o?.removeAllIllustHistory();
  }

  static Future<void> clearNovels() async {
    _o?.removeAllNovelHistory();
  }

  static Future<void> importIllustData() async {
    if (_o == null) return;
    final result = await SAFPlugin.openFile();
    if (result == null) return;
    final json = utf8.decode(result);
    final decoder = JsonDecoder();
    List<dynamic> maps = decoder.convert(json);
    for (var illust in maps) {
      var illustMap = Map.from(illust);
      var illustHis = IllustHistory(
          illustId: illustMap['illust_id'],
          userId: illustMap['user_id'],
          pictureUrl: illustMap['picture_url'],
          time: illustMap['time'],
          title: illustMap['title'],
          userName: illustMap['user_name']);
      _o?.addIllust(illustHis);
    }
  }

  static Future<void> importNovelData() async {
    if (_o == null) return;
    final result = await SAFPlugin.openFile();
    if (result == null) return;
    final json = utf8.decode(result);
    final decoder = JsonDecoder();
    List<dynamic> maps = decoder.convert(json);
    for (var novel in maps) {
      var novelMap = Map.from(novel);
      var noveHis = NovelHistory(
          novelId: novelMap['novel_id'],
          userId: novelMap['user_id'],
          pictureUrl: novelMap['picture_url'],
          time: novelMap['time'],
          title: novelMap['title'],
          userName: novelMap['user_name'],
          lastRead: novelMap['last_read'] ?? 0);
      _o?.addNovel(noveHis);
    }
  }

  static Future<void> exportIllustData() async {
    if (_o == null) return;
    final uriStr =
        await SAFPlugin.createFile("IllustHis.json", "application/json");
    if (uriStr == null) return;
    final exportData = await _o!.getAllIllust();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }

  static Future<void> exportNovelData() async {
    if (_o == null) return;
    final uriStr =
        await SAFPlugin.createFile("NovelHis.json", "application/json");
    if (uriStr == null) return;
    final exportData = await _o!.getAllNovel();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }
}

class HistoryIllust extends GetxController {
  RxList<IllustHistory> illusts = RxList.empty();
  RxList<IllustHistory> searchResult = RxList.empty();
  Rx<LoadingState> loadingState = LoadingState.idle.obs;

  Future<void> load() async {
    if (loadingState.value == LoadingState.loading) return;
    try {
      loadingState.value = LoadingState.loading;
      illusts.clear();
      illusts.refresh();
      searchResult.clear();
      searchResult.refresh();
      var his = await M.getAllIllusts();
      illusts.addAll(his);
      illusts.refresh();
      searchResult.addAll(his);
      searchResult.refresh();
      loadingState.value = LoadingState.idle;
    } catch (e) {
      loadingState.value = LoadingState.error;
    }
  }

  void clear() async {
    await M.clearIllusts();
    illusts.clear();
    searchResult.clear();
    illusts.refresh();
    searchResult.refresh();
    Leader.showToast("Cleared".tr);
  }

  void remove(int illustId) async {
    await M.removeIllust(illustId);
    illusts.removeWhere((element) => element.illustId == illustId);
    searchResult.removeWhere((element) => element.illustId == illustId);
    illusts.refresh();
    searchResult.refresh();
  }

  void search(String searchText) {
    var tmp = illusts
        .where((obj) =>
            obj.title!.toLowerCase().contains(searchText.toLowerCase()) ||
            obj.userName!.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    searchResult.clear();
    searchResult.addAll(tmp);
    searchResult.refresh();
  }
}

class HistoryNovel extends GetxController {
  RxList<NovelHistory> novels = RxList.empty();
  RxList<NovelHistory> searchResult = RxList.empty();
  Rx<LoadingState> loadingState = LoadingState.idle.obs;

  Future<void> load() async {
    if (loadingState.value == LoadingState.loading) return;
    try {
      loadingState.value = LoadingState.loading;
      novels.clear();
      novels.refresh();
      searchResult.clear();
      searchResult.refresh();
      var his = await M.getAllNovels();
      novels.addAll(his);
      novels.refresh();
      searchResult.addAll(his);
      searchResult.refresh();
      loadingState.value = LoadingState.idle;
    } catch (e) {
      loadingState.value = LoadingState.error;
    }
  }

  void clear() async {
    await M.clearNovels();
    novels.clear();
    searchResult.clear();
    novels.refresh();
    searchResult.refresh();
    Leader.showToast("Cleared".tr);
  }

  void remove(int novelId) async {
    await M.removeNovel(novelId);
    novels.removeWhere((element) => element.novelId == novelId);
    searchResult.removeWhere((element) => element.novelId == novelId);
    novels.refresh();
    searchResult.refresh();
  }

  void search(String searchText) {
    var tmp = novels
        .where((obj) =>
            obj.title.toLowerCase().contains(searchText.toLowerCase()) ||
            obj.userName.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    searchResult.clear();
    searchResult.addAll(tmp);
    searchResult.refresh();
  }
}
