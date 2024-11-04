import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagedetail.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/defaults.dart';

import '../model/worktypes.dart';
import '../utils/filters.dart';
import 'avatar.dart';
import 'backarea.dart';
import 'followbutton.dart';
import 'imagepage.dart';
import 'imagetab.dart';
import 'pixivimage.dart';
import 'staricon.dart';
import 'ugoira.dart';
import 'userpage.dart';
import 'package:icon_decoration/icon_decoration.dart';

const _kBottomBarHeight = 64.0;

class ImageListPage extends StatefulWidget {
  const ImageListPage(
      {required this.illusts,
      required this.initialPage,
      this.nextUrl,
      this.heroTag,
      super.key});

  final List<Illust> illusts;

  final int initialPage;

  final String? nextUrl;

  final String? heroTag;

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
    historyManager.addIllust(illusts[widget.initialPage]);
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
              String? tag = widget.initialPage == index ? widget.heroTag : null;
              return IllustPage(illusts[index],
                  heroTag: tag, nextPage: nextPage, previousPage: previousPage);
            },
            onPageChanged: (value) => setState(() {
              page = value;
              historyManager.addIllust(illusts[value]);
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
        BotToast.showText(text: "Network Error".i18n);
      }
    } else {
      nextUrl = res.subData;
      illusts.addAll(res.data);
      setState(() {});
    }
  }
}

class IllustPage extends StatefulWidget {
  const IllustPage(this.illust,
      {this.nextPage, this.previousPage, this.heroTag, super.key});

  final Illust illust;

  final void Function()? nextPage;

  final void Function()? previousPage;

  final String? heroTag;

  static Map<String, UpdateFollowCallback> followCallbacks = {};

  @override
  State<IllustPage> createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  String get id => "${widget.illust.author.id}#${widget.illust.id}";

  late ScrollController _scrollController;
  late EasyRefreshController _refreshController;

  List<Illust> related = [];
  bool isLoading = false;
  bool errorRelated = false;

  // KeyEventListenerState? keyboardListener;

  @override
  void initState() {
    // keyboardListener = KeyEventListener.of(context);
    // keyboardListener?.removeAll();
    // keyboardListener?.addHandler(handleKey);
    _scrollController = ScrollController();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    isLoading = true;
    loadRelated().then((value) {
      if (value.success) {
        setState(() {
          isLoading = false;
          related = value.data;
        });
      } else {
        setState(() {
          isLoading = false;
          errorRelated = true;
          BotToast.showText(text: "Network Error".i18n);
        });
      }
    });
    IllustPage.followCallbacks[id] = (v) {
      setState(() {
        widget.illust.author.isFollowed = v;
      });
    };
    if (user.isPremium) {
      ImageListPage.cachedHistoryIds.add(widget.illust.id);
    }
    super.initState();
  }

  @override
  void dispose() {
    //keyboardListener?.removeHandler(handleKey);
    IllustPage.followCallbacks.remove(id);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: GestureDetector(
        onLongPress: () {
          likes("private");
        },
        child: FloatingActionButton(
            heroTag: widget.illust.id,
            onPressed: likes,
            child: StarIcon(
              state: likeState(),
              illust: widget.illust,
            )),
      ),
      body: ColoredBox(
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
                  _buildAppbar(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  var isBlocked = false;

  Widget buildBody(double width, double height) {
    isBlocked = checkIllusts([widget.illust]).isEmpty;
    if (isBlocked) {
      return Center(
        child: Center(
          child: Column(children: <Widget>[
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 2.3,
            ),
            Text(
              "This artwork is blocked",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 16,
            ),
            FilledButton.tonal(
                onPressed: () {
                  blockIt();
                  setState(() {});
                },
                child: Text("Unblock".i18n)),
          ]),
        ),
      );
    }
    return EasyRefresh(
      footer: DefaultHeaderFooter.footer(context),
      controller: _refreshController,
      onLoad: () {
        nextPage();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if ((widget.illust.width / widget.illust.height) > 5)
            SliverToBoxAdapter(
                child: Container(height: MediaQuery.of(context).padding.top)),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return buildImage(width, height, index);
          }, childCount: widget.illust.images.length + 1)),
          SliverToBoxAdapter(
            child: IllustDetailContent(illust: widget.illust),
          ),
          SliverGrid(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ImageListPage(
                            illusts: related,
                            initialPage: index,
                            nextUrl: nextUrl)));
                  },
                  child: PixivImage(
                    related[index].images.first.squareMedium,
                    enableMemoryCache: false,
                  ),
                );
              }, childCount: related.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3)),
        ],
      ),
    );
  }

  Widget buildImage(double width, double height, int index) {
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

    if (!widget.illust.isUgoira) {
      image = SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ImagePage(
                      widget.illust.images.map((e) => e.large).toList()))),
              child: PixivImage(
                imageUrl,
                width: width,
                height: height,
              )));
    } else {
      image = UgoiraWidget(
        id: widget.illust.id.toString(),
        previewImage: PixivProvider.url(widget.illust.images[index].large),
        width: imageWidth,
        height: imageHeight,
      );
    }

    return Hero(
        tag: widget.heroTag ?? hashCode.toString() + index.toString(),
        child: Center(
          child: image,
        ));
  }

  Widget _buildAppbar() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
        ),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonBackArea(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const DecoratedIcon(
                        icon: Icon(Icons.expand_less),
                        decoration:
                            IconDecoration(border: IconBorder(width: 1.5)),
                      ),
                      onPressed: () {
                        double p = _scrollController.position.maxScrollExtent -
                            (related.length / 3.0) *
                                (MediaQuery.of(context).size.width / 3.0);
                        if (p < 0) p = 0;
                        _scrollController.position.jumpTo(p);
                      }),
                  IconButton(
                      icon: const DecoratedIcon(
                        icon: Icon(Icons.more_vert),
                        decoration:
                            IconDecoration(border: IconBorder(width: 1.5)),
                      ),
                      onPressed: () {
                        buildShowModalBottomSheet(context, widget.illust);
                      })
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Future buildShowModalBottomSheet(BuildContext context, Illust illust) {
    return showModalBottomSheet(
        isScrollControlled: true,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildNameAvatar(context, illust),
                      if (illust.images.length > 1)
                        ListTile(
                          title: Text("Multi-choice Save".i18n),
                          leading: const Icon(
                            Icons.save,
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            _showMutiChoiceDialog(illust, context);
                          },
                        ),
                      ListTile(
                        title: Text("Copy Info".i18n),
                        leading: Icon(
                          Icons.local_library_outlined,
                        ),
                        onTap: () async {
                          final str = illustToShareInfoText(illust);
                          await Clipboard.setData(ClipboardData(text: str));
                          BotToast.showText(text: "Copied to clipboard".i18n);
                          Navigator.of(context).pop();
                        },
                      ),
                      Builder(builder: (context) {
                        return ListTile(
                          title: Text("Share".i18n),
                          leading: Icon(
                            Icons.share,
                          ),
                          onTap: () {
                            final box =
                                context.findRenderObject() as RenderBox?;
                            final pos = box != null
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null;
                            Navigator.of(context).pop();
                            Share.share(
                                "https://www.pixiv.net/artworks/${widget.illust.id}",
                                sharePositionOrigin: pos);
                          },
                        );
                      }),
                      ListTile(
                        leading: Icon(
                          Icons.link,
                        ),
                        title: Text("Link".i18n),
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                              text:
                                  "https://www.pixiv.net/artworks/${widget.illust.id}"));
                          BotToast.showText(text: "Copied to clipboard".i18n);
                          Navigator.of(context).pop();
                        },
                      ),
                      (widget.illust.isBlocked)
                          ? ListTile(
                              title: Text("Unblock".i18n),
                              leading: Icon(Icons.block),
                              onTap: () {
                                blockIt();
                                setState(() {});
                                Navigator.pop(context);
                              },
                            )
                          : ListTile(
                              title: Text("Block".i18n),
                              leading: Icon(Icons.block),
                              onTap: () {
                                blockIt();
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          );
        });
  }

  void blockIt() {
    if (widget.illust.isBlocked) {
      settings.removeBlockedIllusts([widget.illust.id.toString()]);
    } else {
      settings.addBlockedIllusts([widget.illust.id.toString()]);
    }
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
      BotToast.showText(text: "Network Error".i18n);
    } else {
      widget.illust.isBookmarked = !widget.illust.isBookmarked;
      StarIcon.favoriteCallbacks[widget.illust.id.toString()]
          ?.call(widget.illust.isBookmarked);
      IllustCard.favoriteCallbacks[widget.illust.id.toString()]
          ?.call(widget.illust.isBookmarked);
      if (type == "private") {
        BotToast.showText(text: "Bookmarked privately".i18n);
      }
    }
    setState(() {
      isBookmarking = false;
    });
  }

  Future _showMutiChoiceDialog(Illust illust, BuildContext context) async {
    List<bool> indexs = [];
    bool allOn = false;
    for (int i = 0; i < illust.images.length; i++) {
      indexs.add(false);
    }
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(illust.title),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemBuilder: (context, index) {
                          final data = illust.images[index];
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  indexs[index] = !indexs[index];
                                });
                              },
                              onLongPress: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ImagePage(
                                            illust.images
                                                .map((e) => e.large)
                                                .toList(),
                                            initialPage: index)));
                              },
                              child: Stack(
                                children: [
                                  PixivImage(
                                    data.squareMedium,
                                    placeWidget: Container(
                                      child: Center(
                                        child: Text(index.toString()),
                                      ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: Visibility(
                                          visible: indexs[index],
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ));
                        },
                        itemCount: illust.images.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                      ),
                    ),
                    ListTile(
                      leading: Icon(!allOn
                          ? Icons.check_circle_outline
                          : Icons.check_circle),
                      title: Text("All".i18n),
                      onTap: () {
                        allOn = !allOn;
                        for (var i = 0; i < indexs.length; i++) {
                          indexs[i] = allOn;
                        }
                        setDialogState(() {});
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.save),
                      title: Text("Save".i18n),
                      onTap: () {
                        Navigator.of(context).pop("OK");
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
    switch (result) {
      case "OK":
        {
          saveImage(illust, indexes: indexs, context: context);
        }
    }
  }

  Widget _buildNameAvatar(BuildContext context, Illust illust) {
    return InkWell(
      onTap: () async {
        await _push2UserPage(context, illust);
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
                size: Size(32, 32),
                onTap: () async {
                  await _push2UserPage(context, illust);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: illust.author.name + hashCode.toString(),
                    child: SelectionArea(
                      child: Text(
                        illust.author.name,
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          UserFollowButton(
            followed: illust.author.isFollowed,
            onPressed: () async {
              follow();
            },
          ),
          const SizedBox(
            width: 12,
          )
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
    var method = widget.illust.author.isFollowed ? "delete" : "add";
    var res = await followUser(widget.illust.author.id.toString(), method);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: "Network Error".i18n);
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

  Future<void> _push2UserPage(BuildContext context, Illust illust) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => UserPage(
              id: illust.author.id,
              heroTag: hashCode.toString(),
              type: illust.type == "illust"
                  ? ArtworkType.ILLUST
                  : ArtworkType.MANGA,
            )));
  }

  String? nextUrl;

  Future<Res<List<Illust>>> loadRelated() async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    Res<List<Illust>> res = nextUrl == null
        ? await relatedIllusts(widget.illust.id.toString())
        : await getIllustsWithNextUrl(nextUrl!);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      _refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      _refreshController.finishLoad();
    }
    return res;
  }

  void nextPage() {
    if (isLoading) return;
    isLoading = true;
    loadRelated().then((value) {
      isLoading = false;
      if (value.success) {
        setState(() {
          related.addAll(value.data);
        });
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".i18n;
        if (message == "No more data") {
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        BotToast.showText(text: message);
      }
    });
  }

  void reset() {
    setState(() {
      nextUrl = null;
      isLoading = false;
      related = [];
      errorRelated = false;
    });
    firstLoad();
  }

  void firstLoad() {
    loadRelated().then((value) {
      if (value.success) {
        setState(() {
          related = value.data;
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
          }
        });
      }
    });
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
