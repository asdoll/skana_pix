import 'package:cached_network_image/cached_network_image.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/model/worktypes.dart';

import 'userpage.dart';

class PainterAvatar extends StatelessWidget {
  final String url;
  final int id;
  final GestureTapCallback? onTap;
  final double? size;
  final ArtworkType type;
  final bool isMe;

  const PainterAvatar(
      {super.key,
      required this.url,
      required this.id,
      this.onTap,
      this.size = 60,
      this.type = ArtworkType.ALL,
      this.isMe = false});

  void pushToUserPage() {
    Get.to(() => UserPage(
          id: id,
          type: type,
          isMe: isMe,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (onTap == null) {
            pushToUserPage();
          } else {
            onTap!();
          }
        },
        child: MoonAvatar(
          height: size,
          width: size,
          backgroundImage: CachedNetworkImageProvider(url,
              cacheManager: imagesCacheManager),
        ));
  }
}
