import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/gotop.dart';
import 'package:skana_pix/componentwidgets/searchbar.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
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
import 'package:skana_pix/view/search/searchpage.dart';
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
            title: (homeController.pageIndex.value == 7)
                ? SearchBar1(searchPageController
                    .getAwType(searchPageController.selectedIndex.value))
                : Text(getTitle(pages[homeController.pageIndex.value]).tr),
            subtitle: getSubtitle(pages[homeController.pageIndex.value])
                    .isNotEmpty
                ? Text(getSubtitle(pages[homeController.pageIndex.value]).tr)
                : ((homeController.pageIndex.value == 5)
                    ? Text(rankTagsMap[homeController.tagList(homeController
                            .workIndex.value)[homeController.tagIndex.value]] ??
                        homeController.tagList(homeController.workIndex.value)[
                            homeController.tagIndex.value])
                    : null),
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
                                  'My Bookmarks'.tr, BootstrapIcons.bookmark),
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
              if (homeController.pageIndex.value == 11)
                IconButton.ghost(
                    density: ButtonDensity.compact,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Clear History".tr).withAlign(
                                Alignment.centerLeft,
                              ),
                              content:
                                  Text("Are you sure to clear history?".tr),
                              actions: [
                                OutlineButton(
                                  child: Text("Cancel".tr),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                                PrimaryButton(
                                  child: Text("Confirm".tr),
                                  onPressed: () {
                                    try {
                                      if (Get.find<MTab>(tag: "history")
                                              .index
                                              .value ==
                                          0) {
                                        Get.find<HistoryIllust>(
                                                tag: "history_illust")
                                            .clear();
                                      } else {
                                        Get.find<HistoryNovel>(
                                                tag: "history_novel")
                                            .clear();
                                      }
                                    } catch (e) {
                                      log.e(e);
                                    }
                                    Get.back();
                                  },
                                )
                              ],
                            );
                          });
                    }),
              if (homeController.pageIndex.value == 12)
                IconButton.ghost(
                  icon: const Icon(
                    Icons.palette,
                  ),
                  onPressed: () {
                    Get.to(() => ThemePage());
                  },
                ),
              if (homeController.pageIndex.value == 5)
                IconButton.ghost(
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                  ),
                  onPressed: () {
                    showDropdown(
                      context: context,
                      builder: (context) {
                        return DropdownMenu(
                          children: [
                            for (int i = 0;
                                i <
                                    homeController
                                        .tagList(homeController.workIndex.value)
                                        .length;
                                i++)
                              MenuButton(
                                child: Text(rankTagsMap[homeController.tagList(
                                        homeController.workIndex.value)[i]] ??
                                    homeController.tagList(
                                        homeController.workIndex.value)[i]),
                                onPressed: (context) {
                                  homeController.tagIndex.value = i;
                                  homeController.refreshRanking();
                                },
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              if (homeController.pageIndex.value == 5)
                IconButton.ghost(
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          DateTime? date = homeController.dateTime.value;
                          return AlertDialog(
                            content: DatePickerDialog(
                                initialViewType: CalendarViewType.date,
                                selectionMode: CalendarSelectionMode.single,
                                initialValue: date == null
                                    ? null
                                    : CalendarValue.single(date),
                                stateBuilder: (date) {
                                  if (date.isBefore(DateTime(2007, 9))) {
                                    return DateState.disabled;
                                  } //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
                                  if (date.isAfter(DateTime.now())) {
                                    return DateState.disabled;
                                  }
                                  return DateState.enabled;
                                },
                                onChanged: (value) {
                                  if (value == null) return;
                                  final range = value.toSingle();
                                  date = range.date;
                                }),
                            actions: [
                              OutlineButton(
                                child: Text("Cancel".tr),
                                onPressed: () {
                                  date = null;
                                  Get.back();
                                },
                              ),
                              PrimaryButton(
                                child: Text("Confirm".tr),
                                onPressed: () {
                                  homeController.dateTime.value = date;
                                  homeController.refreshRanking();
                                  Get.back();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
            ],
          ),
          const Divider(),
        ],
        footers: [
          const GoTop(),
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
          8 => MyBookmarksPage(
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
