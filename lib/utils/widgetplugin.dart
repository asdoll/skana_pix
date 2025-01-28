import 'package:flutter/widgets.dart';

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
