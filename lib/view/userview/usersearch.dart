import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
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
  SearchOptions searchOptions = SearchOptions();

  @override
  Widget build(BuildContext context) {
    ListUserController controller = Get.put(
        ListUserController(userListType: UserListType.search),
        tag: "search_${widget.word}");
    controller.id = widget.word;
    return Scaffold(
      headers: [
        AppBar(
          title: Text(
            widget.translatedName.isEmpty ? widget.word : widget.translatedName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider()
      ],
      child: UserList(controllerTag: "search_${widget.word}"),
    );
  }
}
