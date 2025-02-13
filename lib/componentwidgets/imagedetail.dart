import 'package:flutter/services.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/tag.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
          child: Text("Related artworks".tr).subHeader(),
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
              ).header(),
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
                size: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(data.totalView.toString()).small(),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.favorite,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text("${data.totalBookmarks}").small(),
              ),
              Container(
                width: 4.0,
              ),
              Icon(
                Icons.timelapse_rounded,
                size: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(data.createDate.toShortTime()).small(),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("Artwork ID".tr).small(),
              Container(
                width: 4.0,
              ),
              colorText(data.id.toString(), context),
              Container(
                width: 10.0,
              ),
              Text("Pixel".tr).small(),
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
            color: context.moonTheme?.textAreaTheme.colors.helperTextColor,
            fontSize: 12),
      ).small(),
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
              decoration: BoxDecoration(
                color: context.moonTheme?.tokens.colors.piccolo,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(text: "AI-generated".tr, children: [
                    TextSpan(text: " ").small(),
                  ]).small()),
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
            color: Theme.of(context).colorScheme.secondary,
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
        child: MoonButton(
      backgroundColor: context.moonTheme?.tokens.colors.gohan,
      onTap: () {
        Get.to(() => CommentPage(id: data.id), preventDuplicates: false);
      },
      leading: Icon(
        Icons.comment,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        "Show comments".tr,
      ).small(),
    )).paddingSymmetric(vertical: 16);
  }

  Future _longPressTag(BuildContext context, Tag f) async {
    switch (await alertDialog<int>(context, f.name, f.translatedName ?? "", [
      outlinedButton(
        label: "Block".tr,
        onPressed: () {
          Get.back(result: 0);
        },
      ),
      outlinedButton(
        label: "Bookmark".tr,
        onPressed: () {
          Get.back(result: 1);
        },
      ),
      filledButton(
        label: "Copy".tr,
        onPressed: () {
          Get.back(result: 2);
        },
      )
    ])) {
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
          color: context.moonTheme?.tokens.colors.piccolo,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(text: "#${f.name}", children: [
                  TextSpan(
                    text: " ",
                  ).small(),
                  if (f.translatedName != null)
                    TextSpan(
                            text: "${f.translatedName}",
                            style: TextStyle(fontStyle: FontStyle.italic))
                        .small()
                ]).small()),
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
                        child: Text(illust.author.name).subHeader(),
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
