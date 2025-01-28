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
                  feedIllustController.reset();
                }),
            TabButton(
                child: Text("Public".tr),
                onPressed: () {
                  feedIllustController.restrict.value = "public";
                  setState(() {
                    tab = 1;
                  });
                  feedIllustController.reset();
                }),
            TabButton(
                child: Text("Private".tr),
                onPressed: () {
                  feedIllustController.restrict.value = "private";
                  setState(() {
                    tab = 2;
                  });
                  feedIllustController.reset();
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
                  feedNovelController.reset();
                }),
            TabButton(
                child: Text("Public".tr),
                onPressed: () {
                  feedNovelController.restrict.value = "public";
                  setState(() {
                    tab = 1;
                  });
                  feedNovelController.reset();
                }),
            TabButton(
                child: Text("Private".tr),
                onPressed: () {
                  feedNovelController.restrict.value = "private";
                  setState(() {
                    tab = 2;
                  });
                  feedNovelController.reset();
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
