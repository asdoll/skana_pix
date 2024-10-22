import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/controller/caches.dart';

import 'userpage.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  final GestureTapCallback? onTap;
  final Size? size;

  const PainterAvatar(
      {Key? key, required this.url, required this.id, this.onTap, this.size})
      : super(key: key);

  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      return UserPage(id: widget.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            pushToUserPage();
          } else
            widget.onTap!();
        },
        child: widget.size == null
            ? CachedNetworkImage(
                imageUrl: widget.url,
                imageBuilder: (context, imageProvider) => Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                //httpHeaders: Hoster.header(url: widget.url),
                cacheManager: imagesCacheManager,
                errorWidget: (context, url, error) => Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor),
                ),
              )
            : CachedNetworkImage(
                imageUrl: widget.url,
                cacheManager: imagesCacheManager,
                errorWidget: (context, url, error) => Container(
                  width: widget.size!.width,
                  height: widget.size!.height,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  width: widget.size!.width,
                  height: widget.size!.height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                width: widget.size!.width,
                height: widget.size!.height,
                //httpHeaders: Hoster.header(url: widget.url),
              ));
  }
}
