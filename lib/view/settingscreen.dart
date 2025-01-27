import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/view/blocklistpage.dart';
import 'package:skana_pix/componentwidgets/followlist.dart';
import 'package:skana_pix/componentwidgets/newversion.dart';
import 'package:skana_pix/componentwidgets/prefsettings.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'about.dart';
import '../componentwidgets/avatar.dart';
import 'boardpage.dart';
import 'mytagspage.dart';
import '../componentwidgets/dataexport.dart';
import '../componentwidgets/historypage.dart';
import '../componentwidgets/mybookmarks.dart';
import '../componentwidgets/themepage.dart';
import '../utils/leaders.dart';
import 'loginpage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    boardController.fetchBoard();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBar(
                  elevation: 0.0,
                  automaticallyImplyLeading: false,
                  forceMaterialTransparency: true,
                  backgroundColor: Colors.transparent,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.palette,
                      ),
                      onPressed: () {
                        Leader.push(context, ThemePage(), root: true);
                      },
                    ),
                  ],
                ),
                Obx(() {
                  if (!accountController.isLoggedIn.value) {
                        return SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.of(context, rootNavigator: true)
                                    //     .push(MaterialPageRoute(builder: (_) {
                                    //   return AccountSelectPage();
                                    // }));
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PainterAvatar(
                                        url: ConnectManager()
                                            .apiClient
                                            .account
                                            .user
                                            .profileImg,
                                        id: int.parse(
                                          ConnectManager().apiClient.userid,
                                        ),
                                        isMe: true,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                  ConnectManager()
                                                      .apiClient
                                                      .account
                                                      .user
                                                      .name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                            ),
                                            Text(
                                              ConnectManager()
                                                  .apiClient
                                                  .account
                                                  .user
                                                  .email,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.favorite_rounded),
                                title: Text("My Bookmarks".tr),
                                onTap: () => Leader.pushWithScaffold(
                                    context,
                                    MyBookmarksPage(
                                      portal: 'mybookmark',
                                      type: settings.awPrefer == "novel"
                                          ? ArtworkType.NOVEL
                                          : ArtworkType.ILLUST,
                                    ),
                                    root: true),
                              ),
                              ListTile(
                                leading: Icon(Icons.bookmark),
                                title: Text("Favorite Tags".tr),
                                onTap: () => Leader.pushWithScaffold(
                                    context, MyTagsPage(),
                                    root: true),
                              ),
                              ListTile(
                                leading: Icon(Icons.star_rate_rounded),
                                title: Text("Following".tr),
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              FollowList(
                                                id: int.parse(ConnectManager()
                                                    .apiClient
                                                    .userid),
                                                setAppBar: true,
                                                isMe: true,
                                              )));
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.people_rounded),
                                title: Text("My Pixiv".tr),
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              FollowList(
                                                id: int.parse(ConnectManager()
                                                    .apiClient
                                                    .userid),
                                                setAppBar: true,
                                                isMe: true,
                                                isMyPixiv: true,
                                              )));
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      return Container();
                    }),
                Divider(),
                Column(
                  children: <Widget>[
                    // ListTile(
                    //   leading: Icon(Icons.save_alt),
                    //   title: Text("Download Manager".i18n),
                    //   onTap: () => Leader.push(context, DownloadsPage()),
                    // ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text("History".tr),
                      onTap: () =>
                          Leader.push(context, HistoryPage(), root: true),
                    ),
                    ListTile(
                      leading: Icon(Icons.block),
                      title: Text("Block List".tr),
                      onTap: () =>
                          Leader.push(context, BlockListPage(), root: true),
                    ),
                    Obx(() {
                      if (!accountController.isLoggedIn.value) {
                        return Container();
                      }
                      return ListTile(
                        leading: Icon(Icons.account_box),
                        title: Text("Account Settings".tr),
                        onTap: () {
                          launchUrlString(
                              "https://www.pixiv.net/setting_user.php");
                        },
                      );
                    }),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Preference Settings".tr),
                      onTap: () => Leader.push(context, PreferenceSettings(),
                          root: true),
                    ),
                    ListTile(
                      onTap: () =>
                          Leader.push(context, DataExport(), root: true),
                      title: Text("App Data".tr),
                      leading: Icon(Icons.folder_open_rounded),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text("About".tr),
                      onTap: () => Leader.push(
                          context, AboutPage(),
                          root: true),
                    ),
                    Obx(() => boardController.needBoardSection.value
                        ? ListTile(
                            leading: Icon(Icons.article),
                            title: Text("Bulletin Board".tr),
                            onTap: () => Get.to(() => BoardPage()),
                          )
                        : Container()),
                    ListTile(
                      leading: Icon(Icons.update),
                      title: Text("Check updates".tr),
                      onTap: () => Leader.push(
                          context,
                          NewVersionPage(),
                          root: true),
                      trailing: Visibility(
                        visible: updateController.hasNewVersion.value,
                        child: NewVersionChip(),
                      ),
                    ),
                    Obx(
                      () {
                        if (accountController.isLoggedIn.value) {
                          return ListTile(
                            leading: Icon(Icons.arrow_back),
                            title: Text("Logout".tr),
                            onTap: () => _showLogoutDialog(context),
                          );
                        } else {
                          return ListTile(
                            leading: Icon(Icons.arrow_back),
                            title: Text("Login".tr),
                            onTap: () => Get.offAll(() => LoginPage()),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future _showSavedLogDialog(BuildContext context) async {
  //   var savedLogFile = await LPrinter.savedLogFile();
  //   var content = savedLogFile.readAsStringSync();
  //   final result = await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text("Log"),
  //           content: Container(
  //             child: Text(content),
  //             height: 400,
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text("Cancel".i18n),
  //               onPressed: () {
  //                 Navigator.of(context).pop("CANCEL");
  //               },
  //             ),
  //             TextButton(
  //               child: Text("Ok".i18n),
  //               onPressed: () {
  //                 Navigator.of(context).pop("OK");
  //               },
  //             ),
  //           ],
  //         );
  //       });
  //   switch (result) {
  //     case "OK":
  //       {}
  //       break;
  //     case "CANCEL":
  //       {}
  //       break;
  //   }
  // }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Logout".tr),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".tr),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    switch (result) {
      case "OK":
        {
          ConnectManager().logout();
          Get.offAll(() => HomePage());
        }
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  // ignore: unused_element
  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clear All Cache".tr),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Get.back(result: "CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".tr),
                onPressed: () {
                  Get.back(result: "OK");
                },
              ),
            ],
          );
        },
        context: context);
    if (result == "OK") {
      try {
        Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            //cleanGlanceData();
      } catch (e) {}
    }
  }
}

class NewVersionChip extends StatelessWidget {
  const NewVersionChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(24.0))),
      child: Text(
        "New",
        style: TextStyle(color: Colors.white, fontSize: 12.0),
      ),
    );
  }
}
