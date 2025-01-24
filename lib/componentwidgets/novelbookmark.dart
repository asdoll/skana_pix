import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';

typedef UpdateFavoriteFunc = void Function(bool v);

class NovelBookmarkButton extends StatefulWidget {
  final Novel novel;
  final String colorMode;

  static Map<String, UpdateFavoriteFunc> favoriteCallbacks = {};

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
  void initState() {
    NovelBookmarkButton.favoriteCallbacks[widget.novel.id.toString()] = (v) {
      setState(() {
        widget.novel.isBookmarked = v;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    NovelBookmarkButton.favoriteCallbacks.remove(widget.novel.id.toString());
    super.dispose();
  }

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
            BotToast.showText(text: "Bookmarked privately".tr);
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
        NovelBookmarkButton.favoriteCallbacks[widget.novel.id.toString()]
            ?.call(widget.novel.isBookmarked);
      },
      child: IconButton(
        icon: isBookmarking
            ? Icon(Icons.favorite_outlined,
                color: isLight
                    ? Colors.white
                    : Theme.of(context).textTheme.bodySmall!.color)
            : widget.novel.isBookmarked
                ? Icon(Icons.favorite_outlined, color: Colors.red)
                : Icon(Icons.favorite_outline,
                    color: isLight
                        ? Colors.white
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
          NovelBookmarkButton.favoriteCallbacks[widget.novel.id.toString()]
              ?.call(widget.novel.isBookmarked);
        },
      ),
    );
  }
}
