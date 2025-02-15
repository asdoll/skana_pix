// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class BookmarksPage extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final bool noScroll;

  const BookmarksPage(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            MoonTabBar(
              tabController: controller,
              tabs: [
                MoonTab(
                  label: Text("Illust".tr),
                ),
                MoonTab(
                  label: Text("Novel".tr),
                ),
              ],
            ).paddingLeft(16).toAlign(Alignment.topLeft),
            Expanded(
                child: TabBarView(
                  controller: controller,
                  children: [
              BookmarkContent(
                id: widget.id,
                type: ArtworkType.ILLUST,
              ),
              BookmarkContent(
                id: widget.id,
                type: ArtworkType.NOVEL,
              )
            ])),
          ],
        );
  }
}

class BookmarkContent extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final bool noScroll;

  const BookmarkContent(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<BookmarkContent> createState() => _BookmarkContentState();
}

class _BookmarkContentState extends State<BookmarkContent> {
  @override
  void dispose() {
    super.dispose();
    try {
      if (widget.type == ArtworkType.ILLUST) {
        Get.delete<ListIllustController>(tag: "userbookmarks_${widget.id}");
      } else {
        Get.delete<ListNovelController>(tag: "userbookmarks_${widget.id}");
      }
    } catch (e) {
      log.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST) {
      ListIllustController controller = Get.put(
          ListIllustController(
              controllerType: ListType.userbookmarks,
              type: widget.type,
              id: widget.id.toString()),
          tag: "userbookmarks_${widget.id}");
      return ImageWaterfall(
          controllerTag: "userbookmarks_${widget.id}",
          noScroll: widget.noScroll);
    } else {
      ListNovelController controller = Get.put(
          ListNovelController(
              controllerType: ListType.userbookmarks, id: widget.id.toString()),
          tag: "userbookmarks_${widget.id}");
      return NovelList(
          controllerTag: "userbookmarks_${widget.id}",
          noScroll: widget.noScroll);
    }
  }
}

class MyBookmarksPage extends StatefulWidget {
  final ArtworkType type;

  const MyBookmarksPage({super.key, required this.type});
  @override
  State<MyBookmarksPage> createState() => _MyBookmarksPageState();
}

class _MyBookmarksPageState extends State<MyBookmarksPage>
    with TickerProviderStateMixin {
  late TabController controller;
  late TabController icontroller;
  late TabController ncontroller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    icontroller = TabController(length: 2, vsync: this);
    ncontroller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    icontroller.dispose();
    ncontroller.dispose();
    Get.delete<MyBookmarkController>();
  }

  @override
  Widget build(BuildContext context) {
    MyBookmarkController bmController = Get.put(MyBookmarkController());
    return Column(
      children: [
        MoonTabBar(
          padding: EdgeInsets.all(0),
          tabController: controller,
          tabs: [
            MoonTab(
              label: Text("Illust".tr),
            ),
            MoonTab(
              label: Text("Novel".tr),
            ),
          ],
        ).paddingLeft(16).toAlign(Alignment.bottomLeft),
        Expanded(
            child: Obx(
          () => TabBarView(controller: controller, children: [
            Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MoonChip(
                      activeBackgroundColor: Get.isDarkMode
                          ? Color.lerp(context.moonTheme?.tokens.colors.bulma,context.moonTheme?.tokens.colors.piccolo, 0.2)
                          : null,
                      chipSize: MoonChipSize.sm,
                      label: Text("Public".tr),
                      isActive: bmController.illustPublic.value,
                      onTap: () {
                        bmController.illustPublic.value = true;
                        icontroller.index = 0;
                      }),
                  MoonChip(
                    activeBackgroundColor: Get.isDarkMode
                          ? Color.lerp(context.moonTheme?.tokens.colors.bulma,context.moonTheme?.tokens.colors.piccolo, 0.2)
                          : null,
                      chipSize: MoonChipSize.sm,
                      label: Text("Private".tr),
                      isActive: !bmController.illustPublic.value,
                      onTap: () {
                        bmController.illustPublic.value = false;
                        icontroller.index = 1;
                      }),
                ]).paddingOnly(top: 8),
                Expanded(
                    child: TabBarView(controller: icontroller, children: [
                  MyBookmarkContent(type: ArtworkType.ILLUST, label: "public"),
                  MyBookmarkContent(type: ArtworkType.ILLUST, label: "private"),
                ])),
              ],
            ),
            Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MoonChip(
                    activeBackgroundColor: Get.isDarkMode
                          ? Color.lerp(context.moonTheme?.tokens.colors.bulma,context.moonTheme?.tokens.colors.piccolo, 0.2)
                          : null,
                      chipSize: MoonChipSize.sm,
                      label: Text("Public".tr),
                      isActive: bmController.novelPublic.value,
                      onTap: () {
                        bmController.novelPublic.value = true;
                        ncontroller.index = 0;
                      }),
                  MoonChip(
                    activeBackgroundColor: Get.isDarkMode
                          ? Color.lerp(context.moonTheme?.tokens.colors.bulma,context.moonTheme?.tokens.colors.piccolo, 0.2)
                          : null,
                      chipSize: MoonChipSize.sm,
                      label: Text("Private".tr),
                      isActive: !bmController.novelPublic.value,
                      onTap: () {
                        bmController.novelPublic.value = false;
                        ncontroller.index = 1;
                      }),
                ]).paddingOnly(top: 8),
                Expanded(
                    child: TabBarView(controller: ncontroller, children: [
                  MyBookmarkContent(type: ArtworkType.NOVEL, label: "public"),
                  MyBookmarkContent(type: ArtworkType.NOVEL, label: "private"),
                ])),
              ],
            ),
          ]),
        )),
      ],
    );
  }
}

class MyBookmarkContent extends StatefulWidget {
  final ArtworkType type;
  final String label;

  const MyBookmarkContent({super.key, required this.type, required this.label});

  @override
  State<MyBookmarkContent> createState() => _MyBookmarkContentState();
}

class _MyBookmarkContentState extends State<MyBookmarkContent> {
  @override
  void dispose() {
    super.dispose();
    if (widget.type == ArtworkType.ILLUST) {
      Get.delete<ListIllustController>(
          tag: "mybookmarks_illust_${widget.label}");
    } else {
      Get.delete<ListNovelController>(tag: "mybookmarks_novel_${widget.label}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST) {
      ListIllustController controller = Get.put(
          ListIllustController(
              controllerType: ListType.mybookmarks,
              type: widget.type,
              restrict: widget.label),
          tag: "mybookmarks_illust_${widget.label}");
      return ImageWaterfall(
          controllerTag: "mybookmarks_illust_${widget.label}");
    } else {
      ListNovelController controller = Get.put(
          ListNovelController(
              controllerType: ListType.mybookmarks, restrict: widget.label),
          tag: "mybookmarks_novel_${widget.label}");
      return NovelList(controllerTag: "mybookmarks_novel_${widget.label}");
    }
  }
}

class MyBookmarkController extends GetxController {
  RxBool illustPublic = true.obs;
  RxBool novelPublic = true.obs;
}
