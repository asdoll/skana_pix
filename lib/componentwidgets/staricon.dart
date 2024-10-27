import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';

import '../model/illust.dart';

typedef UpdateFavoriteFunc = void Function(bool v);

class StarIcon extends StatefulWidget {
  final int state;
  final Illust illust;

  static Map<String, UpdateFavoriteFunc> favoriteCallbacks = {};

  const StarIcon({
    Key? key,
    required this.state,
    required this.illust,
  }) : super(key: key);

  @override
  _StarIconState createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon> {
  late int state;

  @override
  void initState() {
    StarIcon.favoriteCallbacks[widget.illust.toString()] = (v) {
      setState(() {
        widget.illust.isBookmarked = v;
      });
    };
    state = widget.state;
    super.initState();
  }

  @override
  void dispose() {
    StarIcon.favoriteCallbacks.remove(widget.illust.toString());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      setState(() {
        state = widget.state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: Colors.transparent,
      child: _buildData(state),
    );
  }

  Widget _buildData(int state) {
    switch (state) {
      case 0:
        return Icon(
          Icons.favorite_border,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
      case 1:
        return Icon(Icons.favorite,
            color: Theme.of(context).colorScheme.onSurfaceVariant);
      default:
        return Icon(
          Icons.favorite,
          color: Colors.red,
        );
    }
  }
}
