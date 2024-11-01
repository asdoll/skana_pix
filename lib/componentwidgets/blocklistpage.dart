import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/about.dart';
import 'package:skana_pix/model/author.dart';
import 'package:skana_pix/model/user.dart';

class BlockListPage extends StatefulWidget {
  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  ObservableList<UserDetails> blockedUsers = ObservableList();
  ObservableList<String> blockedTags = ObservableList();
  ObservableList<String> blockedCommentUsers = ObservableList();
  ObservableList<String> blockedNovelUsers = ObservableList();
  ObservableList<String> blockedIllusts = ObservableList();
  ObservableList<String> blockedNovels = ObservableList();
  ObservableList<String> blockedNovelTags = ObservableList();
  ObservableList<String> blockedNovelComments = ObservableList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Users'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Blocked Users'),
            subtitle: Text('0'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AboutPage(newVersion: true);
              }));
            },
          ),
        ],
      ),
    );
  }
}
