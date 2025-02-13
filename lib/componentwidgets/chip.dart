import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class PixChip extends StatelessWidget {
  final String f;
  final String type;
  final bool isSetting;
  final Function()? onTap;
  const PixChip(
      {super.key,
      required this.f,
      required this.type,
      this.isSetting = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isSetting) {
      return MoonChip(
          onTap: () => delete(context, f, type),
          trailing: const Icon(Icons.close),
          label: Text(f));
    }
    return InkWell(
        onLongPress: () => delete(context, f, type),
        child: MoonChip(label: Text(f), onTap: onTap));
  }

  Future delete(BuildContext context, String f, String type) async {
    final result = await alertDialog<String>(context, "Delete".tr,
        "${"${'Delete'.tr} $f"}?", [
      outlinedButton(
        label: "Cancel".tr,
        onPressed: () {
          Get.back();
        },
      ),
      filledButton(
        label: "Ok".tr,
        onPressed: () {
          Get.back(result: "OK");
        },
      ),
    ]);
    if (result == "OK") {
      localManager.delete(type, [f]);
    }
  }
}
