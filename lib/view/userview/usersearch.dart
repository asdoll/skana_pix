import 'package:flutter/material.dart';
import 'package:skana_pix/componentwidgets/gotop.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/userview/userlist.dart';

class UserResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const UserResultPage(
      {super.key, required this.word, this.translatedName = ''});

  @override
  State<UserResultPage> createState() => _UserResultPageState();
}

class _UserResultPageState extends State<UserResultPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListUserController>(tag: "search_${widget.word}");
  }

  @override
  Widget build(BuildContext context) {
    ListUserController controller = Get.put(
        ListUserController(userListType: UserListType.search),
        tag: "search_${widget.word}");
    controller.id = widget.word;
    return Scaffold(
      appBar: appBar(
        title:
            widget.translatedName.isEmpty ? widget.word : widget.translatedName,
      ),
      floatingActionButton: const GoTop(),
      body: UserList(controllerTag: "search_${widget.word}"),
    );
  }
}
