import 'package:flutter/material.dart';
import 'package:skana_pix/model/worktypes.dart';

class UserPage extends StatefulWidget {
  final ArtworkType type;
  const UserPage(
      {Key? key, String? heroTag, required int id, required this.type})
      : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
