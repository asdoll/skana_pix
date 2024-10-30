import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../controller/settings.dart';

class DynamicData {
  static var activeNavColor = Colors.indigoAccent;
  static var inActiveNavColor = CupertinoColors.systemGrey;
  static var themeData = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigoAccent,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  static var darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigoAccent,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData get themes =>
      (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark)
          ? themeData
          : darkTheme;

  static bool get isDarkMode => settings.themeMode == ThemeMode.system ?
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark : settings.themeMode == ThemeMode.dark;

  static double widthScreen = WidgetsBinding
          .instance.platformDispatcher.views.first.physicalSize.width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static double heightScreen = WidgetsBinding
          .instance.platformDispatcher.views.first.physicalSize.height /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState>? mainNavigatorKey;

  static final recommendScrollController = ScrollController();
  static final feedScrollController = ScrollController();
  static final searchScrollController = ScrollController();
  static final settingScrollController = ScrollController();
}

class Constants{
  static const String appName = 'SkanaPix';
  static const String appVersion = '1.0.0';
  static const isGooglePlay = bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
}