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
  void dispose() {
    super.dispose();
    Get.delete<ListUserController>(tag: widget.controllerTag);
    Get.delete<MTab>(tag: widget.controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    ListUserController controller =
        Get.find<ListUserController>(tag: widget.controllerTag);
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = easyRefreshController;
    MTab tab = Get.put(MTab(), tag: widget.controllerTag);
    return Obx(() => Column(
          children: [
            if (controller.userListType == UserListType.myfollowing)
              TabList(
                index: tab.index.value,
                children: [
                  TabButton(
                    child: Text("public".tr),
                    onPressed: () {
                      tab.index.value = 0;
                      controller.restrict.value = "public";
                      controller.refreshController?.callRefresh();
                    },
                  ),
                  TabButton(
                    child: Text("private".tr),
                    onPressed: () {
                      tab.index.value = 1;
                      controller.restrict.value = "private";
                      controller.refreshController?.callRefresh();
                    },
                  ),
                  TabButton(
                    child: Text("My Pixiv".tr),
                    onPressed: () {
                      tab.index.value = 2;
                      controller.restrict.value = "mypixiv";
                      controller.refreshController?.callRefresh();
                    },
                  ),
                ],
              ),
            SizedBox(height: 10),
            Expanded(
                child: EasyRefresh(
              controller: easyRefreshController,
              header: DefaultHeaderFooter.header(context),
              footer: DefaultHeaderFooter.footer(context),
              onLoad: () => controller.nextPage(),
              onRefresh: () => controller.reset(),
              refreshOnStart: true,
              child: CustomScrollView(
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
          ],
        ));
  }
}
