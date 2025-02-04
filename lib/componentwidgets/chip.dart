import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:flutter/material.dart' show InkWell;

class PixChip extends StatelessWidget {
  final String f;
  final String type;
  final bool isSetting;
  final ButtonStyle? style;
  final Function()? onTap;
  const PixChip(
      {super.key,
      required this.f,
      required this.type,
      this.isSetting = false,
      this.onTap,
      this.style});

  @override
  Widget build(BuildContext context) {
    if (isSetting) {
      return Chip(
          style: style,
          trailing: ChipButton(
            onPressed: () => delete(context, f, type),
            child: const Icon(Icons.close),
          ),
          child: Text(f));
    }
    return InkWell(
        onLongPress: () => delete(context, f, type),
        child: Chip(style: style, onPressed: onTap, child: Text(f)));
  }

  Future delete(BuildContext context, String f, String type) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete".tr).withAlign(Alignment.centerLeft),
          content: Text("${'Delete'.tr}?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              onPressed: () {
                Get.back(result: "OK");
              },
              child: Text("Ok".tr),
            ),
          ],
        );
      },
    );
    if (result == "OK") {
      localManager.delete(type, [f]);
    }
  }
}
