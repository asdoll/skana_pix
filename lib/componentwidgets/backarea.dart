import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';

class CommonBackArea extends StatefulWidget {
  const CommonBackArea({super.key});

  @override
  State<CommonBackArea> createState() => _CommonBackAreaState();
}

class _CommonBackAreaState extends State<CommonBackArea> {
  bool _isLongPress = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IconButton(
        icon: DecoratedIcon(
          icon: Icon(_isLongPress ? Icons.home : Icons.arrow_back),
          decoration: const IconDecoration(border: IconBorder(width: 1.5)),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      onLongPress: () {
        setState(() {
          _isLongPress = true;
        });
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
