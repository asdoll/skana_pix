import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/view/userview/userlist.dart';

class FollowList extends StatefulWidget {
  final String id;
  final bool isNovel;
  final bool setAppBar;
  final bool isMe;

  const FollowList(
      {super.key,
      required this.id,
      this.isNovel = false,
      this.setAppBar = false,
      this.isMe = false});

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListUserController controller = Get.put(
        ListUserController(
            userListType:
                widget.isMe ? UserListType.myfollowing : UserListType.following,
            id: widget.id),
        tag: "${widget.isMe ? "myfollowing" : widget.id}userlist");

    return Scaffold(
      headers: [
        if (widget.setAppBar)
          AppBar(
            title: Text(widget.isMe ? "My Follow".tr : "Following".tr),
          ),
        if (widget.setAppBar) const Divider()
      ],
      child: UserList(
          controllerTag: "${widget.isMe ? "myfollowing" : widget.id}userlist"),
    );
  }
}
