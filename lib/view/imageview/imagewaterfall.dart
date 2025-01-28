import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagecard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ImageWaterfall extends StatefulWidget {
  final String controllerTag;

  const ImageWaterfall({super.key, required this.controllerTag});

  @override
  State<ImageWaterfall> createState() => _ImageWaterfallState();
}

class _ImageWaterfallState extends State<ImageWaterfall> {
  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<ListIllustController>(tag: widget.controllerTag);
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = refreshController;
    return EasyRefresh(
      controller: refreshController,
      scrollController: globalScrollController,
      refreshOnStart: true,
      onRefresh: controller.reset,
      onLoad: controller.noNextPage ? null : controller.nextPage,
      header: DefaultHeaderFooter.header(context),
      callLoadOverOffset: controller.callLoadOverOffset,
      footer: controller.noNextPage
          ? null
          : DefaultHeaderFooter.footer(context),
      child: Obx(
        () {
          if (controller.error.isNotEmpty && controller.illusts.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text("Error".tr),
                  Button.primary(
                    onPressed: () {
                      controller.reset();
                    },
                    child: Text("Retry".tr),
                  )
                ],
              ),
            );
          }
          if (controller.illusts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('[ ]', style: Theme.of(context).typography.h1),
              ),
            );
          }
          return WaterfallFlow.builder(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  context.orientation == Orientation.portrait ? 2 : 4,
            ),
            itemBuilder: (BuildContext context, int index) {
              return IllustCard(
                  controllerTag: widget.controllerTag,
                  index: index,
                  showMangaBadage: controller.showMangaBadage);
            },
            itemCount: controller.illusts.length,
          );
        },
      ),
    );
  }
}
