import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../view/souppage.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;

  const SpotlightCard({super.key, required this.spotlight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () async {
          Get.to(() => SoupPage(url: spotlight.articleUrl, spotlight: spotlight,heroTag: "spotlight_${spotlight.id}"),preventDuplicates: false);
        },
        child: SizedBox(
          height: 250,
          child: 
          Card(child: 
          Basic(
            title: Text(spotlight.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
            subtitle: Text(spotlight.pureTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
                          content: SizedBox(
                    height: 150.0,
                    width: 150.0,
                    child: CachedNetworkImage(
                      imageUrl: spotlight.thumbnail,
                      //httpHeaders: Hoster.header(url: spotlight.thumbnail),
                      fit: BoxFit.cover,
                      cacheManager: imagesCacheManager,
                      height: 150.0,
                      width: 150.0,
                    ),
                  ).rounded(8.0).paddingTop(5),
          )
          )
        ),
      ),
    );
  }
}
