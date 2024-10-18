import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicData {
  static var activeNavColor =  Colors.indigoAccent;
  static var inActiveNavColor = CupertinoColors.systemGrey;
  static var themeData = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigoAccent,
      brightness: Brightness.light,
    ),
    fontFamily: 'NotoSans',
    useMaterial3: true,
  );
  static var darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigoAccent,
      brightness: Brightness.dark,
    ),
    fontFamily: 'NotoSans',
    useMaterial3: true,
  );
  
  static get locale => PlatformDispatcher.instance.locale;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isIOS => Platform.isIOS;

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState>? mainNavigatorKey;

  static bool get hideR18 => true;
  static bool get feedAIBadge => true;
  static bool get longPressSaveConfirm => true;

  static List<String> blockedTags = [];
  static List<String> blockedUsers = [];
  
  static final recommendScrollController = ScrollController();
}