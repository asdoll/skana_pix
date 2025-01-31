import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

import '../utils/safplugin.dart';

class HistoryManager {
  final illustHistoryProvider = IllustHistoryProvider();
  final novelHistoryProvider = NovelHistoryProvider();

  Future<void> addIllust(Illust illust) async {
    await illustHistoryProvider.open();
    var illustHis = IllustHistory(
        illustId: illust.id,
        userId: illust.author.id,
        pictureUrl: illust.images.first.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.author.name);
    await illustHistoryProvider.insert(illustHis);
  }

  Future<void> addNovel(Novel novel) async {
    await novelHistoryProvider.open();
    var novelHis = NovelHistory(
        novelId: novel.id,
        userId: novel.author.id,
        title: novel.title,
        userName: novel.author.name,
        time: DateTime.now().millisecondsSinceEpoch,
        pictureUrl: novel.coverImageUrl);
    await novelHistoryProvider.insert(novelHis);
  }

  Future<List<IllustHistory>> getIllusts() async {
    await illustHistoryProvider.open();
    return await illustHistoryProvider.getAllIllusts();
  }

  Future<List<IllustHistory>> searchIllusts(String query) async {
    await illustHistoryProvider.open();
    return await illustHistoryProvider.getLikeIllusts(query);
  }

  Future<List<NovelHistory>> getNovels() async {
    await novelHistoryProvider.open();
    return await novelHistoryProvider.getAllNovels();
  }

  Future<List<NovelHistory>> searchNovels(String query) async {
    await novelHistoryProvider.open();
    return await novelHistoryProvider.getLikeNovels(query);
  }

  Future<void> removeIllust(int illustId) async {
    await illustHistoryProvider.open();
    await illustHistoryProvider.delete(illustId);
  }

  Future<void> removeNovel(int novelId) async {
    await novelHistoryProvider.open();
    await novelHistoryProvider.delete(novelId);
  }

  Future<void> clearIllusts() async {
    await illustHistoryProvider.open();
    await illustHistoryProvider.deleteAll();
  }

  Future<void> clearNovels() async {
    await novelHistoryProvider.open();
    await novelHistoryProvider.deleteAll();
  }

  Future<void> close() async {
    await illustHistoryProvider.close();
    await novelHistoryProvider.close();
  }

  Future<void> importIllustData() async {
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
      illustHistoryProvider.insert(illustHis);
    }
  }

  Future<void> importNovelData() async {
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
          userName: novelMap['user_name']);
      novelHistoryProvider.insert(noveHis);
    }
  }

  Future<void> exportIllustData() async {
    final uriStr =
        await SAFPlugin.createFile("IllustHis.json", "application/json");
    if (uriStr == null) return;
    await illustHistoryProvider.open();
    final exportData = await illustHistoryProvider.getAllIllusts();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }

  Future<void> exportNovelData() async {
    final uriStr =
        await SAFPlugin.createFile("NovelHis.json", "application/json");
    if (uriStr == null) return;
    await novelHistoryProvider.open();
    final exportData = await novelHistoryProvider.getAllNovels();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }
}

final historyManager = HistoryManager();

class HistoryIllust extends GetxController {
  RxList<IllustHistory> illusts = RxList.empty();
  RxList<IllustHistory> searchResult = RxList.empty();
  RxBool isLoading = false.obs;
  EasyRefreshController? refreshController;

  void load() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      var his = await historyManager.getIllusts();
      illusts.clear();
      illusts.addAll(his);
      illusts.refresh();
      searchResult.clear();
      searchResult.addAll(his.reversed);
      searchResult.refresh();
      isLoading.value = false;
      refreshController?.finishRefresh();
    } catch (e) {
      isLoading.value = false;
      refreshController?.finishRefresh(IndicatorResult.fail);
    }
  }

  void clear() async {
    await historyManager.clearIllusts();
    illusts.clear();
    searchResult.clear();
    illusts.refresh();
    searchResult.refresh();
  }

  void remove(int illustId) async {
    await historyManager.removeIllust(illustId);
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
    searchResult.addAll(tmp.reversed);
    searchResult.refresh();
  }
}

class HistoryNovel extends GetxController {
  RxList<NovelHistory> novels = RxList.empty();
  RxList<NovelHistory> searchResult = RxList.empty();
  RxBool isLoading = false.obs;
  EasyRefreshController? refreshController;

  void load() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      var his = await historyManager.getNovels();
      novels.clear();
      novels.addAll(his);
      novels.refresh();
      searchResult.clear();
      searchResult.addAll(his.reversed);
      searchResult.refresh();
      isLoading.value = false;
      refreshController?.finishRefresh();
    } catch (e) {
      isLoading.value = false;
      refreshController?.finishRefresh(IndicatorResult.fail);
    }
  }

  void clear() async {
    await historyManager.clearNovels();
    novels.clear();
    searchResult.clear();
    novels.refresh();
    searchResult.refresh();
  }

  void remove(int novelId) async {
    await historyManager.removeNovel(novelId);
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
    searchResult.addAll(tmp.reversed);
    searchResult.refresh();
  }
}
