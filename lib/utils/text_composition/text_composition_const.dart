import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'text_composition.dart';

const indentation = "　";

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换

void paintText(
    ui.Canvas canvas, ui.Size size, TextPage page, TextCompositionConfig config) {
  print("paintText ${page.chIndex} ${page.number} / ${page.total}");
  final lineCount = page.lines.length;
  final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1,
      strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),);
  final titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: config.fontSize + 2,
    fontFamily: config.fontFamily,
    color: config.fontColor,
    height: config.fontHeight,
  );
  final style = TextStyle(
    fontSize: config.fontSize,
    fontFamily: config.fontFamily,
    color: config.fontColor,
    height: config.fontHeight,
  );
  final _lineHeight = config.fontSize * config.fontHeight;
  for (var i = 0; i < lineCount; i++) {
    final line = page.lines[i];
    if (line.letterSpacing != null &&
        (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
      tp.text = TextSpan(
        text: line.text,
        style: line.isTitle
            ? TextStyle(
                letterSpacing: line.letterSpacing,
                fontWeight: FontWeight.bold,
                fontSize: config.fontSize + 2,
                fontFamily: config.fontFamily,
                color: config.fontColor,
                height: config.fontHeight,
              )
            : TextStyle(
                letterSpacing: line.letterSpacing,
                fontSize: config.fontSize,
                fontFamily: config.fontFamily,
                color: config.fontColor,
                height: config.fontHeight,
              ),
      );
    } else {
      tp.text = TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
    }
    final offset = Offset(line.dx, line.dy);
    tp.layout();
    tp.paint(canvas, offset);
    if (config.underLine) {
      canvas.drawLine(
          Offset(line.dx, line.dy + _lineHeight),
          Offset(line.dx + page.column, line.dy + _lineHeight),
          Paint()..color = Colors.grey);
    }
  }
  if (config.showInfo) {
    final styleInfo = TextStyle(
      fontSize: 12,
      fontFamily: config.fontFamily,
      color: config.fontColor,
      overflow: TextOverflow.ellipsis,
    );
    tp.text = TextSpan(text: page.info, style: styleInfo);
    tp.layout(maxWidth: size.width - config.leftPadding - config.rightPadding - 60);
    tp.paint(canvas, Offset(config.leftPadding, size.height - 20));

    tp.text = TextSpan(
      text: '${page.number}/${page.total} ${(100 * page.percent).toStringAsFixed(2)}%',
      style: styleInfo,
    );
    tp.layout();
    tp.paint(
        canvas, Offset(size.width - config.rightPadding - tp.width, size.height - 20));
  }
  if (page.columns == 2) {
    drawMiddleShadow(canvas, size);
  }
}

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

Widget configSettingBuilder(
  BuildContext context,
  TextCompositionConfig config,
  void Function(Color color, void Function(Color color) onChange) onColor,
  void Function(String background, void Function(String background) onChange)
      onBackground,
  void Function(String fontFamily, void Function(String fontFamily) onChange)
      onFontFamily,
) {
  final style = TextStyle(color: Theme.of(context).hintColor);

  AlertDialog showTextDialog(
    BuildContext context,
    String title,
    String s,
    void Function(String s) onPress, [
    bool isInt = false,
  ]) {
    TextEditingController controller = TextEditingController(text: s);
    return AlertDialog(
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
      ),
      title: Text(title),
      actions: [
        TextButton(
          child: Text(
            "Cancel".tr,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            "Ok".tr,
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            final s = (isInt ? RegExp("^\\d+\$") : RegExp("^\\d+(\\.\\d+)?\$"))
                .stringMatch(controller.text);
            if (s == null || s.isEmpty) {
              controller.text += isInt ? "Only numbers are allowed".tr : "Must enter a number".tr;
              controller.selection =
                  TextSelection(baseOffset: 0, extentOffset: controller.text.length);
              return;
            }
            onPress(controller.text);
            Navigator.of(context).pop();
            Future.delayed(Duration(milliseconds: 200), () => controller.dispose());
          },
        ),
      ],
    );
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
      return ListView(
        children: [
          ListTile(title: Text("Note: Some effects will only take effect after re-entering the main text page or the next chapter, or after a few pages.".tr)),
          Divider(),
          ListTile(title: Text("Switches and selections".tr)),
          Divider(),
          SwitchListTile(
            value: config.showStatus,
            onChanged: (value) {
              if (value) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
              }
              setState(() => config.showStatus = value);
            },
            title: Text("Show status bar".tr),
          ),
          SwitchListTile(
            value: config.showInfo,
            onChanged: (value) => setState(() => config.showInfo = value),
            title: Text("Show bottom".tr),
            subtitle: Text("Show book name, page number and progress".tr),
          ),
          SwitchListTile(
            value: config.justifyHeight,
            onChanged: (value) => setState(() => config.justifyHeight = value),
            title: Text("Height adjustment".tr),
            subtitle: Text("Align bottom: Align bottom line to the same position".tr),
          ),
          SwitchListTile(
            value: config.oneHand,
            onChanged: (value) => setState(() => config.oneHand = value),
            title: Text("One-handed operation".tr),
            subtitle: Text("Clicking on left side also turns page down".tr),
          ),
          SwitchListTile(
            value: config.underLine,
            onChanged: (value) => setState(() => config.underLine = value),
            title: Text("Underlined text".tr),
          ),
          SwitchListTile(
            value: config.animationStatus,
            onChanged: (value) => setState(() => config.animationStatus = value),
            title: Text("Status bar animation".tr),
            subtitle: Text("Animation can across status bar".tr),
          ),
          SwitchListTile(
            value: config.animationHighImage,
            onChanged: (value) => setState(() => config.animationHighImage = value),
            title: Text("HD mode".tr),
            subtitle: Text("Increase screenshot quality when enabled. Smoother when disabled".tr),
          ),
          // SwitchListTile(
          //   value: config.animationWithImage,
          //   onChanged: (value) => setState(() => config.animationWithImage = value),
          //   title: Text("背景图跟随"),
          //   subtitle: Text("开启随翻页动画移动，关闭则固定"),
          // ),
          ListTile(
            subtitle: Text("Page-turning animation selection, try dual-column with flip on widescreen (- is horizontal | is vertical + is automatic)".tr),
            title: Wrap(
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
                  Container(
                    width: 80,
                    height: 30,
                    child: InkWell(
                      onTap: () => setState(() => config.animation = pair.value),
                      child: Center(
                        child: Text(pair.key,
                            style: config.animation == pair.value ? style : null),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            title: Text("Animation duration(ms)".tr),
            subtitle: Text(config.animationDuration.toString() + "(ms)"),
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
          ListTile(title: Text("Text and layout".tr)),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            margin: EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              decoration: getDecoration(config.background, config.backgroundColor),
              padding: EdgeInsets.fromLTRB(config.leftPadding, config.topPadding,
                  config.rightPadding, config.bottomPadding),
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
          Wrap(
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
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text("Text".tr, style: TextStyle(color: c.text)),
                  ),
                ),
            ],
          ),
          Divider(),
          ListTile(
            title: Text("Columns".tr),
            subtitle: Text("${config.columns}${"(0 for automatic, 2 columns when width exceeds 580)".tr}"),
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
          ListTile(
            title: Text("Paragraph indentation".tr),
            subtitle: Text(config.indentation.toString()),
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
          ListTile(
            title: Text("Font color".tr),
            subtitle: Text(config.fontColor.value.toRadixString(16).toUpperCase()),
            onTap: () => onColor(
                config.fontColor, (color) => setState(() => config.fontColor = color)),
          ),
          ListTile(
            title: Text("Font size".tr),
            subtitle: Text(config.fontSize.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Line height".tr),
            subtitle: Text(config.fontHeight.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Background color".tr),
            subtitle: Text(config.backgroundColor.value.toRadixString(16).toUpperCase()),
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
          ListTile(title: Text("Margin".tr)),
          Divider(),
          ListTile(
            title: Text("Upper margin".tr),
            subtitle: Text(config.topPadding.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Left margin".tr),
            subtitle: Text(config.leftPadding.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Lower margin".tr),
            subtitle: Text(config.bottomPadding.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Right margin".tr),
            subtitle: Text(config.rightPadding.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Spacing between title and text".tr),
            subtitle: Text(config.titlePadding.toStringAsFixed(1)),
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
          ListTile(
            title: Text("Paragraph spacing".tr),
            subtitle: Text(config.paragraphPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                "Paragraph spacing".tr,
                config.paragraphPadding.toStringAsFixed(1),
                (s) => setState(() => config.paragraphPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("Column spacing".tr),
            subtitle: Text(config.columnPadding.toStringAsFixed(1)),
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
        ],
      );
    },
  );
}
