import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../controller/settings.dart';


class Constants{
  static const String appName = 'SkanaPix';
  static const String appVersion = '1.0.0';
  static const isGooglePlay = bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
}

class DynamicData {
  static var activeNavColor = Color(settings.seedColor);
  static var inActiveNavColor = CupertinoColors.systemGrey;
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(settings.seedColor),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  static ThemeData get darkTheme => settings.isAMOLED? 
  ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(settings.seedColor),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ).copyWith(scaffoldBackgroundColor: Colors.black)
  :ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(settings.seedColor),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeWarp get themeWarp => ThemeWarp(
      themeData: themeData, darkTheme: darkTheme, themeMode: settings.themeMode);

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

class ThemeWarp{
  ThemeData themeData;
  ThemeData darkTheme;
  ThemeMode themeMode;
  ThemeWarp({required this.themeData, required this.darkTheme, required this.themeMode});
}

class ThemeStuff {
  static ThemeStuff? _instance;

  static ThemeStuff get instance {
    _instance ??= ThemeStuff._init();

    return _instance!;
  }

  ThemeStuff._init() {
    theme.value = DynamicData.themeWarp;
  }

  ValueNotifier<ThemeWarp> theme = ValueNotifier<ThemeWarp>(DynamicData.themeWarp);

  void updateValue(ThemeWarp themes) {
    theme.value = themes;
    print(theme.value);
  }
}