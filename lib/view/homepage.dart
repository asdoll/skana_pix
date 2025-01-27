import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/feedpage.dart';
import 'package:skana_pix/view/rankingpage.dart';
import 'package:skana_pix/view/recompage.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/view/searchpage.dart';
import 'package:skana_pix/view/settingscreen.dart';
import 'package:skana_pix/view/spotlightpage.dart';

import 'loginpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!accountController.isLoggedIn.value) {
        return Scaffold(
          child: LoginPage(),
        );
      }

      return Scaffold(
        headers: [
          AppBar(
            title: Text(pages[pageIndexController.pageIndex.value].tr),
            padding: EdgeInsets.all(10),
            leading: [
              OutlineButton(
                density: ButtonDensity.icon,
                onPressed: () {
                  openDrawer(
                      context: context,
                      draggable: false,
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: NavigationSidebar(
                            index: pageIndexController.pageIndex.value,
                            onSelected: (index) {
                              pageIndexController.pageIndex.value = index;
                              closeDrawer(context);
                            },
                            children: [
                              NavigationLabel(child: Text('Recommend'.tr)),
                              buildButton(
                                  'Illust'.tr, BootstrapIcons.image),
                              buildButton('Manga'.tr, BootstrapIcons.images),
                              buildButton('Novel'.tr, BootstrapIcons.book),
                              const NavigationGap(10),
                              const NavigationDivider(),
                              NavigationLabel(child: Text('Feed'.tr)),
                              buildButton(
                                  'Illust•Manga'.tr, BootstrapIcons.images),
                              buildButton('Novel'.tr, BootstrapIcons.book),
                              const NavigationGap(10),
                              const NavigationDivider(),
                              buildButton('Ranking'.tr, BootstrapIcons.list),
                              buildButton('Pixivision'.tr, BootstrapIcons.info),
                              buildButton('Search'.tr, BootstrapIcons.search),
                              buildButton('Bookmarks'.tr, BootstrapIcons.bookmark),
                              buildButton('My Tags'.tr, BootstrapIcons.tags),
                              buildButton('Following'.tr, BootstrapIcons.person),
                              buildButton('History'.tr, BootstrapIcons.clock),
                              buildButton('Settings'.tr, BootstrapIcons.gear),

                            ],
                          ),
                        );
                      },
                      position: OverlayPosition.left);
                },
                child: const Icon(Icons.menu),
              ),
            ],
          ),
          const Divider(),
        ],
        child: switch (pageIndexController.pageIndex.value) {
          0 => RecomImagesPage(ArtworkType.ILLUST),
          1 => RecomImagesPage(ArtworkType.MANGA),
          2 => RecomNovelsPage(),
          3 => FeedIllust(),
          4 => FeedNovel(),
          5 => RankingPage(),
          6 => SpotlightPage(),
          7 => SearchPage(),
          // 8 => BookmarksPage(),
          // 9 => MyTagsPage(),
          // 10 => FollowingPage(),
          // 11 => HistoryPage(),
          _ => SettingPage(),
        },
      );
    });
  }

  NavigationBarItem buildButton(String label, IconData icon) {
    return NavigationButton(
      label: Text(label),
      child: Icon(icon),
    );
  }
}
