import 'package:bootstrap_icons/bootstrap_icons.dart';
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
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/bookmarkspage.dart';
import 'package:skana_pix/view/feedpage.dart';
import 'package:skana_pix/view/historypage.dart';
import 'package:skana_pix/view/mytagspage.dart';
import 'package:skana_pix/view/rankingpage.dart';
import 'package:skana_pix/view/recompage.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/view/search/searchpage.dart';
import 'package:skana_pix/view/settings/settingpage.dart';
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
          appBar: appBar(title: "Login".tr, leading: null),
          body: LoginPage(),
        );
      }

      return Scaffold(
        key: homeKey,
        appBar: AppBar(
          title: (homeController.pageIndex.value == 7)
              ? SearchBar1(searchPageController
                  .getAwType(searchPageController.selectedIndex.value))
              : Row(children: [
                  Text(getTitle(pages[homeController.pageIndex.value]).tr)
                      .appHeader().paddingRight(8),
                  getSubtitle(pages[homeController.pageIndex.value]).isNotEmpty
                      ? Text(getSubtitle(pages[homeController.pageIndex.value]).tr,
                              style: TextStyle(
                                  color: Get.context?.moonTheme?.textAreaTheme
                                      .colors.helperTextColor))
                          .appSubHeader()
                      : (homeController.pageIndex.value == 5)
                          ? Text(
                                  rankTagsMap[homeController.tagList(homeController.workIndex.value)[homeController.tagIndex.value]] ??
                                      homeController.tagList(
                                              homeController.workIndex.value)[
                                          homeController.tagIndex.value],
                                  style: TextStyle(
                                      color: Get
                                          .context
                                          ?.moonTheme
                                          ?.textAreaTheme
                                          .colors
                                          .helperTextColor))
                              .subHeader()
                          : Container()
                ]),
          shape: Border(
              bottom: BorderSide(
            color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
            width: 0.2,
          )),
          actions: [
            if (homeController.pageIndex.value == 11)
              MoonButton.icon(
                icon: Icon(Icons.delete),
                onTap: () {
                  alertDialog<void>(
                    context,
                    "Clear History".tr,
                    "Are you sure to clear history?".tr,
                    [
                      outlinedButton(
                        label: "Cancel".tr,
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      filledButton(
                        label: "Confirm".tr,
                        onPressed: () {
                          try {
                            if (Get.find<MTab>(tag: "history").index.value ==
                                0) {
                              Get.find<HistoryIllust>(tag: "history_illust")
                                  .clear();
                            } else {
                              Get.find<HistoryNovel>(tag: "history_novel")
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
                },
              ),
            if (homeController.pageIndex.value == 12)
              MoonSwitch(
                value: tc.darkMode.value == "system"
                    ? Get.isPlatformDarkMode
                    : tc.darkMode.value == "2",
                switchSize: MoonSwitchSize.xs,
                activeTrackWidget: Icon(Icons.dark_mode_outlined),
                inactiveTrackWidget: Icon(Icons.light_mode_outlined),
                inactiveTrackColor: context.moonTheme?.tokens.colors.krillin,
                onChanged: (bool newValue) =>
                    tc.changeDarkMode(newValue ? "2" : "1"),
              ).paddingRight(8),
            if (homeController.pageIndex.value == 5)
              MoonButton.icon(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                ),
                onTap: () {
                  // showDropdown(
                  //   context: context,
                  //   builder: (context) {
                  //     return DropdownMenu(
                  //       children: [
                  //         for (int i = 0;
                  //             i <
                  //                 homeController
                  //                     .tagList(homeController.workIndex.value)
                  //                     .length;
                  //             i++)
                  //           MenuButton(
                  //             child: Text(rankTagsMap[homeController.tagList(
                  //                     homeController.workIndex.value)[i]] ??
                  //                 homeController.tagList(
                  //                     homeController.workIndex.value)[i]),
                  //             onPressed: (context) {
                  //               homeController.tagIndex.value = i;
                  //               homeController.refreshRanking();
                  //             },
                  //           ),
                  //       ],
                  //     );
                  //   },
                  // );
                },
              ),
            if (homeController.pageIndex.value == 5)
              MoonButton.icon(
                icon: const Icon(
                  Icons.calendar_month,
                ),
                onTap: () {
                  // showMoonModal<void>(
                  //     context: context,
                  //     builder: (context) {
                  //       DateTime? date = homeController.dateTime.value;
                  //       return AlertDialog(
                  //         content: DatePickerDialog(
                  //             initialViewType: CalendarViewType.date,
                  //             selectionMode: CalendarSelectionMode.single,
                  //             initialValue: date == null
                  //                 ? null
                  //                 : CalendarValue.single(date),
                  //             stateBuilder: (date) {
                  //               if (date.isBefore(DateTime(2007, 9))) {
                  //                 return DateState.disabled;
                  //               } //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
                  //               if (date.isAfter(DateTime.now())) {
                  //                 return DateState.disabled;
                  //               }
                  //               return DateState.enabled;
                  //             },
                  //             onChanged: (value) {
                  //               if (value == null) return;
                  //               final range = value.toSingle();
                  //               date = range.date;
                  //             }),
                  //         actions: [
                  //           OutlineButton(
                  //             child: Text("Cancel".tr),
                  //             onPressed: () {
                  //               date = null;
                  //               Get.back();
                  //             },
                  //           ),
                  //           PrimaryButton(
                  //             child: Text("Confirm".tr),
                  //             onPressed: () {
                  //               homeController.dateTime.value = date;
                  //               homeController.refreshRanking();
                  //               Get.back();
                  //             },
                  //           )
                  //         ],
                  //       );
                  //     });
                },
              ),
          ],
        ),
        drawer: MoonDrawer(
            width: context.width > 200 ? 200 : null,
            child: ListView(children: [
              buildButton('Recommend'.tr),
              buildButton('Illust'.tr, BootstrapIcons.image, 0),
              buildButton('Manga'.tr, BootstrapIcons.images, 1),
              buildButton('Novel'.tr, BootstrapIcons.book, 2),
              const Divider(),
              buildButton('Feed'.tr),
              buildButton('Illust•Manga'.tr, BootstrapIcons.images, 3),
              buildButton('Novel'.tr, BootstrapIcons.book, 4),
              const Divider(),
              buildButton('Ranking'.tr, BootstrapIcons.list_stars, 5),
              buildButton('Pixivision'.tr, BootstrapIcons.info, 6),
              buildButton('Search'.tr, BootstrapIcons.search, 7),
              buildButton('My Bookmarks'.tr, BootstrapIcons.bookmark, 8),
              buildButton('My Tags'.tr, BootstrapIcons.tags, 9),
              buildButton('Following'.tr, BootstrapIcons.person, 10),
              buildButton('History'.tr, BootstrapIcons.clock, 11),
              buildButton('Settings'.tr, BootstrapIcons.gear, 12),
            ]).paddingSymmetric(horizontal: 8)),
        floatingActionButton: GoTop(),
        body: switch (homeController.pageIndex.value) {
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

  MoonMenuItem buildButton(String label, [IconData? icon, int? index]) {
    if (index != null) {
      return MoonMenuItem(
        backgroundColor: homeController.pageIndex.value == index
            ? Get.context?.moonTheme?.tokens.colors.piccolo
            : Colors.transparent,
        label: Text(label,
                style: homeController.pageIndex.value == index
                    ? TextStyle(color: MoonColors.light.goku)
                    : null)
            .subHeader(),
        leading: icon == null
            ? null
            : Icon(
                icon,
                color: homeController.pageIndex.value == index
                    ? MoonColors.light.goku
                    : null,
              ),
        onTap: () {
          homeController.pageIndex.value = index;
          closeDrawer();
        },
      );
    }
    return MoonMenuItem(
      label: Text(label).subHeader(),
      leading: icon == null ? null : Icon(icon),
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
