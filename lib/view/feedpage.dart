import 'package:flutter/material.dart';
import 'package:skana_pix/componentwidgets/avatar.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/settingscreen.dart';

import '../componentwidgets/feedillust.dart';
import '../componentwidgets/feednovel.dart';
import 'defaults.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(tabs: [
            Tab(text: 'Illust•Manga'.i18n),
            Tab(text: 'Novel'.i18n),
          ], controller: _tabController),
          actions: [
            PainterAvatar(
              url: ConnectManager().apiClient.account.user.profileImg,
              id: int.parse(ConnectManager().apiClient.userid),
              size: Size(40, 40),
            ),
          ],
        ),
        body: TabBarView(children: [
          FeedIllust(),
          FeedNovel(),
        ], controller: _tabController),
      ),
    );
  }
}
