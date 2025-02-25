import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/tag.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagesearchresult.dart';
import 'package:skana_pix/view/novelview/novelresult.dart';

class PixTag extends StatelessWidget {
  final Tag f;
  final bool isNovel;
  final VoidCallback? onTap;

  const PixTag({super.key, required this.f, this.isNovel = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await _longPressTag(context, f);
      },
      onTap: onTap ?? () {
        if(isNovel) {
          Get.to(
          () => NovelResultPage(
                word: f.name,
                translatedName: f.translatedName ?? "",
              ),
          preventDuplicates: false);
        } else {
          Get.to(
            () => IllustResultPage(
                  word: f.name,
                  translatedName: f.translatedName ?? "",
                ),
            preventDuplicates: false);
        }
      },
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.moonTheme?.tokens.colors.piccolo,
          borderRadius: const BorderRadius.all(Radius.circular(12.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),
                text: TextSpan(
                    text: "#${f.name}",
                    style: TextStyle(
                        color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor),
                    children: [
                  TextSpan(
                    text: " ",
                  ).small(),
                  if (f.translatedName != null)
                    TextSpan(
                            text: "${f.translatedName}",
                            style: TextStyle(color: context.moonTheme?.buttonTheme.colors.filledVariantTextColor,fontStyle: FontStyle.italic))
                        .small()
                ]).small()),
          ],
        ),
      ),
    );
  }

    Future _longPressTag(BuildContext context, Tag f) async {
    switch (await alertDialog<int>(context, f.name, f.translatedName ?? "", [
      outlinedButton(
        label: "Block".tr,
        onPressed: () {
          Get.back(result: 0);
        },
      ),
      filledButton(
        label: "Bookmark".tr,
        onPressed: () {
          Get.back(result: 1);
        },
      ),
      filledButton(
        label: "Copy".tr,
        onPressed: () {
          Get.back(result: 2);
        },
      )
    ])) {
      case 0:
        {
          if (isNovel) {
            localManager.add("blockedNovelTags", [f.name]);
          } else {
            localManager.add("blockedTags", [f.name]);
          }
          Leader.showToast("Blocked".tr);
        }
        break;
      case 1:
        {
          if (isNovel) {
            localManager.add("bookmarkedNovelTags", [f.name]);
          } else {
            localManager.add("bookmarkedTags", [f.name]);
          }
          Leader.showToast("Bookmarked".tr);
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          Leader.showToast("Copied to clipboard".tr);
        }
    }
  }
}