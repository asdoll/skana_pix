import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/settings/blocklistpage.dart';
import 'package:skana_pix/view/settings/netsettings.dart';
import 'package:skana_pix/view/settings/newversion.dart';
import 'package:skana_pix/view/settings/prefsettings.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'about.dart';
import '../../componentwidgets/avatar.dart';
import 'boardpage.dart';
import 'dataexport.dart';
import '../loginpage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    boardController.fetchBoard();
    return Obx(() => CustomScrollView(
          slivers: <Widget>[
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                  child: Card(
                      child: Basic(
                leading: PainterAvatar(
                    url: ConnectManager().apiClient.account.user.profileImg,
                    id: int.parse(
                      ConnectManager().apiClient.userid,
                    ),
                    isMe: true,
                    size: 48),
                title: Text(
                  ConnectManager().apiClient.account.user.name,
                ),
                content: Text(
                  ConnectManager().apiClient.account.user.email,
                ),
              ))),
            SliverToBoxAdapter(
                child: Button(
                    alignment: Alignment.centerLeft,
                    onPressed: () => Get.to(BlockListPage()),
                    style: ButtonStyle.card(),
                    child: Basic(
                      leading: Icon(Icons.block),
                      title: Text("Block List".tr),
                    ))),
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                child: Button(
                  alignment: Alignment.centerLeft,
                  onPressed: () =>
                      launchUrlString("https://www.pixiv.net/setting_user.php"),
                  style: ButtonStyle.card(),
                  child: Basic(
                    leading: Icon(Icons.account_box),
                    title: Text("Account Settings".tr),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Button(
                  alignment: Alignment.centerLeft,
                  onPressed: () => Get.to(PreferenceSettings()),
                  style: ButtonStyle.card(),
                  child: Basic(
                    leading: Icon(Icons.settings),
                    title: Text("Preference Settings".tr),
                  )),
            ),
            SliverToBoxAdapter(
              child: Button(
                  alignment: Alignment.centerLeft,
                  onPressed: () => Get.to(NetworkSettings()),
                  style: ButtonStyle.card(),
                  child: Basic(
                    leading: Icon(Icons.settings),
                    title: Text("Network Settings".tr),
                  )),
            ),
            SliverToBoxAdapter(
              child: Button(
                  alignment: Alignment.centerLeft,
                  onPressed: () => Get.to(DataExport()),
                  style: ButtonStyle.card(),
                  child: Basic(
                    leading: Icon(Icons.folder_open_rounded),
                    title: Text("App Data".tr),
                  )),
            ),
            SliverToBoxAdapter(
              child: Button(
                  alignment: Alignment.centerLeft,
                  onPressed: () => Get.to(AboutPage()),
                  style: ButtonStyle.card(),
                  child: Basic(
                    leading: Icon(Icons.message),
                    title: Text("About".tr),
                  )),
            ),
            if (boardController.needBoardSection.value)
              SliverToBoxAdapter(
                  child: Button(
                alignment: Alignment.centerLeft,
                onPressed: () => Get.to(BoardPage()),
                style: ButtonStyle.card(),
                child: Basic(
                  leading: Icon(Icons.article),
                  title: Text("Bulletin Board".tr),
                ),
              )),
            SliverToBoxAdapter(
              child: Button(
                alignment: Alignment.centerLeft,
                onPressed: () => Get.to(NewVersionPage()),
                style: ButtonStyle.card(),
                child: Basic(
                  leading: Icon(Icons.update),
                  title: Text("Check updates".tr),
                  trailing: Visibility(
                    visible: updateController.hasNewVersion.value,
                    child: NewVersionChip(),
                  ),
                ),
              ),
            ),
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                  child: Button(
                alignment: Alignment.centerLeft,
                onPressed: () => _showLogoutDialog(context),
                style: ButtonStyle.card(),
                child: Basic(
                  leading: Icon(Icons.logout),
                  title: Text("Logout".tr),
                ),
              ))
          ],
        ));
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Logout".tr).toAlign(Alignment.centerLeft),
            content: Text("Are you sure you want to logout?".tr),
            actions: <Widget>[
              OutlineButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Get.back(result: "CANCEL");
                },
              ),
              PrimaryButton(
                child: Text("Ok".tr),
                onPressed: () {
                  Get.back(result: "OK");
                },
              ),
            ],
          );
        });
    switch (result) {
      case "OK":
        {
          accountController.logout();
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
