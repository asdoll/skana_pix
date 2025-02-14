import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/usercard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class UserList extends StatefulWidget {
  final String controllerTag;
  final bool noScroll;
  const UserList({super.key, required this.controllerTag, this.noScroll = false});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListUserController>(tag: widget.controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    ListUserController controller =
        Get.find<ListUserController>(tag: widget.controllerTag);
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = easyRefreshController;
    ScrollController localScrollController = ScrollController();
    return Obx(() => 
            Expanded(
                child: EasyRefresh(
              controller: easyRefreshController,
              scrollController: widget.noScroll ? localScrollController : globalScrollController,
              header: DefaultHeaderFooter.header(context),
              footer: DefaultHeaderFooter.footer(context),
              refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
              onLoad: () => controller.nextPage(),
              onRefresh: () => controller.reset(),
              refreshOnStart: true,
              child: CustomScrollView(
                controller: widget.noScroll ? localScrollController : globalScrollController,
                slivers: [
                  SliverWaterfallFlow(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return PainterCard(
                        user: controller.users[index],
                      );
                    }, childCount: controller.users.length),
                    gridDelegate:
                        const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 600),
                  )
                ],
              ),
            ))
          );
  }
}
