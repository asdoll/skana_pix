import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/controller/like_controller.dart';

class BlockListPage extends StatefulWidget {
  const BlockListPage({super.key});

  @override
  State<BlockListPage> createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        headers: [
          AppBar(
            title: Text('Block List'.tr),
            padding: EdgeInsets.all(10),
            leading: [
              const NormalBackButton(),
            ],
          ),
          const Divider()
        ],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Card(
                    child: Basic(
                  title: Text("Tags".tr),
                  titleSpacing: 6,
                  trailing: IconButton.ghost(
                      onPressed: () {
                        _showBanTagAddDialog(false);
                      },
                      icon: Icon(Icons.add)),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedTags
                        .map((f) =>
                            PixChip(f: f, type: "blockedTags", isSetting: true))
                        .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Novel Tags".tr),
                  titleSpacing: 6,
                  trailing: IconButton.ghost(
                        onPressed: () {
                          _showBanTagAddDialog(true);
                        },
                        icon: Icon(Icons.add)),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedNovelTags
                      .map((f) => PixChip(
                          f: f, type: "blockedNovelTags", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Pianters".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedUsers
                      .map((f) =>
                          PixChip(f: f, type: "blockedUsers", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Authors".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedNovelUsers
                      .map((f) =>
                          PixChip(f: f, type: "blockedNovelUsers", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Commentors".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedCommentUsers
                      .map((f) =>
                          PixChip(f: f, type: "blockedCommentUsers", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Illusts".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedIllusts
                      .map((f) =>
                          PixChip(f: f, type: "blockedIllusts", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Novels".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedNovels
                      .map((f) =>
                          PixChip(f: f, type: "blockedNovels", isSetting: true))
                      .toList(),
                  ),
                )),
                Card(
                    child: Basic(
                  title: Text("Comments".tr),
                  titleSpacing: 6,
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedComments
                      .map((f) =>
                          PixChip(f: f, type: "blockedComments", isSetting: true))
                      .toList(),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    });
  }

  _showBanTagAddDialog(bool isNovel) async {
    final controller = TextEditingController();
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add".tr),
            content: TextField(
              controller: controller,
              placeholder: Text(isNovel ? "Novel Tag".tr : "Tag".tr,
                  style: TextStyle(fontSize: 12)),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                onPressed: () {
                  Get.back(result: controller.text);
                },
                child: Text("Ok".tr),
              ),
            ],
          );
        });
    if (result != null && result is String && result.isNotEmpty) {
      if (isNovel) {
        localManager.add("blockedNovelTags", [result]);
      } else {
        localManager.add("blockedTags", [result]);
      }
    }
  }
}
