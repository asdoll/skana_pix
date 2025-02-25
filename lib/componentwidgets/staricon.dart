import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:like_button/like_button.dart';

class StarIcon extends StatefulWidget {
  final String id;
  final ArtworkType type;
  final double size;
  final bool liked;

  const StarIcon({
    super.key,
    required this.id,
    required this.type,
    this.size = 36,
    this.liked = false,
  });

  @override
  State<StarIcon> createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon> {
  int get liked => widget.liked ? 2 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.size + 4,
        height: widget.size,
        color: Colors.transparent,
        child: Obx(() => LikeButton(
              size: widget.size,
              onTap: (bool v) async {
                await likeController.toggle(widget.id, widget.type, v ? 2 : 0);
                return (widget.type == ArtworkType.ILLUST ||
                            widget.type == ArtworkType.MANGA
                        ? likeController.illusts[widget.id] ?? liked
                        : likeController.novels[widget.id] ?? liked) ==
                    2;
              },
              isLiked: (widget.type == ArtworkType.ILLUST ||
                          widget.type == ArtworkType.MANGA
                      ? likeController.illusts[widget.id] ?? liked
                      : likeController.novels[widget.id] ?? liked) == 2,
            )));
  }
}
