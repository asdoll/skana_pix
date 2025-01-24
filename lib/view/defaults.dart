import 'dart:io';
//import 'package:flutter/scheduler.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../controller/logging.dart';
import '../controller/settings.dart';


class Constants{
  static const String appName = 'SkanaPix';
  static const String appVersion = '1.0.3';
  static const isGooglePlay = bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
}

class DynamicData {

  static double widthScreen = Get.width;

  static double heightScreen = Get.height;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

}

class ThemeManager {
  static ThemeManager? _instance;

  static ThemeManager get instance {
    _instance ??= ThemeManager._init();

    return _instance!;
  }

  ThemeData getUpdatedTheme() {
    return getTheme(settings.themeName, settings.isDarkMode);
  }

  ThemeManager._init() {
    updateValue(getUpdatedTheme());
    if(settings.darkMode == "0") {
      WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
          () {
        updateValue(getUpdatedTheme());
      };
    }
  }

  ValueNotifier<ThemeData> theme = ValueNotifier<ThemeData>(getTheme('zinc', false));

  void updateValue(ThemeData themes) {
    theme.value = themes;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    log.d(theme.value);
  }
}

ThemeData getTheme(String themeName, bool isDark) {
  switch (themeName) {
    case 'blue':
      return ThemeData(colorScheme: ColorSchemes.blue(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'green':
      return ThemeData(colorScheme: ColorSchemes.green(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'red':
      return ThemeData(colorScheme: ColorSchemes.red(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'yellow':
      return ThemeData(colorScheme: ColorSchemes.yellow(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'zinc':
      return ThemeData(colorScheme: ColorSchemes.zinc(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'neutral':
      return ThemeData(colorScheme: ColorSchemes.neutral(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'stone':
      return ThemeData(colorScheme: ColorSchemes.stone(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'rose':
      return ThemeData(colorScheme: ColorSchemes.rose(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'violet':
      return ThemeData(colorScheme: ColorSchemes.violet(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'slate':
      return ThemeData(colorScheme: ColorSchemes.slate(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'orange':
      return ThemeData(colorScheme: ColorSchemes.orange(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    case 'gray':
      return ThemeData(colorScheme: ColorSchemes.gray(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
    default:
      return ThemeData(colorScheme: ColorSchemes.zinc(isDark ? ThemeMode.dark : ThemeMode.light),radius: 0.5);
  }
}

List<String> getThemeNames() {
  return ['blue', 'green', 'red', 'yellow', 'zinc', 'neutral', 'stone', 'rose', 'violet', 'slate', 'orange', 'gray'];
}