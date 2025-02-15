import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class RecomIllustsPage extends StatefulWidget {
  const RecomIllustsPage({super.key});
  @override
  State<RecomIllustsPage> createState() => _RecomIllustsPageState();
}

class _RecomIllustsPageState extends State<RecomIllustsPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(
        tag: "recom_illust");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController recomImagesController = Get.put(
        ListIllustController(controllerType: ListType.recom, type: ArtworkType.ILLUST),
        tag: "recom_illust");
    return ImageWaterfall(controllerTag: "recom_illust");
  }
}

class RecomMangasPage extends StatefulWidget {
  const RecomMangasPage({super.key});
  @override
  State<RecomMangasPage> createState() => _RecomMangasPageState();
}

class _RecomMangasPageState extends State<RecomMangasPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(
        tag: "recom_manga");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController recomImagesController = Get.put(
        ListIllustController(controllerType: ListType.recom, type: ArtworkType.MANGA),
        tag: "recom_manga");
    return ImageWaterfall(controllerTag: "recom_manga");
  }
}

class RecomNovelsPage extends StatefulWidget {
  const RecomNovelsPage({super.key});
  @override
  State<RecomNovelsPage> createState() => _RecomNovelsPageState();
}

class _RecomNovelsPageState extends State<RecomNovelsPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(
        tag: "recom_novels");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListNovelController recomNovelsController = Get.put(
        ListNovelController(controllerType: ListType.recom),
        tag: "recom_novels");
    return NovelList(controllerTag: "recom_novels");
  }
}
