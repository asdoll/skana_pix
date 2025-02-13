import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/staricon.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../model/worktypes.dart';
import '../view/novelview/novelpage.dart';
import 'pixivimage.dart';

class NovelCard extends StatefulWidget {
  final String controllerTag;
  final int index;
  const NovelCard(this.index, this.controllerTag, {super.key});

  @override
  State<NovelCard> createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
  late ListNovelController recomNovelsController;

  @override
  Widget build(BuildContext context) {
    recomNovelsController =
        Get.find<ListNovelController>(tag: widget.controllerTag);
    return Obx(() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: moonListTileWidgets(
            menuItemPadding: EdgeInsets.all(6),
            onTap: () {
              if (recomNovelsController.novelDirectEntry) {
                Get.to(
                    () => NovelViewerPage(
                        recomNovelsController.novels[widget.index]),
                    preventDuplicates: false);
              } else {
                buildShowModalBottomSheet(
                    context, recomNovelsController.novels[widget.index], true);
              }
            },
            menuItemCrossAxisAlignment: CrossAxisAlignment.start,
            leading: PixivImage(
              recomNovelsController.novels[widget.index].coverImageUrl,
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
                    recomNovelsController.novels[widget.index].title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ).header(),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        recomNovelsController
                            .novels[widget.index].author.name.atMost8,
                        maxLines: 1,
                      ).small(),
                    ],
                  ),
                ),
                Row(children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 12,
                        color: context.moonTheme?.tokens.colors.piccolo,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        '${recomNovelsController.novels[widget.index].length}',
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 12,
                          color: context.moonTheme?.tokens.colors.piccolo,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          '${recomNovelsController.novels[widget.index].totalBookmarks}',
                        )
                      ],
                    ),
                  ),
                ]),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 2, // gap between adjacent chips
                  runSpacing: 0,
                  children: [
                    if (recomNovelsController.novels[widget.index].tags.isEmpty)
                      Container(),
                    for (var f
                        in recomNovelsController.novels[widget.index].tags)
                      Text("${f.name} ",strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0)).xSmall()
                  ],
                ).paddingBottom(8),
              ],
            ).paddingLeft(4),
            trailing: StarIcon(
              id: recomNovelsController.novels[widget.index].id.toString(),
              type: ArtworkType.NOVEL,
              liked: recomNovelsController.novels[widget.index].isBookmarked,
            ).paddingTop(12),
          ));
    });
  }
}
