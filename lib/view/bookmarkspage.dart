// ignore_for_file: unused_local_variable

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class BookmarksPage extends StatefulWidget {
  final int id;
  final ArtworkType type;

  const BookmarksPage({super.key, required this.id, required this.type});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    MTab mtab = Get.put(MTab(), tag: "bookmarks_${widget.id}");
    mtab.index.value = widget.type == ArtworkType.ILLUST ? 0 : 1;
    return Obx(() {
      return Column(
        children: [
          TabList(
            index: mtab.index.value,
            children: [
              TabButton(
                child: Text("Illust".tr),
                onPressed: () {
                  mtab.index.value = 0;
                },
              ),
              TabButton(
                child: Text("Novel".tr),
                onPressed: () {
                  mtab.index.value = 1;
                },
              ),
            ],
          ),
          Expanded(
            child: (mtab.index.value == 0)
                ? BookmarkContent(
                    id: widget.id,
                    type: ArtworkType.ILLUST,
                  )
                : BookmarkContent(
                    id: widget.id,
                    type: ArtworkType.NOVEL,
                  ),
          ),
        ],
      );
    });
  }
}

class BookmarkContent extends StatefulWidget {
  final int id;
  final ArtworkType type;

  const BookmarkContent({super.key, required this.id, required this.type});

  @override
  State<BookmarkContent> createState() => _BookmarkContentState();
}

class _BookmarkContentState extends State<BookmarkContent> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST) {
      ListIllustController controller = Get.put(
          ListIllustController(
              controllerType: ListType.userbookmarks,
              type: widget.type,
              id: widget.id.toString()),
          tag: "userbookmarks_${widget.id}");
      return Obx(
          () => ImageWaterfall(controllerTag: "userbookmarks_${widget.id}"));
    } else {
      ListNovelController controller = Get.put(
          ListNovelController(
              controllerType: ListType.userbookmarks, id: widget.id.toString()),
          tag: "userbookmarks_${widget.id}");
      return Obx(() => NovelList(controllerTag: "userbookmarks_${widget.id}"));
    }
  }
}

class MyBookmarksPage extends StatefulWidget {
  final ArtworkType type;

  const MyBookmarksPage({super.key, required this.type});
  @override
  State<MyBookmarksPage> createState() => _MyBookmarksPageState();
}

class _MyBookmarksPageState extends State<MyBookmarksPage> {
  @override
  Widget build(BuildContext context) {
    MTab mtab = Get.put(MTab(), tag: "mybookmarks");
    mtab.index.value = widget.type == ArtworkType.ILLUST ? 0 : 1;
    return Obx(() {
      return Column(
        children: [
          TabList(
            index: mtab.index.value,
            children: [
              TabButton(
                child: Text("Illust".tr),
                onPressed: () {
                  mtab.index.value = 0;
                },
              ),
              TabButton(
                child: Text("Novel".tr),
                onPressed: () {
                  mtab.index.value = 1;
                },
              ),
            ],
          ),
          Expanded(
            child: (mtab.index.value == 0)
                ? MyBookmarkContent(
                    type: ArtworkType.ILLUST,
                  )
                : MyBookmarkContent(
                    type: ArtworkType.NOVEL,
                  ),
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
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST) {
      ListIllustController controller = Get.put(
          ListIllustController(
              controllerType: ListType.mybookmarks, type: widget.type),
          tag: "mybookmarks_illust");
      MTab mtab = Get.put(MTab(), tag: "mybookmarks_illust");
      return Obx(() => Column(
            children: [
              Tabs(
                index: mtab.index.value,
                tabs: [
                  Text("Public".tr),
                  Text("Private".tr),
                ],
                onChanged: (index) {
                  mtab.index.value = index;
                  controller.restrict.value = index == 0 ? 'public' : 'private';
                  controller.refreshController?.callRefresh();
                },
              ).paddingTop(10),
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
      return Obx(() => Column(
            children: [
              Tabs(
                index: mtab.index.value,
                tabs: [Text("Public".tr), Text("Private".tr)],
                onChanged: (index) {
                  mtab.index.value = index;
                  controller.restrict.value = index == 0 ? 'public' : 'private';
                  controller.refreshController?.callRefresh();
                },
              ).paddingTop(10),
              Expanded(
                child: NovelList(controllerTag: "mybookmarks_novel"),
              ),
            ],
          ));
    }
  }
}
