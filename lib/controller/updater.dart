import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';

enum Result { yes, no, timeout }

class Updater {
  static Result result = Result.timeout;
  static String? updateUrl;
  static String? updateDescription;
  static String? updateVersion;
  static String? updateDate;

  static Future<Result> check() async {
    //if (Constants.isGooglePlay) return Result.no;
    final result = await compute(checkUpdate, "");
    Updater.result = result;
    return result;
  }
}

Future<Result> checkUpdate(String arg) async {
  logger("check for update ============");
  try {
    Response response =
        await Dio(BaseOptions(baseUrl: 'https://api.github.com'))
            .get('/repos/asdoll/skana_pix/releases/latest');
    if (response.statusCode != 200) return Result.no;
    String tagName = response.data['tag_name'];
    Updater.updateVersion = tagName;
    logger("tagName:$tagName ");
    if (tagName != Constants.appVersion) {
      List<String> remoteList = tagName.split(".");
      List<String> localList = Constants.appVersion.split(".");
      logger("r:$remoteList l$localList");
      if (remoteList.length != localList.length) return Result.yes;
      for (var i = 0; i < remoteList.length; i++) {
        int r = int.tryParse(remoteList[i]) ?? 0;
        int l = int.tryParse(localList[i]) ?? 0;
        logger("r:$r l$l");
        if (r > l) {
          Updater.updateDate = response.data['published_at'];
          Updater.updateUrl = response.data['assets'][0]['browser_download_url'];
          Updater.updateDescription = response.data['body'];
          return Result.yes;
        }
      }
    }
  } catch (e) {
    print(e);
    return Result.timeout;
  }
  return Result.no;
}
