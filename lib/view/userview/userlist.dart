import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/usercard.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class UserList extends StatefulWidget {
  final String controllerTag;
  const UserList({super.key, required this.controllerTag});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    ListUserController controller =
        Get.find<ListUserController>(tag: widget.controllerTag);
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = easyRefreshController;
    MTab tab = Get.put(MTab(), tag: widget.controllerTag);
    return EasyRefresh(
      controller: easyRefreshController,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      onLoad: () => controller.nextPage(),
      onRefresh: () => controller.reset(),
      refreshOnStart: true,
      child: CustomScrollView(
        slivers: [
          if (controller.userListType == UserListType.myfollowing)
            SliverToBoxAdapter(
              child: Tabs(
                tabs: [
                  Text("public".tr),
                  Text("private".tr),
                  Text("My Pixiv".tr)
                ],
                index: tab.index.value,
                onChanged: (index) {
                  tab.index.value = index;
                  controller.restrict.value = index == 0
                      ? "public"
                      : index == 1
                          ? "private"
                          : "mypixiv";
                  controller.refreshController?.callRefresh();
                },
              ),
            ),
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
    );
  }
}
