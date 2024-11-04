import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/componentwidgets/blocklistpage.dart';
import 'package:skana_pix/componentwidgets/followlist.dart';
import 'package:skana_pix/componentwidgets/prefsettings.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../componentwidgets/about.dart';
import '../componentwidgets/avatar.dart';
import '../componentwidgets/booktagpage.dart';
import '../componentwidgets/dataexport.dart';
import '../componentwidgets/historypage.dart';
import '../componentwidgets/mybookmarks.dart';
import '../componentwidgets/themepage.dart';
import '../utils/leaders.dart';
import 'loginpage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    initMethod();
    //fetchBoard();
  }

  bool hasNewVersion = false;

  initMethod() async {
    if (Constants.isGooglePlay || DynamicData.isIOS) return;
    // if (Updater.result != Result.timeout) {
    //   bool hasNew = Updater.result == Result.yes;
    //   if (mounted)
    //     setState(() {
    //       hasNewVersion = hasNew;
    //     });
    //   return;
    // }
    // Result result = await Updater.check();
    // switch (result) {
    //   case Result.yes:
    //     if (mounted) {
    //       setState(() {
    //         hasNewVersion = true;
    //       });
    //     }
    //     break;
    //   default:
    //     if (mounted) {
    //       setState(() {
    //         hasNewVersion = false;
    //       });
    //     }
    // }
  }

  @override
  Widget build(BuildContext context) {
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ThemePage()));
                      },
                    ),
                  ],
                ),
                Observer(builder: (context) {
                  if (!ConnectManager().notLoggedIn) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          padding: const EdgeInsets.symmetric(
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
                            title: Text("My Bookmarks".i18n),
                            onTap: () => Leader.pushWithScaffold(
                                context,
                                MyBookmarksPage(
                                  portal: 'mybookmark',
                                  type: settings.awPrefer == "novel"
                                      ? ArtworkType.NOVEL
                                      : ArtworkType.ILLUST,
                                )),
                          ),
                          ListTile(
                            leading: Icon(Icons.bookmark),
                            title: Text("Favorite Tags".i18n),
                            onTap: () =>
                                Leader.pushWithScaffold(context, BookTagPage()),
                          ),
                          ListTile(
                            leading: Icon(Icons.star_rate_rounded),
                            title: Text("Following".i18n),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => FollowList(
                                        id: int.parse(
                                            ConnectManager().apiClient.userid),
                                        setAppBar: true,
                                        isMe: true,
                                      )));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.people_rounded),
                            title: Text("My Pixiv".i18n),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => FollowList(
                                        id: int.parse(
                                            ConnectManager().apiClient.userid),
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
                      title: Text("History".i18n),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return HistoryPage();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.block),
                      title: Text("Block List".i18n),
                      onTap: () => Leader.push(context, BlockListPage()),
                    ),
                    if (!ConnectManager().notLoggedIn)
                      ListTile(
                        leading: Icon(Icons.account_box),
                        title: Text("Account Settings".i18n),
                        onTap: () {
                          launchUrlString(
                              "https://www.pixiv.net/setting_user.php");
                        },
                      ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Preference Settings".i18n),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return PreferenceSettings();
                        }));
                      },
                    ),
                    ListTile(
                      onTap: () => Leader.push(context, DataExport()),
                      title: Text("App Data".i18n),
                      leading: Icon(Icons.folder_open_rounded),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text("About".i18n),
                      onTap: () => Leader.push(
                          context, AboutPage(newVersion: hasNewVersion)),
                      // trailing: Visibility(
                      //   child: NewVersionChip(),
                      //   visible: hasNewVersion,
                      // ),
                    ),
                    // if (_needBoardSection)
                    //   ListTile(
                    //     leading: Icon(Icons.article),
                    //     title: Text(I18n.of(context).bulletin_board),
                    //     onTap: () => Leader.push(
                    //         context,
                    //         BoardPage(
                    //           boardList: _boardList,
                    //         )),
                    //   ),
                    Observer(builder: (context) {
                      if (!ConnectManager().notLoggedIn) {
                        return ListTile(
                          leading: Icon(Icons.arrow_back),
                          title: Text("Logout".i18n),
                          onTap: () => _showLogoutDialog(context),
                        );
                      } else {
                        return ListTile(
                          leading: Icon(Icons.arrow_back),
                          title: Text("Login".i18n),
                          onTap: () => Leader.push(
                              context, LoginPage(() => setState(() {}))),
                        );
                      }
                    })
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
            title: Text("Logout".i18n),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".i18n),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".i18n),
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
          DynamicData.rootNavigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (route) => false);
        }
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clear All Cache".i18n),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".i18n),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".i18n),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        },
        context: context);
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            //cleanGlanceData();
          } catch (e) {}
        }
        break;
    }
  }

  // void cleanGlanceData() async {
  //   GlanceIllustPersistProvider glanceIllustPersistProvider =
  //       GlanceIllustPersistProvider();
  //   await glanceIllustPersistProvider.open();
  //   await glanceIllustPersistProvider.deleteAll();
  //   await glanceIllustPersistProvider.close();
  // }

  // bool _needBoardSection = false;
  // List<BoardInfo> _boardList = [];

  // fetchBoard() async {
  //   try {
  //     if (BoardInfo.boardDataLoaded) {
  //       setState(() {
  //         _boardList = BoardInfo.boardList;
  //         _needBoardSection = _boardList.isNotEmpty;
  //       });
  //       return;
  //     }
  //     final list = await BoardInfo.load();
  //     setState(() {
  //       BoardInfo.boardDataLoaded = true;
  //       _boardList = list;
  //       _needBoardSection = _boardList.isNotEmpty;
  //     });
  //   } catch (e) {}
  // }
}
