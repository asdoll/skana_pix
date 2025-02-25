import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/objectbox.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/model/objectbox_models.dart';
import 'package:skana_pix/utils/leaders.dart';

import '../utils/safplugin.dart';

class M {

  static late ObjectBox o;
  static Future<void> init() async {
    o = await ObjectBox.create();
  }

  static Future<void> addIllust(Illust illust) async {
    var illustHis = IllustHistory(
        illustId: illust.id,
        userId: illust.author.id,
        pictureUrl: illust.images.first.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.author.name);
    await o.addIllust(illustHis);
  }

  static Future<void> addNovel(Novel novel,{int lastRead = 0}) async {
    var novelHis = NovelHistory(
        novelId: novel.id,
        userId: novel.author.id,
        title: novel.title,
        userName: novel.author.name,
        time: DateTime.now().millisecondsSinceEpoch,
        pictureUrl: novel.image.squareMedium,
        lastRead: lastRead);
    await o.addNovel(novelHis);
  }

  static Future<List<IllustHistory>> getAllIllusts() async {
    return await o.getAllIllust();
  }

  static Future<List<NovelHistory>> getAllNovels() async {
    return await o.getAllNovel();
  }


  static Future<void> removeIllust(int illustId) async {
    await o.removeIllust(illustId);
  }

  static Future<void> removeNovel(int novelId) async {
    await o.removeNovel(novelId);
  }

  static Future<void> clearIllusts() async {
    o.removeAllIllustHistory();
  }

  static Future<void> clearNovels() async {
    o.removeAllNovelHistory();
  }

  static Future<void> importIllustData() async {
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
      o.addIllust(illustHis);
    }
  }

  static Future<void> importNovelData() async {
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
          lastRead: novelMap['last_read']??0);
      o.addNovel(noveHis);
    }
  }

  static Future<void> exportIllustData() async {
    final uriStr =
        await SAFPlugin.createFile("IllustHis.json", "application/json");
    if (uriStr == null) return;
    final exportData = await o.getAllIllust();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }

  static Future<void> exportNovelData() async {
    final uriStr =
        await SAFPlugin.createFile("NovelHis.json", "application/json");
    if (uriStr == null) return;
    final exportData = await o.getAllNovel();
    await SAFPlugin.writeUri(
        uriStr, Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }
}

class HistoryIllust extends GetxController {
  RxList<IllustHistory> illusts = RxList.empty();
  RxList<IllustHistory> searchResult = RxList.empty();
  RxBool isLoading = false.obs;
  EasyRefreshController? refreshController;

  void load() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      var his = await M.getAllIllusts();
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
      var his = await M.getAllNovels();
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
    searchResult.addAll(tmp.reversed);
    searchResult.refresh();
  }
}
