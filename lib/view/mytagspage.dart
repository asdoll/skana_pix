import 'package:flutter/material.dart' show InkWell;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/controller/like_controller.dart';

import 'defaults.dart';
import '../componentwidgets/novelresult.dart';
import '../componentwidgets/searchresult.dart';

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
    return Obx(() {
      return CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Illust•Manga".tr,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.foreground),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
                child: (localManager.bookmarkedTags.isNotEmpty)
                    ? (localManager.bookmarkedTags.length > 20)
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Wrap(
                              runSpacing: 0.0,
                              spacing: 5.0,
                              children: [
                                for (var f in _tagExpand
                                    ? localManager.bookmarkedTags
                                    : localManager.bookmarkedTags
                                        .sublist(0, 12))
                                  PixChip(
                                      f: f,
                                      type: "bookmarkedTags",
                                      onTap: () => Get.to(
                                          () => ResultPage(word: f),
                                          preventDuplicates: false)),
                                Chip(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      transitionBuilder: (child, anim) {
                                        return ScaleTransition(
                                            scale: anim, child: child);
                                      },
                                      child: Icon(!_tagExpand
                                          ? Icons.expand_more
                                          : Icons.expand_less),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _tagExpand = !_tagExpand;
                                      });
                                    })
                              ],
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Wrap(
                              runSpacing: 0.0,
                              spacing: 3.0,
                              children: [
                                for (var f in localManager.bookmarkedTags)
                                  PixChip(
                                      f: f,
                                      type: "bookmarkedTags",
                                      onTap: () => Get.to(
                                          () => ResultPage(word: f),
                                          preventDuplicates: false)),
                              ],
                            ),
                          )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(children: [
                          SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("No bookmarked tags".tr),
                              ]),
                        ]),
                      )),
          ),
          if (localManager.bookmarkedTags.isNotEmpty)
            SliverToBoxAdapter(
                child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Clean history?".tr),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("Cancel".tr)),
                          TextButton(
                              onPressed: () {
                                localManager.clear("bookmarkedTags");
                                Get.back();
                              },
                              child: Text("Ok".tr)),
                        ],
                      );
                    });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18.0,
                        color: Theme.of(context).colorScheme.foreground,
                      ),
                      Text(
                        "Clear search history".tr,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.foreground),
                      )
                    ],
                  ),
                ),
              ),
            )),
          if (DynamicData.isAndroid)
            SliverToBoxAdapter(
              child: Container(
                height: (MediaQuery.of(context).size.width / 3) - 16,
              ),
            ),
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Novel".tr,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.foreground),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: (localManager.bookmarkedNovelTags.isNotEmpty)
                  ? (localManager.bookmarkedNovelTags.length > 20)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Wrap(
                            runSpacing: 0.0,
                            spacing: 5.0,
                            children: [
                              for (var f in _tagExpandNovel
                                  ? localManager.bookmarkedNovelTags
                                  : localManager.bookmarkedNovelTags
                                      .sublist(0, 12))
                                PixChip(
                                  f: f,
                                  type: "bookmarkedNovelTags",
                                  onTap: () => Get.to(
                                      () => NovelResultPage(word: f),
                                      preventDuplicates: false),
                                ),
                              Chip(
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) {
                                      return ScaleTransition(
                                          scale: anim, child: child);
                                    },
                                    child: Icon(!_tagExpandNovel
                                        ? Icons.expand_more
                                        : Icons.expand_less),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _tagExpandNovel = !_tagExpandNovel;
                                    });
                                  })
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Wrap(
                            runSpacing: 0.0,
                            spacing: 3.0,
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
                            children: [
                              Text("No bookmarked tags".tr),
                            ]),
                      ]),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Clean history?".tr),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("Cancel".tr)),
                          TextButton(
                              onPressed: () {
                                localManager.clear("bookmarkedNovelTags");
                                Get.back();
                              },
                              child: Text("Ok".tr)),
                        ],
                      );
                    });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18.0,
                        color: Theme.of(context).colorScheme.foreground,
                      ),
                      Text(
                        "Clear search history".tr,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.foreground),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (DynamicData.isAndroid)
            SliverToBoxAdapter(
              child: Container(
                height: (MediaQuery.of(context).size.width / 3) - 16,
              ),
            )
        ],
      );
    });
  }
}
