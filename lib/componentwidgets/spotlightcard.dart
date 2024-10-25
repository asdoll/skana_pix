import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

import 'souppage.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightArticle spotlight;

  const SpotlightCard({Key? key, required this.spotlight}) : super(key: key);

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(
                              builder: (BuildContext context) => SoupPage(
                      url: spotlight.articleUrl, spotlight: spotlight)));
        },
        child: Container(
          height: 230,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 160.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).splashColor,
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: ListTile(
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
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: spotlight.thumbnail,
                      //httpHeaders: Hoster.header(url: spotlight.thumbnail),
                      fit: BoxFit.cover,
                      height: 150.0,
                      cacheManager: imagesCacheManager,
                      width: 150.0,
                    ),
                    height: 150.0,
                    width: 150.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
