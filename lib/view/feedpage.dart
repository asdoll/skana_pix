import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';
import 'package:flutter/material.dart';

class FeedIllust extends StatefulWidget {
  const FeedIllust({super.key});

  @override
  State<FeedIllust> createState() => _FeedIllustState();
}

class _FeedIllustState extends State<FeedIllust>
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
        MoonTabBar(
          tabController: tabController,
          tabs: [
            MoonTab(
              label: Text("All".tr),
            ),
            MoonTab(
              label: Text("Public".tr),
            ),
            MoonTab(
              label: Text("Private".tr),
            )
          ],
        ).paddingLeft(16).toAlign(Alignment.topLeft),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              FeedIllustTab("all"),
              FeedIllustTab("public"),
              FeedIllustTab("private"),
            ],
          ),
        ),
      ],
    );
  }
}

class FeedIllustTab extends StatefulWidget {
  final String type;
  const FeedIllustTab(this.type, {super.key});

  @override
  State<FeedIllustTab> createState() => _FeedIllustTabState();
}

class _FeedIllustTabState extends State<FeedIllustTab> {
  String get type => widget.type;

  @override
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(tag: "feedillust_$type");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController feedIllustController = Get.put(
        ListIllustController(type: ArtworkType.ILLUST, controllerType: ListType.feed, restrict: type),
        tag: "feedillust_$type");
    return ImageWaterfall(controllerTag: "feedillust_$type");
  }
}

class FeedNovel extends StatefulWidget {
  const FeedNovel({super.key});

  @override
  State<FeedNovel> createState() => _FeedNovelState();
}

class _FeedNovelState extends State<FeedNovel> with SingleTickerProviderStateMixin {
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
    Get.delete<ListNovelController>(tag: "feednovel");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoonTabBar(
          tabController: tabController,
          tabs: [
            MoonTab(
              label: Text("All".tr),
            ),
            MoonTab(
              label: Text("Public".tr),
            ),
            MoonTab(
              label: Text("Private".tr),
            )
          ],
        ).paddingLeft(16).toAlign(Alignment.topLeft),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              FeedNovelTab("all"),
              FeedNovelTab("public"),
              FeedNovelTab("private"),
            ],
          ),
        ),
      ],
    );
  }
}

class FeedNovelTab extends StatefulWidget {
  const FeedNovelTab(this.type, {super.key});

  final String type;

  @override
  State<FeedNovelTab> createState() => _FeedNovelTabState();

}

class _FeedNovelTabState extends State<FeedNovelTab> {
  String get type => widget.type;

  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(tag: "feednovel_$type");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListNovelController feedNovelController = Get.put(
        ListNovelController(controllerType: ListType.feed, restrict: type),
        tag: "feednovel_$type");
    return NovelList(controllerTag: "feednovel_$type");
  }
}