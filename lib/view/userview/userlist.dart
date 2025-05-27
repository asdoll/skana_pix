import 'dart:math' show max;

import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/usercard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class UserList extends StatefulWidget {
  final String controllerTag;
  final bool noScroll;
  const UserList(
      {super.key, required this.controllerTag, this.noScroll = false});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    ListUserController controller =
        Get.find<ListUserController>(tag: widget.controllerTag);
    ScrollController localScrollController = ScrollController();
    return Obx(
      () => controller.loadingState.value == LoadingState.loading &&
              controller.users.isEmpty
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
                SliverPadding(padding: EdgeInsets.only(top: 4)),
                SliverWaterfallFlow(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (controller.error.isNotEmpty &&
                        controller.users.isEmpty) {
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
                    
                    if (index == controller.users.length) {
                      if (controller.loadingState.value !=
                          LoadingState.loading &&
                          controller.loadingState.value !=
                              LoadingState.noMore) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          controller.nextPage();
                        });
                      }
                      return Container();
                    }
                    return PainterCard(
                      user: controller.users[index],
                    );
                  }, childCount: controller.users.length + 1),
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller.users.isEmpty
                        ? 1
                        : max(1, (context.width / 400).floor()),
                  ),
                ),
                buildLoadMoreIndicator(
                    controller.loadingState.value, controller.nextPage),
                if (controller.users.length < 10)
                  SliverToBoxAdapter(
                    child: SizedBox(height: Get.height),
                  ),
              ],
            ),
    );
  }
}
