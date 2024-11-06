import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../model/worktypes.dart';
import 'avatar.dart';
import 'commentpage.dart';
import 'followbutton.dart';
import 'novelbookmark.dart';
import 'novelpage.dart';
import 'novelresult.dart';
import 'novelseries.dart';
import 'pixivimage.dart';
import 'selecthtml.dart';

class NovelCard extends StatefulWidget {
  final Novel novel;
  const NovelCard(this.novel, {super.key});

  @override
  State<NovelCard> createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
  Novel get novel => widget.novel;
  @override
  Widget build(BuildContext context) {
    {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            if (settings.novelDirectEntry) {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (BuildContext context) => NovelViewerPage(novel)));
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
                          novel.coverImageUrl,
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
                                novel.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
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
                                    novel.author.name.atMost8,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
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
                                              .textTheme
                                              .labelSmall!
                                              .color,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${novel.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
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
                                  if (novel.tags.isEmpty) Container(),
                                  for (var f in novel.tags)
                                    Text(
                                      f.name,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                      NovelBookmarkButton(novel: novel, colorMode: ""),
                      Text('${novel.totalBookmarks}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  Future buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (BuildContext context) => NovelViewerPage(novel)));
            },
            child: Icon(Icons.menu_book_rounded),
          ),
          body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0))),
            child: SingleChildScrollView(child: _buildFirstView(context)),
          ),
        ).rounded(16);
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
              widget.novel.coverImageUrl,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
            ).rounded(8.0),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              "${widget.novel.title}",
              style: Theme.of(context).textTheme.titleMedium,
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
                    url: widget.novel.author.avatar,
                    id: widget.novel.author.id,
                    size: Size(16, 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      widget.novel.author.name.atMost8,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 8),
                UserFollowButton(
                  followed: widget.novel.author.isFollowed,
                  onPressed: () async {
                    follow();
                  },
                ),
              ],
            ),
          ),
          if (widget.novel.seriesId != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          NovelSeriesPage(widget.novel.seriesId!)));
                },
                child: Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(12.5)),
                  ),
                  child: Text(
                    "Series:${widget.novel.seriesTitle}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ),
          //MARK DETAIL NUM,
          _buildNumItem(widget.novel, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.novel.createDate.toShortTime(),
              style: Theme.of(context).textTheme.labelSmall,
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
                  if (widget.novel.isAi)
                    Text("AI-generated".i18n,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.secondary)),
                  for (var f in widget.novel.tags) buildRow(context, f)
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectionArea(
                  onSelectionChanged: (value) {
                    // ignore: unused_local_variable
                    var _selectedText = value?.plainText ?? "";
                  },
                  contextMenuBuilder: (context, editableTextState) {
                    return _buildSelectionMenu(editableTextState, context);
                  },
                  child: SelectableHtml(data: widget.novel.caption),
                ),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CommentPage(
                        id: widget.novel.id, type: ArtworkType.NOVEL)));
              },
              child: Text("Show comments".i18n)),
        ],
      ),
    );
  }

  bool isFollowing = false;

  void follow() async {
    if (isFollowing) return;
    setState(() {
      isFollowing = true;
    });
    var method = widget.novel.author.isFollowed ? "delete" : "add";
    var res = await followUser(widget.novel.author.id.toString(), method);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: "Network Error".i18n);
      }
    } else {
      setState(() {
        widget.novel.author.isFollowed = !widget.novel.author.isFollowed;
      });
    }
    setState(() {
      isFollowing = false;
    });
    // UserInfoPage.followCallbacks[widget.illust.author.id.toString()]
    //     ?.call(widget.illust.author.isFollowed);
    // UserPreviewWidget.followCallbacks[widget.illust.author.id.toString()]
    //     ?.call(widget.illust.author.isFollowed);
  }

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NovelResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "#${f.name}",
                children: [
                  TextSpan(
                    text: " ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextSpan(
                      text: "${f.translatedName ?? "~"}",
                      style: Theme.of(context).textTheme.bodySmall)
                ],
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.secondary))),
      ),
    );
  }

  Future _longPressTag(BuildContext context, Tag f) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: f.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: Theme.of(context).textTheme.bodyLarge!)
              ]),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text("Block".i18n),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Text("Bookmark".i18n),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Text("Copy".i18n),
              ),
            ],
          );
        })) {
      case 0:
        {
          settings.addBlockedNovelTags([f.name]);
        }
        break;
      case 1:
        {
          settings.addBookmarkedNovelTags([f.name]);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text("Copied to clipboard".i18n),
          ));
        }
    }
  }

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    // if (supportTranslate) {
    //   buttonItems.insert(
    //     buttonItems.length,
    //     ContextMenuButtonItem(
    //       label: I18n.of(context).translate,
    //       onPressed: () async {
    //         final selectionText = _selectedText;
    //         if (Platform.isIOS) {
    //           final box = context.findRenderObject() as RenderBox?;
    //           final pos = box != null
    //               ? box.localToGlobal(Offset.zero) & box.size
    //               : null;
    //           Share.share(selectionText, sharePositionOrigin: pos);
    //           return;
    //         }
    //         await SupportorPlugin.start(selectionText);
    //         ContextMenuController.removeAny();
    //       },
    //     ),
    //   );
    // }
    return AdaptiveTextSelectionToolbar.buttonItems(
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
