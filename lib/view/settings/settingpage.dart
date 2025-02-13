import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/settings/blocklistpage.dart';
import 'package:skana_pix/view/settings/netsettings.dart';
import 'package:skana_pix/view/settings/newversion.dart';
import 'package:skana_pix/view/settings/prefsettings.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'about.dart';
import '../../componentwidgets/avatar.dart';
import 'boardpage.dart';
import 'dataexport.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomScrollView(
          slivers: <Widget>[
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                  child: moonListTile(
                leading: PainterAvatar(
                    url: accountController.user.profileImg,
                    id: int.parse(
                      accountController.userid.value,
                    ),
                    isMe: true,
                    size: 48),
                title: accountController.user.name,
                subtitle: accountController.user.email,
              )),
            SliverToBoxAdapter(
                child: moonListTile(
                    onTap: () => Get.to(BlockListPage()),
                    leading: Icon(Icons.block),
                    title: "Block List".tr)),
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                child: moonListTile(
                    onTap: () => launchUrlString(
                        "https://www.pixiv.net/setting_user.php"),
                    leading: Icon(Icons.account_box),
                    title: "Account Settings".tr),
              ),
            SliverToBoxAdapter(
              child: moonListTile(
                  onTap: () => Get.to(PreferenceSettings()),
                  leading: Icon(Icons.settings),
                  title: "Preference Settings".tr),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  onTap: () => Get.to(NetworkSettings()),
                  leading: Icon(Icons.settings),
                  title: "Network Settings".tr),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  onTap: () => Get.to(DataExport()),
                  leading: Icon(Icons.folder_open_rounded),
                  title: "App Data".tr),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  onTap: () => Get.to(AboutPage()),
                  leading: Icon(Icons.message),
                  title: "About".tr),
            ),
            if (boardController.needBoardSection.value)
              SliverToBoxAdapter(
                  child: moonListTile(
                onTap: () => Get.to(BoardPage()),
                leading: Icon(Icons.article),
                title: "Bulletin Board".tr,
              )),
            SliverToBoxAdapter(
              child: moonListTile(
                onTap: () => Get.to(NewVersionPage()),
                leading: Icon(Icons.update),
                title: "Check updates".tr,
                trailing: Visibility(
                  visible: updateController.hasNewVersion.value,
                  child: NewVersionChip(),
                ),
              ),
            ),
            if (accountController.isLoggedIn.value)
              SliverToBoxAdapter(
                  child: moonListTile(
                onTap: () => _showLogoutDialog(context),
                leading: Icon(Icons.logout),
                title: "Logout".tr,
              ))
          ],
        ));
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await alertDialog<String>(
        context, "Logout".tr, "Are you sure you want to logout?".tr, [
      outlinedButton(
        label: "Cancel".tr,
        onPressed: () {
          Get.back(result: "CANCEL");
        },
      ),
      filledButton(
        label: "Ok".tr,
        onPressed: () {
          Get.back(result: "OK");
        },
      ),
    ]);
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
//   Future _showClearCacheDialog(BuildContext context) async {
//     final result = await showDialog(
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Clear All Cache".tr),
//             actions: <Widget>[
//               TextButton(
//                 child: Text("Cancel".tr),
//                 onPressed: () {
//                   Get.back(result: "CANCEL");
//                 },
//               ),
//               TextButton(
//                 child: Text("Ok".tr),
//                 onPressed: () {
//                   Get.back(result: "OK");
//                 },
//               ),
//             ],
//           );
//         },
//         context: context);
//     if (result == "OK") {
//       try {
//         Directory tempDir = await getTemporaryDirectory();
//         tempDir.deleteSync(recursive: true);
//         //cleanGlanceData();
//       } catch (e) {}
//     }
//   }
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
