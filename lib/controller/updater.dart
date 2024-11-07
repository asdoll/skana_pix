import 'package:dio/dio.dart';
import 'package:skana_pix/view/defaults.dart';

enum Result { yes, no, timeout }

class Updater {
  static Result result = Result.timeout;
  String updateUrl = "https://github.com/asdoll/skana_pix/releases";
  String updateDescription = "";
  String updateVersion = "";
  String updateDate = "";

  static Future<Result> check() async {
    //if (Constants.isGooglePlay) return Result.no;
    final result = await checkUpdate("");
    Updater.result = result;
    return result;
  }
}

Updater updater = Updater();

Future<Result> checkUpdate(String arg) async {
  print("check for update ============");
  try {
    Response response =
        await Dio(BaseOptions(baseUrl: 'https://api.github.com'))
            .get('/repos/asdoll/skana_pix/releases/latest');
    if (response.statusCode != 200) return Result.no;
    String tagName = response.data['tag_name'];
    updater.updateVersion = tagName;
    print("tagName:$tagName ");
    if (tagName != Constants.appVersion) {
      List<String> remoteList = tagName.split(".");
      List<String> localList = Constants.appVersion.split(".");
      print("r:$remoteList l$localList");
      if (remoteList.length != localList.length) return Result.yes;
      for (var i = 0; i < remoteList.length; i++) {
        int r = int.tryParse(remoteList[i]) ?? 0;
        int l = int.tryParse(localList[i]) ?? 0;
        print("r:$r l$l");
        if (r > l) {
          updater.updateDate = response.data['published_at'];
          updater.updateUrl = response.data['assets'][0]['browser_download_url'];
          updater.updateDescription = response.data['body'];
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
