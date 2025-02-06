import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
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

class _FollowListState extends State<FollowList> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(tag: "${widget.isMe ? "myfollowing" : widget.id}userlist");
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
    // ignore: unused_local_variable
    ListUserController controller = Get.put(
        ListUserController(userListType: userListType, id: widget.id),
        tag: "${widget.isMe ? "myfollowing" : widget.id}userlist");

    return Scaffold(
      headers: [
        if (widget.setAppBar)
          AppBar(
            title: Text(widget.isMyPixiv ? "My Pixiv".tr : "Following".tr),
          ),
        if (widget.setAppBar) const Divider()
      ],
      child: UserList(
          controllerTag:
               "${widget.isMe ? "myfollowing" : widget.id}userlist"),
    );
  }
}
