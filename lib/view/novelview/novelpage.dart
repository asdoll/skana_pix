import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/componentwidgets/tag.dart';
import 'package:skana_pix/view/userview/userpage.dart';
import 'package:skana_pix/controller/bases.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/novel_controller.dart';
import 'package:skana_pix/controller/text_controller.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/model/tag.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/readersetting.dart';
import 'package:skana_pix/utils/text_composition/text_composition.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../../model/worktypes.dart';
import '../../componentwidgets/avatar.dart';
import '../commentpage.dart';
import '../../componentwidgets/followbutton.dart';
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
    M.addNovel(widget.novel);
    _novelStore =
        Get.put(NovelStore(widget.novel), tag: widget.novel.id.toString());
    _novelStore.fetch();
  }

  @override
  void dispose() {
    TextConfigManager.config = config;
    Get.delete<NovelStore>(tag: widget.novel.id.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextCompositionPage(
        controller: TextComposition(
            config: config,
            loadChapter: (e) => _novelStore.fetch(),
            chapters: [widget.novel.title],
            percent: 0.0,
            progressIndicator: DefaultHeaderFooter.progressIndicator(context, color: config.fontColor),
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
                  Spacer(),
                  _buildBottomRow(
                      context,
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.onSurface,
                      textComposition),
                ],
              );
            }),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: CommonBackArea(),
      title: Text(
        widget.novel.title.atMost8,
        style: const TextStyle(
          fontSize: 20,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        StarIcon(
          id: widget.novel.id.toString(),
          type: ArtworkType.NOVEL,
          liked: widget.novel.isBookmarked,
        ),
        IconButton(
            onPressed: () => buildShowModalBottomSheet(context, widget.novel),
            icon: Icon(Icons.info_outline_rounded)),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) => SizedBox(
              height: context.height > 700 ? 700 : context.height,
              child: configSettingBuilderMoon(context, config,
                  (Color color, void Function(Color color) onChange) {
                showMoonModal(
                    context: context,
                    builder: (context) => Dialog(
                            child: ListView(
                                  shrinkWrap: true,
                                children: [
                              MoonAlert(
                                borderColor: Get.context?.moonTheme
                                          ?.buttonTheme.colors.borderColor
                                          .withValues(alpha: 0.5),
                                      showBorder: true,
                                label: Text("Pick A Color".tr),
                                content: SingleChildScrollView(
                                    child: Theme(
                                  data: ThemeData.dark(),
                                  child: ColorPicker(
                                    pickerColor: color,
                                    onColorChanged: onChange,
                                    labelTypes: [],
                                    pickerAreaHeightPercent: 0.8,
                                    portraitOnly: true,
                                    hexInputBar: true,
                                  ),
                                )),
                              ),
                            ])));
              }, (e, ee) {}, (e, ee) {}),
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

  Future _showMessage(BuildContext context) {
    return showMoonModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoonMenuItem(
                  onTap: () {},
                  content: Text(
                    widget.novel.author.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  label: Text(
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
                MoonMenuItem(
                    label: Text('Previous'.tr).subHeader(),
                    content: _novelStore.novelWebResponse?.seriesNavigation
                                ?.prevNovel ==
                            null
                        ? null
                        : Text(
                                _novelStore.novelWebResponse?.seriesNavigation
                                        ?.prevNovel?.title ??
                                    "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)
                            .subHeader(),
                    onTap: _novelStore.novelWebResponse?.seriesNavigation
                                ?.prevNovel ==
                            null
                        ? null
                        : () => Get.to(NovelPageLite(_novelStore
                                .novelWebResponse
                                ?.seriesNavigation
                                ?.prevNovel
                                ?.id
                                .toString() ??
                            ""))),
                Container(height: 8),
                MoonMenuItem(
                    label: Text('Next'.tr).subHeader(),
                    content: _novelStore.novelWebResponse?.seriesNavigation
                                ?.nextNovel ==
                            null
                        ? null
                        : Text(
                                _novelStore.novelWebResponse?.seriesNavigation
                                        ?.nextNovel?.title ??
                                    "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)
                            .subHeader(),
                    onTap: _novelStore.novelWebResponse?.seriesNavigation
                                ?.nextNovel ==
                            null
                        ? null
                        : () => Get.to(NovelPageLite(_novelStore
                                .novelWebResponse
                                ?.seriesNavigation
                                ?.nextNovel
                                ?.id
                                .toString() ??
                            ""))),
                if (GetPlatform.isAndroid) Container(height: 8),
                if (GetPlatform.isAndroid)
                  MoonMenuItem(
                    label: Text("Export".tr).subHeader(),
                    leading: Icon(Icons.folder_zip),
                    onTap: () {
                      _export(context);
                    },
                  ),
                Container(height: 8),
                MoonMenuItem(
                  label: Text("Share".tr).subHeader(),
                  leading: Icon(
                    Icons.share,
                  ),
                  onTap: () {
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
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Blocked".tr,
                    ).h2().paddingBottom(16),
                    filledButton(
                        label: "Unblock".tr,
                        onPressed: () {
                          localManager.delete("blockedNovels", [widget.id]);
                        }),
                  ],
                ),
              ),
            )
          : controller.error == null
              ? controller.isLoading.value
                  ? Scaffold(
                      body: Center(
                        child: DefaultHeaderFooter.progressIndicator(context),
                      ),
                    )
                  : Scaffold(
                      body: NovelViewerPage(controller.novels.first),
                    )
              : Scaffold(
                  body: Center(
                    child: Column(
                      children: [
                        Text("Error".tr)
                            .h2()
                            .paddingBottom(16)
                            .paddingTop(context.height / 4),
                        filledButton(
                            onPressed: () {
                              controller.reset();
                            },
                            label: "Retry".tr),
                      ],
                    ),
                  ),
                ),
    );
  }
}

Future buildShowModalBottomSheet(BuildContext context, Novel novel,
    [bool showFloating = false]) {
  return showMoonModalBottomSheet(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    context: context,
    builder: (_) {
      return SafeArea(
          child: SizedBox(
        height: Get.mediaQuery.size.height * 0.6,
        child: Scaffold(
          floatingActionButton: showFloating
              ? MoonButton.icon(
                  backgroundColor: Get.context?.moonTheme?.tokens.colors.cell,
                  icon: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.black,
                  ),
                  onTap: () =>
                      Get.to(NovelViewerPage(novel), preventDuplicates: false),
                )
              : null,
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
            child: Column(
              children: [
                Container(
                  height: 20,
                ),
                Center(
                  child: PixivImage(
                    novel.coverImageUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  ).rounded(8.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                  child: Text(
                    novel.title,
                  ).header(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PainterAvatar(
                              url: novel.author.avatar,
                              id: novel.author.id,
                              size: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                novel.author.name.atMost8,
                              ).subHeader(),
                            ),
                          ]),
                      const SizedBox(width: 16),
                      UserFollowButton(
                        id: novel.author.id.toString(),
                        liked: novel.author.isFollowed,
                      ),
                    ],
                  ),
                ),
                if (novel.seriesId != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
                    child: PixTag(
                      onTap: () {
                        Get.to(() => NovelSeriesPage(novel.seriesId!));
                      },
                      f: Tag("Series:${novel.seriesTitle}", null),
                      isNovel: true,
                    ),
                  ),
                //MARK DETAIL NUM,
                _buildNumItem(novel, context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    novel.createDate.toShortTime(),
                  ).small(),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2,
                      runSpacing: 1,
                      children: [
                        if (novel.isAi)
                          PixTag(
                              f: Tag("AI-generated".tr, null), isNovel: true),
                        for (var f in novel.tags) PixTag(f: f, isNovel: true),
                      ],
                    )),
                if (novel.caption.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: context.moonTheme?.tokens.colors.frieza60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectionArea(
                          contextMenuBuilder: (context, editableTextState) {
                            return _buildSelectionMenu(
                                editableTextState, context);
                          },
                          child: SelectableHtml(data: novel.caption),
                        ),
                      ),
                    ),
                  ),
                MoonButton(
                  backgroundColor: context.moonTheme?.tokens.colors.gohan,
                  onTap: () {
                    Get.to(
                        () =>
                            CommentPage(id: novel.id, type: ArtworkType.NOVEL),
                        preventDuplicates: false);
                  },
                  leading: Icon(
                    Icons.comment,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ).paddingTop(2),
                  label: Text("Show comments".tr,
                          strutStyle: const StrutStyle(
                              forceStrutHeight: true, leading: 0))
                      .small(),
                ).paddingSymmetric(vertical: 16).paddingBottom(100),
              ],
            ),
          )),
        ),
      ));
    },
  );
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
          color: context.moonTheme?.tokens.colors.piccolo,
        ),
        Text(
          "${novel.totalBookmarks}",
        ).small(),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.remove_red_eye_rounded,
            size: 14,
            color: context.moonTheme?.tokens.colors.piccolo,
          ),
        ),
        Text(
          "${novel.totalViews}",
        ).small(),
      ],
    ),
  );
}
