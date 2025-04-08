import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

import '../model/worktypes.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoonTabBar(
            tabController: tabController,
            onTabChanged: (value) {
              homeController.workIndex.value = value;
              homeController.tagIndex.value = 0;
              homeController.dateTime.value = null;
            },
            tabs: [
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
              _OneRankingIllustPage(),
              _OneRankingMangaPage(),
              _OneRankingNovelPage(),
            ],
          ),
        )
      ],
    );
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
    // ignore: unused_local_variable
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.ranking, type: ArtworkType.ILLUST),
        tag: "rankingIllust");
    return ImageWaterfall(controllerTag: "rankingIllust");
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
    // ignore: unused_local_variable
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.ranking, type: ArtworkType.MANGA),
        tag: "rankingManga");
    return ImageWaterfall(controllerTag: "rankingManga");
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
    return NovelList(controllerTag: "rankingNovel");
  }
}
