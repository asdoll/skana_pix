import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/userview/userlist.dart';

class FollowList extends StatefulWidget {
  final String id;
  final bool isNovel;
  final bool setAppBar;
  final bool isMe;
  final bool isMyPixiv;

  const FollowList(
      {super.key,
      required this.id,
      this.isNovel = false,
      this.setAppBar = false,
      this.isMe = false,
      this.isMyPixiv = false});

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserListType userListType;
    if (widget.isMe) {
      if (widget.isMyPixiv) {
        userListType = UserListType.mymypixiv;
      } else {
        userListType = UserListType.myfollowing;
      }
    } else {
      if (widget.isMyPixiv) {
        userListType = UserListType.usermypixiv;
      } else {
        userListType = UserListType.following;
      }
    }

    return Scaffold(
      appBar: (widget.setAppBar
          ? appBar(title: widget.isMyPixiv ? "My Pixiv".tr : "Following".tr)
          : null),
      body: widget.isMe
          ? Column(children: [
              MoonTabBar(
                tabController: tabController,
                tabs: [
                  MoonTab(
                    label: Text("Public".tr),
                  ),
                  MoonTab(
                    label: Text("Private".tr),
                  ),
                  MoonTab(
                    label: Text("My Pixiv".tr),
                  ),
                ],
              ).paddingLeft(16).toAlign(Alignment.topLeft),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    FollowTabs(
                      userListType: userListType,
                      id: widget.id,
                      type: 'public',
                      isMe: widget.isMe,
                      isMyPixiv: widget.isMyPixiv,
                    ),
                    FollowTabs(
                      userListType: userListType,
                      id: widget.id,
                      type: 'private',
                      isMe: widget.isMe,
                      isMyPixiv: widget.isMyPixiv,
                    ),
                    FollowTabs(
                      userListType: userListType,
                      id: widget.id,
                      type: 'mypixiv',
                      isMe: widget.isMe,
                      isMyPixiv: widget.isMyPixiv,
                    ),
                  ],
                ),
              )
            ])
          : Builder(builder: (context) {
              // ignore: unused_local_variable
              ListUserController controller = Get.put(
                  ListUserController(userListType: userListType, id: widget.id),
                  tag: "${widget.id}userlist_${userListType.name}");
              return UserList(
                  controllerTag: "${widget.id}userlist_${userListType.name}",
                  noScroll: true);
            }),
    );
  }
}

class FollowTabs extends StatefulWidget {
  final UserListType userListType;
  final String type;
  final String id;
  final bool isMe;
  final bool isMyPixiv;
  const FollowTabs(
      {super.key,
      required this.type,
      required this.userListType,
      required this.id,
      required this.isMe,
      required this.isMyPixiv});
  @override
  State<FollowTabs> createState() => _FollowTabsState();
}

class _FollowTabsState extends State<FollowTabs> {
  @override
  void dispose() {
    super.dispose();
    if (!widget.isMe) {
      Get.delete<ListUserController>(
          tag: "${widget.id}userlist_${widget.type}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListUserController controller = Get.put(
        ListUserController(
            userListType: widget.isMyPixiv
                ? UserListType.mymypixiv
                : widget.userListType,
            id: widget.id,
            restrict: widget.type),
        tag:
            "${widget.isMe ? "myfollowing" : widget.id}userlist_${widget.type}");
    return UserList(
        controllerTag:
            "${widget.isMe ? "myfollowing" : widget.id}userlist_${widget.type}",
        noScroll: !widget.isMe);
  }
}
