import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../view/defaults.dart';
import 'avatar.dart';
import 'commentpage.dart';
import 'followbutton.dart';
import 'novelresult.dart';
import 'novelseries.dart';
import 'pixivimage.dart';
import 'selecthtml.dart';

class NovelViewerPage extends StatefulWidget {
  final Novel novel;

  NovelViewerPage(this.novel, {super.key});

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  bool _isBottomBarVisible = true;
  bool _isAppBarVisible = true;
  late NovelStore _novelStore;
  // ignore: unused_field
  String _selectedText = "";
  late int nowPosition;
  late PageController _pageController;
  late double fontsize;

  _isShow() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
      _isBottomBarVisible = !_isBottomBarVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    fontsize = settings.fontSize;
    _novelStore = NovelStore(
        widget.novel, DynamicData.heightScreen, DynamicData.widthScreen,
        fontSize: fontsize);
    _novelStore.fetch();
    nowPosition = 0;
    _pageController = PageController(initialPage: nowPosition);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isShow,
            onHorizontalDragEnd: (DragEndDetails detail) {
              final pixelsPerSecond = detail.velocity.pixelsPerSecond;
              if (pixelsPerSecond.dy.abs() > pixelsPerSecond.dx.abs()) return;
              if (pixelsPerSecond.dx.abs() > _novelStore.pageWidth) {
                int result = nowPosition;
                if (pixelsPerSecond.dx < 0)
                  result++;
                else
                  result--;
                _pageController.animateToPage(result,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
                if (result >= _novelStore.pageConfig.length + 1)
                  result = _novelStore.pageConfig.length;
                if (result < 0) result = 0;
                setState(() {
                  nowPosition = result;
                });
              }
            },
            child: Observer(
              builder: (_) {
                if (_novelStore.errorMessage != null) {
                  return _buildFailPage(context);
                }
                if (_novelStore.pageConfig.isEmpty &&
                    _novelStore.errorMessage == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return PageView.builder(
                  controller: _pageController,
                  //physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0)
                      return SingleChildScrollView(
                          child: _buildFirstView(context));
                    final f = _novelStore.pageConfig[index - 1];
                    return Container(
                      width: _novelStore.pageWidth,
                      height: _novelStore.pageHeight,
                      padding: EdgeInsets.only(
                          left: _novelStore.linePaddingHorizontal,
                          right: _novelStore.linePaddingHorizontal,
                          top: _novelStore.paddingVertical * 1.5),
                      child: Text(
                        f,
                        style: TextStyle(fontSize: fontsize),
                      ),
                    );
                  },
                  itemCount: _novelStore.pageConfig.length + 1,
                );
              },
            ),
          ),
          if (_isAppBarVisible)
            _buildAppBar(context,
                height: kToolbarHeight,
                minHeight: 40,
                duration: Duration(milliseconds: 200),
                isAppBarVisible: _isAppBarVisible),
        ],
      ),
      bottomNavigationBar: _buildBottmAppBar(
        context,
        height: 100,
        minHeight: 0,
        duration: Duration(milliseconds: 200),
        isBottomBarVisible: _isBottomBarVisible,
      ),
    );
  }

  _buildFailPage(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(':(',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                _novelStore.fetch();
              },
              child: Text("Retry".i18n)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Network error'.i18n,
                style: Theme.of(context).textTheme.labelSmall),
          )
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context,
      {required double height,
      required double minHeight,
      required Duration duration,
      required bool isAppBarVisible}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        height: _isAppBarVisible ? height * 1.5 : minHeight,
        duration: duration,
        child: AnimatedOpacity(
          opacity: _isAppBarVisible ? 1.0 : 0.0,
          duration: duration,
          child: SingleChildScrollView(
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              leading: const BackButton(),
              title: Text(
                widget.novel.title.atMost8,
                style: const TextStyle(
                  fontSize: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.bookmark),
                    onPressed: () {
                      // _saveNovelBookMark();
                    }),
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      _shareNovel();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          Container(
            height: 100,
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
                        color: Colors.white,
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
                child: Text(
                  "Series:${widget.novel.seriesTitle}",
                  style: Theme.of(context).textTheme.titleSmall,
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
                runSpacing: 0,
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectionArea(
                  onSelectionChanged: (value) {
                    _selectedText = value?.plainText ?? "";
                  },
                  contextMenuBuilder: (context, editableTextState) {
                    return _buildSelectionMenu(editableTextState, context);
                  },
                  child: SelectableHtml(data: widget.novel.caption),
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CommentPage(
                        id: widget.novel.id, type: CommentArtWorkType.NOVEL)));
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
      widget.novel.author.isFollowed = !widget.novel.author.isFollowed;
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
        //_longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NovelResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
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
    );
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

  _buildBottmAppBar(BuildContext context,
      {required double height,
      required double minHeight,
      required Duration duration,
      required bool isBottomBarVisible}) {
    //bool isDark = _themeStyleProvider.theme.brightness != Brightness.dark;
    return AnimatedContainer(
      height: isBottomBarVisible ? height : minHeight,
      duration: duration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: AnimatedOpacity(
        opacity: isBottomBarVisible ? 1 : 0,
        duration: duration,
        child: BottomAppBar(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      _pageController
                          .jumpToPage(_novelStore.pageConfig.length - 1);
                      setState(() {
                        nowPosition = _novelStore.pageConfig.length - 1;
                      });
                    }),
                IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      // _openBookmarkList();
                    }),
                IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      // _openSetting();
                    }),
                // _buildBottomAppBarItem(
                //     icon: isDark ? Icons.nightlight : Icons.wb_sunny,
                //     text: isDark ? "夜间" : "白天",
                //     onPressed: _themeStyleProvider.switchTheme),
                IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      BotToast.showText(text: "Coming soon".i18n);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareNovel() {
    Share.share("https://www.pixiv.net/novel/show.php?id=${widget.novel.id}");
  }
}

class NovelStore {
  final Novel novel;
  final double fontSize;
  final double linePaddingHorizontal;
  final double paddingVertical;
  final double lineSpace;
  final double pageHeight;
  final double pageWidth;
  late String stringContent;
  late ObservableList<String> pageConfig = ObservableList();
  String? errorMessage;
  late TextPainter textPainter;

  NovelStore(this.novel, this.pageHeight, this.pageWidth,
      {this.fontSize = 20,
      this.linePaddingHorizontal = 10,
      this.paddingVertical = kToolbarHeight,
      this.lineSpace = 0});

  Future<List<String>> parse(String content) async {
    List<int> result = [];
    List<String> resultString = [];
    String tmp = stringContent;
    textPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: tmp,
        style: TextStyle(fontSize: fontSize),
      ),
    );
    var width = pageWidth - linePaddingHorizontal * 2;
    textPainter.layout(maxWidth: width);
    double lineHeight = textPainter.preferredLineHeight;
    int lineNumberPerPage = (pageHeight - paddingVertical * 2.5) ~/ lineHeight;
    lineNumberPerPage = lineNumberPerPage - 1;
    // int pageNum = (lineNumber / lineNumberPerPage).ceil();
    double actualPageHeight = lineNumberPerPage * lineHeight;
    while (true) {
      textPainter = TextPainter(
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: tmp,
          style: TextStyle(fontSize: fontSize),
        ),
      );
      textPainter.layout(maxWidth: width);

      var end = textPainter
          .getPositionForOffset(Offset(width, actualPageHeight))
          .offset;

      if (end == 0) {
        break;
      }

      result.add(end);
      resultString.add(tmp.substring(0, end));

      tmp = tmp.substring(end, tmp.length);
      while (tmp.startsWith("\n")) {
        tmp = tmp.substring(1);
      }
    }
    return resultString;
  }

  Future<void> fetch() async {
    errorMessage = null;
    try {
      Res<String> response =
          await ConnectManager().apiClient.getNovelContent(novel.id.toString());
      if (response.error) {
        throw BadResponseException(response.errMsg);
      }
      stringContent = response.data;
      List<String> result = await parse(stringContent);
      if (result.isEmpty) {
        throw BadResponseException("No content");
      }
      pageConfig.addAll(result);
    } catch (e) {
      loggerError(e.toString());
      errorMessage = e.toString();
    }
  }
}
