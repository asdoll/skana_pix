import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/controller/feed_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../componentwidgets/imagecard.dart';

class FeedIllust extends StatefulWidget {
  const FeedIllust({super.key});

  @override
  State<FeedIllust> createState() => _FeedIllustState();
}

class _FeedIllustState extends State<FeedIllust> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController = EasyRefreshController();
    FeedIllustController feedIllustController = Get.put(
        FeedIllustController(
            type: ArtworkType.ILLUST, refreshController: refreshController),
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
          child: EasyRefresh(
            controller: refreshController,
            onRefresh: feedIllustController.reset,
            onLoad: feedIllustController.nextPage,
            header: DefaultHeaderFooter.header(context),
            footer: DefaultHeaderFooter.footer(context),
            child: Obx(
              () {
                if (feedIllustController.error != null &&
                    feedIllustController.error!.isNotEmpty &&
                    feedIllustController.illusts.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Text("Error".tr),
                        Button.primary(
                          onPressed: () {
                            feedIllustController.reset();
                          },
                          child: Text("Retry".tr),
                        )
                      ],
                    ),
                  );
                }
                if (feedIllustController.illusts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('[ ]', style: Theme.of(context).typography.h1),
                    ),
                  );
                }
                return WaterfallFlow.builder(
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        context.orientation == Orientation.portrait ? 2 : 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return IllustCard(
                        controllerTag: "feedillust", index: index);
                  },
                  itemCount: feedIllustController.illusts.length,
                );
              },
            ),
          ),
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
    EasyRefreshController refreshController = EasyRefreshController();
    FeedNovelController feedNovelController = Get.put(
        FeedNovelController(refreshController: refreshController),
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
          child: EasyRefresh(
            controller: refreshController,
            onRefresh: feedNovelController.reset,
            onLoad: feedNovelController.nextPage,
            header: DefaultHeaderFooter.header(context),
            footer: DefaultHeaderFooter.footer(context),
            child: Obx(
              () {
                if (feedNovelController.error != null &&
                    feedNovelController.error!.isNotEmpty &&
                    feedNovelController.novels.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Text("Error".tr),
                        Button.primary(
                          onPressed: () {
                            feedNovelController.reset();
                          },
                          child: Text("Retry".tr),
                        )
                      ],
                    ),
                  );
                }
                if (feedNovelController.novels.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('[ ]', style: Theme.of(context).typography.h1),
                    ),
                  );
                }
                return WaterfallFlow.builder(
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        context.orientation == Orientation.portrait ? 2 : 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return NovelCard(index, "feednovel");
                  },
                  itemCount: feedNovelController.novels.length,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
