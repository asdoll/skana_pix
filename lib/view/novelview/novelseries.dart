import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/view/userview/userpage.dart';
import 'package:skana_pix/controller/novel_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../../componentwidgets/avatar.dart';
import 'novelpage.dart';
import '../../componentwidgets/pixivimage.dart';

class NovelSeriesPage extends StatefulWidget {
  final int seriesId;

  const NovelSeriesPage(this.seriesId, {super.key});

  @override
  State<NovelSeriesPage> createState() => _NovelSeriesPageState();
}

class _NovelSeriesPageState extends State<NovelSeriesPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<NovelSeriesDetailController>(
        tag: "novelseries_${widget.seriesId}");
  }

  @override
  Widget build(BuildContext context) {
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    NovelSeriesDetailController controller = Get.put(
        NovelSeriesDetailController(seriesId: widget.seriesId.toString()),
        tag: "novelseries_${widget.seriesId}");
    controller.easyRefreshController = easyRefreshController;
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Row(children: [
              if (controller.novelSeriesDetail.value != null) ...[
                PainterAvatar(
                  url: controller.novelSeriesDetail.value!.user.avatar,
                  id: controller.novelSeriesDetail.value!.user.id,
                  size: 30,
                  onTap: () {
                    Get.to(() => UserPage(
                          id: controller.novelSeriesDetail.value!.user.id,
                          type: ArtworkType.NOVEL,
                        ));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(controller.novelSeriesDetail.value!.user.name)
                      .header(),
                )
              ]
            ]),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      final pos = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.share(
                          "https://www.pixiv.net/novel/series/${widget.seriesId}",
                          sharePositionOrigin: pos);
                    },
                    icon: Icon(Icons.share));
              })
            ],
          ),
          body: EasyRefresh(
            controller: easyRefreshController,
            onLoad: () => controller.nextPage(),
            onRefresh: () => controller.firstLoad(),
            header: DefaultHeaderFooter.header(context),
            footer: DefaultHeaderFooter.footer(context),
            refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
            refreshOnStart: true,
            child: Builder(builder: (context) {
              if (controller.novelSeriesDetail.value != null) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SelectionArea(
                            child:
                                Text(controller.novelSeriesDetail.value!.title)
                                    .header(),
                          ).paddingAll(16),
                          SelectionArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(controller
                                          .novelSeriesDetail.value!.caption ??
                                      "")
                                  .small(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.last.value != null)
                      SliverToBoxAdapter(
                        child: Column(children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: filledButton(
                                  onPressed: () {
                                    Get.to(() => NovelViewerPage(
                                        controller.last.value!));
                                  },
                                  label: "View the latest".tr),
                            ),
                          ),
                          Divider()
                        ]),
                      ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: moonListTileWidgets(
                            menuItemPadding: EdgeInsets.all(6),
                            onTap: () {
                              Get.to(
                                  () =>
                                      NovelViewerPage(controller.novels[index]),
                                  preventDuplicates: false);
                            },
                            menuItemCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            leading: PixivImage(
                              controller.novels[index].coverImageUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            ).rounded(8.0).paddingTop(6),
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    controller.novels[index].title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ).header(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller
                                            .novels[index].author.name.atMost8,
                                        maxLines: 1,
                                      ).small(),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.sticky_note_2_outlined,
                                              size: 12,
                                              color: context.moonTheme?.tokens
                                                  .colors.piccolo,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              '${controller.novels[index].length}',
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.favorite_outline,
                                              size: 12,
                                              color: context.moonTheme?.tokens
                                                  .colors.piccolo,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              '${controller.novels[index].totalBookmarks}',
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 2, // gap between adjacent chips
                                  runSpacing: 0,
                                  children: [
                                    if (controller.novels[index].tags.isEmpty)
                                      Container(),
                                    for (var f in controller.novels[index].tags)
                                      Text("${f.name} ").xSmall()
                                  ],
                                ).paddingBottom(8),
                              ],
                            ).paddingLeft(4),
                            trailing: StarIcon(
                              id: controller.novels[index].id.toString(),
                              type: ArtworkType.NOVEL,
                              liked: controller.novels[index].isBookmarked,
                            ).paddingTop(12),
                          ));
                    }, childCount: controller.novels.length))
                  ],
                );
              }
              return CustomScrollView(
                slivers: [],
              );
            }),
          ),
        ));
  }
}
