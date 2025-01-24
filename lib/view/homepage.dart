import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/recom_images_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
            title: Text(pages[pageIndexController.pageIndex.value]),
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
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: NavigationSidebar(
                            index: pageIndexController.pageIndex.value,
                            onSelected: (index) {
                              pageIndexController.pageIndex.value = index;
                              closeDrawer(context);
                            },
                            children: [
                              const NavigationLabel(child: Text('Discovery')),
                              buildButton(
                                  'Listen Now', BootstrapIcons.playCircle),
                              buildButton('Browse', BootstrapIcons.grid),
                              buildButton('Radio', BootstrapIcons.broadcast),
                              const NavigationGap(24),
                              const NavigationDivider(),
                              const NavigationLabel(child: Text('Library')),
                              buildButton(
                                  'Playlist', BootstrapIcons.musicNoteList),
                              buildButton('Songs', BootstrapIcons.musicNote),
                              buildButton('For You', BootstrapIcons.person),
                              buildButton('Artists', BootstrapIcons.mic),
                              buildButton('Albums', BootstrapIcons.record2),
                              const NavigationGap(24),
                              const NavigationDivider(),
                              const NavigationLabel(child: Text('Playlists')),
                              buildButton('Recently Added',
                                  BootstrapIcons.musicNoteList),
                              buildButton('Recently Played',
                                  BootstrapIcons.musicNoteList),
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
          _ => RecomImagesPage(ArtworkType.MANGA),
          // 0 => IllustRecomPage(),
          // 1 => MangaRecomPage(),
          // 2 => NovelRecomPage(),
          // 3 => RankingPage(),
          // 4 => PixivisionPage(),
          // 5 => IllustFeedPage(),
          // 6 => NovelFeedPage(),
          // 7 => SearchPage(),
          // 8 => BookmarksPage(),
          // 9 => MyTagsPage(),
          // 10 => FollowingPage(),
          // 11 => HistoryPage(),
          // _ => SettingsPage(),
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
