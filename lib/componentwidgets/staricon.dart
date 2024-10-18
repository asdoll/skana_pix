import 'package:flutter/material.dart';

class StarIcon extends StatefulWidget {
  final int state;

  const StarIcon({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  _StarIconState createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon> {
  late int state;

  @override
  void initState() {
    state = widget.state;
    super.initState();
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