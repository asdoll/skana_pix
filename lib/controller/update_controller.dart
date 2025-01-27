import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/model/boardinfo.dart';
import 'package:skana_pix/view/defaults.dart';

class BoardController extends GetxController {
  RxList<BoardInfo> boardList = RxList.empty();
  RxBool boardDataLoaded = false.obs;
  RxBool needBoardSection = false.obs;

  void fetchBoard({EasyRefreshController? controller}) async {
    try {
      if (boardDataLoaded.value) {
        needBoardSection.value = boardList.isNotEmpty;
        return;
      }
      final list = await load();
      boardDataLoaded.value = true;
      boardList.value = list;
      boardList.refresh();
      needBoardSection.value = boardList.isNotEmpty;
      controller?.finishRefresh();
    } catch (e) {
      log.e(e);
      controller?.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<List<BoardInfo>> load() async {
    log.d(path());
    final request = await dio.Dio().get(
        'https://raw.githubusercontent.com/asdoll/skana_pix/refs/heads/main/.github/board/${path()}');
    final list = (jsonDecode(request.data) as List)
        .map((e) => BoardInfo.fromJson(e))
        .toList();
    return list;
  }

  String path() {
    if (kDebugMode) {
      return "android.json";
    }
    if (DynamicData.isAndroid) {
      if (Constants.isGooglePlay) {
        return "android_play.json";
      }
      return "android.json";
    } else if (DynamicData.isIOS) {
      return "ios.json";
    }
    return "";
  }
}

class UpdateController extends GetxController {
  RxBool hasNewVersion = false.obs;

  Result result = Result.timeout;
  String updateUrl = "https://github.com/asdoll/skana_pix/releases";
  String updateDescription = "";
  String updateVersion = "";
  String updateDate = "";

  Future<void> check() async {
    //if (Constants.isGooglePlay) return Result.no;
    final result = await checkUpdate("");
    switch (result) {
      case Result.yes:
        hasNewVersion.value = true;
        break;
      default:
        hasNewVersion.value = false;
    }
  }

  String getVersion() {
    return Constants.appVersion;
  }

  Future<Result> checkUpdate(String arg) async {
    log.d("check for update ============");
    try {
      dio.Response response =
          await dio.Dio(dio.BaseOptions(baseUrl: 'https://api.github.com'))
              .get('/repos/asdoll/skana_pix/releases/latest');
      if (response.statusCode != 200) return Result.no;
      String tagName = response.data['tag_name'];
      updateVersion = tagName;
      log.d("tagName:$tagName ");
      if (tagName != Constants.appVersion) {
        List<String> remoteList = tagName.split(".");
        List<String> localList = Constants.appVersion.split(".");
        log.d("r:$remoteList l$localList");
        if (remoteList.length != localList.length) return Result.yes;
        for (var i = 0; i < remoteList.length; i++) {
          int r = int.tryParse(remoteList[i]) ?? 0;
          int l = int.tryParse(localList[i]) ?? 0;
          log.d("r:$r l$l");
          if (r > l) {
            updateDate = response.data['published_at'];
            updateUrl = response.data['assets'][0]['browser_download_url'];
            updateDescription = response.data['body'];
            return Result.yes;
          }
        }
      }
    } catch (e) {
      log.e(e);
      return Result.timeout;
    }
    return Result.no;
  }
}

enum Result { yes, no, timeout }

late BoardController boardController;

late UpdateController updateController;