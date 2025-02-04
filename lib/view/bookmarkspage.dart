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
    if (widget.id == 0) {
      if (widget.type == ArtworkType.ILLUST) {
        ListIllustController controller = Get.put(
            ListIllustController(
                controllerType: ListType.mybookmarks, type: widget.type),
            tag: "mybookmarks_${widget.id}");
        MTab mtab = Get.put(MTab(), tag: "mybookmarks_${widget.id}");
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
              child: ImageWaterfall(controllerTag: "mybookmarks_${widget.id}"),
            ),
          ],
        ));
      } else {
        ListNovelController controller = Get.put(
            ListNovelController(controllerType: ListType.mybookmarks),
            tag: "mybookmarks_${widget.id}");
        MTab mtab = Get.put(MTab(), tag: "mybookmarks_${widget.id}");
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
              child: NovelList(controllerTag: "mybookmarks_${widget.id}"),
            ),
          ],
        ));
      }
    } else {
      if (widget.type == ArtworkType.ILLUST) {
        ListIllustController controller = Get.put(
            ListIllustController(
                controllerType: ListType.userbookmarks,
                type: widget.type,
                id: widget.id.toString()),
            tag: "userbookmarks_${widget.id}");
        return Obx(() => ImageWaterfall(controllerTag: "userbookmarks_${widget.id}"));
      } else {
        ListNovelController controller = Get.put(
            ListNovelController(
                controllerType: ListType.userbookmarks,
                id: widget.id.toString()),
            tag: "userbookmarks_${widget.id}");
        return Obx(() => NovelList(controllerTag: "userbookmarks_${widget.id}"));
      }
    }
  }
}
