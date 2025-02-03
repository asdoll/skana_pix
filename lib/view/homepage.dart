import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/bookmarkspage.dart';
import 'package:skana_pix/view/feedpage.dart';
import 'package:skana_pix/view/historypage.dart';
import 'package:skana_pix/view/mytagspage.dart';
import 'package:skana_pix/view/rankingpage.dart';
import 'package:skana_pix/view/recompage.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/view/searchpage.dart';
import 'package:skana_pix/view/settings/settingpage.dart';
import 'package:skana_pix/view/settings/themepage.dart';
import 'package:skana_pix/view/spotlightpage.dart';
import 'package:skana_pix/view/userview/followlist.dart';

import 'loginpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    globalScrollController.addListener(() {
      if (globalScrollController.offset < context.height) {
        homeController.showBackArea.value = false;
      } else {
        homeController.showBackArea.value = true;
      }
    });

    return Obx(() {
      if (!accountController.isLoggedIn.value) {
        return Scaffold(
          child: LoginPage(),
        );
      }

      return Scaffold(
        headers: [
          AppBar(
            title: Text(getTitle(pages[homeController.pageIndex.value]).tr),
            subtitle: getSubtitle(pages[homeController.pageIndex.value])
                    .isNotEmpty
                ? Text(getSubtitle(pages[homeController.pageIndex.value]).tr)
                : null,
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
                            index: homeController.pageIndex.value,
                            onSelected: (index) {
                              homeController.pageIndex.value = index;
                              closeDrawer(context);
                            },
                            children: [
                              NavigationLabel(child: Text('Recommend'.tr)),
                              buildButton('Illust'.tr, BootstrapIcons.image),
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
                              buildButton(
                                  'Bookmarks'.tr, BootstrapIcons.bookmark),
                              buildButton('My Tags'.tr, BootstrapIcons.tags),
                              buildButton(
                                  'Following'.tr, BootstrapIcons.person),
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
            trailing: [
              if (homeController.pageIndex.value == 12)
                IconButton.ghost(
                  icon: const Icon(
                    Icons.palette,
                  ),
                  onPressed: () {
                    Get.to(() => ThemePage());
                  },
                ),
            ],
          ),
          const Divider(),
        ],
        footers: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (homeController.pageIndex.value < 11 &&
                    homeController.showBackArea.value)
                ? Button(
                    style: ButtonStyle.card(
                        size: ButtonSize.small, density: ButtonDensity.dense),
                    onPressed: () {
                      globalScrollController.animateTo(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: Icon(
                      Icons.arrow_upward,
                      size: 30,
                    ).paddingOnly(right: 6, top: 1, bottom: 1),
                  )
                    .withAlign(Alignment(1.05, 0.9))
                    .paddingOnly(bottom: Get.mediaQuery.size.height * 0.05)
                : Container(),
          )
        ],
        floatingFooter: true,
        child: switch (homeController.pageIndex.value) {
          0 => RecomIllustsPage(),
          1 => RecomMangasPage(),
          2 => RecomNovelsPage(),
          3 => FeedIllust(),
          4 => FeedNovel(),
          5 => RankingPage(),
          6 => SpotlightPage(),
          7 => SearchPage(),
          8 => BookmarksPage(
              id: 0,
              type: settings.awPrefer == "novel"
                  ? ArtworkType.NOVEL
                  : ArtworkType.ILLUST,
            ),
          9 => MyTagsPage(),
          10 => FollowList(
              id: accountController.userid.value,
              isMe: true,
            ),
          11 => HistoryPage(),
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

  String getTitle(String s) {
    if (s.contains(":")) {
      return s.split(":")[0];
    }
    return s;
  }

  String getSubtitle(String s) {
    if (s.contains(":")) {
      return s.split(":")[1];
    }
    return "";
  }
}
