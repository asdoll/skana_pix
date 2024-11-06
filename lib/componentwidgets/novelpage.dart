import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/novelbookmark.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/text_composition/text_composition.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../model/worktypes.dart';
import '../view/defaults.dart';
import 'avatar.dart';
import 'commentpage.dart';
import 'followbutton.dart';
import 'loading.dart';
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
  late NovelStore _novelStore;
  // ignore: unused_field
  String _selectedText = "";
  late TextCompositionConfig config;

  @override
  void initState() {
    super.initState();
    config = TextConfigManager.config;
    historyManager.addNovel(widget.novel);
    _novelStore = NovelStore(widget.novel);
    _novelStore.fetch();
  }

  @override
  void dispose() {
    TextConfigManager.config = config;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor:
                config.backgroundColor),
      ),
      body: Observer(
        builder: (_) {
          return TextCompositionPage(
            controller: TextComposition(
                config: config,
                loadChapter: (e) => _novelStore.fetch(),
                chapters: [widget.novel.title],
                percent: 0.0,
                onSave: (TextCompositionConfig config, double percent) {
                  // Global.prefs.setString(TextConfigKey, config);
                  // searchItem.durContentIndex = (percent * NovelContentTotal).floor();
                  //print("save config: $config");
                  //print("save percent: $percent");
                },
                name: widget.novel.title,
                menuBuilder: (textComposition) {
                  return Container(
                      child: Column(
                    children: [
                      _buildAppBar(context),
                      Spacer(),
                      _buildBottomRow(
                          context,
                          Theme.of(context).colorScheme.surfaceContainer,
                          Theme.of(context).colorScheme.onSurface,
                          textComposition),
                    ],
                  ));
                }),
          );
        },
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child:
                  Text(":(", style: Theme.of(context).textTheme.headlineMedium),
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
          ),
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
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
        NovelBookmarkButton(novel: widget.novel, colorMode: "default"),
        IconButton(
            onPressed: () => buildShowModalBottomSheet(context),
            icon: Icon(Icons.info_outline_rounded)),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 520,
                child: configSettingBuilder(context, config,
                    (Color color, void Function(Color color) onChange) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Pick A Color".i18n),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: color,
                          onColorChanged: onChange,
                          labelTypes: [],
                          pickerAreaHeightPercent: 0.8,
                          portraitOnly: true,
                          hexInputBar: true,
                        ),
                      ),
                    ),
                  );
                }, (e, ee) {}, (e, ee) {}),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            _showMessage(context);
          },
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, Color bgColor, Color color,
      TextComposition composition) {
    return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Text(
                  '   ',
                  style: TextStyle(color: color),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FlutterSlider(
                    values: [
                      0.0 +
                          (composition.textPages[composition.currentIndex]
                                  ?.number ??
                              1)
                    ],
                    max:
                        composition.textPages[composition.currentIndex]!.total *
                            1.0,
                    min: 1,
                    step: FlutterSliderStep(step: 1),
                    onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                      // provider.loadChapter((lowerValue as double).toInt() - 1);
                      //BotToast.showText(text: "${(lowerValue as double).toInt() - 1}");
                      composition.goToPage(composition.currentIndex +
                          (lowerValue as double).toInt() -
                          1 -
                          composition
                              .textPages[composition.currentIndex]!.number);
                    },
                    // disabled: provider.isLoading,
                    handlerWidth: 6,
                    handlerHeight: 14,
                    handler: FlutterSliderHandler(
                      decoration: BoxDecoration(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: bgColor,
                          border: Border.all(
                              color: color.withOpacity(0.65), width: 1),
                        ),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      inactiveTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: color.withOpacity(0.5),
                      ),
                      activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    touchSize: 30,
                    tooltip: FlutterSliderTooltip(
                      alwaysShowTooltip: true,
                      disableAnimation: false,
                      positionOffset: FlutterSliderTooltipPositionOffset(
                        // left: -20,
                        top: -40,
                        // right: 80 - MediaQuery.of(context).size.width,
                      ),
                      custom: (value) {
                        final index = (value as double).toInt();
                        return Container(
                          color: bgColor,
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$index / ${composition.textPages[composition.currentIndex]!.total}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: composition.config.fontFamily,
                                  color: color.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ).rounded(8.0);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '   ',
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (_novelStore.novelWebResponse!.seriesNavigation
                                ?.prevNovel ==
                            null &&
                        _novelStore.novelWebResponse!.seriesNavigation
                                ?.nextNovel ==
                            null)
                    ? []
                    : [
                        InkWell(
                          child: Column(
                            children: [
                              Icon(Icons.library_books_rounded,
                                  color: color, size: 20),
                              if (_novelStore.novelWebResponse!.seriesNavigation
                                      ?.prevNovel !=
                                  null)
                                Text("Previous".i18n,
                                    style: TextStyle(color: color))
                              else
                                Text("NoMore".i18n,
                                    style: TextStyle(color: color))
                            ],
                          ),
                          onTap: () {
                            if (_novelStore.novelWebResponse!.seriesNavigation
                                    ?.prevNovel ==
                                null) return;
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NovelPageLite(_novelStore
                                            .novelWebResponse!
                                            .seriesNavigation!
                                            .prevNovel!
                                            .id
                                            .toString())));
                          },
                        ),
                        InkWell(
                          child: Column(
                            children: [
                              Icon(Icons.library_books_rounded,
                                  color: color, size: 20),
                              if (_novelStore.novelWebResponse!.seriesNavigation
                                      ?.nextNovel !=
                                  null)
                                Text("Next".i18n,
                                    style: TextStyle(color: color))
                              else
                                Text("No more".i18n,
                                    style: TextStyle(color: color))
                            ],
                          ),
                          onTap: () {
                            if (_novelStore.novelWebResponse!.seriesNavigation
                                    ?.nextNovel ==
                                null) return;
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NovelPageLite(_novelStore
                                            .novelWebResponse!
                                            .seriesNavigation!
                                            .nextNovel!
                                            .id
                                            .toString())));
                          },
                        ),
                        // InkWell(
                        //   child: Column(
                        //     children: [
                        //       Icon(Icons.arrow_back, color: color, size: 28),
                        //       Text("上一章", style: TextStyle(color: color))
                        //     ],
                        //   ),
                        //   onTap: () => composition.gotoPreviousChapter(),
                        // ),
                        // InkWell(
                        //   child: Column(
                        //     children: [
                        //       Icon(Icons.format_list_bulleted,
                        //           color: color, size: 20),
                        //       Text("目录", style: TextStyle(color: color))
                        //     ],
                        //   ),
                        //   onTap: () {},
                        // ),
                        // InkWell(
                        //   child: Column(
                        //     children: [
                        //       Icon(Icons.arrow_forward, color: color, size: 28),
                        //       Text("下一章", style: TextStyle(color: color))
                        //     ],
                        //   ),
                        //   onTap: () => composition.gotoNextChapter(),
                        // ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
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
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0))),
          child: SingleChildScrollView(child: _buildFirstView(context)),
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
                    _selectedText = value?.plainText ?? "";
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

  Future _showMessage(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  subtitle: Text(
                    widget.novel.author.name,
                    maxLines: 2,
                  ),
                  title: Text(
                    widget.novel.title,
                    maxLines: 2,
                  ),
                  leading: PainterAvatar(
                    url: widget.novel.author.avatar,
                    id: widget.novel.author.id,
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return UserPage(
                          id: widget.novel.author.id,
                          type: ArtworkType.NOVEL,
                        );
                      }));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Previous'.i18n),
                ),
                buildListTile(
                    _novelStore.novelWebResponse!.seriesNavigation?.prevNovel,
                    context),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Next'.i18n),
                ),
                buildListTile(
                    _novelStore.novelWebResponse!.seriesNavigation?.nextNovel,
                    context),
                if (DynamicData.isAndroid)
                  ListTile(
                    title: Text("Export".i18n),
                    leading: Icon(Icons.folder_zip),
                    onTap: () {
                      _export(context);
                    },
                  ),
                ListTile(
                  title: Text("Share".i18n),
                  leading: Icon(
                    Icons.share,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(
                        "https://www.pixiv.net/novel/show.php?id=${widget.novel.id}");
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget buildListTile(SimpleNovel? relNovel, BuildContext context) {
    if (relNovel == null)
      return ListTile(
        title: Text("No more".i18n),
      );
    return ListTile(
      title: Text(relNovel.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NovelPageLite(relNovel.id.toString())));
      },
    );
  }

  void _export(BuildContext context) async {
    if (_novelStore.stringContent.isEmpty) return;
    String targetPath =
        join(BasePath.cachePath, "share_cache", "${widget.novel.title}.txt");
    File file = File(targetPath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    await file.writeAsString(_novelStore.stringContent);
    final box = context.findRenderObject() as RenderBox?;
    Share.shareXFiles([XFile(targetPath)],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    logger("path: $targetPath");
  }
}

class NovelStore {
  final Novel novel;
  late String stringContent;
  List<String> result = [];
  String? errorMessage;
  NovelWebResponse? novelWebResponse;
  TextSpan? textSpan;

  NovelStore(this.novel);

  Future<List<String>> fetch() async {
    errorMessage = null;
    try {
      Res<NovelWebResponse> response =
          await ConnectManager().apiClient.getNovelContent(novel.id.toString());
      if (response.error) {
        throw BadResponseException(response.errMsg);
      }
      novelWebResponse = response.data;
      stringContent = novelWebResponse!.text;
      result = stringContent.split(RegExp(r"\n\s*|\s{2,}"));
      if (result.isEmpty) {
        throw BadResponseException("No content");
      }
      return result;
    } catch (e) {
      loggerError(e.toString());
      errorMessage = e.toString();
    }
    return result;
  }
}

class NovelPageLite extends StatefulWidget {
  final String id;
  const NovelPageLite(this.id, {super.key});
  @override
  _NovelPageLiteState createState() => _NovelPageLiteState();
}

class _NovelPageLiteState extends LoadingState<NovelPageLite, Novel> {
  @override
  Widget buildContent(BuildContext context, Novel data) {
    return NovelViewerPage(data);
  }

  @override
  Future<Res<Novel>> loadData() {
    return getNovelById(widget.id);
  }
}
