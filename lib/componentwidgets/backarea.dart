import 'package:shadcn_flutter/shadcn_flutter.dart';
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
      child: IconButton.ghost(
        icon: DecoratedIcon(
          icon: Icon(_isLongPress ? Icons.home : Icons.arrow_back),
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
