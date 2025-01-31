import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart' show InkWell, SelectionArea;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagedetail.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';

import '../../model/worktypes.dart';
import '../../componentwidgets/avatar.dart';
import '../../componentwidgets/backarea.dart';
import '../../componentwidgets/followbutton.dart';
import 'imageviewpage.dart';
import '../../componentwidgets/pixivimage.dart';
import '../../componentwidgets/ugoira.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:get/get.dart';

const _kBottomBarHeight = 64.0;

// page view for image detail page
class ImageListViewPage extends StatefulWidget {
  const ImageListViewPage(
      {required this.controllerTag,
      required this.index,
      this.heroTag,
      super.key});

  final String controllerTag;

  final int index;

  final String? heroTag;

  @override
  State<ImageListViewPage> createState() => _ImageListViewPageState();
}

class _ImageListViewPageState extends State<ImageListViewPage> {
  late final PageController controller;
  late ListIllustController listController;
  String type = "";

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    listController = Get.find<ListIllustController>(tag: widget.controllerTag);
  }

  @override
  void dispose() {
    controller.dispose();
    ListIllustController.sendHistory();
    super.dispose();
  }

  void nextPage() {
    var length = listController.illusts.length;
    if (controller.page == length - 1) return;
    controller.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  void previousPage() {
    if (controller.page == 0) return;
    controller.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    controller = PageController(initialPage: widget.index);
    historyManager.addIllust(listController.illusts[widget.index]);

    var length = listController.illusts.length;
    if (listController.nexturl.isNotEmpty) {
      length++;
    }

    return Obx(() => Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: controller,
                itemCount: length,
                itemBuilder: (context, index) {
                  if (index == listController.illusts.length) {
                    return buildLast();
                  }
                  String? tag = widget.index == index ? widget.heroTag : null;
                  return IllustPage(listController.illusts[index],
                      heroTag: tag,
                      nextPage: nextPage,
                      previousPage: previousPage);
                },
                onPageChanged: (value) => setState(() {
                  listController.index.value = value;

                  historyManager.addIllust(listController.illusts[value]);
                }),
              ),
            ),
            if (listController.index.value < length - 1 &&
                length > 1 &&
                GetPlatform.isDesktop)
              Positioned(
                right: 0,
                top: 0,
                bottom: 32,
                child: Center(
                    child: IconButton.ghost(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    nextPage();
                  },
                )),
              ),
            if (listController.index.value != 0 &&
                length > 1 &&
                GetPlatform.isDesktop)
              Positioned(
                left: 0,
                top: 0,
                bottom: 32,
                child: Center(
                    child: IconButton.ghost(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    previousPage();
                  },
                )),
              ),
          ],
        ));
  }

  Widget buildLast() {
    if (listController.nexturl.isEmpty) {
      return const SizedBox();
    }
    load();
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void load() async {
    listController.nextPage();
  }
}

class IllustPage extends StatefulWidget {
  const IllustPage(this.illust,
      {this.nextPage, this.previousPage, this.heroTag, super.key});

  final Illust illust;

  final void Function()? nextPage;

  final void Function()? previousPage;

  final String? heroTag;

  @override
  State<IllustPage> createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  String get id => "${widget.illust.author.id}#${widget.illust.id}";

  late ScrollController _scrollController;
  late EasyRefreshController _refreshController;

  late ListIllustController relatedListController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    relatedListController = Get.put(
        ListIllustController(
            controllerType: ListType.related,
            id: widget.illust.id.toString(),
            type: widget.illust.type == "illust"
                ? ArtworkType.ILLUST
                : ArtworkType.MANGA),
        tag: "related_${widget.illust.id}");
    relatedListController.refreshController = _refreshController;
    relatedListController.firstLoad();
    if (user.isPremium) {
      ListIllustController.historyIds.add(widget.illust.id);
    }
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ListIllustController>(tag: "related_${widget.illust.id}");
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.background,
        child: SizedBox.expand(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.background,
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
                  _buildAppbar(context),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget buildBody(double width, double height) {
    return Obx(() {
      if (localManager.blockedIllusts.contains(widget.illust.id.toString())) {
        return Center(
          child: Center(
            child: Column(children: <Widget>[
              SizedBox(
                height: MediaQuery.sizeOf(context).height / 2.3,
              ),
              Text(
                "This artwork is blocked".tr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 16,
              ),
              Button.secondary(
                  onPressed: () {
                    localManager.delete(
                        "blockedIllusts", [widget.illust.id.toString()]);
                  },
                  child: Text("Unblock".tr)),
            ]),
          ),
        );
      } else {
        return EasyRefresh(
          footer: DefaultHeaderFooter.footer(context),
          controller: _refreshController,
          onLoad: () {
            relatedListController.nextPage();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if ((widget.illust.width / widget.illust.height) > 5)
                SliverToBoxAdapter(
                    child:
                        Container(height: MediaQuery.of(context).padding.top)),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return buildImage(width, height, index);
              }, childCount: widget.illust.images.length + 1)),
              SliverToBoxAdapter(
                child: IllustDetailContent(illust: widget.illust),
              ),
              SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Get.to(
                            () => ImageListViewPage(
                                controllerTag: "related_${widget.illust.id}",
                                index: index),
                            preventDuplicates: false);
                      },
                      child: PixivImage(
                        relatedListController
                            .illusts[index].images.first.squareMedium,
                        enableMemoryCache: false,
                      ),
                    );
                  }, childCount: relatedListController.illusts.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3)),
            ],
          ),
        );
      }
    });
  }

  Widget buildImage(double width, double height, int index) {
    if (index == widget.illust.images.length) {
      return SizedBox(
        height: _kBottomBarHeight + MediaQuery.of(context).padding.bottom,
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
              onTap: () => Get.to(() => ImageViewPage(
                  widget.illust.images.map((e) => e.large).toList(),
                  initialPage: index)),
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

  Widget _buildAppbar(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonBackArea(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.ghost(
                    icon: const DecoratedIcon(
                      icon: Icon(Icons.expand_less),
                      decoration:
                          IconDecoration(border: IconBorder(width: 1.5)),
                    ),
                    onPressed: () {
                      double p = _scrollController.position.maxScrollExtent -
                          (relatedListController.illusts.length / 3.0) *
                              (MediaQuery.of(context).size.width / 3.0);
                      if (p < 0) p = 0;
                      _scrollController.position.jumpTo(p);
                    }),
                IconButton.ghost(
                    icon: const DecoratedIcon(
                      icon: Icon(Icons.more_vert),
                      decoration:
                          IconDecoration(border: IconBorder(width: 1.5)),
                    ),
                    onPressed: () {
                      showDropdown(
                          context: context,
                          builder: (_) => DropdownMenu(children: [
                                MenuLabel(
                                  leading: Hero(
                                    tag: widget.illust.author.avatar +
                                        hashCode.toString(),
                                    child: PainterAvatar(
                                      url: widget.illust.author.avatar,
                                      id: widget.illust.author.id,
                                      size: 32,
                                    ),
                                  ),
                                  trailing: UserFollowButton(
                                      liked: widget.illust.author.isFollowed,
                                      id: widget.illust.author.id.toString()),
                                  child: SelectionArea(
                                    child: Text(
                                      widget.illust.author.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .typography
                                              .textSmall
                                              .color),
                                    ),
                                  ),
                                ),
                                if (widget.illust.images.length > 1)
                                  MenuButton(
                                    onPressed: (context) {
                                      _showMutiChoiceDialog(
                                          widget.illust, context);
                                    },
                                    leading: const Icon(
                                      Icons.save,
                                    ),
                                    child: Text("Multi-choice Save".tr),
                                  ),
                                MenuButton(
                                  leading: Icon(
                                    Icons.share,
                                  ),
                                  onPressed: (context) {
                                    final box = context.findRenderObject()
                                        as RenderBox?;
                                    final pos = box != null
                                        ? box.localToGlobal(Offset.zero) &
                                            box.size
                                        : null;
                                    Share.share(
                                        "https://www.pixiv.net/artworks/${widget.illust.id}",
                                        sharePositionOrigin: pos);
                                  },
                                  child: Text("Share".tr),
                                ),
                                MenuButton(
                                  leading: Icon(
                                    Icons.link,
                                  ),
                                  child: Text("Link".tr),
                                  onPressed: (context) async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            "https://www.pixiv.net/artworks/${widget.illust.id}"));
                                    Leader.showToast("Copied to clipboard".tr);
                                  },
                                ),
                                MenuButton(
                                    leading: Icon(Icons.block),
                                    onPressed: (context) {
                                      if (localManager.blockedIllusts.contains(
                                          widget.illust.id.toString())) {
                                        settings.removeBlockedIllusts(
                                            [widget.illust.id.toString()]);
                                      } else {
                                        settings.addBlockedIllusts(
                                            [widget.illust.id.toString()]);
                                      }
                                    },
                                    child: Obx(() => localManager.blockedIllusts
                                            .contains(
                                                widget.illust.id.toString())
                                        ? Text("Unblock".tr)
                                        : Text("Block".tr))),
                              ]));
                    })
              ],
            )
          ],
        ),
      ],
    );
  }

  Future _showMutiChoiceDialog(Illust illust, BuildContext context) async {
    List<bool> indexs = [];
    bool allOn = false;
    for (int i = 0; i < illust.images.length; i++) {
      indexs.add(false);
    }
    final result = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return SafeArea(
              child: AlertDialog(
                content: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(illust.title),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemBuilder: (context, index) {
                          final data = illust.images[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  indexs[index] = !indexs[index];
                                });
                              },
                              onLongPress: () {
                                Get.to(() => ImageViewPage(
                                    illust.images.map((e) => e.large).toList(),
                                    initialPage: index));
                              },
                              child: Stack(
                                children: [
                                  PixivImage(
                                    data.squareMedium,
                                    placeWidget: Center(
                                      child: Text(index.toString()),
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
                          );
                        },
                        itemCount: illust.images.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                      ),
                    ),
                  ],
                ),
                actions: [
                  PrimaryButton(
                    leading: Icon(!allOn
                        ? Icons.check_circle_outline
                        : Icons.check_circle),
                    child: Text("All".tr),
                    onPressed: () {
                      allOn = !allOn;
                      for (var i = 0; i < indexs.length; i++) {
                        indexs[i] = allOn;
                      }
                      setDialogState(() {});
                    },
                  ),
                  PrimaryButton(
                    leading: Icon(Icons.save),
                    child: Text("Save".tr),
                    onPressed: () {
                      Get.back(result: "OK");
                    },
                  ),
                ],
              ),
            );
          });
        });
    switch (result) {
      case "OK":
        {
          saveImage(illust, indexes: indexs);
        }
    }
  }
}

class IllustPageLite extends StatefulWidget {
  final String id;
  const IllustPageLite(this.id, {super.key});
  @override
  State<IllustPageLite> createState() => _IllustPageLiteState();
}

class _IllustPageLiteState extends State<IllustPageLite> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.single,
            id: widget.id,
            type: ArtworkType.ILLUST),
        tag: "illust_${widget.id}");
    return ImageListViewPage(controllerTag: "illust_${widget.id}", index: 0);
  }
}
