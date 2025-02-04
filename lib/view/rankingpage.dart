import 'package:flutter/material.dart' show kToolbarHeight;
import 'package:shadcn_flutter/shadcn_flutter.dart';
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
    controller.init();

    return Obx(() {
      return Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: AppBar(
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
          (controller.index.value == 0)
              ? Expanded(child: _OneRankingIllustPage())
              : Container(),
          (controller.index.value == 1)
              ? Expanded(child: _OneRankingMangaPage())
              : Container(),
          (controller.index.value == 2)
              ? Expanded(child: _OneRankingNovelPage())
              : Container(),
        ],
      );
    });
  }
}

class _OneRankingIllustPage extends StatefulWidget {
  const _OneRankingIllustPage();

  @override
  _OneRankingIllustPageState createState() => _OneRankingIllustPageState();
}

class _OneRankingIllustPageState extends State<_OneRankingIllustPage> {
  @override
  Widget build(BuildContext context) {
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.ranking, type: ArtworkType.ILLUST),
        tag: "rankingIllust");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Select<int>(
                itemBuilder: (context, item) {
                  return Text(
                      rankTagsMap[modeIllust[item]] ?? modeIllust[item]);
                },
                onChanged: (value) {
                  if (value == null) return;
                  controller.tagIndex.value = value;
                  controller.refreshController?.callRefresh();
                },
                value: controller.tagIndex.value,
                children: [
                  SelectGroup(
                    children: [
                      for (var i = 0; i < modeIllust.length; i++)
                        SelectItemButton(
                          value: i,
                          child:
                              Text(rankTagsMap[modeIllust[i]] ?? modeIllust[i]),
                        ),
                    ],
                  ),
                ]),
            DatePicker(
              placeholder: Text("Date".tr),
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
                controller.refreshController?.callRefresh();
              },
            ),
          ],
        ),
        Expanded(child: ImageWaterfall(controllerTag: "rankingIllust")),
      ],
    );
  }
}

class _OneRankingMangaPage extends StatefulWidget {
  const _OneRankingMangaPage();

  @override
  _OneRankingMangaPageState createState() => _OneRankingMangaPageState();
}

class _OneRankingMangaPageState extends State<_OneRankingMangaPage> {
  @override
  Widget build(BuildContext context) {
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.ranking, type: ArtworkType.MANGA),
        tag: "rankingManga");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Select<int>(
                itemBuilder: (context, item) {
                  return Text(rankTagsMap[modeManga[item]] ?? modeManga[item]);
                },
                onChanged: (value) {
                  if (value == null) return;
                  controller.tagIndex.value = value;
                  controller.refreshController?.callRefresh();
                },
                value: controller.tagIndex.value,
                children: [
                  SelectGroup(
                    children: [
                      for (var i = 0; i < modeManga.length; i++)
                        SelectItemButton(
                          value: i,
                          child:
                              Text(rankTagsMap[modeManga[i]] ?? modeManga[i]),
                        ),
                    ],
                  ),
                ]),
            DatePicker(
              placeholder: Text("Date".tr),
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
                controller.refreshController?.callRefresh();
              },
            ),
          ],
        ),
        Expanded(child: ImageWaterfall(controllerTag: "rankingManga")),
      ],
    );
  }
}

class _OneRankingNovelPage extends StatefulWidget {
  const _OneRankingNovelPage();

  @override
  _OneRankingNovelPageState createState() => _OneRankingNovelPageState();
}

class _OneRankingNovelPageState extends State<_OneRankingNovelPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListNovelController controller = Get.put(
        ListNovelController(controllerType: ListType.ranking),
        tag: "rankingNovel");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Select<int>(
                itemBuilder: (context, item) {
                  return Text(rankTagsMap[modeNovel[item]] ?? modeNovel[item]);
                },
                onChanged: (value) {
                  if (value == null) return;
                  controller.tagIndex.value = value;
                  controller.refreshController?.callRefresh();
                },
                value: controller.tagIndex.value,
                children: [
                  SelectGroup(
                    children: [
                      for (var i = 0; i < modeNovel.length; i++)
                        SelectItemButton(
                          value: i,
                          child:
                              Text(rankTagsMap[modeNovel[i]] ?? modeNovel[i]),
                        ),
                    ],
                  ),
                ]),
            DatePicker(
              value: controller.dateTime.value,
              placeholder: Text("Date".tr),
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
                controller.refreshController?.callRefresh();
              },
            ),
          ],
        ),
        Expanded(child: NovelList(controllerTag: "rankingNovel"))
      ],
    );
  }
}
