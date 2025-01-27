import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

import '../view/souppage.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;

  const SpotlightCard({super.key, required this.spotlight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () async {
          Get.to(() => SoupPage(url: spotlight.articleUrl, spotlight: spotlight,heroTag: "spotlight_${spotlight.id}"),preventDuplicates: false);
        },
        child: SizedBox(
          height: 230,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 160.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.ring,
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Basic(
                        title: Text(
                          spotlight.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          spotlight.pureTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 150.0,
                    width: 150.0,
                    child: CachedNetworkImage(
                      imageUrl: spotlight.thumbnail,
                      //httpHeaders: Hoster.header(url: spotlight.thumbnail),
                      fit: BoxFit.cover,
                      height: 150.0,
                      cacheManager: imagesCacheManager,
                      width: 150.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
