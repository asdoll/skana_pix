import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

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
        appBar: appBar(title: "Blocked List".tr),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                moonListTileWidgets(
                  label: Text("Tags".tr).header(),
                  trailing: IconButton(
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
                ),
                moonListTileWidgets(
                  label: Text("Novel Tags".tr).header(),
                  trailing: IconButton(
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
                ),
                moonListTileWidgets(
                  label: Text("Pianters".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedUsers
                        .map((f) => PixChip(
                            f: f, type: "blockedUsers", isSetting: true))
                        .toList(),
                  ),
                ),
                moonListTileWidgets(
                  label: Text("Authors".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedNovelUsers
                        .map((f) => PixChip(
                            f: f, type: "blockedNovelUsers", isSetting: true))
                        .toList(),
                  ),
                ),
                moonListTileWidgets(
                  label: Text("Commentors".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedCommentUsers
                        .map((f) => PixChip(
                            f: f, type: "blockedCommentUsers", isSetting: true))
                        .toList(),
                  ),
                ),
                moonListTileWidgets(
                  label: Text("Illusts".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedIllusts
                        .map((f) => PixChip(
                            f: f, type: "blockedIllusts", isSetting: true))
                        .toList(),
                  ),
                ),
                moonListTileWidgets(
                  label: Text("Novels".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedNovels
                        .map((f) => PixChip(
                            f: f, type: "blockedNovels", isSetting: true))
                        .toList(),
                  ),
                ),
                moonListTileWidgets(
                  label: Text("Comments".tr).header(),
                  trailing: IconButton(onPressed: () {}, icon: Container()),
                  content: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: localManager.blockedComments
                        .map((f) => PixChip(
                            f: f, type: "blockedComments", isSetting: true))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  _showBanTagAddDialog(bool isNovel) async {
    final controller = TextEditingController();
    final result = await showMoonModal(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [MoonAlert(
            label: Text("Add".tr).header(),
            content: Column(children: [MoonTextInput(
                controller: controller,
                hintText: isNovel ? "Novel Tag".tr : "Tag".tr).paddingAll(8),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  outlinedButton(
                    label: "Cancel".tr,
                    onPressed: () {
                      Get.back();
                    },
                  ).paddingRight(8),
                  filledButton(
                    label: "Ok".tr,
                    onPressed: () {
                      Get.back(result: controller.text);
                    },
                  ).paddingRight(8),
                ],
              )
            ],
            )
          )],
            )
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
