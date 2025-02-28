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
    if(type == "search"){
      return MoonChip(
        chipSize: MoonChipSize.sm,
          backgroundColor: context.moonTheme?.tokens.colors.frieza,
          onTap: onTap,
          label: Text(f,
              style: TextStyle(color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor),
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0)));
    }
    if (isSetting) {
      return MoonChip(
          backgroundColor: context.moonTheme?.tokens.colors.frieza,
          onTap: () => delete(context, f, type),
          trailing: Icon(MoonIcons.controls_close_small_16_regular, color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor),
          label: Text(f,
              style: TextStyle(color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor),
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0)));
    }
    return InkWell(
        onLongPress: () => delete(context, f, type),
        child: MoonChip(
            backgroundColor: context.moonTheme?.tokens.colors.frieza,
            label: Text(f,
                style: TextStyle(color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor),
                strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0)),
            onTap: onTap));
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
