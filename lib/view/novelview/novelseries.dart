import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart' show SelectionArea,InkWell;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/controller/novel_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
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
  Widget build(BuildContext context) {
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    NovelSeriesDetailController controller = Get.put(
        NovelSeriesDetailController(
            seriesId: widget.seriesId.toString(),
            easyRefreshController: easyRefreshController));

    return Scaffold(
      headers: [
        AppBar(
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
                child: Text(
                  controller.novelSeriesDetail.value!.user.name,
                  style: Theme.of(context).typography.h3,
                ),
              )
            ]
          ]),
          trailing: [
            Builder(builder: (context) {
              return IconButton.ghost(
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
        const Divider()
      ],
      child: EasyRefresh(
        controller: easyRefreshController,
        onLoad: () => controller.nextPage(),
        onRefresh: () => controller.firstLoad(),
        header: DefaultHeaderFooter.header(context),
        footer: DefaultHeaderFooter.footer(context),
        refreshOnStart: true,
        child: Builder(builder: (context) {
          if (controller.novelSeriesDetail.value != null) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                      ),
                      SelectionArea(
                        child: Text(
                          controller.novelSeriesDetail.value!.title,
                          style: Theme.of(context).typography.h2,
                        ),
                      ),
                      SelectionArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            controller.novelSeriesDetail.value!.caption ?? "",
                            style: Theme.of(context).typography.textSmall,
                          ),
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
                          child: PrimaryButton(
                              onPressed: () {
                               Get.to(() => NovelViewerPage(controller.last.value!));
                              },
                              child: Text("View the latest".tr)),
                        ),
                      ),
                      Divider()
                    ]),
                  ),
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => NovelViewerPage(
                        controller.novels[index])));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PixivImage(
                        controller.novels[index].coverImageUrl,
                        width: 80,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              "#${index + 1} ${controller.novels[index].title}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).typography.textLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              controller.novels[index].author.name,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .typography
                                  .textSmall
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2, // gap between adjacent chips
                              runSpacing: 0,
                              children: [
                                for (var f in controller.novels[index].tags)
                                  Chip(
                                    child: Text(f.name,
                                        style: Theme.of(context)
                                            .typography
                                            .textSmall),
                                  )
                              ],
                            ),
                          ),
                          Container(
                            height: 8.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    StarIcon(
                      id: controller.novels[index].id.toString(),
                      type: ArtworkType.NOVEL,
                      size: 20,
                      liked: controller.novels[index].isBookmarked,
                    ),
                    Text('${controller.novels[index].totalBookmarks}',
                        style: Theme.of(context).typography.textSmall),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
                }, childCount: controller.novels.length))
              ],
            );
          }
          return CustomScrollView(
            slivers: [],
          );
        }),
      ),
    );
  }
}
