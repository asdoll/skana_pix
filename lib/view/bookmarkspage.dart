// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
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
    return Obx(() => Column(
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
            ),
            Expanded(
                child: TabBarView(children: [
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
        ));
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
    return Builder(builder: (_) {
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
          ),
          Expanded(
            child: TabBarView(children: [
              MyBookmarkContent(
                type: ArtworkType.ILLUST,
              ),
              MyBookmarkContent(
                type: ArtworkType.NOVEL,
              ),
            ]),
          ),
        ],
      );
    });
  }
}

class MyBookmarkContent extends StatefulWidget {
  final ArtworkType type;

  const MyBookmarkContent({super.key, required this.type});

  @override
  State<MyBookmarkContent> createState() => _MyBookmarkContentState();
}

class _MyBookmarkContentState extends State<MyBookmarkContent> {
  @override
  void dispose() {
    super.dispose();
    try {
      if (widget.type == ArtworkType.ILLUST) {
        Get.delete<ListIllustController>(tag: "mybookmarks_illust");
      } else {
        Get.delete<ListNovelController>(tag: "mybookmarks_novel");
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
              controllerType: ListType.mybookmarks, type: widget.type),
          tag: "mybookmarks_illust");
      MTab mtab = Get.put(MTab(), tag: "mybookmarks_illust");
      return Builder(
          builder: (_) => Column(
                children: [
                  // Tabs(
                  //   index: mtab.index.value,
                  //   tabs: [
                  //     Text("Public".tr),
                  //     Text("Private".tr),
                  //   ],
                  //   onChanged: (index) {
                  //     mtab.index.value = index;
                  //     controller.restrict.value = index == 0 ? 'public' : 'private';
                  //     controller.refreshController?.callRefresh();
                  //   },
                  // ).paddingTop(10),
                  Expanded(
                    child: ImageWaterfall(controllerTag: "mybookmarks_illust"),
                  ),
                ],
              ));
    } else {
      ListNovelController controller = Get.put(
          ListNovelController(controllerType: ListType.mybookmarks),
          tag: "mybookmarks_novel");
      MTab mtab = Get.put(MTab(), tag: "mybookmarks_novel");
      return Builder(
          builder: (_) => Column(
                children: [
                  // Tabs(
                  //   index: mtab.index.value,
                  //   tabs: [Text("Public".tr), Text("Private".tr)],
                  //   onChanged: (index) {
                  //     mtab.index.value = index;
                  //     controller.restrict.value = index == 0 ? 'public' : 'private';
                  //     controller.refreshController?.callRefresh();
                  //   },
                  // ).paddingTop(10),
                  Expanded(
                    child: NovelList(controllerTag: "mybookmarks_novel"),
                  ),
                ],
              ));
    }
  }
}
