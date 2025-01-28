import 'package:flutter/material.dart' show kToolbarHeight;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

import '../model/worktypes.dart';

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
    // ignore: unused_local_variable
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.ranking,
            type: widget.awType,
            dateTime: widget.dateTime),
        tag: "rankingIllust_${widget.tag}");
    return ImageWaterfall(controllerTag: "rankingIllust_${widget.tag}");
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
    // ignore: unused_local_variable
    ListNovelController controller = Get.put(
        ListNovelController(controllerType: ListType.ranking, dateTime: widget.dateTime),
        tag: "rankingNovel_${widget.tag}");
    return NovelList(controllerTag: "rankingNovel_${widget.tag}");
  }
}

