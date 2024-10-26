import 'package:flutter/material.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';

import '../model/worktypes.dart';
import 'recom_images_page.dart';
import 'recom_novels_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      RecomImagesPage(ArtworkType.ILLUST),
      RecomImagesPage(ArtworkType.MANGA),
      RecomNovelsPage(),
    ];
    return MaterialApp(
      theme: DynamicData.themeData,
      darkTheme: DynamicData.darkTheme,
      themeMode: ThemeMode.system,
      home: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(32.0), // here the desired height
            child: AppBar(
              toolbarHeight: 0.0,
              bottom: TabBar(
                tabs: [
                  Container(
                    height: 30.0,
                    width: 80,
                    child: Tab(text: 'Illust'.i18n),
                  ),
                  Container(
                    height: 30.0,
                    width: 80,
                    // color: Colors.red,
                    child: Tab(text: 'Manga'.i18n),
                  ),
                  Container(
                    height: 30.0,
                    width: 80,
                    // color: Colors.red,
                    child: Tab(text: 'Novel'.i18n),
                  ),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
          body: TabBarView(
            children: tabs,
          ),
        ),
      ),
    );
  }
}
