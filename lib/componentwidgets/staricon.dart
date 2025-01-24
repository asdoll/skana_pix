import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';

class StarIcon extends StatefulWidget {
  final String id;
  final ArtworkType type;
  final double size;
  final bool liked;

  const StarIcon({
    super.key,
    required this.id,
    required this.type,
    this.size = 40,
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
        width: widget.size,
        height: widget.size,
        color: Colors.transparent,
        child: IconButton.ghost(
          onPressed: () {
            likeController.toggle(widget.id, widget.type, liked);
          },
          icon: Obx(() {
            switch (widget.type == ArtworkType.ILLUST ||
                    widget.type == ArtworkType.MANGA
                ? likeController.illusts[widget.id] ?? liked
                : likeController.novels[widget.id] ?? liked) {
              case 0:
                return Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).colorScheme.secondaryForeground,
                );
              case 1:
                return Icon(Icons.favorite,
                    color: Theme.of(context).colorScheme.secondaryForeground);
              default:
                return Icon(
                  Icons.favorite,
                  color: Colors.red,
                );
            }
          }),
        ));
  }
}