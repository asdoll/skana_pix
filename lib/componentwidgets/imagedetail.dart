import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/utils/translate.dart';

import 'avatar.dart';
import 'commentpage.dart';
import 'followbutton.dart';
import 'searchresult.dart';
import 'selecthtml.dart';
import 'userpage.dart';

class IllustDetailContent extends StatefulWidget {
  final Illust illust;
  const IllustDetailContent({
    super.key,
    required this.illust,
  });

  @override
  State<IllustDetailContent> createState() => _IllustDetailContentState();
}

class _IllustDetailContentState extends State<IllustDetailContent> {
  late Illust _illust;

  late FocusNode _focusNode;
  String _selectedText = "";

  @override
  void initState() {
    _focusNode = FocusNode();
    _illust = widget.illust;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IllustDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.illust.caption.isNotEmpty &&
        widget.illust.caption != oldWidget.illust.caption) {
      setState(() {
        _illust = widget.illust;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoArea(context, _illust),
          _buildNameAvatar(context, _illust),
          _buildTagArea(context, _illust),
          _buildCaptionArea(_illust),
          _buildCommentTextArea(context, _illust),
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
            child: Text("Related artworks".i18n),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoArea(BuildContext context, Illust data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SelectionArea(
              child: Text(
                data.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  data.totalView.toString(),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text("${data.totalBookmarks}",
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.timelapse_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(data.createDate.toShortTime(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Text(
                "Artwork ID".i18n,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
              )),
              Container(
                width: 4.0,
              ),
              colorText(data.id.toString(), context),
              Container(
                width: 10.0,
              ),
              Container(
                  child: Text(
                "Pixel".i18n,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
              )),
              Container(
                width: 4.0,
              ),
              colorText("${data.width}x${data.height}", context)
            ],
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget colorText(String text, BuildContext context) {
    return SelectionArea(
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary, fontSize: 12),
      ),
    );
  }

  Padding _buildTagArea(BuildContext context, Illust data) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          if (data.isAi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                      text: "AI-generated".i18n,
                      children: [
                        TextSpan(
                          text: " ",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 12),
                        ),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.white, fontSize: 12))),
            ),
          for (var f in data.tags) buildRow(context, f)
        ],
      ),
    );
  }

  Widget _buildCaptionArea(Illust data) {
    final caption = data.caption.isEmpty ? "" : data.caption;
    if (caption.isEmpty) {
      return Container(height: 1);
    }
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Container(
              width: double.infinity,
              child: SelectionArea(
                focusNode: _focusNode,
                onSelectionChanged: (value) {
                  _selectedText = value?.plainText ?? "";
                },
                contextMenuBuilder: (context, selectableRegionState) {
                  return _buildSelectionMenu(selectableRegionState, context);
                },
                child: SelectableHtml(
                  data: caption.isEmpty ? "~" : caption,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool supportTranslate = false;

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Widget _buildCommentTextArea(BuildContext context, Illust data) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: InkWell(
          onTap: () {
            context.to(() => CommentPage(id: data.id));
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.comment,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Show comments".i18n,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ]),
            ),
          ),
        ),
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
          settings.addBlockedTags([f.name]);
        }
        break;
      case 1:
        {
          settings.addBookmarkedTags([f.name]);
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

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(
                    text: "#${f.name}",
                    children: [
                      TextSpan(
                        text: " ",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontSize: 12),
                      ),
                      if (f.translatedName != null)
                        TextSpan(
                            text: "${f.translatedName}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 12))
                    ],
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Future<void> _push2UserPage(BuildContext context, Illust illust) async {
    await PersistentNavBarNavigator.pushNewScreen(context,
        screen: UserPage(
          id: illust.author.id,
          heroTag: hashCode.toString(),
        ));
  }

  Widget _buildNameAvatar(BuildContext context, Illust illust) {
    return InkWell(
      onTap: () async {
        await _push2UserPage(context, illust);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Hero(
              tag: illust.author.avatar + hashCode.toString(),
              child: PainterAvatar(
                url: illust.author.avatar,
                id: illust.author.id,
                size: Size(32, 32),
                onTap: () async {
                  await _push2UserPage(context, illust);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: illust.author.name + this.hashCode.toString(),
                    child: SelectionArea(
                      child: GestureDetector(
                        onTap: () {
                          _push2UserPage(context, illust);
                        },
                        child: Text(
                          illust.author.name,
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          UserFollowButton(
            followed: illust.author.isFollowed,
            onPressed: () async {
              follow();
            },
          ),
          SizedBox(
            width: 12,
          )
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
    var method = widget.illust.author.isFollowed ? "delete" : "add";
    var res = await followUser(widget.illust.author.id.toString(), method);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: "Network Error".i18n);
      }
    } else {
      widget.illust.author.isFollowed = !widget.illust.author.isFollowed;
    }
    setState(() {
      isFollowing = false;
    });
    // UserInfoPage.followCallbacks[widget.illust.author.id.toString()]
    //     ?.call(widget.illust.author.isFollowed);
    // UserPreviewWidget.followCallbacks[widget.illust.author.id.toString()]
    //     ?.call(widget.illust.author.isFollowed);
  }
}
