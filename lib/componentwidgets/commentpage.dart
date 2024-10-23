import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/pixivimage.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:skana_pix/view/mainscreen.dart';

import 'avatar.dart';
import 'commentemoji.dart';

enum CommentArtWorkType { ILLUST, NOVEL }

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
  final int? pId;
  final String? name;
  final CommentArtWorkType type;

  const CommentPage(
      {Key? key,
      required this.id,
      this.isReplay = false,
      this.pId,
      this.name,
      this.type = CommentArtWorkType.ILLUST})
      : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late TextEditingController _editController;
  int? parentCommentId;
  String? parentCommentName;
  late EasyRefreshController easyRefreshController;
  List<Comment> comments = [];
  String errorMessage = "";

  List<String> banList = [
    "bb8.news",
    "77k.live",
    "7mm.live",
    "p26w.com",
    "33h.live"
  ];

  late FocusNode _focusNode;

  bool isLoading = false;

  @override
  void initState() {
    supportTranslate = false;
    _focusNode = FocusNode();
    parentCommentId = widget.isReplay ? widget.pId : null;
    parentCommentName = widget.isReplay ? widget.name : null;
    _editController = TextEditingController();
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    firstLoad();
    super.initState();
    supportTranslateCheck();
  }

  @override
  void dispose() {
    _editController.dispose();
    easyRefreshController.dispose();
    _focusNode.dispose();
    errorMessage = "";
    super.dispose();
  }

  bool _emojiPanelShow = false;

  Widget _buildEmojiPanel(BuildContext context) {
    return Container(
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
                    _editController.text = "${_editController.text}${key}";
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

  bool commentHateByUser(Comment comment) {
    if (settings.blockedComments.contains(comment.id.toString())) {
      return true;
    }
    if (settings.blockedUsers.contains(comment.uid)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: _buildBody(context),
      behavior: HitTestBehavior.translucent,
      onPointerDown: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      onPointerMove: (value) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
    );
  }

  Container _buildBody(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Comments".i18n),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: EasyRefresh(
                  controller: easyRefreshController,
                  header: DefaultHeaderFooter.header(context),
                  onRefresh: () => reset(),
                  onLoad: () => nextPage(),
                  child: (comments.isEmpty)
                      ? Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('[ ]',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: comments.length,
                          padding: const EdgeInsets.only(top: 10),
                          itemBuilder: (context, index) {
                            if (banList
                                .where((element) =>
                                    comments[index].comment.contains(element))
                                .isNotEmpty) {
                              return Visibility(
                                visible: false,
                                child: Container(),
                              );
                            }
                            var comment = comments[index];
                            return Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PainterAvatar(
                                      url: comments[index].avatar,
                                      id: int.parse(comments[index].uid),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              comment.name,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            _buildTrailingRow(comment, context)
                                          ],
                                        ),
                                        if (comment.parentComment?.name != null)
                                          Text(
                                              'To ${comment.parentComment!.name}'),
                                        if (comment.stampUrl == null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: _buildCommentContent(
                                                context, comment),
                                          ),
                                        if (comment.stampUrl != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: PixivImage(
                                              comment.stampUrl!,
                                              height: 100,
                                              width: 100,
                                            ),
                                          ),
                                        if (comment.hasReplies == true)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: ActionChip(
                                              label: Text("View Replies".i18n),
                                              onPressed: () async {
                                                PersistentNavBarNavigator
                                                    .pushNewScreen(context,
                                                        screen: CommentPage(
                                                          id: widget.id,
                                                          isReplay: true,
                                                          pId: comment.id,
                                                          type: widget.type,
                                                          name: comment.name,
                                                        ));
                                              },
                                            ),
                                          ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            comment.date.toShortTime(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            if (banList
                                .where((element) =>
                                    comments[index].comment.contains(element))
                                .isNotEmpty) {
                              return Visibility(
                                visible: false,
                                child: Container(),
                              );
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                    Container(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.book),
                            onPressed: () {
                              if (widget.isReplay) return;
                              setState(() {
                                parentCommentName = null;
                                parentCommentId = null;
                              });
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
                                child: TextField(
                                  controller: _editController,
                                  decoration: InputDecoration(
                                      labelText:
                                          "${"Reply to".i18n} ${parentCommentName ?? "Artwork".i18n}",
                                      suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.reply,
                                          ),
                                          onPressed: () async {
                                            String txt =
                                                _editController.text.trim();
                                            final fun1 = BotToast.showLoading();
                                            try {
                                              Res<bool> res;
                                              if (txt.isNotEmpty) {
                                                fun1();
                                                String pp =
                                                    parentCommentId == null
                                                        ? ""
                                                        : parentCommentId
                                                            .toString();
                                                if (widget.type ==
                                                    CommentArtWorkType.ILLUST) {
                                                  res = await commentIt(
                                                      widget.id.toString(), txt,
                                                      parentId: pp.toString());
                                                  if (res.error) {
                                                    BotToast.showText(
                                                        text:
                                                            res.errorMessage ??
                                                                "Network Error"
                                                                    .i18n);
                                                  } else {
                                                    BotToast.showText(
                                                        text: "Commented".i18n);
                                                    easyRefreshController
                                                        .callRefresh();
                                                  }
                                                } else if (widget.type ==
                                                    CommentArtWorkType.NOVEL) {
                                                  res = await commentNovel(
                                                      widget.id.toString(), txt,
                                                      parentId: pp.toString());
                                                  if (res.error) {
                                                    BotToast.showText(
                                                        text:
                                                            res.errorMessage ??
                                                                "Network Error"
                                                                    .i18n);
                                                  } else {
                                                    BotToast.showText(
                                                        text: "Commented".i18n);
                                                    easyRefreshController
                                                        .callRefresh();
                                                  }
                                                }
                                              }
                                              _editController.clear();
                                            } catch (e) {
                                              loggerError("Comment Error");
                                            }
                                          })),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom == 0 &&
                        _emojiPanelShow)
                      _buildEmojiPanel(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SelectionArea _buildCommentContent(BuildContext context, Comment comment) {
    return SelectionArea(
      focusNode: _focusNode,
      contextMenuBuilder: (context, selectableRegionState) {
        return _buildSelectionMenu(
            selectableRegionState, context, supportTranslate);
      },
      onSelectionChanged: (value) {
        _selectedText = value?.plainText ?? "";
      },
      child: CommentEmojiText(
        text: comment.comment,
      ),
    );
  }

  Widget _buildTrailingRow(Comment comment, BuildContext context) {
    return Row(
      children: [
        InkWell(
            onTap: () {
              if (widget.isReplay) return;
              parentCommentId = comment.id;
              setState(() {
                parentCommentName = comment.name;
              });
            },
            child: Text(
              widget.isReplay ? "" : "Reply".i18n,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )),
        if (!widget.isReplay)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text("Block User".i18n),
                              onTap: () async {
                                Navigator.of(context).pop();
                                settings.addBlockedUsers([comment.uid]);
                              },
                            ),
                            ListTile(
                              title: Text("Block Comment".i18n),
                              onTap: () {
                                Navigator.of(context).pop();
                                settings.addBlockedComments(
                                    [comment.id.toString()]);
                              },
                            ),
                            Container(
                              height: MediaQuery.of(context).padding.bottom,
                            )
                          ],
                        );
                      });
                },
                child: const Icon(Icons.more_horiz)),
          )
      ],
    );
  }

  String? nextUrl;

  Future<Res<List<Comment>>> loadData() async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    Res<List<Comment>> res = widget.type == CommentArtWorkType.NOVEL
        ? await getNovelComments(widget.id.toString(), nextUrl)
        : await getComments(widget.id.toString(), nextUrl);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad();
    }
    return res;
  }

  nextPage() {
    if (isLoading) return;
    isLoading = true;
    loadData().then((value) {
      isLoading = false;
      if (value.success) {
        setState(() {
          comments.addAll(value.data);
        });
        easyRefreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".i18n;
        if (message == "No more data") {}
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        errorMessage = message;
        BotToast.showText(text: message);
        easyRefreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  reset() {
    setState(() {
      nextUrl = null;
      isLoading = false;
      comments = [];
    });
    firstLoad();
    return true;
  }

  firstLoad() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          comments = value.data;
        });
        easyRefreshController.finishRefresh();
        return true;
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            errorMessage = "Network Error. Please refresh to try again.".i18n;
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
          }
        });
        easyRefreshController.finishRefresh(IndicatorResult.fail);
        return false;
      }
    });
    return false;
  }

  bool supportTranslate = false;
  String _selectedText = "";

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState,
      BuildContext context,
      bool supportTranslate) {
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

  Future<void> supportTranslateCheck() async {
    if (!DynamicData.isAndroid) return;
    bool results = false;
    //bool results = await SupportorPlugin.processText();
    if (mounted) {
      setState(() {
        supportTranslate = results;
      });
    }
  }
}
