import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/model/spotlight.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/souppage.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;

  const SpotlightCard({super.key, required this.spotlight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: SizedBox(
          height: 250,
          child: moonListTileWidgets(
            noPadding: true,
            onTap: () async {
              Get.to(
                  () => SoupPage(
                      url: spotlight.articleUrl,
                      spotlight: spotlight,
                      heroTag: "spotlight_${spotlight.id}"),
                  preventDuplicates: false);
            },
            menuItemPadding: EdgeInsets.all(6),
            content: Column(
              children: [
                Text(
              spotlight.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.moonTheme?.menuItemTheme.colors.labelTextColor),
            ).subHeader(),
                Text(
              spotlight.pureTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).small()
              ],
            ),
            label: SizedBox(
              height: 190.0,
              width: 190.0,
              child: CachedNetworkImage(
                imageUrl: spotlight.thumbnail,
                //httpHeaders: Hoster.header(url: spotlight.thumbnail),
                fit: BoxFit.cover,
                cacheManager: imagesCacheManager,
                height: 190.0,
                width: 190.0,
              ),
            ).rounded(8.0).paddingBottom(5),
          )),
    );
  }
}
