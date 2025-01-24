import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/model/worktypes.dart';

import 'userpage.dart';

class PainterAvatar extends StatefulWidget {
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

  @override
  State<PainterAvatar> createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Get.to(() => UserPage(
          id: widget.id,
          type: widget.type,
          isMe: widget.isMe,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            pushToUserPage();
          } else {
            widget.onTap!();
          }
        },
        child: Avatar(
          backgroundColor: Theme.of(context).colorScheme.card,
          initials: Avatar.getInitials(widget.id.toString()),
          size: widget.size,
          provider: CachedNetworkImageProvider(widget.url,
              cacheManager: imagesCacheManager),
        ));
  }
}
