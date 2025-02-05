import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as m;
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/view/userview/usersearch.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';

import '../novelview/novelresult.dart';
import '../../componentwidgets/pixivimage.dart';
import '../imageview/imagesearchresult.dart';
import '../../componentwidgets/usercard.dart';
import '../../model/worktypes.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        headers: [
          TabList(
            index: searchPageController.selectedIndex.value,
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
        ],
        child: (searchPageController.selectedIndex.value == 2)
            ? SearchRecommmendUserPage()
            : (searchPageController.selectedIndex.value == 0)
                ? _RecommendIllust()
                : (searchPageController.selectedIndex.value == 1)
                    ? _RecommendNovel()
                    : Container(),
      );
    });
  }
}

class _RecommendIllust extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchRecommendPage(ArtworkType.ILLUST);
  }
}

class _RecommendNovel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchRecommendPage(ArtworkType.NOVEL);
  }
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
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    ListUserController controller = Get.put(
        ListUserController(userListType: UserListType.recom),
        tag: "search_user");
    controller.refreshController = refreshController;
    return Scaffold(
      child: EasyRefresh(
        header: DefaultHeaderFooter.header(context),
        controller: refreshController,
        onRefresh: () => controller.reset(),
        onLoad: () => controller.nextPage(),
        refreshOnStart: true,
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
                                      child: Icon(!controller.tagExpand.value
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
                  child: m.InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Clean history?".tr)
                                  .withAlign(Alignment.centerLeft),
                              actions: [
                                OutlineButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("Cancel".tr)),
                                PrimaryButton(
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
                  child: Text("Recommended Users".tr).h4(),
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(top: 8.0)),
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
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishRefresh: true, controlFinishLoad: true);
    HotTagsController hotTagsController = Get.put(
        HotTagsController(widget.type),
        tag: "hotTags_${widget.type.name}");
    hotTagsController.refreshController = refreshController;

    final rowCount = max(3, (context.width / 200).floor());
    return Obx(
      () => EasyRefresh(
        onRefresh: hotTagsController.reset,
        header: DefaultHeaderFooter.header(context),
        controller: refreshController,
        refreshOnStart: true,
        callRefreshOverOffset: 10,
        child: CustomScrollView(
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: 16.0)),
            if (widget.type == ArtworkType.ILLUST &&
                    localManager.historyIllustTag.isNotEmpty ||
                widget.type == ArtworkType.NOVEL &&
                    localManager.historyNovelTag.isNotEmpty)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("History".tr).h4(),
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
                            runSpacing: 5.0,
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
                                          () => IllustResultPage(
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
                                  style: ButtonStyle.primary(),
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
                            runSpacing: 5.0,
                            spacing: 5.0,
                            children: [
                              if (widget.type == ArtworkType.ILLUST)
                                for (var f in localManager.historyIllustTag)
                                  PixChip(
                                      f: f,
                                      type: "historyIllustTag",
                                      onTap: () => Get.to(
                                          () => IllustResultPage(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(
                      style: ButtonStyle.card(density: ButtonDensity.dense),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Clean history?".tr)
                                    .withAlign(Alignment.centerLeft),
                                actions: [
                                  OutlineButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("Cancel".tr)),
                                  PrimaryButton(
                                      onPressed: () {
                                        if (widget.type == ArtworkType.ILLUST) {
                                          localManager
                                              .clear("historyIllustTag");
                                        } else if (widget.type ==
                                            ArtworkType.NOVEL) {
                                          localManager.clear("historyNovelTag");
                                        }
                                        Get.back();
                                      },
                                      child: Text("Ok".tr)),
                                ],
                              );
                            });
                      },
                      child: Basic(
                        leading: Icon(Icons.delete_outline),
                        title: Text("Clear search history".tr).textSmall(),
                      ),
                    ),
                  ],
                ).paddingAll(16.0),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Recommended Tags".tr).h4(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() {
                          if (widget.type == ArtworkType.NOVEL) {
                            return NovelResultPage(
                              word: hotTagsController.tags[index].tag.name,
                            );
                          }
                          return IllustResultPage(
                            word: hotTagsController.tags[index].tag.name,
                          );
                        });
                      },
                      onLongPress: () {
                        Get.to(() {
                          return IllustPageLite(hotTagsController
                              .tags[index].illust.id
                              .toString());
                        });
                      },
                      child: m.Card(
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
            if (GetPlatform.isAndroid)
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
