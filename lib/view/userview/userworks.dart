import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/view/imageview/imagewaterfall.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class WorksPage extends StatefulWidget {
  final int id;
  final ArtworkType type;

  const WorksPage({super.key, required this.id, required this.type});

  @override
  State<WorksPage> createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  @override
  Widget build(BuildContext context) {
    MTab mtab = Get.put(MTab(), tag: "works_${widget.id}");
    return Obx(() {
      return Column(
        children: [
          TabList(
            index: mtab.index.value,
            children: [
              TabButton(
                child: Text("Illust".tr),
                onPressed: () {
                  mtab.index.value = 0;
                },
              ),
              TabButton(
                child: Text("Manga".tr),
                onPressed: () {
                  mtab.index.value = 1;
                },
              ),
              TabButton(
                child: Text("Novel".tr),
                onPressed: () {
                  mtab.index.value = 2;
                },
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: mtab.index.value,
              children: [
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.ILLUST,
                ),
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.MANGA,
                ),
                WorkContent(
                  id: widget.id,
                  type: ArtworkType.NOVEL,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class WorkContent extends StatefulWidget {
  final int id;
  final ArtworkType type;

  const WorkContent({super.key, required this.id, required this.type});

  @override
  State<WorkContent> createState() => _WorkContentState();
}

class _WorkContentState extends State<WorkContent> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA) {
      // ignore: unused_local_variable
      ListIllustController controller = Get.put(
          ListIllustController(
              controllerType: ListType.works, type: widget.type),
          tag: "works_${widget.type.name}_${widget.id}");
      return ImageWaterfall(
          controllerTag: "works_${widget.type.name}_${widget.id}");
    } else {
      Get.put(ListNovelController(controllerType: ListType.works),
          tag: "works_${widget.type.name}_${widget.id}");
      return NovelList(controllerTag: "works_${widget.type.name}_${widget.id}");
    }
  }
}
