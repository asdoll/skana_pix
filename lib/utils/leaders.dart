import 'package:dio/dio.dart' as d;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:skana_pix/view/novelview/novelpage.dart';
import 'package:skana_pix/view/novelview/novelseries.dart';
import 'package:skana_pix/view/imageview/imagesearchresult.dart';
import 'package:skana_pix/view/souppage.dart';
import 'package:skana_pix/view/userview/userpage.dart';
class Leader {
  static showToast(String text,[Duration? duration]) {
    try {
      MoonToast.show(
        toastAlignment: Alignment(0.0, 0.8),
        backgroundColor: MoonColors.dark.gohan,
        Get.context!,
        label: Text(text, style: TextStyle(color: MoonColors.light.goku)),
        displayDuration: duration,
      );
    } catch (e) {
      log.e(e);
    }
  }

  static Future<bool> pushWithUri(BuildContext context, Uri link) async {
    // https://www.pixiv.net/novel/series/$id
    if (link.path.contains("novel") && link.path.contains("series")) {
      final id = int.tryParse(link.pathSegments.last);
      if (id != null) {
        Get.to(() => NovelSeriesPage(id), preventDuplicates: false);
        return true;
      }
    }
    if (link.host == "i.pximg.net") {
      final id = link.pathSegments.last.split(".").first.split("_").first;
      Get.to(() => IllustPageLite(id), preventDuplicates: false);
      return true;
    }
    if (link.host == "pixiv.me") {
      try {
        showToast("Pixiv me...");
        var dio = d.Dio();
        d.Response response = await dio.getUri(link);
        if (response.isRedirect == true) {
          Uri source = response.realUri;
          log.d("here we go pixiv me:$source");
          return await pushWithUri(context, source);
        }
      } catch (e) {
        try {
          launchUrlString(link.toString());
        } catch (e) {
          Leader.showToast(e.toString());
        }
      }
      return true;
    }
    if (link.host.contains("pixivision.net")) {
      Get.to(
          () => SoupPage(
                url: link.toString().replaceAll("pixez://", "https://"),
                spotlight: null,
              ),
          preventDuplicates: false);
      return true;
    }
    if (link.scheme == "pixiv") {
      // if (link.host.contains("account")) {
      //   try {
      //     BotToast.showText(text: "working....");
      //     String code = link.queryParameters['code']!;
      //     logger("here we go:" + code);
      //     Response response = await oAuthClient.code2Token(code);
      //     AccountResponse accountResponse =
      //         Account.fromJson(response.data).response;
      //     final user = accountResponse.user;
      //     AccountProvider accountProvider = new AccountProvider();
      //     await accountProvider.open();
      //     var accountPersist = AccountPersist(
      //         userId: user.id,
      //         userImage: user.profileImageUrls.px170x170,
      //         accessToken: accountResponse.accessToken,
      //         refreshToken: accountResponse.refreshToken,
      //         deviceToken: "",
      //         passWord: "no more",
      //         name: user.name,
      //         account: user.account,
      //         mailAddress: user.mailAddress,
      //         isPremium: user.isPremium ? 1 : 0,
      //         xRestrict: user.xRestrict,
      //         isMailAuthorized: user.isMailAuthorized ? 1 : 0);
      //     await accountProvider.insert(accountPersist);
      //     await accountStore.fetch();
      //     BotToast.showText(text: "Login Success");
      //     if (Platform.isIOS) pushUntilHome(context);
      //   } catch (e) {
      //     LPrinter.d(e);
      //     BotToast.showText(text: e.toString());
      //   }
      // } else
      if (link.host.contains("illusts") ||
          link.host.contains("user") ||
          link.host.contains("novel")) {
        return _parseUriContent(context, link);
      }
    } else if (link.scheme.contains("http")) {
      return _parseUriContent(context, link);
    } else if (link.scheme == "pixez") {
      return _parseUriContent(context, link);
    }
    return false;
  }

  static bool _parseUriContent(BuildContext context, Uri link) {
    if (link.host.contains('illusts')) {
      var idSource = link.pathSegments.last;
      try {
        Get.to(() => IllustPageLite(idSource), preventDuplicates: false);
      } catch (e) {
        Leader.showToast(e.toString());
      }
      return true;
    } else if (link.host.contains('user')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Get.to(
            () => UserPage(
                  id: id,
                  type: ArtworkType.ALL,
                ),
            preventDuplicates: false);
      } catch (e) {
        Leader.showToast(e.toString());
      }
      return true;
    } else if (link.host.contains("novel")) {
      try {
        Get.to(() => NovelPageLite(link.pathSegments.last),
            preventDuplicates: false);
        return true;
      } catch (e) {
        Leader.showToast(e.toString());
      }
    } else if (link.host.contains('pixiv')) {
      if (link.path.contains("artworks")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("artworks");
        if (index != -1) {
          try {
            Get.to(() => IllustPageLite(paths[index + 1]),
                preventDuplicates: false);
            return true;
          } catch (e) {
            Leader.showToast(e.toString());
          }
        }
      }
      if (link.path.contains("users")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("users");
        if (index != -1) {
          try {
            Get.to(
                () => UserPage(
                      id: int.parse(paths[index + 1]),
                      type: ArtworkType.ALL,
                    ),
                preventDuplicates: false);
            return true;
          } catch (e) {
            Leader.showToast(e.toString());
          }
        }
      }
      if (link.queryParameters['illust_id'] != null) {
        try {
          var id = link.queryParameters['illust_id'];
          Get.to(() => IllustPageLite(id.toString()), preventDuplicates: false);
          return true;
        } catch (e) {
          Leader.showToast(e.toString());
        }
      }
      if (link.queryParameters['id'] != null) {
        try {
          var id = link.queryParameters['id'];
          if (!link.path.contains("novel")) {
            Get.to(
                () => UserPage(
                      id: int.parse(id!),
                      type: ArtworkType.ALL,
                    ),
                preventDuplicates: false);
          } else {
            Get.to(() => NovelPageLite(id!), preventDuplicates: false);
          }
          return true;
        } catch (e) {
          Leader.showToast(e.toString());
        }
      }
      if (link.pathSegments.length >= 2) {
        String i = link.pathSegments[link.pathSegments.length - 2];
        if (i == "i") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Get.to(() => IllustPageLite(id.toString()),
                preventDuplicates: false);
            return true;
          } catch (e) {}
        } else if (i == "u") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Get.to(
                () => UserPage(
                      id: id,
                      type: ArtworkType.ALL,
                    ),
                preventDuplicates: false);
            return true;
          } catch (e) {}
        } else if (i == "tags") {
          try {
            String tag = link.pathSegments[link.pathSegments.length - 1];
            Get.to(
                () => IllustResultPage(
                      word: tag,
                    ),
                preventDuplicates: false);
            return true;
          } catch (e) {
            Leader.showToast(e.toString());
          }
        }
      }
    }
    return false;
  }
}
