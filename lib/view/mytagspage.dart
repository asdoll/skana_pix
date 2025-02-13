import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import 'novelview/novelresult.dart';
import 'imageview/imagesearchresult.dart';

class MyTagsPage extends StatefulWidget {
  const MyTagsPage({super.key});

  @override
  State<MyTagsPage> createState() => _MyTagsPageState();
}

class _MyTagsPageState extends State<MyTagsPage> {
  bool _tagExpand = false;
  bool _tagExpandNovel = false;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        controller: globalScrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Illust•Manga".tr,
                ).header(),
              ],
            ),
          ),
          (localManager.bookmarkedTags.isNotEmpty)
              ? (localManager.bookmarkedTags.length > 20)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          for (var f in _tagExpand
                              ? localManager.bookmarkedTags
                              : localManager.bookmarkedTags.sublist(0, 12))
                            PixChip(
                                f: f,
                                type: "bookmarkedTags",
                                onTap: () => Get.to(
                                    () => IllustResultPage(word: f),
                                    preventDuplicates: false)),
                          MoonChip(
                              label: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) {
                                  return ScaleTransition(
                                      scale: anim, child: child);
                                },
                                child: Icon(!_tagExpand
                                    ? Icons.expand_more
                                    : Icons.expand_less),
                              ),
                              onTap: () {
                                setState(() {
                                  _tagExpand = !_tagExpand;
                                });
                              })
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          for (var f in localManager.bookmarkedTags)
                            PixChip(
                                f: f,
                                type: "bookmarkedTags",
                                onTap: () => Get.to(
                                    () => IllustResultPage(word: f),
                                    preventDuplicates: false)),
                        ],
                      ),
                    )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(children: [
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("No bookmarked tags".tr).small(),
                    ]),
                  ]),
                ),
          if (localManager.bookmarkedTags.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MoonFilledButton(
                  onTap: () {
                    alertDialog(context,
                            "Clean history?".tr,
                            "",
                            [
                              outlinedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  label: "Cancel".tr),
                              filledButton(
                                  onPressed: () {
                                    localManager.clear("bookmarkedTags");
                                    Get.back();
                                  },
                                  label: "Ok".tr),
                            ],
                          );
                        },
                    leading: Icon(Icons.delete_outline),
                    label: Text("Delete all".tr).small(),
                ),
              ],
            ).paddingAll(16.0),
          Padding(padding: EdgeInsets.only(top: 16.0)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Novel".tr,
                ).header(),
              ],
            ),
          ),
          (localManager.bookmarkedNovelTags.isNotEmpty)
              ? (localManager.bookmarkedNovelTags.length > 20)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          for (var f in _tagExpandNovel
                              ? localManager.bookmarkedNovelTags
                              : localManager.bookmarkedNovelTags.sublist(0, 12))
                            PixChip(
                              f: f,
                              type: "bookmarkedNovelTags",
                              onTap: () => Get.to(
                                  () => NovelResultPage(word: f),
                                  preventDuplicates: false),
                            ),
                          MoonChip(
                              label: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) {
                                  return ScaleTransition(
                                      scale: anim, child: child);
                                },
                                child: Icon(!_tagExpandNovel
                                    ? Icons.expand_more
                                    : Icons.expand_less),
                              ),
                              onTap: () {
                                setState(() {
                                  _tagExpandNovel = !_tagExpandNovel;
                                });
                              })
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          for (var f in localManager.bookmarkedNovelTags)
                            PixChip(
                              f: f,
                              type: "bookmarkedNovelTags",
                              onTap: () => Get.to(
                                  () => NovelResultPage(word: f),
                                  preventDuplicates: false),
                            ),
                        ],
                      ),
                    )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(children: [
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("No bookmarked tags".tr).small()]),
                  ]),
                ),
          if (localManager.bookmarkedNovelTags.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MoonFilledButton(
                  onTap: () {
                    alertDialog(context,
                            "Clean history?".tr,
                            "",
                            [
                              outlinedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  label: "Cancel".tr),
                              filledButton(
                                  onPressed: () {
                                    localManager.clear("bookmarkedNovelTags");
                                    Get.back();
                                  },
                                  label: "Ok".tr),
                            ],
                          );
                        },
                    leading: Icon(Icons.delete_outline),
                    label: Text("Delete all".tr).small(),
                ),
              ],
            ).paddingAll(16.0),
        ],
      ),
    );
  }
}
