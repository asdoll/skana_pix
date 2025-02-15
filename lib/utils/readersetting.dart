import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/text_composition/text_composition_config.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

const indentation = "　";

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换

Decoration getDecoration(String background, Color backgroundColor) {
  DecorationImage? image;
  if (background.isEmpty || background == 'null') {
    // backgroundColor = Color(int.parse(background.substring(1), radix: 16));
  } else if (background.startsWith("assets")) {
    try {
      image = DecorationImage(
        image: AssetImage(background),
        fit: BoxFit.fill,
        onError: (_, __) {
          print(_);
          print(__);
          image = null;
        },
      );
    } catch (e) {}
  } else if (!background.startsWith("#")) {
    final file = File(background);
    if (file.existsSync()) {
      try {
        image = DecorationImage(
          image: FileImage(file),
          fit: BoxFit.fill,
          onError: (_, __) => image = null,
        );
      } catch (e) {}
    }
  }
  return BoxDecoration(
    color: backgroundColor,
    image: image,
  );
}

class _StyleItem {
  final Color bg;
  final Color text;
  final String img;
  const _StyleItem(this.bg, this.text, this.img);
}

Widget configSettingBuilderMoon(
  BuildContext context,
  TextCompositionConfig config,
  void Function(Color color, void Function(Color color) onChange) onColor,
  void Function(String background, void Function(String background) onChange)
      onBackground,
  void Function(String fontFamily, void Function(String fontFamily) onChange)
      onFontFamily,
) {
  final style = TextStyle(color: Theme.of(context).hintColor);

  Dialog showTextDialog(
    BuildContext context,
    String title,
    String s,
    void Function(String s) onPress, [
    bool isInt = false,
  ]) {
    TextEditingController controller = TextEditingController(text: s);

    return Dialog(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoonAlert(
            borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
                .withValues(alpha: 0.5),
            showBorder: true,
            label: Text(title).header(),
            content: Column(
              children: [
                MoonTextInput(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ).paddingAll(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    outlinedButton(
                      label: "Cancel".tr,
                      onPressed: () {
                        Get.back();
                      },
                    ).paddingRight(8),
                    filledButton(
                      label: "Ok".tr,
                      onPressed: () {
                        final s = (isInt
                                ? RegExp("^\\d+\$")
                                : RegExp("^\\d+(\\.\\d+)?\$"))
                            .stringMatch(controller.text);
                        if (s == null || s.isEmpty) {
                          controller.text += isInt
                              ? "Only numbers are allowed".tr
                              : "Must enter a number".tr;
                          controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: controller.text.length);
                          return;
                        }
                        onPress(controller.text);
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 200),
                            () => controller.dispose());
                      },
                    ).paddingRight(8),
                  ],
                )
              ],
            ))
      ],
    ));
  }

  final colors = [
    const _StyleItem(Color(0xFFFFFFCC), Color(0xFF303133), ''), //page_turn
    const _StyleItem(Color(0xfff1f1f1), Color(0xff373534), ''), //白底
    const _StyleItem(Color(0xfff5ede2), Color(0xff373328), ''), //浅黄
    const _StyleItem(Color(0xFFF5DEB3), Color(0xff373328), ''), //黄
    const _StyleItem(Color(0xffe3f8e1), Color(0xff485249), ''), //绿
    const _StyleItem(Color(0xff999c99), Color(0xff353535), ''), //浅灰
    const _StyleItem(Color(0xff33383d), Color(0xffc5c4c9), ''), //黑
    const _StyleItem(Color(0xff010203), Color(0xFfffffff), ''), //纯黑
    ///
    const _StyleItem(Color(0xFF303133), Color(0xFFFFFFCC), ''), //page_turn
    const _StyleItem(Color(0xff373534), Color(0xfff1f1f1), ''), //白底
    const _StyleItem(Color(0xff373328), Color(0xfff5ede2), ''), //浅黄
    const _StyleItem(Color(0xff373328), Color(0xFFF5DEB3), ''), //黄
    const _StyleItem(Color(0xff485249), Color(0xffe3f8e1), ''), //绿
    const _StyleItem(Color(0xff353535), Color(0xff999c99), ''), //浅灰
    const _StyleItem(Color(0xffc5c4c9), Color(0xff33383d), ''), //黑
    const _StyleItem(Color(0xFfffffff), Color(0xff010203), ''), //纯黑
    ///
    // const _StyleItem(Color(0xffffffff), Color(0xff101010), "assets/bg/001.jpg"),
    // const _StyleItem(Color(0xffffffff), Color(0xff101010), "assets/bg/002.jpg"),
    // const _StyleItem(Color(0xffffffff), Color(0xff000000), "assets/bg/003.png"),
    // const _StyleItem(Color(0xffffffff), Color(0xff102030), "assets/bg/004.jpg"),
    // const _StyleItem(Color(0xff101010), Color(0xffc5c4c9), "assets/bg/005.jpg"),
    // const _StyleItem(Color(0xfffefefe), Color(0xff353535), "assets/bg/006.jpg"),
    // const _StyleItem(Color(0xff101010), Color(0xffc5c4c9), "assets/bg/007.jpg"),
    // const _StyleItem(Color(0xfffefefe), Color(0xff010203), "assets/bg/008.png"),
  ];
  return StatefulBuilder(
    builder: (context, setState) {
      return MoonModal(
          child: ListView(
        children: [
          moonListTile(
              title:
                  "Note: Some effects will only take effect after re-entering the main text page or the next chapter, or after a few pages."
                      .tr),
          Divider(),
          Text("Switches and selections".tr).header().paddingAll(8),
          moonListTile(
              title: "Show status bar".tr,
              trailing: MoonSwitch(
                  value: config.showStatus,
                  onChanged: (value) {
                    if (value) {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                          overlays: SystemUiOverlay.values);
                    } else {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                          overlays: []);
                    }
                    setState(() => config.showStatus = value);
                  })),
          moonListTile(
            title: "Show bottom".tr,
            subtitle: "Show book name, page number and progress".tr,
            trailing: MoonSwitch(
              value: config.showInfo,
              onChanged: (value) => setState(() => config.showInfo = value),
            ),
          ),
          moonListTile(
              title: "Height adjustment".tr,
              subtitle:
                  "Align bottom: Align bottom line to the same position".tr,
              trailing: MoonSwitch(
                value: config.justifyHeight,
                onChanged: (value) =>
                    setState(() => config.justifyHeight = value),
              )),
          moonListTile(
            title: "One-handed operation".tr,
            subtitle: "Clicking on left side also turns page down".tr,
            trailing: MoonSwitch(
              value: config.oneHand,
              onChanged: (value) => setState(() => config.oneHand = value),
            ),
          ),
          moonListTile(
            title: "Underlined text".tr,
            subtitle: "Underline text when reading".tr,
            trailing: MoonSwitch(
              value: config.underLine,
              onChanged: (value) => setState(() => config.underLine = value),
            ),
          ),
          moonListTile(
            title: "Status bar animation".tr,
            subtitle: "Animation can across status bar".tr,
            trailing: MoonSwitch(
              value: config.animationStatus,
              onChanged: (value) =>
                  setState(() => config.animationStatus = value),
            ),
          ),
          moonListTile(
            title: "HD mode".tr,
            subtitle:
                "Increase screenshot quality when enabled. Smoother when disabled"
                    .tr,
            trailing: MoonSwitch(
              value: config.animationHighImage,
              onChanged: (value) =>
                  setState(() => config.animationHighImage = value),
            ),
          ),
          // SwitchListTile(
          //   value: config.animationWithImage,
          //   onChanged: (value) => setState(() => config.animationWithImage = value),
          //   title: Text("背景图跟随"),
          //   subtitle: Text("开启随翻页动画移动，关闭则固定"),
          // ),
          moonListTileWidgets(
            content: Text(
                    "Page-turning animation selection, try dual-column with flip on widescreen (- is horizontal | is vertical + is automatic)"
                        .tr)
                .subHeader(),
            label: Wrap(
              children: [
                for (var pair in <String, AnimationType>{
                  "Curl-".tr: AnimationType.curl,
                  "Cover+".tr: AnimationType.cover,
                  // "水平覆盖": AnimationType.coverHorizontal,
                  // "垂直覆盖": AnimationType.coverVertical,
                  "Flip-".tr: AnimationType.flip,
                  "Simulate-".tr: AnimationType.simulation,
                  // "卷轴半左": AnimationType.simulation2L,
                  // "卷轴半右": AnimationType.simulation2R,
                  "Scroll|".tr: AnimationType.scroll,
                  "Slide+".tr: AnimationType.slide,
                  // "滑动水平": AnimationType.slideHorizontal,
                  // "滑动垂直": AnimationType.slideVertical,
                }.entries)
                  SizedBox(
                    width: 80,
                    height: 30,
                    child: InkWell(
                      onTap: () =>
                          setState(() => config.animation = pair.value),
                      child: Center(
                        child: Text(pair.key,
                            style:
                                config.animation == pair.value ? style : null),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          moonListTile(
            title: "Animation duration(ms)".tr,
            subtitle: "${config.animationDuration}(ms)",
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Animation duration(ms)".tr,
                config.animationDuration.toString(),
                (s) => setState(() => config.animationDuration = int.parse(s)),
                true,
              ),
            ),
          ),
          Divider(),
          Text("Text and layout".tr).header().paddingAll(8),
          moonListTileWidgets(
            label: Container(
              decoration: BoxDecoration(border: Border.all()),
              margin: EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration:
                    getDecoration(config.background, config.backgroundColor),
                padding: EdgeInsets.fromLTRB(
                    config.leftPadding,
                    config.topPadding,
                    config.rightPadding,
                    config.bottomPadding),
                child: Text(
                  "${indentation * config.indentation}这是一段示例文字。This is an example sentence. This is another example sentence. 这是另一段示例文字。",
                  maxLines: null,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: config.fontSize,
                    height: config.fontHeight,
                    color: config.fontColor,
                    fontFamily: config.fontFamily,
                  ),
                ),
              ),
            ),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var c in colors)
                  InkWell(
                    onTap: () => setState(() {
                      config.backgroundColor = c.bg;
                      config.background = c.img;
                      config.fontColor = c.text;
                    }),
                    child: Container(
                      decoration: getDecoration(c.img, c.bg),
                      padding: EdgeInsets.all(4),
                      margin:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text("Text".tr, style: TextStyle(color: c.text)),
                    ),
                  ),
              ],
            ),
          ),
          Divider(),
          moonListTile(
            title: "Columns".tr,
            subtitle:
                "${config.columns}${"(0 for automatic, 2 columns when width exceeds 580)".tr}",
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Columns".tr,
                config.columns.toString(),
                (s) => setState(() => config.columns = int.parse(s)),
                true,
              ),
            ),
          ),
          moonListTile(
            title: "Paragraph indentation".tr,
            subtitle: config.indentation.toString(),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Paragraph indentation".tr,
                config.indentation.toString(),
                (s) => setState(() => config.indentation = int.parse(s)),
                true,
              ),
            ),
          ),
          moonListTile(
            title: "Font color".tr,
            subtitle:
                config.fontColor.toARGB32().toRadixString(16).toUpperCase(),
            onTap: () => onColor(config.fontColor,
                (color) => setState(() => config.fontColor = color)),
          ),
          moonListTile(
            title: "Font size".tr,
            subtitle: config.fontSize.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Font size".tr,
                config.fontSize.toStringAsFixed(1),
                (s) => setState(() => config.fontSize = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Line height".tr,
            subtitle: config.fontHeight.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Line height".tr,
                config.fontHeight.toStringAsFixed(1),
                (s) => setState(() => config.fontHeight = double.parse(s)),
              ),
            ),
          ),
          // ListTile(
          //   title: Text("字体"),
          //   subtitle: Text(config.fontFamily.isEmpty ? "无" : config.fontFamily),
          //   onTap: () => onFontFamily(
          //       config.fontFamily, (font) => setState(() => config.fontFamily = font)),
          // ),
          moonListTile(
            title: "Background color".tr,
            subtitle: config.backgroundColor
                .toARGB32()
                .toRadixString(16)
                .toUpperCase(),
            onTap: () => onColor(
                config.backgroundColor,
                (color) => setState(() {
                      config.backgroundColor = color;
                      config.background = '';
                    })),
          ),
          // ListTile(
          //   title: Text("背景 图片"),
          //   subtitle: Text(config.background),
          //   onTap: () => onBackground(config.background,
          //       (background) => setState(() => config.background = background)),
          // ),
          Divider(),
          moonListTile(title: "Margin".tr),
          Divider(),
          moonListTile(
            title: "Upper margin".tr,
            subtitle: config.topPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Upper margin".tr,
                config.topPadding.toStringAsFixed(1),
                (s) => setState(() => config.topPadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Left margin".tr,
            subtitle: config.leftPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Left margin".tr,
                config.leftPadding.toStringAsFixed(1),
                (s) => setState(() => config.leftPadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Lower margin".tr,
            subtitle: config.bottomPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Lower margin".tr,
                config.bottomPadding.toStringAsFixed(1),
                (s) => setState(() => config.bottomPadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Right margin".tr,
            subtitle: config.rightPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Right margin".tr,
                config.rightPadding.toStringAsFixed(1),
                (s) => setState(() => config.rightPadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Spacing between title and text".tr,
            subtitle: config.titlePadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Spacing between title and text".tr,
                config.titlePadding.toStringAsFixed(1),
                (s) => setState(() => config.titlePadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Paragraph spacing".tr,
            subtitle: config.paragraphPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Paragraph spacing".tr,
                config.paragraphPadding.toStringAsFixed(1),
                (s) =>
                    setState(() => config.paragraphPadding = double.parse(s)),
              ),
            ),
          ),
          moonListTile(
            title: "Column spacing".tr,
            subtitle: config.columnPadding.toStringAsFixed(1),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Column spacing".tr,
                config.columnPadding.toStringAsFixed(1),
                (s) => setState(() => config.columnPadding = double.parse(s)),
              ),
            ),
          ),
          filledButton(
              color: Colors.red,
              buttonSize: MoonButtonSize.lg,
              label: "Reset".tr,
              onPressed: () {
                setState(() {
                  alertDialog(context, "${"Confirm Reset".tr}?", "", [
                    outlinedButton(
                      label: "Cancel".tr,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    filledButton(
                      label: "Ok".tr,
                      onPressed: () {
                        config.reset();
                        Get.back();
                        Get.back();
                        Leader.showToast("Resetted".tr);
                      },
                    ),
                  ]);
                });
              }).toAlign(Alignment.center).paddingAll(8),
          SizedBox(height: context.height/4),
        ],
      ));
    },
  );
}
