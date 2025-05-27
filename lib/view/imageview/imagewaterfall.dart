import 'dart:math';

import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/imagecard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/loading_indicator.dart';
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
    controller.reset();
    ScrollController localScrollController = ScrollController();
    return Obx(
      () {
        return controller.loadingState.value == LoadingState.loading &&
                controller.illusts.isEmpty
            ? progressIndicator(context)
            : CustomScrollView(
                physics: BouncingScrollPhysics(),
                controller: widget.noScroll
                    ? localScrollController
                    : globalScrollController,
                slivers: [
                    CupertinoSliverRefreshControl(
                      refreshTriggerPullDistance: 70,
                      onRefresh: controller.reset,
                      builder: buildRefreshIndicator,
                    ),
                    SliverWaterfallFlow(
                      gridDelegate:
                          SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: controller.illusts.isEmpty
                            ? 1
                            : max(2, (context.width / 200).floor()),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (controller.error.isNotEmpty &&
                              controller.illusts.isEmpty) {
                            return SizedBox(
                                height: context.height / 1.5,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text("Error".tr)
                                          .h2()
                                          .paddingTop(context.height / 4),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      filledButton(
                                        onPressed: () {
                                          controller.reset();
                                        },
                                        label: "Retry".tr,
                                      )
                                    ],
                                  ),
                                ));
                          }
                          if (controller.illusts.isEmpty) {
                            if (!controller.isFirstLoading.value &&
                                controller.loadingState.value !=
                                    LoadingState.loading) {
                              return emptyPlaceholder(context);
                            }
                          }
                          if (index == controller.illusts.length) {
                            if (!controller.noNextPage &&
                                controller.loadingState.value !=
                                    LoadingState.loading &&
                                controller.loadingState.value !=
                                    LoadingState.noMore) {
                              Future.delayed(Duration(milliseconds: 100), () {
                                controller.nextPage();
                              });
                            }
                            return Container();
                          }
                          return IllustCard(
                              controllerTag: widget.controllerTag,
                              index: index,
                              showMangaBadage: controller.showMangaBadage);
                        },
                        childCount: controller.illusts.length + 1,
                      ),
                    ).sliverPaddingAll(8),
                    if (!controller.noNextPage)
                      buildLoadMoreIndicator(
                          controller.loadingState.value, controller.nextPage),
                    if (controller.illusts.length < 20)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: Get.height,
                        ),
                      ),
                  ]);
      },
    );
  }
}
