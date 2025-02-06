import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class FeedIllust extends StatefulWidget {
  const FeedIllust({super.key});

  @override
  State<FeedIllust> createState() => _FeedIllustState();
}

class _FeedIllustState extends State<FeedIllust> {
  int tab = 0;

  @override
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(tag: "feedillust");
  }

  @override
  Widget build(BuildContext context) {
    ListIllustController feedIllustController = Get.put(
        ListIllustController(
            controllerType: ListType.feed, type: ArtworkType.ILLUST),
        tag: "feedillust");
    return Column(
      children: [
        TabList(
          index: tab,
          children: [
            TabButton(
                child: Text("All".tr),
                onPressed: () {
                  feedIllustController.restrict.value = "all";
                  setState(() {
                    tab = 0;
                  });
                  feedIllustController.refreshController?.callRefresh();
                }),
            TabButton(
                child: Text("Public".tr),
                onPressed: () {
                  feedIllustController.restrict.value = "public";
                  setState(() {
                    tab = 1;
                  });
                  feedIllustController.refreshController?.callRefresh();
                }),
            TabButton(
                child: Text("Private".tr),
                onPressed: () {
                  feedIllustController.restrict.value = "private";
                  setState(() {
                    tab = 2;
                  });
                  feedIllustController.refreshController?.callRefresh();
                })
          ],
        ),
        Expanded(
          child: ImageWaterfall(controllerTag: "feedillust"),
        ),
      ],
    );
  }
}

class FeedNovel extends StatefulWidget {
  const FeedNovel({super.key});

  @override
  State<FeedNovel> createState() => _FeedNovelState();
}

class _FeedNovelState extends State<FeedNovel> {
  int tab = 0;
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(tag: "feednovel");
  }

  @override
  Widget build(BuildContext context) {
    ListNovelController feedNovelController = Get.put(
        ListNovelController(controllerType: ListType.feed),
        tag: "feednovel");

    return Column(
      children: [
        TabList(
          index: tab,
          children: [
            TabButton(
                child: Text("All".tr),
                onPressed: () {
                  feedNovelController.restrict.value = "all";
                  setState(() {
                    tab = 0;
                  });
                  feedNovelController.refreshController?.callRefresh();
                }),
            TabButton(
                child: Text("Public".tr),
                onPressed: () {
                  feedNovelController.restrict.value = "public";
                  setState(() {
                    tab = 1;
                  });
                  feedNovelController.refreshController?.callRefresh();
                }),
            TabButton(
                child: Text("Private".tr),
                onPressed: () {
                  feedNovelController.restrict.value = "private";
                  setState(() {
                    tab = 2;
                  });
                  feedNovelController.refreshController?.callRefresh();
                }),
          ],
        ),
        Expanded(
          child: NovelList(controllerTag: "feednovel"),
        ),
      ],
    );
  }
}
