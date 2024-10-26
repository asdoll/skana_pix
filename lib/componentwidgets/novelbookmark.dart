import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';

class NovelBookmarkButton extends StatefulWidget {
  final Novel novel;
  final String colorMode;

  const NovelBookmarkButton(
      {Key? key, required this.novel, required this.colorMode})
      : super(key: key);

  @override
  _NovelBookmarkButtonState createState() => _NovelBookmarkButtonState();
}

class _NovelBookmarkButtonState extends State<NovelBookmarkButton> {
  bool isBookmarking = false;
  bool isLight = false;
  @override
  Widget build(BuildContext context) {
    if (widget.colorMode == "light") {
      isLight = true;
    }
    return InkWell(
      onLongPress: () async {
        if (!widget.novel.isBookmarked) {
          try {
            setState(() {
              isBookmarking = true;
            });
            await favoriteNovel(widget.novel.id.toString(), "private");
            setState(() {
              isBookmarking = false;
              widget.novel.isBookmarked = true;
            });
          } catch (e) {}
        } else {
          try {
            setState(() {
              isBookmarking = true;
            });
            await deleteFavoriteNovel(widget.novel.id.toString());
            setState(() {
              isBookmarking = false;
              widget.novel.isBookmarked = false;
            });
          } catch (e) {}
        }
      },
      child: IconButton(
        icon: isBookmarking
            ? Icon(Icons.favorite_outlined,
                color: isLight
                    ? DynamicData.darkTheme.textTheme.bodySmall!.color
                    : Theme.of(context).textTheme.bodySmall!.color)
            : widget.novel.isBookmarked
                ? Icon(Icons.favorite_outlined, color: Colors.red)
                : Icon(Icons.favorite_outline,
                    color: isLight
                        ? DynamicData.darkTheme.textTheme.bodySmall!.color
                        : Theme.of(context).textTheme.bodySmall!.color),
        onPressed: () async {
          if (!widget.novel.isBookmarked) {
            try {
              setState(() {
                isBookmarking = true;
              });
              await favoriteNovel(widget.novel.id.toString(), "public");
              setState(() {
                isBookmarking = false;
                widget.novel.isBookmarked = true;
              });
            } catch (e) {}
          } else {
            try {
              setState(() {
                isBookmarking = true;
              });
              await deleteFavoriteNovel(widget.novel.id.toString());
              setState(() {
                isBookmarking = false;
                widget.novel.isBookmarked = false;
              });
            } catch (e) {}
          }
        },
      ),
    );
  }
}
