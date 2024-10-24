import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class NovelBookmarkButton extends StatefulWidget {
  final Novel novel;

  const NovelBookmarkButton({Key? key, required this.novel}) : super(key: key);

  @override
  _NovelBookmarkButtonState createState() => _NovelBookmarkButtonState();
}

class _NovelBookmarkButtonState extends State<NovelBookmarkButton> {
  bool isBookmarking = false;
  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).textTheme.bodySmall!.color)
            : widget.novel.isBookmarked
                ? Icon(Icons.favorite_outlined,
                    color: Colors.red)
                : Icon(Icons.favorite_outline,
                    color: Theme.of(context).textTheme.bodySmall!.color),
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
