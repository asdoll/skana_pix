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
  final bool noScroll;

  const WorksPage(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<WorksPage> createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<MTab>(tag: "works_${widget.id}");
  }

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
            child: (mtab.index.value == 0)
                ? WorkContent(
                    id: widget.id,
                    type: ArtworkType.ILLUST,
                    noScroll: widget.noScroll,
                  )
                : (mtab.index.value == 1)
                    ? WorkContentManga(
                        id: widget.id,
                        noScroll: widget.noScroll,
                      )
                    : WorkContent(
                        id: widget.id,
                        type: ArtworkType.NOVEL,
                        noScroll: widget.noScroll,
                      ),
          ),
        ],
      );
    });
  }
}

class WorkContentManga extends StatelessWidget {
  final int id;
  final bool noScroll;
  const WorkContentManga({super.key, required this.id, this.noScroll = false});

  @override
  Widget build(BuildContext context) {
    return WorkContent(
      id: id,
      type: ArtworkType.MANGA,
      noScroll: noScroll,
    );
  }
}

class WorkContent extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final bool noScroll;

  const WorkContent(
      {super.key, required this.id, required this.type, this.noScroll = false});

  @override
  State<WorkContent> createState() => _WorkContentState();
}

class _WorkContentState extends State<WorkContent> {
  @override
  void dispose() {
    super.dispose();
    if (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA) {
      Get.delete<ListIllustController>(
          tag: "works_${widget.type.name}_${widget.id}");
    } else {
      Get.delete<ListNovelController>(
          tag: "works_${widget.type.name}_${widget.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA) {
      // ignore: unused_local_variable
      ListIllustController controller = Get.put(
          ListIllustController(
              id: widget.id.toString(),
              controllerType: ListType.works,
              type: widget.type),
          tag: "works_${widget.type.name}_${widget.id}");
      return ImageWaterfall(
          controllerTag: "works_${widget.type.name}_${widget.id}",
          noScroll: widget.noScroll);
    } else {
      // ignore: unused_local_variable
      ListNovelController controller = Get.put(
          ListNovelController(
              id: widget.id.toString(), controllerType: ListType.works),
          tag: "works_${widget.type.name}_${widget.id}");
      return NovelList(
          controllerTag: "works_${widget.type.name}_${widget.id}",
          noScroll: widget.noScroll);
    }
  }
}
