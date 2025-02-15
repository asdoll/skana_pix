import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/pixivimage.dart';
import 'package:skana_pix/controller/comment_controller.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

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
  final bool isReply;
  final ArtworkType type;

  const CommentPage(
      {super.key,
      required this.id,
      this.isReply = false,
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
    Get.delete<CommentController>(tag: "comment_${widget.id}_${widget.type}");
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
        CommentController(widget.id.toString(), widget.type, widget.isReply),
        tag: "comment_${widget.id}_${widget.type}");
    controller.easyRefreshController = easyRefreshController;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      onPointerMove: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Scaffold(
        appBar: appBar(title: "Comments".tr),
        body: SafeArea(
          child: Obx(
            () => Column(
              children: <Widget>[
                Expanded(
                  child: EasyRefresh(
                    controller: easyRefreshController,
                    header: DefaultHeaderFooter.header(context),
                    footer: DefaultHeaderFooter.footer(context),
                    refreshOnStartHeader:
                        DefaultHeaderFooter.refreshHeader(context),
                    onRefresh: controller.reset,
                    refreshOnStart: true,
                    onLoad: controller.nextPage,
                    child: ListView.separated(
                      itemCount: controller.comments.length + 1,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        if (controller.error.isNotEmpty &&
                            controller.comments.isEmpty) {
                          return SizedBox(
                              height: context.height / 1.5,
                              child: Center(
                                child: Column(
                                  children: [
                                    Text("Error".tr)
                                        .h2()
                                        .paddingTop(context.height / 4),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    filledButton(
                                      onPressed: () {
                                        easyRefreshController.callRefresh();
                                      },
                                      label: "Retry".tr,
                                    )
                                  ],
                                ),
                              ));
                        }
                        if (controller.comments.isEmpty) {
                          if (!controller.isLoading.value) {
                            return emptyPlaceholder(context);
                          }
                        }
                        if (index == controller.comments.length) {
                          return Container();
                        }
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
                                      Expanded(
                                          child: Text(
                                                  controller
                                                      .comments[index].name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis)
                                              .header()),
                                      Obx(() => Row(children: [
                                            if (!widget.isReply)
                                              filledButton(
                                                  onPressed: () {
                                                    controller.parentCommentId
                                                            .value =
                                                        controller
                                                            .comments[index].id;
                                                    controller.parentCommentName
                                                            .value =
                                                        controller
                                                            .comments[index]
                                                            .name;
                                                  },
                                                  label: "Reply".tr),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0),
                                                child: MoonDropdown(
                                                    offset: Offset(-30, 0),
                                                    minWidth: 80,
                                                    maxWidth: 80,
                                                    show: controller
                                                            .showMenu[index] ??
                                                        false,
                                                    onTapOutside: () =>
                                                        controller.showMenu[
                                                            index] = false,
                                                    content: Column(
                                                      children: [
                                                        MoonMenuItem(
                                                          label: Text(
                                                                  "Block User"
                                                                      .tr)
                                                              .small(),
                                                          onTap: () async {
                                                            localManager.add(
                                                                "blockedCommentUsers",
                                                                [
                                                                  controller
                                                                      .comments[
                                                                          index]
                                                                      .name
                                                                ]);
                                                            controller
                                                                .easyRefreshController
                                                                ?.callRefresh();
                                                          },
                                                        ),
                                                        MoonMenuItem(
                                                          label: Text(
                                                                  "Block Comment"
                                                                      .tr)
                                                              .small(),
                                                          onTap: () async {
                                                            localManager.add(
                                                                "blockedComments",
                                                                [
                                                                  controller
                                                                      .comments[
                                                                          index]
                                                                      .comment
                                                                ]);
                                                            controller
                                                                .easyRefreshController
                                                                ?.callRefresh();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    child: MoonButton.icon(
                                                        icon: const Icon(
                                                          Icons.more_horiz,
                                                        ),
                                                        onTap: () {
                                                          controller.showMenu[
                                                                      index] !=
                                                                  null
                                                              ? controller
                                                                      .showMenu[
                                                                  index] = !controller
                                                                      .showMenu[
                                                                  index]!
                                                              : controller
                                                                      .showMenu[
                                                                  index] = true;
                                                        })))
                                          ]))
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
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: MoonFilledButton(
                                        buttonSize: MoonButtonSize.sm,
                                        backgroundColor: Get.context?.moonTheme
                                            ?.tokens.colors.frieza,
                                        label: Text("View Replies".tr,
                                            style:
                                                TextStyle(color: Colors.black)),
                                        onTap: () async {
                                          Get.to(
                                              CommentPage(
                                                id: controller
                                                    .comments[index].id,
                                                isReply: true,
                                                type: controller.type,
                                              ),
                                              preventDuplicates: false);
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(controller.comments[index].date
                                            .toShortTime())
                                        .small(),
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
                          IconButton(
                            icon: Icon(Icons.book_outlined),
                            onPressed: () {
                              if (widget.isReply) return;
                              controller.parentCommentId.value = 0;
                              controller.parentCommentName.value = "";
                            },
                          ),
                          IconButton(
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
                                child: MoonFormTextInput(
                                  hintText:
                                      "${"Reply to".tr} ${controller.parentCommentName.value == "" ? "" : controller.parentCommentName.value}",
                                  controller: _editController,
                                  trailing: IconButton(
                                      icon: const Icon(
                                        MoonIcons.arrows_reply_24_regular,
                                      ),
                                      onPressed: () async {
                                        String txt =
                                            _editController.text.trim();
                                        controller.submitComment(txt);
                                        _editController.clear();
                                        setState(() {
                                          _emojiPanelShow = !_emojiPanelShow;
                                          if (_emojiPanelShow) {
                                            FocusScope.of(context).unfocus();
                                          }
                                        });
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
