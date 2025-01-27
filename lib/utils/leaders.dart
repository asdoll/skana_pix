import 'package:dio/dio.dart' as d;
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/imagelist.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../componentwidgets/novelpage.dart';
import '../componentwidgets/novelseries.dart';
import '../componentwidgets/searchresult.dart';
import '../view/souppage.dart';
import '../componentwidgets/userpage.dart';

class Leader {
  static showBasicToast(Widget? title, Widget? subtitle, Widget? trailing) {
    showToast(
        context: Get.context!,
        builder: (BuildContext context, ToastOverlay overlay) {
          return SurfaceCard(
            child: Basic(
              title: title,
              subtitle: subtitle,
              trailing: trailing,
              trailingAlignment: Alignment.center,
            ),
          );
        });
  }

  static showTextToast(String text) {
    showToast(
        context: Get.context!,
        builder: (BuildContext context, ToastOverlay overlay) {
          return SurfaceCard(
            child: Text(text),
          );
        });
  }

  static Future<bool> pushWithUri(BuildContext context, Uri link) async {
    // https://www.pixiv.net/novel/series/$id
    if (link.path.contains("novel") && link.path.contains("series")) {
      final id = int.tryParse(link.pathSegments.last);
      if (id != null) {
        Leader.push(context, NovelSeriesPage(id), root: true);
        return true;
      }
    }
    // if (link.host == "script" && link.scheme == "pixez") {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //     return SaveEvalPage(
    //       eval: link.queryParameters["code"] != null
    //           ? String.fromCharCodes(
    //               base64Decode(link.queryParameters["code"]!))
    //           : null,
    //     );
    //   }));
    //   return true;
    // }
    if (link.host == "i.pximg.net") {
      final id = link.pathSegments.last.split(".").first.split("_").first;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return IllustPageLite(id);
      }));
      return true;
    }
    if (link.host == "pixiv.me") {
      try {
        showBasicToast(Text("Pixiv me..."), null, null);
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
        } catch (e) {}
      }
      return true;
    }
    if (link.host.contains("pixivision.net")) {
      Leader.push(
          context,
          SoupPage(
              url: link.toString().replaceAll("pixez://", "https://"),
              spotlight: null),
          root: true);
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
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return IllustPageLite(id.toString());
        }));
      } catch (e) {}
      return true;
    } else if (link.host.contains('user')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return UserPage(
            id: id,
            type: ArtworkType.ALL,
          );
        }));
      } catch (e) {}
      return true;
    } else if (link.host.contains("novel")) {
      try {
        int id = int.parse(link.pathSegments.last);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return NovelPageLite(id.toString());
        }));
        return true;
      } catch (e) {
        log.e(e.toString());
      }
    } else if (link.host.contains('pixiv')) {
      if (link.path.contains("artworks")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("artworks");
        if (index != -1) {
          try {
            int id = int.parse(paths[index + 1]);
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return IllustPageLite(id.toString());
            }));
            return true;
          } catch (e) {
            log.e(e.toString());
          }
        }
      }
      if (link.path.contains("users")) {
        List<String> paths = link.pathSegments;
        int index = paths.indexOf("users");
        if (index != -1) {
          try {
            int id = int.parse(paths[index + 1]);
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => UserPage(
                      id: id,
                      type: ArtworkType.ALL,
                    )));
            return true;
          } catch (e) {
            log.e(e);
          }
        }
      }
      if (link.queryParameters['illust_id'] != null) {
        try {
          var id = link.queryParameters['illust_id'];
          Leader.push(context, IllustPageLite(id.toString()), root: true);
          return true;
        } catch (e) {}
      }
      if (link.queryParameters['id'] != null) {
        try {
          var id = link.queryParameters['id'];
          if (!link.path.contains("novel")) {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return UserPage(
                id: int.parse(id!),
                type: ArtworkType.ALL,
              );
            }));
          } else {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return NovelPageLite(id!);
            }));
          }
          return true;
        } catch (e) {}
      }
      if (link.pathSegments.length >= 2) {
        String i = link.pathSegments[link.pathSegments.length - 2];
        if (i == "i") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Leader.push(context, IllustPageLite(id.toString()), root: true);
            return true;
          } catch (e) {}
        } else if (i == "u") {
          try {
            int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return UserPage(
                id: id,
                type: ArtworkType.ALL,
              );
            }));
            return true;
          } catch (e) {}
        } else if (i == "tags") {
          try {
            String tag = link.pathSegments[link.pathSegments.length - 1];
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return ResultPage(
                word: tag,
              );
            }));
            return true;
          } catch (e) {}
        }
      }
    }
    return false;
  }

  static Future<dynamic> pushWithScaffold(context, Widget widget,
      {Widget? icon, Widget? title, bool root = false}) {
    if (root) {
      return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          child: widget,
        ),
      ));
    }
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              child: widget,
            )));
  }

  static Future<dynamic> push(
    context,
    Widget widget, {
    Widget? icon,
    Widget? title,
    bool forceSkipWrap = false,
    bool root = false,
  }) {
    if (root) {
      return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          child: widget,
        ),
      ));
    }
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              child: widget,
            )));
  }
}
