import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../model/worktypes.dart';
import 'avatar.dart';
import 'commentpage.dart';
import 'followbutton.dart';
import 'novelpage.dart';
import 'novelresult.dart';
import 'novelseries.dart';
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
                                style: Theme.of(context).typography.textLarge,
                                maxLines: 3,
                              ),
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
                                    style: Theme.of(context)
                                        .typography
                                        .textSmall
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 12,
                                          color: Theme.of(context)
                                              .typography
                                              .textSmall
                                              .color,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${recomNovelsController.novels[widget.index].length}',
                                          style: Theme.of(context)
                                              .typography
                                              .textSmall,
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
                                    Text(
                                      f.name,
                                      style: Theme.of(context)
                                          .typography
                                          .textSmall,
                                    )
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
                        size: 20,
                        liked: recomNovelsController
                            .novels[widget.index].isBookmarked,
                      ),
                      Text(
                          '${recomNovelsController.novels[widget.index].totalBookmarks}',
                          style: Theme.of(context).typography.textSmall)
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
        return m.Scaffold(
          floatingActionButton: m.IconButton(
            onPressed: () {
              Get.back();
              Get.to(
                  () => NovelViewerPage(
                      recomNovelsController.novels[widget.index]),
                  preventDuplicates: false);
            },
            icon: Icon(Icons.menu_book_rounded),
          ),
          body: SingleChildScrollView(child: _buildFirstView(context)),
        );
      },
    );
  }

  Widget _buildFirstView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
              style: Theme.of(context).typography.h3,
            ),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 8),
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
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(12.5)),
                  ),
                  child: Text(
                    "Series:${recomNovelsController.novels[widget.index].seriesTitle}",
                    style: Theme.of(context).typography.textSmall,
                  ),
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
              style: Theme.of(context).typography.textSmall,
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
                        style: Theme.of(context).typography.textSmall.copyWith(
                            color: Theme.of(context).colorScheme.secondary)),
                  for (var f in recomNovelsController.novels[widget.index].tags)
                    buildRow(context, f)
                ],
              )),
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
                      data: recomNovelsController.novels[widget.index].caption),
                ),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                Get.to(() => CommentPage(
                    id: recomNovelsController.novels[widget.index].id,
                    type: ArtworkType.NOVEL));
              },
              child: Text("Show comments".tr)),
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
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "#${f.name}",
                children: [
                  TextSpan(
                    text: " ",
                    style: Theme.of(context).typography.textSmall,
                  ),
                  TextSpan(
                      text: f.translatedName ?? "~",
                      style: Theme.of(context).typography.textSmall)
                ],
                style: Theme.of(context)
                    .typography
                    .textSmall
                    .copyWith(color: Theme.of(context).colorScheme.secondary))),
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
                    style: Theme.of(context).typography.textLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: Theme.of(context).typography.textLarge)
              ]),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Get.back(result: 0);
                },
                child: Text("Block".tr),
              ),
              TextButton(
                onPressed: () {
                  Get.back(result: 1);
                },
                child: Text("Bookmark".tr),
              ),
              TextButton(
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
          Icon(Icons.bookmark, size: 12),
          Text(
            "${novel.totalBookmarks}",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.remove_red_eye_rounded, size: 12),
          ),
          Text(
            "${novel.totalViews}",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
