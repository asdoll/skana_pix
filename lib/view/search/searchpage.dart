import 'dart:math' show max;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/search_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/view/userview/usersearch.dart';
import 'package:skana_pix/controller/like_controller.dart';
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

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoonTabBar(
          tabController: tabController,
          onTabChanged: (value) {
            try {
              Get.find<SuggestionStore>().type.value = value == 0
                  ? ArtworkType.ILLUST
                  : value == 1
                      ? ArtworkType.NOVEL
                      : ArtworkType.USER;
            } catch (e) {
              log.e(e);
            }
          },
          tabs: [
            MoonTab(
              label: Text('Illust•Manga'.tr),
            ),
            MoonTab(
              label: Text('Novel'.tr),
            ),
            MoonTab(
              label: Text('User'.tr),
            ),
          ],
        ).paddingLeft(16).toAlign(Alignment.topLeft),
        Expanded(
            child: TabBarView(controller: tabController, children: [
          SearchRecommendPage(ArtworkType.ILLUST),
          SearchRecommendPage(ArtworkType.NOVEL),
          SearchRecommmendUserPage(),
        ]))
      ],
    );
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
    return EasyRefresh(
      header: DefaultHeaderFooter.header(context),
      refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
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
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("History".tr).header(),
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
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Wrap(
                            runSpacing: 5.0,
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
                              MoonChip(
                                  label: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) {
                                      return ScaleTransition(
                                          scale: anim, child: child);
                                    },
                                    child: Icon(!controller.tagExpand.value
                                        ? Icons.expand_more
                                        : Icons.expand_less),
                                  ),
                                  onTap: () {
                                    controller.tagExpand.value =
                                        !controller.tagExpand.value;
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    filledButton(
                      onPressed: () {
                        alertDialog(context, "Clean history?".tr, "", [
                          outlinedButton(
                            label: "Cancel".tr,
                            onPressed: () {
                              Get.back();
                            },
                          ),
                          filledButton(
                            label: "Ok".tr,
                            onPressed: () {
                              localManager.clear("historyUserTag");
                              Get.back();
                            },
                          )
                        ]);
                      },
                      leading: Icon(Icons.delete_outline),
                      label: "Clear search history".tr,
                    ),
                  ],
                ).paddingAll(16.0),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Recommended Users".tr).header(),
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
    return Obx(
      () => EasyRefresh(
        onRefresh: hotTagsController.reset,
        header: DefaultHeaderFooter.header(context),
        refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
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
                    Text("History".tr).header(),
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
                              MoonChip(
                                  label: AnimatedSwitcher(
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
                                  onTap: () {
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
                    filledButton(
                      onPressed: () {
                        alertDialog(
                          context,
                          "Clean history?".tr,
                          "",
                          [
                            outlinedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                label: "Cancel".tr),
                            filledButton(
                                onPressed: () {
                                  if (widget.type == ArtworkType.ILLUST) {
                                    localManager.clear("historyIllustTag");
                                  } else if (widget.type == ArtworkType.NOVEL) {
                                    localManager.clear("historyNovelTag");
                                  }
                                  Get.back();
                                },
                                label: "Ok".tr),
                          ],
                        );
                      },
                      leading: Icon(Icons.delete_outline),
                      label: "Clear search history".tr,
                    ),
                  ],
                ).paddingAll(16.0),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Recommended Tags".tr).header(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return InkWell(
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
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white),
                                    ).small(),
                                    if (hotTagsController.tags[index].tag
                                                .translatedName !=
                                            null &&
                                        hotTagsController.tags[index].tag
                                            .translatedName!.isNotEmpty)
                                      Text(
                                        hotTagsController
                                            .tags[index].tag.translatedName!,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white),
                                      ).xSmall(),
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
                      crossAxisCount: max(3, (context.width / 200).floor()))),
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
