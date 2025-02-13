import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/illust.dart';

extension WidgetExtension on Widget {
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  Widget paddingLeft(double padding) {
    return Padding(padding: EdgeInsets.only(left: padding), child: this);
  }

  Widget paddingRight(double padding) {
    return Padding(padding: EdgeInsets.only(right: padding), child: this);
  }

  Widget paddingTop(double padding) {
    return Padding(padding: EdgeInsets.only(top: padding), child: this);
  }

  Widget paddingBottom(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding), child: this);
  }

  Widget paddingVertical(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: padding), child: this);
  }

  Widget paddingHorizontal(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding), child: this);
  }

  Widget rounded(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  Widget toCenter() {
    return Center(child: this);
  }

  Widget toAlign(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  Widget sliverPadding(EdgeInsetsGeometry padding) {
    return SliverPadding(padding: padding, sliver: this);
  }

  Widget sliverPaddingAll(double padding) {
    return SliverPadding(padding: EdgeInsets.all(padding), sliver: this);
  }

  Widget sliverPaddingVertical(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: padding), sliver: this);
  }

  Widget sliverPaddingHorizontal(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding), sliver: this);
  }

  Widget fixWidth(double width) {
    return SizedBox(width: width, child: this);
  }

  Widget fixHeight(double height) {
    return SizedBox(height: height, child: this);
  }

  Widget bgColor(Color color) {
    return Container(color: color, child: this);
  }

  PreferredSizeWidget preferredSize(double height) {
    return PreferredSize(preferredSize: Size.fromHeight(height), child: this);
  }
}

final homeKey = GlobalKey<ScaffoldState>();

void openDrawer() {
  homeKey.currentState!.openDrawer();
}

void closeDrawer() {
  homeKey.currentState!.closeDrawer();
}

Future<T?> alertDialog<T>(BuildContext context, String title, String content,
    [List<Widget>? actions]) {
  return showMoonModal<T>(
      context: context,
      builder: (context) {
        return Dialog(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoonAlert(
                borderColor: Get
                    .context?.moonTheme?.buttonTheme.colors.borderColor
                    .withValues(alpha: 0.5),
                showBorder: true,
                label: Text(title).header(),
                verticalGap: 16,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content).paddingBottom(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions
                              ?.map((action) => action.paddingRight(8))
                              .toList() ??
                          [],
                    )
                  ],
                )),
          ],
        ));
      });
}

Widget outlinedButton(
    {String? label, VoidCallback? onPressed, MoonButtonSize? buttonSize}) {
  return MoonOutlinedButton(
      buttonSize: buttonSize ?? MoonButtonSize.sm,
      onTap: onPressed,
      label: label == null ? null : Text(label),
      borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
          .withValues(alpha: 0.5));
}

Widget filledButton(
    {String? label,
    VoidCallback? onPressed,
    MoonButtonSize? buttonSize,
    Color? color}) {
  return MoonFilledButton(
    buttonSize: buttonSize ?? MoonButtonSize.sm,
    onTap: onPressed,
    label: label == null ? null : Text(label),
    backgroundColor: color,
  );
}

Widget moonListTile(
    {required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? leading,
    Widget? trailing}) {
  return InkWell(
    onTap: onTap ?? () {},
    child: MoonMenuItem(
    backgroundColor: Get.context?.moonTheme?.tokens.colors.gohan,
    onTap: onTap ?? () {},
    label: Text(title).header(),
    content: subtitle == null ? null : Text(subtitle).subHeader(),
    leading: leading,
    trailing: trailing,
    ).paddingSymmetric(vertical: 2, horizontal: 8)
  );
}

Widget moonListTileWidgets({required Widget label, Widget? content, Widget? leading, Widget? trailing, VoidCallback? onTap,EdgeInsetsGeometry? menuItemPadding, CrossAxisAlignment? menuItemCrossAxisAlignment, bool noPadding = false}) {
return InkWell(
    onTap: onTap ?? () {},
    child: MoonMenuItem(
    backgroundColor: Get.context?.moonTheme?.tokens.colors.gohan,
    menuItemPadding: menuItemPadding,
    menuItemCrossAxisAlignment: menuItemCrossAxisAlignment,
    onTap: onTap ?? () {},
    label: label,
    content: content,
    leading: leading,
    trailing: trailing,
    ).paddingSymmetric(vertical: noPadding ? 0 : 2, horizontal: noPadding ? 0 : 8)
  );
}

AppBar appBar(
        {required String title,
        String? subtitle,
        Widget? leading = const NormalBackButton(),
        List<Widget>? actions}) =>
    AppBar(
      title: MoonMenuItem(
          onTap: () {},
          label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
              .appHeader(),
          verticalGap: 0,
          content: subtitle == null
              ? null
              : Text(subtitle,
                      style: TextStyle(
                          color: Get.context?.moonTheme?.textAreaTheme.colors
                              .helperTextColor))
                  .subHeader()),
      leading: leading,
      actions: actions,
      shape: Border(
          bottom: BorderSide(
        color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
        width: 0.2,
      )),
    );

extension TextExtension on Text {
  Text appHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text18
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text appSubHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text16
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text header() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text16
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text subHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text14
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text small() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text12
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text xSmall() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text10
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text h1() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text40
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );

  Text h2() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text32
            .copyWith(
                color: style?.color ??
                    Get.context?.moonTheme?.textAreaTheme.colors.textColor),
      );
}

extension TextSpanExtension on TextSpan {
  TextSpan small() => TextSpan(
        style: Get.context?.moonTheme?.tokens.typography.heading.text12
            .copyWith(color: style?.color, fontStyle: style?.fontStyle),
        text: text,
        children: children,
        recognizer: recognizer,
        mouseCursor: mouseCursor,
        locale: locale,
        spellOut: spellOut,
        onEnter: onEnter,
        onExit: onExit,
      );
}

extension Translation on String {
  String get atMost8 {
    if (length > 8) {
      return "${substring(0, 8)}...";
    }
    return this;
  }

  String get atMost13 {
    if (length > 13) {
      return "${substring(0, 8)}...";
    }
    return this;
  }
}

String get copyInfoText =>
    "${"Illust ID:".tr} {illust_id}\n${"Title:".tr} {title}\n${"User ID:".tr} {user_id}\n${"User Name:".tr} {user_name}\n${"Tags:".tr} {tags}";

String illustToShareInfoText(Illust illust) {
  final str = copyInfoText
      .replaceAll('{illust_id}', illust.id.toString())
      .replaceAll("{user_name}", illust.author.name)
      .replaceAll("{tags}", illust.tags.map((e) => e.toString()).join(', '))
      .replaceAll("{user_id}", illust.author.id.toString())
      .replaceAll("{title}", illust.title);
  return str;
}

class Parser {
  static List<String> parseImgsInNovel(String content) {
    var reg = RegExp(r'\[pixivimage.{0,15}\]');
    var regPre = RegExp(r'\[pixivimage:');
    var regEnd = RegExp(r'\]');
    Iterable<Match> matches = reg.allMatches(content);
    List<String> imgs = [];
    for (final Match m in matches) {
      String match = m[0]!;
      imgs.add(match.replaceAll(regPre, '').replaceAll(regEnd, ''));
    }
    return imgs;
  }

  static Color stringToColor(String color) {
    return Color(int.parse(color, radix: 16) + 0xFF000000);
  }
}

void resetOrientation() {
  if (settings.settings[1] == '0') {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else if (settings.settings[1] == '1') {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  } else {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
