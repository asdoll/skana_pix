import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart'
    show InkWell, AdaptiveTextSelectionToolbar, SelectionArea;
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/pixivimage.dart';
import 'package:skana_pix/controller/comment_controller.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/utils/io_extension.dart';

import '../model/worktypes.dart';
import '../componentwidgets/avatar.dart';
import '../componentwidgets/commentemoji.dart';

final emojisMap = {
  '(normal)': '101.png',
  '(surprise)': '102.png',
  '(serious)': '103.png',
  '(heaven)': '104.png',
  '(happy)': '105.png',
  '(excited)': '106.png',
  '(sing)': '107.png',
  '(cry)': '108.png',
  '(normal2)': '201.png',
  '(shame2)': '202.png',
  '(love2)': '203.png',
  '(interesting2)': '204.png',
  '(blush2)': '205.png',
  '(fire2)': '206.png',
  '(angry2)': '207.png',
  '(shine2)': '208.png',
  '(panic2)': '209.png',
  '(normal3)': '301.png',
  '(satisfaction3)': '302.png',
  '(surprise3)': '303.png',
  '(smile3)': '304.png',
  '(shock3)': '305.png',
  '(gaze3)': '306.png',
  '(wink3)': '307.png',
  '(happy3)': '308.png',
  '(excited3)': '309.png',
  '(love3)': '310.png',
  '(normal4)': '401.png',
  '(surprise4)': '402.png',
  '(serious4)': '403.png',
  '(love4)': '404.png',
  '(shine4)': '405.png',
  '(sweat4)': '406.png',
  '(shame4)': '407.png',
  '(sleep4)': '408.png',
  '(heart)': '501.png',
  '(teardrop)': '502.png',
  '(star)': '503.png'
};

class CommentPage extends StatefulWidget {
  final int id;
  final bool isReplay;
  final ArtworkType type;

  const CommentPage(
      {super.key,
      required this.id,
      this.isReplay = false,
      this.type = ArtworkType.ILLUST});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late TextEditingController _editController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    _editController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _emojiPanelShow = false;

  Widget _buildEmojiPanel(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView.count(
        crossAxisCount: 5,
        children: [
          for (var i in emojisMap.keys)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () {
                  String key = i;
                  String text = _editController.text;
                  TextSelection textSelection = _editController.selection;
                  if (!textSelection.isValid) {
                    _editController.text = "${_editController.text}$key";
                    return;
                  }
                  String newText = text.replaceRange(
                      textSelection.start, textSelection.end, key);
                  final emojiLength = key.length;
                  _editController.text = newText;
                  _editController.selection = textSelection.copyWith(
                    baseOffset: textSelection.start + emojiLength,
                    extentOffset: textSelection.start + emojiLength,
                  );
                },
                child: Image.asset(
                  'assets/emojis/${emojisMap[i]}',
                  width: 32,
                  height: 32,
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    CommentController controller = Get.put(
        CommentController(
            widget.id.toString(), widget.type, easyRefreshController),
        tag: "comment_${widget.id}_${widget.type}");

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      onPointerMove: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Scaffold(
        headers: [
          AppBar(
            title: Text("Comments".tr),
            padding: EdgeInsets.all(10),
            leading: [
              const NormalBackButton(),
            ],
          ),
          const Divider()
        ],
        child: SafeArea(
          child: Obx(
            () => Column(
              children: <Widget>[
                Expanded(
                  child: EasyRefresh(
                    controller: easyRefreshController,
                    header: DefaultHeaderFooter.header(context),
                    onRefresh: () => controller.reset(),
                    refreshOnStart: true,
                    onLoad: () => controller.nextPage(),
                    child: ListView.separated(
                      itemCount: controller.comments.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PainterAvatar(
                                url: controller.comments[index].avatar,
                                id: int.parse(controller.comments[index].uid),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        controller.comments[index].name,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryForeground,
                                            overflow: TextOverflow.ellipsis),
                                      ).semiBold(),
                                      Row(
                                        children: [
                                          PrimaryButton(
                                              density: ButtonDensity.dense,
                                              onPressed: () {
                                                if (widget.isReplay) return;
                                                controller
                                                        .parentCommentId.value =
                                                    controller
                                                        .comments[index].id;
                                                controller.parentCommentName
                                                        .value =
                                                    controller
                                                        .comments[index].name;
                                              },
                                              child: Text(widget.isReplay
                                                  ? ""
                                                  : "Reply".tr)),
                                          if (!widget.isReplay)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: GhostButton(
                                                  density: ButtonDensity.dense,
                                                  onPressed: () {
                                                    openSheet(
                                                        context: context,
                                                        position:
                                                            OverlayPosition
                                                                .bottom,
                                                        builder: (context) {
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              InkWell(
                                                                child: Basic(
                                                                  title: Text(
                                                                      "Block User"
                                                                          .tr),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  Get.back();
                                                                  localManager.add(
                                                                      "blockedCommentUsers",
                                                                      [
                                                                        controller
                                                                            .comments[index]
                                                                            .name
                                                                      ]);
                                                                },
                                                              ).paddingSymmetric(vertical: 6),
                                                              InkWell(
                                                                child: Basic(
                                                                  title: Text(
                                                                      "Block Comment"
                                                                          .tr),
                                                                ),
                                                                onTap: () {
                                                                  Get.back();
                                                                  localManager.add(
                                                                      "blockedComments",
                                                                      [
                                                                        controller
                                                                            .comments[index]
                                                                            .comment
                                                                      ]);
                                                                },
                                                              ).paddingSymmetric(vertical: 6),
                                                              Container(
                                                                height: context
                                                                    .mediaQueryPadding
                                                                    .bottom,
                                                              )
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  child: const Icon(
                                                      Icons.more_horiz)),
                                            )
                                        ],
                                      )
                                    ],
                                  ),
                                  if (controller.comments[index].parentComment
                                          ?.name !=
                                      null)
                                    Text(
                                        'To ${controller.comments[index].parentComment!.name}'),
                                  if (controller.comments[index].stampUrl ==
                                      null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: SelectionArea(
                                        focusNode: _focusNode,
                                        contextMenuBuilder:
                                            (context, selectableRegionState) {
                                          return _buildSelectionMenu(
                                              selectableRegionState, context);
                                        },
                                        onSelectionChanged: (value) {
                                          _selectedText =
                                              value?.plainText ?? "";
                                        },
                                        child: CommentEmojiText(
                                          text: controller
                                              .comments[index].comment,
                                        ),
                                      ),
                                    ),
                                  if (controller.comments[index].stampUrl !=
                                      null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: PixivImage(
                                        controller.comments[index].stampUrl!,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                  if (controller.comments[index].hasReplies ==
                                      true)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top:8.0),
                                      child: Chip(
                                        child: Text("View Replies".tr),
                                        onPressed: () async {
                                          Get.to(
                                              CommentPage(
                                                id: controller
                                                    .comments[index].id,
                                                isReplay: true,
                                              ),
                                              preventDuplicates: false);
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      controller.comments[index].date
                                          .toShortTime(),
                                      style: Theme.of(context)
                                          .typography
                                          .textSmall,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ).paddingSymmetric(vertical: 8);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          IconButton.ghost(
                            icon: Icon(Icons.book),
                            onPressed: () {
                              if (widget.isReplay) return;
                              controller.parentCommentId.value = 0;
                              controller.parentCommentName.value = "";
                            },
                          ),
                          IconButton.ghost(
                            icon: Icon(Icons.emoji_emotions_outlined),
                            onPressed: () {
                              setState(() {
                                _emojiPanelShow = !_emojiPanelShow;
                                if (_emojiPanelShow) {
                                  FocusScope.of(context).unfocus();
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 2.0, right: 8.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context)
                                      .colorScheme
                                      .copyWith(
                                          primary: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                child: TextField(
                                  placeholder: Text(
                                      "${"Reply to".tr} ${controller.parentCommentName.value == "" ? "" : controller.parentCommentName.value}"),
                                  controller: _editController,
                                  trailing: IconButton.ghost(
                                      icon: const Icon(
                                        Icons.reply,
                                      ),
                                      onPressed: () async {
                                        String txt =
                                            _editController.text.trim();
                                        controller.submitComment(txt);
                                        _editController.clear();
                                      }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (context.mediaQueryViewInsets.bottom == 0 &&
                          _emojiPanelShow)
                        _buildEmojiPanel(context),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_field
  String _selectedText = "";

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }
}
