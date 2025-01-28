import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class RecomImagesPage extends StatefulWidget {
  final ArtworkType type;

  const RecomImagesPage(this.type, {super.key});
  @override
  State<RecomImagesPage> createState() => _RecomImagesPageState();
}

class _RecomImagesPageState extends State<RecomImagesPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController recomImagesController = Get.put(
        ListIllustController(controllerType: ListType.recom, type: widget.type),
        tag: "recom_${widget.type.name}");
    return ImageWaterfall(controllerTag: "recom_${widget.type.name}");
  }
}

class RecomNovelsPage extends StatefulWidget {
  const RecomNovelsPage({super.key});
  @override
  State<RecomNovelsPage> createState() => _RecomNovelsPageState();
}

class _RecomNovelsPageState extends State<RecomNovelsPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListNovelController recomNovelsController = Get.put(
        ListNovelController(controllerType: ListType.recom),
        tag: "recom_novels");
    return NovelList(controllerTag: "recom_novels");
  }
}
