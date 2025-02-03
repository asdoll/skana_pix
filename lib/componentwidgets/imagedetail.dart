import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'
    show SelectionArea, AdaptiveTextSelectionToolbar, InkWell;
import 'package:skana_pix/utils/leaders.dart';

import 'avatar.dart';
import '../view/commentpage.dart';
import 'followbutton.dart';
import '../view/imageview/imagesearchresult.dart';
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
  // ignore: unused_field
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoArea(context, _illust),
        _buildNameAvatar(context, _illust),
        _buildTagArea(context, _illust),
        _buildCaptionArea(_illust),
        _buildCommentTextArea(context, _illust),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Related artworks".tr).small(),
        ),
      ],
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
                    .typography
                    .textSmall
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
                color: Theme.of(context).colorScheme.foreground,
                size: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  data.totalView.toString(),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.foreground),
                ),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.foreground,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text("${data.totalBookmarks}",
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.foreground)),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.timelapse_rounded,
                color: Theme.of(context).colorScheme.foreground,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(data.createDate.toShortTime(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.foreground)),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Artwork ID".tr,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.foreground),
              ),
              Container(
                width: 4.0,
              ),
              colorText(data.id.toString(), context),
              Container(
                width: 10.0,
              ),
              Text(
                "Pixel".tr,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.foreground),
              ),
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
            color: Theme.of(context).colorScheme.mutedForeground, fontSize: 12),
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
                      text: "AI-generated".tr,
                      children: [
                        TextSpan(
                          text: " ",
                          style: Theme.of(context)
                              .typography
                              .textSmall
                              .copyWith(fontSize: 12),
                        ),
                      ],
                      style: Theme.of(context)
                          .typography
                          .textSmall
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
            color: Theme.of(context).colorScheme.secondaryForeground,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: SizedBox(
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
            Get.to(() => CommentPage(id: data.id), preventDuplicates: false);
          },
          child: Center(
            child: Card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      "Show comments".tr,
                    ).xSmall(),
                  ]),
            ).paddingSymmetric(vertical: 16),
          ),
        ),
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
                    style: Theme.of(context).typography.textSmall.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: Theme.of(context).typography.textSmall)
              ]),
            ),
            actions: <Widget>[
              PrimaryButton(
                onPressed: () {
                  Get.back(result: 0);
                },
                child: Text("Block".tr),
              ),
              PrimaryButton(
                onPressed: () {
                  Get.back(result: 1);
                },
                child: Text("Bookmark".tr),
              ),
              PrimaryButton(
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
          localManager.add("blockedTags", [f.name]);
        }
        break;
      case 1:
        {
          localManager.add("bookmarkedTags", [f.name]);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          Leader.showToast("Copied to clipboard".tr);
        }
    }
  }

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: () {
        Get.to(
            () => IllustResultPage(
                  word: f.name,
                  translatedName: f.translatedName ?? "",
                ),
            preventDuplicates: false);
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary,
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
                            .typography
                            .textSmall
                            .copyWith(fontSize: 12),
                      ),
                      if (f.translatedName != null)
                        TextSpan(
                            text: "${f.translatedName}",
                            style: Theme.of(context)
                                .typography
                                .textSmall
                                .copyWith(fontSize: 12))
                    ],
                    style: Theme.of(context).typography.textSmall.copyWith(
                        color: Theme.of(context).colorScheme.primaryForeground,
                        fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAvatar(BuildContext context, Illust illust) {
    return InkWell(
      onTap: () {
        Get.to(
            () => UserPage(
                  id: illust.author.id,
                  heroTag: hashCode.toString(),
                  type: illust.type == "illust"
                      ? ArtworkType.ILLUST
                      : ArtworkType.MANGA,
                ),
            preventDuplicates: false);
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
                size: 32,
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
                    tag: illust.author.name + hashCode.toString(),
                    child: SelectionArea(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                              () => UserPage(
                                    id: illust.author.id,
                                    heroTag: hashCode.toString(),
                                    type: illust.type == "illust"
                                        ? ArtworkType.ILLUST
                                        : ArtworkType.MANGA,
                                  ),
                              preventDuplicates: false);
                        },
                        child: Text(
                          illust.author.name,
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).typography.textSmall.color),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          UserFollowButton(
            id: illust.author.id.toString(),
            liked: illust.author.isFollowed,
          ),
          SizedBox(
            width: 12,
          )
        ],
      ),
    );
  }
}
