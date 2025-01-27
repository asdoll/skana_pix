import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart' show kToolbarHeight;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/ranking_controller.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../model/worktypes.dart';
import '../componentwidgets/imagecard.dart';
import '../componentwidgets/novelcard.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    RankingPageController controller = Get.put(RankingPageController());

    return Obx(() {
      return Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: AppBar(
              leading: [CommonBackArea()],
              title: Tabs(
                index: controller.index.value,
                tabs: [
                  Text("Illust".tr),
                  Text("Manga".tr),
                  Text("Novel".tr),
                ],
                onChanged: (i) {
                  controller.setIndex(i);
                },
              ),
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Select<int>(
                  itemBuilder: (context, item) {
                    return Text(rankTagsMap[controller.tagList[item]] ??
                        controller.tagList[item]);
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    controller.tagIndex.value = value;
                  },
                  value: controller.tagIndex.value,
                  children: [
                    SelectGroup(
                      children: [
                        for (var i = 0; i < controller.tagList.length; i++)
                          SelectItemButton(
                            value: i,
                            child: Text(controller.tagList[i]),
                          ),
                      ],
                    ),
                  ]),
              DatePicker(
                value: controller.dateTime.value,
                mode: PromptMode.dialog,
                stateBuilder: (date) {
                  if (date.isBefore(DateTime(2007, 9))) {
                    return DateState.disabled;
                  } //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
                  if (date.isAfter(DateTime.now())) {
                    return DateState.disabled;
                  }
                  return DateState.enabled;
                },
                onChanged: (value) {
                  if (value == null) return;
                  controller.dateTime.value = value;
                  controller.dateTime.refresh();
                },
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              if (controller.index.value == 0)
                SliverToBoxAdapter(
                  child: _OneRankingIllustPage(
                      controller.tagList[controller.tagIndex.value],
                      ArtworkType.ILLUST,
                      controller.dateTime.value.toString(),
                      key: Key(controller.tagList[controller.tagIndex.value])),
                ),
              if (controller.index.value == 1)
                SliverToBoxAdapter(
                  child: _OneRankingIllustPage(
                      controller.tagList[controller.tagIndex.value],
                      ArtworkType.MANGA,
                      controller.dateTime.value.toString(),
                      key: Key(controller.tagList[controller.tagIndex.value])),
                ),
              if (controller.index.value == 2)
                SliverToBoxAdapter(
                  child: _OneRankingNovelPage(
                      controller.tagList[controller.tagIndex.value],
                      ArtworkType.NOVEL,
                      controller.dateTime.value.toString(),
                      key: Key(controller.tagList[controller.tagIndex.value])),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _OneRankingIllustPage extends StatefulWidget {
  const _OneRankingIllustPage(this.tag, this.awType, this.dateTime,
      {super.key});

  final String tag;
  final ArtworkType awType;
  final String dateTime;
  @override
  _OneRankingIllustPageState createState() => _OneRankingIllustPageState();
}

class _OneRankingIllustPageState extends State<_OneRankingIllustPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    RankingIllustController controller = Get.put(
        RankingIllustController(refreshController, widget.tag,
            type: widget.awType, dateTime: widget.dateTime),
        tag: "rankingIllust_${widget.tag}");

    return EasyRefresh.builder(
      controller: refreshController,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      onRefresh: () {
        controller.reset();
      },
      onLoad: () {
        controller.nextPage();
      },
      childBuilder: (context, physics) => WaterfallFlow.builder(
        physics: physics,
        padding: EdgeInsets.all(5.0),
        itemCount: controller.illusts.length,
        itemBuilder: (context, index) {
          return IllustCard(
            controllerTag: "rankingIllust_${widget.tag}",
            index: index,
            type: widget.awType,
            showMangaBadage: true,
          );
        },
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.orientation == Orientation.portrait ? 2 : 4,
        ),
      ),
    );
  }
}

class _OneRankingNovelPage extends StatefulWidget {
  const _OneRankingNovelPage(this.tag, this.awType, this.dateTime,
      {super.key});

  final String tag;
  final ArtworkType awType;
  final String dateTime;

  @override
  _OneRankingNovelPageState createState() => _OneRankingNovelPageState();
}

class _OneRankingNovelPageState extends State<_OneRankingNovelPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    RankingNovelController controller = Get.put(
        RankingNovelController(refreshController, widget.tag, dateTime: widget.dateTime),
        tag: "rankingNovel_${widget.tag}");
    return EasyRefresh.builder(
      controller: refreshController,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      onRefresh: () {
        controller.reset();
      },
      onLoad: () {
        controller.nextPage();
      },
      childBuilder: (context, physics) => ListView.builder(
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return NovelCard(index,"rankingNovel_${widget.tag}");
              },
              itemCount: controller.novels.length),
    );
  }
}
