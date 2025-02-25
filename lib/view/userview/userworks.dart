import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class WorksPage extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final bool noScroll;

  const WorksPage(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<WorksPage> createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
          MoonTabBar(tabController: tabController, tabs: [
            MoonTab(
              label: Text("Illust".tr),
            ),
            MoonTab(
              label: Text("Manga".tr),
            ),
            MoonTab(
              label: Text("Novel".tr),
            ),
          ]).paddingLeft(16).toAlign(Alignment.topLeft),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.ILLUST,
                  noScroll: widget.noScroll,
                ),
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.MANGA,
                  noScroll: widget.noScroll,
                ),
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.NOVEL,
                  noScroll: widget.noScroll,
                ),
              ],
            ),
          )
        ],
    );
  }
}

class WorkContent extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final bool noScroll;

  const WorkContent(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<WorkContent> createState() => _WorkContentState();
}

class _WorkContentState extends State<WorkContent> {
  @override
  void dispose() {
    super.dispose();
    if (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA) {
      Get.delete<ListIllustController>(
          tag: "works_${widget.type.name}_${widget.id}");
    } else {
      Get.delete<ListNovelController>(
          tag: "works_${widget.type.name}_${widget.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA) {
      // ignore: unused_local_variable
      ListIllustController controller = Get.put(
          ListIllustController(
              id: widget.id.toString(),
              controllerType: ListType.works,
              type: widget.type),
          tag: "works_${widget.type.name}_${widget.id}");
      return ImageWaterfall(
          controllerTag: "works_${widget.type.name}_${widget.id}",
          noScroll: widget.noScroll);
    } else {
      // ignore: unused_local_variable
      ListNovelController controller = Get.put(
          ListNovelController(
              id: widget.id.toString(), controllerType: ListType.works),
          tag: "works_${widget.type.name}_${widget.id}");
      return NovelList(
          controllerTag: "works_${widget.type.name}_${widget.id}",
          noScroll: widget.noScroll);
    }
  }
}
