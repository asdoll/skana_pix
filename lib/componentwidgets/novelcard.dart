import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../model/worktypes.dart';
import 'avatar.dart';
import '../view/commentpage.dart';
import 'followbutton.dart';
import '../view/novelview/novelpage.dart';
import '../view/novelview/novelresult.dart';
import '../view/novelview/novelseries.dart';
import 'pixivimage.dart';
import 'selecthtml.dart';

class NovelCard extends StatefulWidget {
  final String controllerTag;
  final int index;
  const NovelCard(this.index, this.controllerTag, {super.key});

  @override
  State<NovelCard> createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
  late ListNovelController recomNovelsController;

  @override
  Widget build(BuildContext context) {
    recomNovelsController =
        Get.find<ListNovelController>(tag: widget.controllerTag);
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: m.InkWell(
          onTap: () {
            if (settings.novelDirectEntry) {
              Get.to(
                  () => NovelViewerPage(
                      recomNovelsController.novels[widget.index]),
                  preventDuplicates: false);
            } else {
              buildShowModalBottomSheet(context);
            }
          },
          child: Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PixivImage(
                          recomNovelsController
                              .novels[widget.index].coverImageUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ).rounded(8.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                recomNovelsController
                                    .novels[widget.index].title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ).textSmall(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    recomNovelsController.novels[widget.index]
                                        .author.name.atMost8,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: mtc.theme.value.colorScheme
                                            .mutedForeground),
                                  ).xSmall(),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 12,
                                          color: mtc
                                              .theme.value.colorScheme.primary,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${recomNovelsController.novels[widget.index].length}',
                                          style: mtc
                                              .theme.value.typography.textSmall
                                              .copyWith(
                                                  color: mtc
                                                      .theme
                                                      .value
                                                      .colorScheme
                                                      .mutedForeground),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 2, // gap between adjacent chips
                                runSpacing: 0,
                                children: [
                                  if (recomNovelsController
                                      .novels[widget.index].tags.isEmpty)
                                    Container(),
                                  for (var f in recomNovelsController
                                      .novels[widget.index].tags)
                                    Text("${f.name} ").xSmall()
                                ],
                              ),
                            ),
                            Container(
                              height: 8.0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      StarIcon(
                        id: recomNovelsController.novels[widget.index].id
                            .toString(),
                        type: ArtworkType.NOVEL,
                        size: 32,
                        liked: recomNovelsController
                            .novels[widget.index].isBookmarked,
                      ).paddingOnly(top: 8),
                      Text(
                          '${recomNovelsController.novels[widget.index].totalBookmarks}',
                          style: mtc.theme.value.typography.textSmall.copyWith(
                            color: mtc.theme.value.colorScheme.mutedForeground,
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Future buildShowModalBottomSheet(BuildContext context) {
    return openSheet(
      context: context,
      position: OverlayPosition.bottom,
      builder: (_) {
        return SizedBox(
          height: Get.mediaQuery.size.height * 0.6,
          child: Scaffold(
            footers: [
              IconButton.primary(
                size: ButtonSize(1.2),
                onPressed: () {
                  Get.back();
                  Get.to(
                      () => NovelViewerPage(
                          recomNovelsController.novels[widget.index]),
                      preventDuplicates: false);
                },
                icon: Icon(Icons.menu_book_rounded),
              )
                  .withAlign(Alignment(0.85, 0.9))
                  .paddingBottom(Get.mediaQuery.size.height * 0.05)
            ],
            floatingFooter: true,
            child: SingleChildScrollView(child: _buildFirstView(context)),
          ),
        );
      },
    );
  }

  Widget _buildFirstView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
      child: Column(
        children: [
          Container(
            height: 20,
          ),
          Center(
            child: PixivImage(
              recomNovelsController.novels[widget.index].coverImageUrl,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
            ).rounded(8.0),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              recomNovelsController.novels[widget.index].title,
            ).h4(),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 8.0, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  PainterAvatar(
                    url: recomNovelsController
                        .novels[widget.index].author.avatar,
                    id: recomNovelsController.novels[widget.index].author.id,
                    size: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      recomNovelsController
                          .novels[widget.index].author.name.atMost8,
                    ).xSmall(),
                  ),
                ]),
                const SizedBox(width: 16),
                UserFollowButton(
                  id: recomNovelsController.novels[widget.index].author.id
                      .toString(),
                  liked: recomNovelsController
                      .novels[widget.index].author.isFollowed,
                ),
              ],
            ),
          ),
          if (recomNovelsController.novels[widget.index].seriesId != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
              child: m.InkWell(
                onTap: () {
                  Get.to(() => NovelSeriesPage(
                      recomNovelsController.novels[widget.index].seriesId!));
                },
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: mtc.theme.value.colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
                    "Series:${recomNovelsController.novels[widget.index].seriesTitle}",
                  ).textSmall().semiBold(),
                ),
              ),
            ),
          //MARK DETAIL NUM,
          _buildNumItem(recomNovelsController.novels[widget.index], context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              recomNovelsController.novels[widget.index].createDate
                  .toShortTime(),
              style: mtc.theme.value.typography.textSmall,
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 1,
                children: [
                  if (recomNovelsController.novels[widget.index].isAi)
                    Text("AI-generated".tr,
                        style: mtc.theme.value.typography.textSmall.copyWith(
                            color: mtc.theme.value.colorScheme.secondary)),
                  for (var f in recomNovelsController.novels[widget.index].tags)
                    buildRow(context, f)
                ],
              )),
          if (recomNovelsController.novels[widget.index].caption
              .trim()
              .isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: m.SelectionArea(
                    contextMenuBuilder: (context, editableTextState) {
                      return _buildSelectionMenu(editableTextState, context);
                    },
                    child: SelectableHtml(
                        data:
                            recomNovelsController.novels[widget.index].caption),
                  ),
                ),
              ),
            ),
          Button(
            onPressed: () {
              Get.to(
                  () => CommentPage(
                      id: recomNovelsController.novels[widget.index].id,
                      type: ArtworkType.NOVEL),
                  preventDuplicates: false);
            },
            style: ButtonStyle.card(density: ButtonDensity.dense),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: mtc.theme.value.colorScheme.primary,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Show comments".tr,
                  ).xSmall(),
                ]),
          ).paddingSymmetric(vertical: 16),
        ],
      ),
    );
  }

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        _longPressTag(context, f);
      },
      onTap: () {
        Get.to(
            () => NovelResultPage(
                  word: f.name,
                  translatedName: f.translatedName ?? "",
                ),
            preventDuplicates: false);
      },
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: mtc.theme.value.colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "#${f.name}",
                children: [
                  TextSpan(
                    text: " ",
                    style: mtc.theme.value.typography.textSmall,
                  ),
                  TextSpan(
                      text: f.translatedName ?? "~",
                      style: mtc.theme.value.typography.textSmall)
                ],
                style: mtc.theme.value.typography.textSmall.copyWith(
                    color: mtc.theme.value.colorScheme.secondaryForeground))),
      ),
    );
  }

  Future _longPressTag(BuildContext context, Tag f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: f.name,
                    style: mtc.theme.value.typography.textLarge
                        .copyWith(color: mtc.theme.value.colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: mtc.theme.value.typography.textLarge)
              ]),
            ).withAlign(Alignment.centerLeft),
            actions: <Widget>[
              OutlineButton(
                density: ButtonDensity.dense,
                onPressed: () {
                  Get.back(result: 0);
                },
                child: Text("Block".tr),
              ),
              PrimaryButton(
                density: ButtonDensity.dense,
                onPressed: () {
                  Get.back(result: 1);
                },
                child: Text("Bookmark".tr),
              ),
              PrimaryButton(
                density: ButtonDensity.dense,
                onPressed: () {
                  Get.back(result: 2);
                },
                child: Text("Copy".tr),
              ),
            ],
          );
        })) {
      case 0:
        {
          localManager.add("blockedNovelTags", [f.name]);
        }
        break;
      case 1:
        {
          localManager.add("bookmarkedNovelTags", [f.name]);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          Leader.showToast("Copied to clipboard".tr);
        }
    }
  }

  m.AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    return m.AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Widget _buildNumItem(Novel novel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 0,
        children: [
          Icon(
            Icons.bookmark,
            size: 14,
            color: mtc.theme.value.colorScheme.primary,
          ),
          Text("${novel.totalBookmarks}",
              style: mtc.theme.value.typography.textSmall.copyWith(
                  color: mtc.theme.value.colorScheme.mutedForeground)),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.remove_red_eye_rounded,
              size: 14,
              color: mtc.theme.value.colorScheme.primary,
            ),
          ),
          Text("${novel.totalViews}",
              style: mtc.theme.value.typography.textSmall.copyWith(
                  color: mtc.theme.value.colorScheme.mutedForeground)),
        ],
      ),
    );
  }
}
