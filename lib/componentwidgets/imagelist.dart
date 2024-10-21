import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/defaults.dart';

import '../controller/downloader.dart';
import '../controller/histories.dart';
import '../utils/filters.dart';
import 'commentpage.dart';
import 'imagepage.dart';
import 'message.dart';
import 'pixivimage.dart';
import 'relatedillusts.dart';
import 'routes.dart';

const _kBottomBarHeight = 64.0;

class ImageListPage extends StatefulWidget {
  const ImageListPage(Illust illust,
      {required this.illusts,
      required this.initialPage,
      this.nextUrl,
      super.key});

  final List<Illust> illusts;

  final int initialPage;

  final String? nextUrl;

  static var cachedHistoryIds = <int>{};

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  late List<Illust> illusts;

  late final PageController controller;

  String? nextUrl;

  bool loading = false;

  late int page = widget.initialPage;

  @override
  void initState() {
    illusts = List.from(widget.illusts);
    controller = PageController(initialPage: widget.initialPage);
    nextUrl = widget.nextUrl;
    if (nextUrl == "end") {
      nextUrl = null;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (ImageListPage.cachedHistoryIds.length > 5) {
      sendHistory(ImageListPage.cachedHistoryIds.toList().reversed.toList());
      ImageListPage.cachedHistoryIds.clear();
    }
    super.dispose();
  }

  void nextPage() {
    var length = illusts.length;
    if (controller.page == length - 1) return;
    controller.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  void previousPage() {
    if (controller.page == 0) return;
    controller.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ImagePage(widget.illust.images.map((e) => e.large).toList());
  // }

  @override
  Widget build(BuildContext context) {
    var length = illusts.length;
    if (nextUrl != null) {
      length++;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: controller,
            itemCount: length,
            itemBuilder: (context, index) {
              if (index == illusts.length) {
                return buildLast();
              }
              return IllustPage(illusts[index],
                  nextPage: nextPage, previousPage: previousPage);
            },
            onPageChanged: (value) => setState(() {
              page = value;
            }),
          ),
        ),
        if (page < length - 1 && length > 1 && DynamicData.isDesktop)
          Positioned(
            right: 0,
            top: 0,
            bottom: 32,
            child: Center(
                child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                nextPage();
              },
            )),
          ),
        if (page != 0 && length > 1 && DynamicData.isDesktop)
          Positioned(
            left: 0,
            top: 0,
            bottom: 32,
            child: Center(
                child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                previousPage();
              },
            )),
          ),
      ],
    );
  }

  Widget buildLast() {
    if (nextUrl == null) {
      return const SizedBox();
    }
    load();
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  void load() async {
    if (loading) return;
    loading = true;

    var res = await getIllustsWithNextUrl(nextUrl!);
    loading = false;
    if (res.error) {
      if (mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      nextUrl = res.subData;
      illusts.addAll(res.data);
      setState(() {});
    }
  }
}

class IllustPage extends StatefulWidget {
  const IllustPage(this.illust, {this.nextPage, this.previousPage, super.key});

  final Illust illust;

  final void Function()? nextPage;

  final void Function()? previousPage;

  static Map<String, UpdateFollowCallback> followCallbacks = {};

  @override
  State<IllustPage> createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  String get id => "${widget.illust.author.id}#${widget.illust.id}";

  final _bottomBarController = _BottomBarController();

  // KeyEventListenerState? keyboardListener;

  @override
  void initState() {
    // keyboardListener = KeyEventListener.of(context);
    // keyboardListener?.removeAll();
    // keyboardListener?.addHandler(handleKey);
    IllustPage.followCallbacks[id] = (v) {
      setState(() {
        widget.illust.author.isFollowed = v;
      });
    };
    HistoryManager().addHistory(widget.illust);
    if (user.isPremium) {
      ImageListPage.cachedHistoryIds.add(widget.illust.id);
    }
    super.initState();
  }

  @override
  void dispose() {
    //keyboardListener?.removeHandler(handleKey);
    IllustPage.followCallbacks.remove(id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox.expand(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: LayoutBuilder(builder: (context, constrains) {
            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: buildBody(constrains.maxWidth, constrains.maxHeight),
                ),
                _BottomBar(
                  widget.illust,
                  constrains.maxHeight,
                  constrains.maxWidth,
                  updateCallback: () => setState(() {}),
                  controller: _bottomBarController,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  final scrollController = ScrollController();

  // void handleKey(LogicalKeyboardKey key) {
  //   const kShortcutScrollOffset = 200;

  //   var shortcuts = appdata.settings["shortcuts"] as List;

  //   switch (shortcuts.indexOf(key.keyId)) {
  //     case 0:
  //       if (scrollController.position.pixels >=
  //           scrollController.position.maxScrollExtent) {
  //         _bottomBarController.openOrClose();
  //       } else {
  //         scrollController.animateTo(
  //           scrollController.offset + kShortcutScrollOffset,
  //           duration: const Duration(milliseconds: 200),
  //           curve: Curves.easeOut,
  //         );
  //       }
  //       break;
  //     case 1:
  //       if (_bottomBarController.isOpen()) {
  //         _bottomBarController.openOrClose();
  //         break;
  //       }
  //       scrollController.animateTo(
  //         scrollController.offset - kShortcutScrollOffset,
  //         duration: const Duration(milliseconds: 200),
  //         curve: Curves.easeOut,
  //       );
  //       break;
  //     case 2:
  //       widget.nextPage?.call();
  //       break;
  //     case 3:
  //       widget.previousPage?.call();
  //       break;
  //     case 4:
  //       _bottomBarController.favorite();
  //     case 5:
  //       _bottomBarController.download();
  //     case 6:
  //       _bottomBarController.follow();
  //     case 7:
  //       if (ModalRoute.of(context)?.isCurrent ?? true) {
  //         CommentsPage.show(context, widget.illust.id.toString());
  //       } else {
  //         context.pop();
  //       }
  //     case 8:
  //       openImage(0);
  //   }
  // }

  var isBlocked = false;

  Widget buildBody(double width, double height) {
    isBlocked = checkIllusts([widget.illust]).isEmpty;
    if (isBlocked) {
      return ListView(
        children: [
          AppBar(
            title: Text(widget.illust.title),
          ),
          const Positioned.fill(
              child: Center(
            child: Center(
                child: Text(
              "This artwork is blocked",
            )),
          )),
        ],
      );
    }
    return ListView.builder(
        controller: scrollController,
        itemCount: widget.illust.images.length + 2,
        padding: EdgeInsets.only(
            top: 0, bottom: _kBottomBarHeight + context.padding.bottom),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AppBar(title: Text(widget.illust.title));
          }
          return buildImage(width, height, index);
        });
  }

  Widget buildImage(double width, double height, int index) {
    index--;
    // File? downloadFile;
    // if (downloaded(widget.illust.id)) {
    //   downloadFile = DownloadManager().getImage(widget.illust.id, index);
    // }
    if (index == widget.illust.images.length) {
      return SizedBox(
        height: _kBottomBarHeight + context.padding.bottom,
      );
    }
    var imageWidth = width;
    var imageHeight = widget.illust.height * width / widget.illust.width;
    if (imageHeight > height) {
      // 确保图片能够完整显示在屏幕上
      var scale = imageHeight / height;
      imageWidth = imageWidth / scale;
      imageHeight = height;
    }
    Widget image;

    var imageUrl = settings.showOriginal
        ? widget.illust.images[index].original
        : widget.illust.images[index].medium;

    //if (!widget.illust.isUgoira) {
    image = SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: GestureDetector(
            onTap: () => PersistentNavBarNavigator.pushNewScreen(context,
                screen: ImagePage(
                    widget.illust.images.map((e) => e.large).toList())),
            child: PixivImage(
              imageUrl,
              width: width,
              height: height,
            )));
    //} else {
    //TODO: UgoiraWidget
    // image = UgoiraWidget(
    //   id: widget.illust.id.toString(),
    //   previewImage: CachedImageProvider(widget.illust.images[index].large),
    //   width: imageWidth,
    //   height: imageHeight,
    // );
    //}

    return Center(
      child: image,
    );
  }
}

class _BottomBarController {
  VoidCallback? _openOrClose;

  VoidCallback get openOrClose => _openOrClose!;

  bool Function()? _isOpen;

  bool isOpen() => _isOpen!();

  VoidCallback? _favorite;

  VoidCallback get favorite => _favorite!;

  VoidCallback? _download;

  VoidCallback get download => _download!;

  VoidCallback? _follow;

  VoidCallback get follow => _follow!;
}

class _BottomBar extends StatefulWidget {
  const _BottomBar(this.illust, this.height, this.width,
      {this.updateCallback, this.controller});

  final void Function()? updateCallback;

  final Illust illust;

  final double height;

  final double width;

  final _BottomBarController? controller;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> with TickerProviderStateMixin {
  double pageHeight = 0;

  double widgetHeight = 48;

  final key = GlobalKey();

  double _width = 0;

  late VerticalDragGestureRecognizer _recognizer;

  late final AnimationController animationController;

  double get minValue => pageHeight - widgetHeight;
  double get maxValue =>
      pageHeight - _kBottomBarHeight - context.padding.bottom;

  @override
  void initState() {
    _width = widget.width;
    pageHeight = widget.height;
    Future.delayed(const Duration(milliseconds: 200), () {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      widgetHeight = (box?.size.height) ?? 0;
    });
    _recognizer = VerticalDragGestureRecognizer()
      ..onStart = _handlePointerDown
      ..onUpdate = _handlePointerMove
      ..onEnd = _handlePointerUp
      ..onCancel = _handlePointerCancel;
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180), value: 1);
    if (widget.controller != null) {
      widget.controller!._openOrClose = () {
        if (animationController.value == 0) {
          animationController.animateTo(1);
        } else if (animationController.value == 1) {
          animationController.animateTo(0);
        }
      };
      widget.controller!._isOpen = () => animationController.value == 0;
      widget.controller!._favorite = likes;
      widget.controller!._download = () {
        DownloadManager().addDownloadingTask(widget.illust);
        setState(() {});
      };
      widget.controller!._follow = follow;
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    _recognizer.dispose();
    super.dispose();
  }

  void _handlePointerDown(DragStartDetails details) {}
  void _handlePointerMove(DragUpdateDetails details) {
    var offset = details.primaryDelta ?? 0;
    final minValue = pageHeight - widgetHeight;
    final maxValue = pageHeight - _kBottomBarHeight - context.padding.bottom;
    var top = animationController.value * (maxValue - minValue) + minValue;
    top = (top + offset).clamp(minValue, maxValue);
    animationController.value = (top - minValue) / (maxValue - minValue);
  }

  void _handlePointerUp(DragEndDetails details) {
    var speed = details.primaryVelocity ?? 0;
    const minShouldTransitionSpeed = 1000;
    if (speed > minShouldTransitionSpeed) {
      animationController.forward();
    } else if (speed < 0 - minShouldTransitionSpeed) {
      animationController.reverse();
    } else {
      _handlePointerCancel();
    }
  }

  void _handlePointerCancel() {
    if (animationController.value == 1 || animationController.value == 0) {
      return;
    }
    if (animationController.value >= 0.5) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant _BottomBar oldWidget) {
    if (widget.height != pageHeight) {
      setState(() {
        pageHeight = widget.height;
      });
    }
    _recognizer.dispose();
    if (_width != widget.width) {
      _width = widget.width;
      Future.microtask(() {
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        var oldHeight = widgetHeight;
        widgetHeight = (box?.size.height) ?? 0;
        if (oldHeight != widgetHeight) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: animationController,
        curve: Curves.ease,
        reverseCurve: Curves.ease,
      ),
      builder: (context, child) {
        return Positioned(
          top: minValue + (maxValue - minValue) * animationController.value,
          left: 0,
          right: 0,
          child: Listener(
            onPointerDown: (event) {
              _recognizer.addPointer(event);
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                var offset = (event).scrollDelta.dy;
                if (offset < 0) {
                  animationController.reverse();
                } else {
                  animationController.forward();
                }
              }
            },
            child: Card(
              color:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.96),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                key: key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTop(),
                    buildStats(),
                    buildTags(),
                    buildMoreActions(),
                    SelectableText(
                      "${"Artwork ID".i18n}: ${widget.illust.id}\n"
                      "${"Artist ID".i18n}: ${widget.illust.author.id}\n"
                      "${widget.illust.createDate.toString().split('.').first}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ).paddingLeft(4),
                    SizedBox(
                      height: 8 + context.padding.bottom,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTop() {
    return SizedBox(
      height: _kBottomBarHeight,
      width: double.infinity,
      child: LayoutBuilder(builder: (context, constrains) {
        return Row(
          children: [
            buildAuthor(),
            ...buildActions(constrains.maxWidth),
            const Spacer(),
            if (animationController.value == 1)
              IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    animationController.reverse();
                  })
            else
              IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {
                    animationController.forward();
                  })
          ],
        ).toCenter();
      }),
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
        context.showToast(message: "Network Error");
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

  Widget buildAuthor() {
    final bool showUserName = MediaQuery.of(context).size.width > 640;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: SizedBox(
        height: double.infinity,
        width: showUserName ? 246 : 116,
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            SizedBox(
              height: 30,
              width: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: GestureDetector(
                    // onTap: () => context.to(() => UserInfoPage(
                    //       widget.illust.author.id.toString(),
                    //     )),
                    child: PixivImage(
                      widget.illust.author.avatar,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (showUserName)
              Expanded(
                child: Text(
                  widget.illust.author.name,
                  maxLines: 2,
                ),
              ),
            if (isFollowing)
              TextButton(
                  onPressed: follow,
                  child: const SizedBox(
                    width: 26,
                    height: 24,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ))
            else if (!widget.illust.author.isFollowed)
              TextButton(onPressed: follow, child: Text("Follow".i18n))
            else
              TextButton(
                onPressed: follow,
                child: Text(
                  "Unfo".i18n,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool isBookmarking = false;

  int likeState() {
    if (isBookmarking) {
      return 1;
    }
    if (widget.illust.isBookmarked) {
      return 2;
    }
    return 0;
  }

  void likes([String type = "public"]) async {
    if (isBookmarking) return;
    setState(() {
      isBookmarking = true;
    });
    var method = widget.illust.isBookmarked ? "delete" : "add";
    var res = await ConnectManager()
        .apiClient
        .addBookmark(widget.illust.id.toString(), method, type);
    if (res.error) {
      if (mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      widget.illust.isBookmarked = !widget.illust.isBookmarked;
    }
    setState(() {
      isBookmarking = false;
    });
  }

  void blockIt() {
    if (widget.illust.isBlocked) {
      settings.removeBlockedIllusts([widget.illust.id.toString()]);
    } else {
      settings.addBlockedIllusts([widget.illust.id.toString()]);
    }
  }

  Iterable<Widget> buildActions(double width) sync* {
    yield const SizedBox(
      width: 8,
    );

    void download() {
      // DownloadManager().addDownloadingTask(widget.illust);
      // setState(() {});
    }

    bool showText = width > 640;

    yield FilledButton.tonal(
      onPressed: likes,
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            if (isBookmarking)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                ),
              )
            else if (widget.illust.isBookmarked)
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.error,
                size: 18,
              )
            else
              const Icon(
                Icons.favorite_border,
                size: 18,
              ),
            if (showText)
              const SizedBox(
                width: 8,
              ),
            if (showText)
              if (widget.illust.isBookmarked)
                Text("Cancel".i18n)
              else
                Text("Favorite".i18n)
          ],
        ),
      ),
    );

    yield const SizedBox(
      width: 8,
    );

    // if (!downloaded(widget.illust.id)) {
    //   if (downloading(widget.illust.id)) {
    //     yield ElevatedButton(
    //       onPressed: () => {},
    //       child: SizedBox(
    //         height: 28,
    //         child: Row(
    //           children: [
    //             Icon(
    //               Icons.download_outlined,
    //               color: Theme.of(context).colorScheme.outline,
    //               size: 18,
    //             ),
    //             if (showText)
    //               const SizedBox(
    //                 width: 8,
    //               ),
    //             if (showText)
    //               Text(
    //                 "Downloading".i18n,
    //                 style:
    //                     TextStyle(color: Theme.of(context).colorScheme.outline),
    //               ),
    //           ],
    //         ),
    //       ),
    //     );
    //   } else
    {
      yield FilledButton.tonal(
        onPressed: download,
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              const Icon(
                Icons.download_outlined,
                size: 18,
              ),
              if (showText)
                const SizedBox(
                  width: 8,
                ),
              if (showText) Text("Download".i18n),
            ],
          ),
        ),
      );
    }
    // }

    yield const SizedBox(
      width: 8,
    );

    yield FilledButton.tonal(
      onPressed: () => CommentsPage.show(context, widget.illust.id.toString()),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            const Icon(
              Icons.reviews_outlined,
              size: 18,
            ),
            if (showText)
              const SizedBox(
                width: 8,
              ),
            if (showText) Text("Comment".i18n),
          ],
        ),
      ),
    );
  }

  Widget buildStats() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              width: 100,
              height: 52,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 0.6),
                  borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                      ),
                      Text(
                        "Views".i18n,
                        style: const TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.illust.totalView.toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Container(
            width: 100,
            height: 52,
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.6),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.thumb_up_off_alt,
                      size: 20,
                    ),
                    Text(
                      "Favorites".i18n,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  widget.illust.totalBookmarks.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                )
              ],
            ),
          )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Widget buildTags() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.illust.tags.map((e) {
          var text = e.name;
          if (e.translatedName != null && e.name != e.translatedName) {
            text += "/${e.translatedName}";
          }
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                //context.to(() => SearchResultPage(e.name));
              },
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 12),
                ).paddingAll(4),
              ),
            ),
          );
        }).toList(),
      ),
    ).paddingVertical(8).paddingHorizontal(5);
  }

  Widget buildMoreActions() {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: [
        FilledButton.tonal(
          onPressed: () => likes("private"),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                if (isBookmarking)
                  const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  )
                else if (widget.illust.isBookmarked)
                  Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.error,
                    size: 15,
                  )
                else
                  const Icon(
                    Icons.favorite_border,
                    size: 15,
                  ),
                const SizedBox(
                  width: 8,
                ),
                if (widget.illust.isBookmarked)
                  Text("Cancel".i18n)
                else
                  Text("Private".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
        FilledButton.tonal(
          onPressed: () {
            Share.share(
                "${widget.illust.title}\nhttps://pixiv.net/artworks/${widget.illust.id}");
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                const Icon(
                  Icons.share,
                  size: 15,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text("Share".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
        FilledButton.tonal(
          onPressed: () {
            var text = "https://pixiv.net/artworks/${widget.illust.id}";
            Clipboard.setData(ClipboardData(text: text));
            showToast(context, message: "Copied".i18n);
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                const Icon(Icons.copy, size: 15),
                const SizedBox(
                  width: 8,
                ),
                Text("Link".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
        FilledButton.tonal(
          onPressed: () {
            context.to(() => RelatedIllustsPage(widget.illust.id.toString()));
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                const Icon(Icons.stars, size: 15),
                const SizedBox(
                  width: 8,
                ),
                Text("Related".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
        FilledButton.tonal(
          onPressed: () async {
            blockIt();
            if (mounted) {
              widget.updateCallback?.call();
            }
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                if (widget.illust.isBlocked)
                  Icon(
                    Icons.block,
                    color: Theme.of(context).colorScheme.error,
                    size: 15,
                  )
                else
                  const Icon(
                    Icons.block,
                    size: 15,
                  ),
                const SizedBox(
                  width: 8,
                ),
                if (widget.illust.isBlocked)
                  Text("Cancel".i18n)
                else
                  Text("Block".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
        FilledButton.tonal(
          onPressed: () async {
            await Navigator.of(context)
                .push(SideBarRoute(_BlockingPage(widget.illust)));
            if (mounted) {
              widget.updateCallback?.call();
            }
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                const Icon(Icons.block, size: 15),
                const SizedBox(
                  width: 8,
                ),
                Text("Block+".i18n)
              ],
            ),
          ),
        ).fixWidth(120),
      ],
    ).paddingHorizontal(2).paddingBottom(4);
  }
}

class _BlockingPage extends StatefulWidget {
  const _BlockingPage(this.illust);

  final Illust illust;

  @override
  State<_BlockingPage> createState() => __BlockingPageState();
}

class __BlockingPageState extends State<_BlockingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: Text("Block".i18n)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: context.padding.bottom),
            itemCount: widget.illust.tags.length + 1,
            itemBuilder: (context, index) {
              var text = index == 0
                  ? widget.illust.author.name
                  : widget.illust.tags[index - 1].name;

              var subTitle = index == 0
                  ? "author"
                  : widget.illust.tags[index - 1].translatedName ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: blockedTagOrUser(index)
                    ? RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(4.0))
                    : RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withOpacity(0.2),
                            width: 2.0)),
                child: ListTile(
                  title: Text(text),
                  subtitle: Text(subTitle),
                  trailing: FilledButton.tonal(
                          onPressed: () {
                            if (index == 0) {
                              if (settings.blockedUsers.contains(
                                  widget.illust.author.id.toString())) {
                                settings.removeBlockedUsers(
                                    [widget.illust.author.id.toString()]);
                              } else {
                                settings.addBlockedUsers(
                                    [widget.illust.author.id.toString()]);
                              }
                            } else {
                              if (settings.blockedTags.contains(
                                  widget.illust.tags[index - 1].name)) {
                                settings.removeBlockedTags(
                                    [widget.illust.tags[index - 1].name]);
                              } else {
                                settings.addBlockedTags(
                                    [widget.illust.tags[index - 1].name]);
                              }
                            }
                            setState(() {});
                          },
                          child: blockedTagOrUser(index)
                              ? Text("Cancel".i18n)
                              : Text("Block".i18n))
                      .fixWidth(100),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  bool blockedTagOrUser(int index) {
    if (index == 0) {
      return settings.blockedUsers.contains(widget.illust.author.id.toString());
    }
    return settings.blockedTags.contains(widget.illust.tags[index - 1].name);
  }

  bool isSubmitting = false;
}
