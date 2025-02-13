import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:skana_pix/view/homepage.dart';

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
          icon: Icon(_isLongPress ? Icons.home : Icons.arrow_back,color: Colors.white,),
          decoration: const IconDecoration(border: IconBorder(width: 1.5)),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      onLongPress: () {
        setState(() {
          _isLongPress = true;
        });
        Get.offAll(() => const HomePage());
      },
    );
  }
}

class NormalBackButton extends StatelessWidget {
  const NormalBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}
