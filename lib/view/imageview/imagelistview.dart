import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagedetail.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

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
    if (listController.illusts.isNotEmpty &&
        widget.index <= listController.illusts.length) {
      historyManager.addIllust(listController.illusts[widget.index]);
    }

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
                    child: IconButton(
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
                    child: IconButton(
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
    if (accountController.isPremium.value) {
      ListIllustController.historyIds.add(widget.illust.id);
    }
    _scrollController.addListener(() {
      if (_scrollController.offset < context.height) {
        relatedListController.showBackArea.value = false;
      } else {
        relatedListController.showBackArea.value = true;
      }
    });
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
      floatingActionButton: Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: (relatedListController.showBackArea.value)
                            ? MoonButton.icon(
                                buttonSize: MoonButtonSize.lg,
                                showBorder: true,
                                borderColor: Get.context?.moonTheme?.buttonTheme
                                    .colors.borderColor
                                    .withValues(alpha: 0.5),
                                backgroundColor:
                                    Get.context?.moonTheme?.tokens.colors.zeno,
                                onTap: () {
                                  _scrollController.animateTo(0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                },
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              )
                            : Container())),
      body: ColoredBox(
        color: context.moonTheme?.tokens.colors.goku ??
            Theme.of(context).colorScheme.surface,
        child: SizedBox.expand(
          child: ColoredBox(
            color: context.moonTheme?.tokens.colors.goku ??
                Theme.of(context).colorScheme.surface,
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
              Text("This artwork is blocked".tr).header(),
              const SizedBox(
                height: 16,
              ),
              filledButton(
                  onPressed: () {
                    localManager.delete(
                        "blockedIllusts", [widget.illust.id.toString()]);
                  },
                  label: "Unblock".tr),
            ]),
          ),
        );
      } else {
        return EasyRefresh(
          header: DefaultHeaderFooter.header(context),
          refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
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
                                    controllerTag:
                                        "related_${widget.illust.id}",
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              max(3, (context.width / 150).floor())))
                  .sliverPadding(EdgeInsets.all(8)),
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

    var imageUrl = relatedListController.showOriginal
        ? widget.illust.images[index].original
        : widget.illust.images[index].medium;

    if (!widget.illust.isUgoira) {
      image = SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
              onTap: () => Get.to(() => ImageViewPage(
                  widget.illust.images.map((e) => e.large).toList(),
                  initialPage: index)),
              child: PixivImage(
                imageUrl,
                width: MediaQuery.of(context).size.width,
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
            Obx(() => MoonDropdown(
                constrainWidthToChild: true,
                show: relatedListController.showDropdown.value,
                onTapOutside: () =>
                    relatedListController.showDropdown.value = false,
                content: SizedBox(
                  child: Column(children: [
                    MoonMenuItem(
                      onTap: () => Get.to(UserPage(
                        id: widget.illust.author.id,
                        heroTag: hashCode.toString(),
                        type: widget.illust.type == "illust"
                            ? ArtworkType.ILLUST
                            : ArtworkType.MANGA,
                      )),
                      leading: Hero(
                        tag: widget.illust.author.avatar + hashCode.toString(),
                        child: PainterAvatar(
                          url: widget.illust.author.avatar,
                          id: widget.illust.author.id,
                          size: 32,
                        ),
                      ),
                      trailing: UserFollowButton(
                          liked: widget.illust.author.isFollowed,
                          id: widget.illust.author.id.toString()),
                      label: SelectionArea(
                        child: Text(widget.illust.author.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis)
                            .subHeader(),
                      ),
                    ),
                    if (widget.illust.images.length > 1)
                      MoonMenuItem(
                        onTap: () {
                          relatedListController.showDropdown.value = false;
                          _showMutiChoiceDialog(widget.illust, context);
                        },
                        leading: const Icon(
                          Icons.save,
                        ),
                        label: Text("Multi-choice Save".tr),
                      ),
                    MoonMenuItem(
                      leading: const Icon(
                        Icons.share,
                      ),
                      onTap: () {
                        relatedListController.showDropdown.value = false;
                        final box = context.findRenderObject() as RenderBox?;
                        final pos = box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null;
                        Share.share(
                            "https://www.pixiv.net/artworks/${widget.illust.id}",
                            sharePositionOrigin: pos);
                      },
                      label: Text("Share".tr),
                    ),
                    MoonMenuItem(
                      leading: Icon(
                        Icons.link,
                      ),
                      label: Text("Link".tr),
                      onTap: () async {
                        relatedListController.showDropdown.value = false;
                        await Clipboard.setData(ClipboardData(
                            text:
                                "https://www.pixiv.net/artworks/${widget.illust.id}"));
                        Leader.showToast("Copied to clipboard".tr);
                      },
                    ),
                    MoonMenuItem(
                        leading: Icon(Icons.block),
                        onTap: () {
                          relatedListController.showDropdown.value = false;
                          if (localManager.blockedIllusts
                              .contains(widget.illust.id.toString())) {
                            localManager.delete("blockedIllusts",
                                [widget.illust.id.toString()]);
                          } else {
                            localManager.add("blockedIllusts",
                                [widget.illust.id.toString()]);
                          }
                        },
                        label: Obx(() => localManager.blockedIllusts
                                .contains(widget.illust.id.toString())
                            ? Text("Unblock".tr)
                            : Text("Block".tr))),
                  ]),
                ),
                child: SizedBox(
                  width: max(200, min(300, context.width / 1.5)),
                  child: Row(
                    children: [
                      Expanded(child: Spacer()),
                      MoonButton.icon(
                        icon: DecoratedIcon(
                          icon: Icon(Icons.more_vert,color: Colors.white,),
                          decoration:
                              IconDecoration(border: IconBorder(width: 1.5)),
                        ),
                        onTap: () => relatedListController.showDropdown.value =
                            !relatedListController.showDropdown.value,
                      )
                    ],
                  ),
                )))
          ],
        ),
      ],
    );
  }

  Future _showMutiChoiceDialog(Illust illust, BuildContext context) async {
    MutiChoiceDialogController controller =
        MutiChoiceDialogController(illust.images.length);
    final result = await showMoonModal(
        context: context,
        builder: (context) {
          return Dialog(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            MoonAlert(
              borderColor: Get
                  .context?.moonTheme?.buttonTheme.colors.borderColor
                  .withValues(alpha: 0.5),
              showBorder: true,
              label: Text(illust.title).header(),
              verticalGap: 16,
              content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: context.height / 2,
                        child: GridView.builder(
                          itemBuilder: (context, index) {
                            final data = illust.images[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                    controller.indexs[index] = !controller.indexs[index];
                                    controller.indexs.refresh();
                                },
                                onLongPress: () {
                                  Get.to(() => ImageViewPage(
                                      illust.images
                                          .map((e) => e.large)
                                          .toList(),
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
                                    Obx(() => Align(
                                        alignment: Alignment.bottomRight,
                                        child: Visibility(
                                            visible: controller.indexs[index],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                            )))),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: illust.images.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                        ),
                      ).paddingBottom(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MoonFilledButton(
                            buttonSize: MoonButtonSize.sm,
                            leading: Icon(!controller.allOn.value
                                ? Icons.check_circle_outline
                                : Icons.check_circle),
                            label: Text("All".tr),
                            onTap: () {
                              controller.allOn.value = !controller.allOn.value;
                              for (var i = 0; i < controller.indexs.length; i++) {
                                controller.indexs[i] = controller.allOn.value;
                              }
                              controller.indexs.refresh();
                            },
                          ).paddingRight(8),
                          MoonFilledButton(
                            buttonSize: MoonButtonSize.sm,
                            leading: Icon(Icons.save),
                            label: Text("Save".tr),
                            onTap: () {
                              Get.back(result: "OK");
                            },
                          ),
                        ],
                      )
                    ],
                  )),
            
          ]));
        });
    switch (result) {
      case "OK":
        {
          saveImage(illust, indexes: controller.indexs);
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
  void dispose() {
    super.dispose();
    Get.delete<ListIllustController>(tag: "illust_${widget.id}");
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ListIllustController controller = Get.put(
        ListIllustController(
            controllerType: ListType.single,
            id: widget.id,
            type: ArtworkType.ILLUST),
        tag: "illust_${widget.id}");
    controller.reset();
    return Obx(() => controller.isLoading.value
        ? Container()
        : ImageListViewPage(controllerTag: "illust_${widget.id}", index: 0));
  }
}

class MutiChoiceDialogController extends GetxController {
  RxList<bool> indexs = RxList.empty();
  RxBool allOn = false.obs;
  MutiChoiceDialogController(int length) {
    indexs = RxList.filled(length, false);
    indexs.refresh();
  }
}