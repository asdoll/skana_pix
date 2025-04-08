import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagecard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ImageWaterfall extends StatefulWidget {
  final String controllerTag;
  final bool noScroll;

  const ImageWaterfall(
      {super.key, required this.controllerTag, this.noScroll = false});

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
    ScrollController localScrollController = ScrollController();
    return EasyRefresh(
      controller: refreshController,
      scrollController:
          widget.noScroll ? localScrollController : globalScrollController,
      refreshOnStart: controller.illusts.isEmpty,
      onRefresh: controller.reset,
      onLoad: controller.noNextPage ? null : controller.nextPage,
      header: DefaultHeaderFooter.header(context),
      refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
      callLoadOverOffset: controller.callLoadOverOffset,
      footer:
          controller.noNextPage ? null : DefaultHeaderFooter.footer(context),
      child: Obx(
        () {
          return WaterfallFlow.builder(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            controller: widget.noScroll
                ? localScrollController
                : globalScrollController,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.illusts.isEmpty
                  ? 1
                  : max(2, (context.width / 200).floor()),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (controller.error.isNotEmpty && controller.illusts.isEmpty) {
                return SizedBox(
                    height: context.height / 1.5,
                    child: Center(
                      child: Column(
                        children: [
                          Text("Error".tr).h2().paddingTop(context.height / 4),
                          SizedBox(
                            height: 10,
                          ),
                          filledButton(
                            onPressed: () {
                              refreshController.callRefresh();
                            },
                            label: "Retry".tr,
                          )
                        ],
                      ),
                    ));
              }
              if (controller.illusts.isEmpty) {
                if (!controller.isFirstLoading.value &&
                    !controller.isLoading.value) {
                  return emptyPlaceholder(context);
                }
              }
              if (index == controller.illusts.length) {
                return Container();
              }
              return IllustCard(
                  controllerTag: widget.controllerTag,
                  index: index,
                  showMangaBadage: controller.showMangaBadage);
            },
            itemCount: controller.illusts.length + 1,
          );
        },
      ),
    );
  }
}
