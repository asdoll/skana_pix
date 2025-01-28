import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class NovelList extends StatefulWidget {
  final String controllerTag;
  const NovelList({super.key, required this.controllerTag});

  @override
  State<NovelList> createState() => _NovelListState();
}

class _NovelListState extends State<NovelList> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    ListNovelController controller =
        Get.find<ListNovelController>(tag: widget.controllerTag);
    controller.refreshController = refreshController;
    return EasyRefresh(
      controller: refreshController,
      scrollController: globalScrollController,
      refreshOnStart: true,
      onRefresh: controller.reset,
      callRefreshOverOffset: 10,
      onLoad: controller.noNextPage ? null : controller.nextPage,
      header: DefaultHeaderFooter.header(context),
      footer:
          controller.noNextPage ? null : DefaultHeaderFooter.footer(context),
      child: Obx(
        () {
          if (controller.error != null &&
              controller.error!.isNotEmpty &&
              controller.novels.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text("Error".tr),
                  Button.primary(
                    onPressed: () {
                      refreshController.callRefresh();
                    },
                    child: Text("Retry".tr),
                  )
                ],
              ),
            );
          }
          if (controller.novels.isEmpty) {
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
                  context.orientation == Orientation.portrait ? 1 : 2,
            ),
            itemBuilder: (BuildContext context, int index) {
              return NovelCard(index, widget.controllerTag);
            },
            itemCount: controller.novels.length,
          );
        },
      ),
    );
  }
}
