import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/componentwidgets/usersearch.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';

import '../componentwidgets/novelresult.dart';
import '../componentwidgets/pixivimage.dart';
import '../componentwidgets/searchbar.dart';
import '../componentwidgets/searchresult.dart';
import '../componentwidgets/usercard.dart';
import '../model/worktypes.dart';
import 'defaults.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    SearchPageController searchPageController = Get.put(SearchPageController());
    return Obx(() {
      return Scaffold(
        headers: [
          PreferredSize(
            preferredSize:
                const Size.fromHeight(100), // here the desired height
            child: AppBar(
              title: SearchBar1(
                  getAwType(searchPageController.selectedIndex.value)),
              child: TabList(
                children: [
                  TabButton(
                    child: Text('Illust•Manga'.tr),
                    onPressed: () {
                      searchPageController.selectedIndex.value = 0;
                    },
                  ),
                  TabButton(
                    child: Text('Novel'.tr),
                    onPressed: () {
                      searchPageController.selectedIndex.value = 1;
                    },
                  ),
                  TabButton(
                    child: Text('User'.tr),
                    onPressed: () {
                      searchPageController.selectedIndex.value = 2;
                    },
                  ),
                ],
              ),
            ),
          )
        ],
        child: IndexedStack(
          index: searchPageController.selectedIndex.value,
          children: [
            SearchRecommendPage(ArtworkType.ILLUST),
            SearchRecommendPage(ArtworkType.NOVEL),
            SearchRecommmendUserPage(),
          ],
        ),
      );
    });
  }

  ArtworkType getAwType(int index) {
    switch (index) {
      case 0:
        return ArtworkType.ILLUST;
      case 1:
        return ArtworkType.NOVEL;
      default:
        return ArtworkType.ALL;
    }
  }
}

class SearchPageController extends GetxController {
  RxInt selectedIndex = (settings.awPrefer == "novel") ? 1.obs : 0.obs;
}

class SearchRecommmendUserPage extends StatefulWidget {
  const SearchRecommmendUserPage({super.key});

  @override
  State<SearchRecommmendUserPage> createState() =>
      _SearchRecommmendUserPageState();
}

class _SearchRecommmendUserPageState extends State<SearchRecommmendUserPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController = EasyRefreshController();
    ListUserController controller =
        ListUserController(userListType: UserListType.recom);
    controller.refreshController = refreshController;
    return Scaffold(
      child: EasyRefresh(
        header: DefaultHeaderFooter.header(context),
        controller: refreshController,
        onRefresh: () => controller.reset(),
        onLoad: () => controller.nextPage(),
        refreshOnStart: controller.users.isEmpty,
        child: Obx(() {
          return CustomScrollView(
            slivers: [
              SliverPadding(padding: EdgeInsets.only(top: 16.0)),
              if (localManager.historyUserTag.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "History".tr,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).typography.h4.color),
                        ),
                      ],
                    ),
                  ),
                ),
              if (localManager.historyUserTag.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverToBoxAdapter(
                    child: (localManager.historyUserTag.length > 20)
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Wrap(
                              runSpacing: 0.0,
                              spacing: 5.0,
                              children: [
                                if (controller.tagExpand.value)
                                  for (var f in localManager.historyUserTag)
                                    PixChip(
                                        f: f,
                                        type: "historyUserTag",
                                        onTap: () => Get.to(
                                            () => UserResultPage(
                                                  word: f,
                                                ),
                                            preventDuplicates: false)),
                                if (!controller.tagExpand.value)
                                  for (var f in localManager.historyUserTag
                                      .sublist(0, 12))
                                    PixChip(
                                        f: f,
                                        type: "historyUserTag",
                                        onTap: () => Get.to(
                                            () => UserResultPage(
                                                  word: f,
                                                ),
                                            preventDuplicates: false)),
                                Chip(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      transitionBuilder: (child, anim) {
                                        return ScaleTransition(
                                            scale: anim, child: child);
                                      },
                                      child: Icon(
                                          !controller.tagExpand.value
                                              ? Icons.expand_more
                                              : Icons.expand_less),
                                    ),
                                    onPressed: () {
                                      controller.tagExpand.value =
                                          !controller.tagExpand.value;
                                    })
                              ],
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Wrap(
                              runSpacing: 0.0,
                              spacing: 3.0,
                              children: [
                                for (var f in localManager.historyUserTag)
                                  PixChip(
                                      f: f,
                                      type: "historyUserTag",
                                      onTap: () => Get.to(
                                          () => UserResultPage(
                                                word: f,
                                              ),
                                          preventDuplicates: false)),
                              ],
                            ),
                          ),
                  ),
                ),
              if (localManager.historyUserTag.isNotEmpty)
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Clean history?".tr),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("Cancel".tr)),
                                TextButton(
                                    onPressed: () {
                                      settings
                                          .clearHistoryTag(ArtworkType.USER);
                                      localManager.clear("historyUserTag");
                                      Get.back();
                                    },
                                    child: Text("Ok".tr)),
                              ],
                            );
                          });
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18.0,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              "Clear search history".tr,
                              style: Theme.of(context)
                                  .typography
                                  .medium
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Recommended Users".tr,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).typography.h2.color),
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return PainterCard(user: controller.users[index]);
              }, childCount: controller.users.length)),
            ],
          );
        }),
      ),
    );
  }
}

class SearchRecommendPage extends StatefulWidget {
  final ArtworkType type;

  const SearchRecommendPage(this.type, {super.key});

  @override
  State<SearchRecommendPage> createState() => _SearchRecommendPageState();
}

class _SearchRecommendPageState extends State<SearchRecommendPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController refreshController =
        EasyRefreshController(controlFinishRefresh: true);
    HotTagsController hotTagsController = Get.put(
        HotTagsController(widget.type, refreshController),
        tag: "hotTags_${widget.type.name}");

    final rowCount = max(3, (context.width / 200).floor());
    return Obx(
      () => EasyRefresh(
        onRefresh: () => hotTagsController.reset(),
        header: DefaultHeaderFooter.header(context),
        controller: refreshController,
        refreshOnStart: hotTagsController.tags.isEmpty,
        child: CustomScrollView(
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: 16.0)),
            if (widget.type == ArtworkType.ILLUST &&
                    localManager.historyIllustTag.isNotEmpty ||
                widget.type == ArtworkType.NOVEL &&
                    localManager.historyNovelTag.isNotEmpty)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "History".tr,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).typography.h4.color),
                    ),
                  ],
                ),
              )),
            if (widget.type == ArtworkType.ILLUST &&
                    localManager.historyIllustTag.isNotEmpty ||
                widget.type == ArtworkType.NOVEL &&
                    localManager.historyNovelTag.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverToBoxAdapter(
                  child: (widget.type == ArtworkType.ILLUST &&
                              localManager.historyIllustTag.length > 20 ||
                          widget.type == ArtworkType.NOVEL &&
                              localManager.historyNovelTag.length > 20)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Wrap(
                            runSpacing: 0.0,
                            spacing: 5.0,
                            children: [
                              if (widget.type == ArtworkType.ILLUST)
                                for (var f in hotTagsController.tagExpand.value
                                    ? localManager.historyIllustTag
                                    : localManager.historyIllustTag
                                        .sublist(0, 12))
                                  PixChip(
                                      f: f,
                                      type: "historyIllustTag",
                                      onTap: () => Get.to(
                                          () => ResultPage(
                                                word: f,
                                              ),
                                          preventDuplicates: false)),
                              if (widget.type == ArtworkType.NOVEL)
                                for (var f in hotTagsController.tagExpand.value
                                    ? localManager.historyNovelTag
                                    : localManager.historyNovelTag
                                        .sublist(0, 12))
                                  PixChip(
                                      f: f,
                                      type: "historyNovelTag",
                                      onTap: () => Get.to(
                                          () => NovelResultPage(
                                                word: f,
                                              ),
                                          preventDuplicates: false)),
                              Chip(
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) {
                                      return ScaleTransition(
                                          scale: anim, child: child);
                                    },
                                    child: Icon(
                                        hotTagsController.tagExpand.value
                                            ? Icons.expand_more
                                            : Icons.expand_less),
                                  ),
                                  onPressed: () {
                                    hotTagsController.tagExpand.value =
                                        !hotTagsController.tagExpand.value;
                                  })
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Wrap(
                            runSpacing: 0.0,
                            spacing: 3.0,
                            children: [
                              if (widget.type == ArtworkType.ILLUST)
                                for (var f in localManager.historyIllustTag)
                                  PixChip(
                                      f: f,
                                      type: "historyIllustTag",
                                      onTap: () => Get.to(
                                          () => ResultPage(
                                                word: f,
                                              ),
                                          preventDuplicates: false)),
                              if (widget.type == ArtworkType.NOVEL)
                                for (var f in localManager.historyNovelTag)
                                  PixChip(
                                      f: f,
                                      type: "historyNovelTag",
                                      onTap: () => Get.to(
                                          () => NovelResultPage(
                                                word: f,
                                              ),
                                          preventDuplicates: false)),
                            ],
                          ),
                        ),
                ),
              ),
            if (widget.type == ArtworkType.ILLUST &&
                    localManager.historyIllustTag.isNotEmpty ||
                widget.type == ArtworkType.NOVEL &&
                    localManager.historyNovelTag.isNotEmpty)
              SliverToBoxAdapter(
                  child: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Clean history?".tr),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text("Cancel".tr)),
                            TextButton(
                                onPressed: () {
                                  localManager.clear("historyIllustTag");
                                  localManager.clear("historyNovelTag");
                                  Get.back();
                                },
                                child: Text("Ok".tr)),
                          ],
                        );
                      });
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          "Clear search history".tr,
                          style: Theme.of(context).typography.medium.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                        )
                      ],
                    ),
                  ),
                ),
              )),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Recommended Tags".tr,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).typography.h2.color),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (_) {
                          if (widget.type == ArtworkType.NOVEL) {
                            return NovelResultPage(
                              word: hotTagsController.tags[index].tag.name,
                            );
                          }
                          return ResultPage(
                            word: hotTagsController.tags[index].tag.name,
                          );
                        }));
                      },
                      onLongPress: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (_) {
                          return IllustPageLite(hotTagsController
                              .tags[index].illust.id
                              .toString());
                        }));
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: <Widget>[
                            PixivImage(
                              hotTagsController
                                  .tags[index].illust.images.first.squareMedium,
                              fit: BoxFit.cover,
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "#${hotTagsController.tags[index].tag}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    if (hotTagsController.tags[index].tag
                                                .translatedName !=
                                            null &&
                                        hotTagsController.tags[index].tag
                                            .translatedName!.isNotEmpty)
                                      Text(
                                        hotTagsController
                                            .tags[index].tag.translatedName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: hotTagsController.tags.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowCount)),
            ),
            if (DynamicData.isAndroid)
              SliverToBoxAdapter(
                child: Container(
                  height: (MediaQuery.of(context).size.width / 3) - 16,
                ),
              )
          ],
        ),
      ),
    );
  }
}
