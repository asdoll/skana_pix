import 'dart:math';

import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;
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
    ListNovelController controller =
        Get.find<ListNovelController>(tag: widget.controllerTag);
    ScrollController localScrollController = ScrollController();
    return Obx(
      () {
        return controller.loadingState.value == LoadingState.loading &&
                controller.novels.isEmpty
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
                        crossAxisCount: controller.novels.isEmpty
                            ? 1
                            : max(1, (context.width / 400).floor()),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (controller.error.isNotEmpty &&
                              controller.novels.isEmpty) {
                            return Center(
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
                            );
                          }
                          if (controller.novels.isEmpty) {
                            if (!controller.isFirstLoading.value &&
                                controller.loadingState.value !=
                                    LoadingState.loading) {
                              return Container();
                            }
                          }
                          if (index == controller.novels.length) {
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
                          return NovelCard(index, widget.controllerTag);
                        },
                        childCount: controller.novels.length + 1,
                      ),
                    ).sliverPadding(EdgeInsetsGeometry.only(top: 8)),
                    if (!controller.noNextPage)
                      buildLoadMoreIndicator(
                          controller.loadingState.value, controller.nextPage),
                    if (controller.novels.length < 10)
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
