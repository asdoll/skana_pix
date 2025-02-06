import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
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
    return Obx(() {
      return Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            child: TabList(index: homeController.workIndex.value, children: [
              TabButton(
                child: Text("Illust".tr),
                onPressed: () {
                  homeController.workIndex.value = 0;
                  homeController.tagIndex.value = 0;
                  homeController.dateTime.value = null;
                },
              ),
              TabButton(
                child: Text("Manga".tr),
                onPressed: () {
                  homeController.workIndex.value = 1;
                  homeController.tagIndex.value = 0;
                  homeController.dateTime.value = null;
                },
              ),
              TabButton(
                child: Text("Novel".tr),
                onPressed: () {
                  homeController.workIndex.value = 2;
                  homeController.tagIndex.value = 0;
                  homeController.dateTime.value = null;
                },
              ),
            ]),
          ),
          (homeController.workIndex.value == 0)
              ? Expanded(child: _OneRankingIllustPage())
              : Container(),
          (homeController.workIndex.value == 1)
              ? Expanded(child: _OneRankingMangaPage())
              : Container(),
          (homeController.workIndex.value == 2)
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
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(
        tag: "rankingIllust");
  }

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
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(
        tag: "rankingManga");
  }

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
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(
        tag: "rankingNovel");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListNovelController controller = Get.put(
        ListNovelController(controllerType: ListType.ranking),
        tag: "rankingNovel");
    return NovelList(controllerTag: "rankingNovel");
  }
}
