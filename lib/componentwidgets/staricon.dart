import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/moonbariconbutton.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';

/// Like/bookmark button.
///
/// Cards keep the animated [LikeButton] heart ([compact] = false, unchanged
/// geometry), while bars pass [compact] = true to render the very same flat
/// Moon icon button as their neighbours - same 20px glyph, same footprint,
/// same colour - so a bar of actions always lines up.
class StarIcon extends StatefulWidget {
  final String id;
  final ArtworkType type;

  /// Size of the glyph.
  final double size;

  final bool liked;

  /// Colour of the glyph while not liked; falls back to the ambient icon
  /// colour.
  final Color? color;

  /// Colour of the glyph once liked; falls back to Moon's `chichi` (pink).
  final Color? likedColor;

  /// Renders a flat Moon icon button instead of the animated card heart.
  final bool compact;

  const StarIcon({
    super.key,
    required this.id,
    required this.type,
    this.size = 36,
    this.liked = false,
    this.color,
    this.likedColor,
    this.compact = false,
  });

  @override
  State<StarIcon> createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon> {
  int get liked => widget.liked ? 2 : 0;

  /// Live state from the controller, so the button can never disagree with the
  /// rest of the app. 0 = not bookmarked, 2 = bookmarked, 1 = request in
  /// flight.
  int get _state =>
      (widget.type == ArtworkType.ILLUST || widget.type == ArtworkType.MANGA
          ? likeController.illusts[widget.id]
          : likeController.novels[widget.id]) ??
      liked;

  /// [LikeController.toggle] takes the *current* state and derives the action
  /// from it (0 => add, 2 => delete), so [_state] is passed through unchanged -
  /// sending the target state instead makes it call the opposite endpoint and
  /// the request fails while the bookmark stays untouched.
  Future<void> _toggle() =>
      likeController.toggle(widget.id, widget.type, _state);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isLiked = _state == 2;

      if (!widget.compact) {
        return Container(
            width: widget.size + 4,
            height: widget.size,
            color: Colors.transparent,
            child: LikeButton(
              size: widget.size,
              onTap: (bool _) async {
                await _toggle();
                return _state == 2;
              },
              isLiked: isLiked,
            ));
      }

      final Color baseColor =
          widget.color ?? Theme.of(context).colorScheme.onSurface;
      final Color likedColor = widget.likedColor ??
          context.moonTheme?.tokens.colors.chichi ??
          Colors.pinkAccent;

      return MoonBarIconButton(
        icon: MoonIcons.generic_heart_24_light,
        iconSize: widget.size,
        color: isLiked ? likedColor : baseColor,
        onTap: _toggle,
      );
    });
  }
}
