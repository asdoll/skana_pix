import 'dart:io';
import 'package:flutter/material.dart'
    show AdaptiveTextSelectionToolbar, InkWell, SelectionArea;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/novel_controller.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/text_composition/text_composition.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../../model/worktypes.dart';
import '../../componentwidgets/avatar.dart';
import '../commentpage.dart';
import '../../componentwidgets/followbutton.dart';
import 'novelresult.dart';
import 'novelseries.dart';
import '../../componentwidgets/pixivimage.dart';
import '../../componentwidgets/selecthtml.dart';

class NovelViewerPage extends StatefulWidget {
  final Novel novel;

  const NovelViewerPage(this.novel, {super.key});

  @override
  State<NovelViewerPage> createState() => _NovelViewerPageState();
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
    _novelStore =
        Get.put(NovelStore(widget.novel), tag: widget.novel.id.toString());
    _novelStore.fetch();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  void dispose() {
    TextConfigManager.config = config;
    Get.delete<NovelStore>(tag: widget.novel.id.toString());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: TextCompositionPage(
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
              return Column(
                children: [
                  _buildAppBar(context),
                  Divider(),
                  Spacer(),
                  _buildBottomRow(
                      context,
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.foreground,
                      textComposition),
                ],
              );
            }),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      leading: [CommonBackArea()],
      title: Text(
        widget.novel.title.atMost8,
        style: const TextStyle(
          fontSize: 20,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: [
        StarIcon(
          id: widget.novel.id.toString(),
          type: ArtworkType.NOVEL,
          liked: widget.novel.isBookmarked,
        ),
        IconButton.ghost(
            onPressed: () => buildShowModalBottomSheet(context),
            icon: Icon(Icons.info_outline_rounded)),
        IconButton.ghost(
          icon: Icon(Icons.settings),
          onPressed: () => openSheet(
            context: context,
            position: OverlayPosition.bottom,
            builder: (context) => SizedBox(
              height: context.height > 700 ? 700 : context.height,
              child: configSettingBuilder(context, config,
                  (Color color, void Function(Color color) onChange) {
                showColorPickerDialog(
                  title: Text("Pick A Color".tr),
                  context: context,
                  color: ColorDerivative.fromColor(color),
                  onColorChanged: (value) {
                    onChange(value.toColor());
                  },
                );
              }, (e, ee) {}, (e, ee) {}),
            ),
          ),
        ),
        IconButton.ghost(
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
                          border:
                              Border.all(color: color.withAlpha(65), width: 1),
                        ),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      inactiveTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: color.withAlpha(50),
                      ),
                      activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.primary,
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
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$index / ${composition.textPages[composition.currentIndex]!.total}",
                                overflow: TextOverflow.ellipsis,
                              ).xSmall(),
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
                                Text("Previous".tr,
                                    style: TextStyle(color: color))
                              else
                                Text("NoMore".tr,
                                    style: TextStyle(color: color))
                            ],
                          ),
                          onTap: () {
                            if (_novelStore.novelWebResponse!.seriesNavigation
                                    ?.prevNovel ==
                                null) {
                              return;
                            }
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
                                Text("Next".tr, style: TextStyle(color: color))
                              else
                                Text("No more".tr,
                                    style: TextStyle(color: color))
                            ],
                          ),
                          onTap: () {
                            if (_novelStore.novelWebResponse!.seriesNavigation
                                    ?.nextNovel ==
                                null) {
                              return;
                            }
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
    return openSheet(
      context: context,
      position: OverlayPosition.bottom,
      builder: (_) {
        return SizedBox(
          height: Get.mediaQuery.size.height * 0.6,
          child: Scaffold(
            child: SingleChildScrollView(child: _buildFirstView(context)),
          ),
        );
      },
    );
  }

  Widget _buildFirstView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
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
              widget.novel.title,
            ).h4(),
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
                    size: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      widget.novel.author.name.atMost8,
                    ).xSmall(),
                  ),
                ]),
                const SizedBox(width: 16),
                UserFollowButton(
                  id: widget.novel.author.id.toString(),
                  liked: widget.novel.author.isFollowed,
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
                  Get.to(() => NovelSeriesPage(widget.novel.seriesId!));
                },
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: mtc.theme.value.colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
                    "Series:${widget.novel.seriesTitle}",
                  ).textSmall().semiBold(),
                ),
              ),
            ),
          //MARK DETAIL NUM,
          _buildNumItem(widget.novel, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.novel.createDate.toShortTime(),
              style: mtc.theme.value.typography.textSmall,
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
                    Text("AI-generated".tr,
                        style: mtc.theme.value.typography.textSmall.copyWith(
                            color: mtc.theme.value.colorScheme.secondary)),
                  for (var f in widget.novel.tags) buildRow(context, f)
                ],
              )),
          if (widget.novel.caption.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectionArea(
                    contextMenuBuilder: (context, editableTextState) {
                      return _buildSelectionMenu(editableTextState, context);
                    },
                    child: SelectableHtml(data: widget.novel.caption),
                  ),
                ),
              ),
            ),
          Button(
            onPressed: () {
              Get.to(
                  () =>
                      CommentPage(id: widget.novel.id, type: ArtworkType.NOVEL),
                  preventDuplicates: false);
            },
            style: ButtonStyle.card(density: ButtonDensity.dense),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: mtc.theme.value.colorScheme.primary,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Show comments".tr,
                  ).xSmall(),
                ]),
          ).paddingSymmetric(vertical: 16),
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
          color: mtc.theme.value.colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "#${f.name}",
                children: [
                  TextSpan(
                    text: " ",
                    style: mtc.theme.value.typography.textSmall,
                  ),
                  TextSpan(
                      text: f.translatedName ?? "~",
                      style: mtc.theme.value.typography.textSmall)
                ],
                style: mtc.theme.value.typography.textSmall.copyWith(
                    color: mtc.theme.value.colorScheme.secondaryForeground))),
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
                    style: mtc.theme.value.typography.textLarge
                        .copyWith(color: mtc.theme.value.colorScheme.primary)),
                if (f.translatedName != null)
                  TextSpan(
                      text: "\n${"${f.translatedName}"}",
                      style: mtc.theme.value.typography.textLarge)
              ]),
            ).withAlign(Alignment.centerLeft),
            actions: <Widget>[
              OutlineButton(
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

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
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
          Icon(
            Icons.bookmark,
            size: 14,
            color: mtc.theme.value.colorScheme.primary,
          ),
          Text("${novel.totalBookmarks}",
              style: mtc.theme.value.typography.textSmall.copyWith(
                  color: mtc.theme.value.colorScheme.mutedForeground)),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.remove_red_eye_rounded,
              size: 14,
              color: mtc.theme.value.colorScheme.primary,
            ),
          ),
          Text("${novel.totalViews}",
              style: mtc.theme.value.typography.textSmall.copyWith(
                  color: mtc.theme.value.colorScheme.mutedForeground)),
        ],
      ),
    );
  }

  Future _showMessage(BuildContext context) {
    return openSheet(
        context: context,
        position: OverlayPosition.bottom,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Basic(
                  subtitle: Text(
                    widget.novel.author.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  title: Text(
                    widget.novel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: PainterAvatar(
                    url: widget.novel.author.avatar,
                    id: widget.novel.author.id,
                    onTap: () {
                      Get.to(
                          UserPage(
                            id: widget.novel.author.id,
                            type: ArtworkType.NOVEL,
                          ),
                          preventDuplicates: false);
                    },
                  ),
                ).paddingVertical(16),
                Button(
                    style: ButtonStyle.card(density: ButtonDensity.dense),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Previous'.tr).textSmall(),
                        buildListTile(
                            _novelStore
                                .novelWebResponse!.seriesNavigation?.prevNovel,
                            context),
                      ],
                    )),
                Container(height: 8),
                Button(
                    style: ButtonStyle.card(density: ButtonDensity.dense),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Next'.tr).textSmall(),
                        buildListTile(
                            _novelStore
                                .novelWebResponse!.seriesNavigation?.nextNovel,
                            context),
                      ],
                    )),
                if (GetPlatform.isAndroid) Container(height: 8),
                if (GetPlatform.isAndroid)
                  Button(
                    style: ButtonStyle.card(density: ButtonDensity.dense),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Basic(
                          title: Text("Export".tr),
                          leading: Icon(Icons.folder_zip).textSmall(),
                        ).textSmall(),
                      ],
                    ),
                    onPressed: () {
                      _export(context);
                    },
                  ),
                Container(height: 8),
                Button(
                  style: ButtonStyle.card(density: ButtonDensity.dense),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Basic(
                            title: Text("Share".tr).textSmall(),
                            leading: Icon(
                              Icons.share,
                            )).textSmall(),
                      ]),
                  onPressed: () {
                    Get.back();
                    Share.share(
                        "https://www.pixiv.net/novel/show.php?id=${widget.novel.id}");
                  },
                ),
              ],
            ).paddingHorizontal(16),
          );
        });
  }

  Widget buildListTile(SimpleNovel? relNovel, BuildContext context) {
    if (relNovel == null) {
      return Basic(
        title: Text("No more".tr).xSmall(),
      );
    }
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  NovelPageLite(relNovel.id.toString())));
        },
        child: Basic(
          title:
              Text(relNovel.title, maxLines: 2, overflow: TextOverflow.ellipsis)
                  .xSmall(),
        ));
  }

  void _export(BuildContext context) async {
    if (_novelStore.stringContent.isEmpty) return;
    String targetPath = path.join(
        BasePath.cachePath, "share_cache", "${widget.novel.title}.txt");
    File file = File(targetPath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    await file.writeAsString(_novelStore.stringContent);
    final box = context.findRenderObject() as RenderBox?;
    Share.shareXFiles([XFile(targetPath)],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    log.d("path: $targetPath");
  }
}

class NovelPageLite extends StatefulWidget {
  final String id;
  const NovelPageLite(this.id, {super.key});
  @override
  State<NovelPageLite> createState() => _NovelPageLiteState();
}

class _NovelPageLiteState extends State<NovelPageLite> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(tag: "novel_${widget.id}");
  }

  @override
  Widget build(BuildContext context) {
    ListNovelController controller = Get.put(
        ListNovelController(controllerType: ListType.single, id: widget.id),
        tag: "novel_${widget.id}");
    controller.reset();
    return Obx(
      () => localManager.blockedNovels.contains(widget.id)
          ? Scaffold(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Blocked".tr,
                      style: Theme.of(context).typography.h2,
                    ).paddingBottom(16),
                    PrimaryButton(
                        onPressed: () {
                          localManager.delete("blockedNovels", [widget.id]);
                        },
                        child: Text("Unblock".tr)),
                  ],
                ),
              ),
            )
          : controller.error == null
              ? controller.isLoading.value
                  ? Scaffold(
                      headers: [
                        AppBar(
                          title: Text("Loading".tr),
                        ),
                        const Divider()
                      ],
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Scaffold(
                      headers: [
                        AppBar(
                          title: Text(controller.novels.first.title),
                        ),
                        const Divider()
                      ],
                      child: NovelViewerPage(controller.novels.first),
                    )
              : Scaffold(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Error".tr,
                          style: Theme.of(context).typography.h3,
                        ).paddingBottom(16).paddingTop(context.height / 4),
                        PrimaryButton(
                            onPressed: () {
                              controller.reset();
                            },
                            child: Text("Retry".tr)),
                      ],
                    ),
                  ),
                ),
    );
  }
}
