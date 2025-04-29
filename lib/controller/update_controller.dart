import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart' show settings;
import 'package:skana_pix/model/boardinfo.dart';
import 'package:skana_pix/utils/leaders.dart' show Leader;
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Constants {
  static const String appName = 'SkanaPix';
  static const String appVersion = '1.0.8';
  static const isGooglePlay =
      bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
}

class BoardController extends GetxController {
  RxList<BoardInfo> boardList = RxList.empty();
  RxBool boardDataLoaded = false.obs;
  RxBool needBoardSection = false.obs;

  void fetchBoard({EasyRefreshController? controller}) async {
    try {
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
    if (GetPlatform.isAndroid) {
      if (Constants.isGooglePlay) {
        return "android_play.json";
      }
      return "android.json";
    } else if (GetPlatform.isIOS) {
      return "ios.json";
    }
    return "";
  }
}

class UpdateController extends GetxController {
  RxBool hasNewVersion = false.obs;

  Result result = Result.timeout;
  String updateUrl = "https://github.com/asdoll/skana_pix/releases/latest";
  String updateDescription = "";
  String updateVersion = "";
  String updateDate = "";

  void init() {
    if (settings.settings[9]=="1") {
      check().then((value) {
        if (result == Result.yes) {
          alertDialog(
              Get.context!,
              "New version available".tr,
              "${"Description: ".tr} $updateDescription\n${"Version: ".tr} $updateVersion\n${"Date: ".tr} $updateDate",
              [
                outlinedButton(onPressed: () => Get.back(), label: "Cancel".tr),
                filledButton(
                    onPressed: () {
                      launchUrlString(updateUrl);
                      Get.back();
                    },
                    label: "Update".tr)
              ]);
        }
      });
    }
  }

  Future<void> check({bool showResult = false}) async {
    //if (Constants.isGooglePlay) return Result.no;
    result = await checkUpdate("");
    if (showResult) {
      if (result == Result.yes) {
        Leader.showToast('Update available'.tr);
      } else if (result == Result.no) {
        Leader.showToast('No update available'.tr);
      } else {
        Leader.showToast('Update check failed'.tr);
      }
    }
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
