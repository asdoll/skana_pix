import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class NovelList extends StatefulWidget {
  final String controllerTag;
  final bool noScroll;
  const NovelList(
      {super.key, required this.controllerTag, this.noScroll = false});

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
    ScrollController localScrollController = ScrollController();
    return EasyRefresh(
      controller: refreshController,
      refreshOnStart: controller.novels.isEmpty,
      scrollController:
          widget.noScroll ? localScrollController : globalScrollController,
      onRefresh: controller.reset,
      onLoad: controller.noNextPage ? null : controller.nextPage,
      header: DefaultHeaderFooter.header(context),
      refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
      footer:
          controller.noNextPage ? null : DefaultHeaderFooter.footer(context),
      child: Obx(
        () {
          return WaterfallFlow.builder(
            padding: const EdgeInsets.only(top: 8),
            controller: widget.noScroll
                ? localScrollController
                : globalScrollController,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.novels.isEmpty
                  ? 1
                  : max(1, (context.width / 400).floor()),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (controller.error != null &&
                  controller.error!.isNotEmpty &&
                  controller.novels.isEmpty) {
                return Center(
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
                );
              }
              if (controller.novels.isEmpty) {
                if (!controller.isFirstLoading.value &&
                    !controller.isLoading.value) {
                  return emptyPlaceholder(context);
                }
              }
              if (index == controller.novels.length) {
                return Container();
              }
              return NovelCard(index, widget.controllerTag);
            },
            itemCount: controller.novels.length + 1,
          );
        },
      ),
    );
  }
}
