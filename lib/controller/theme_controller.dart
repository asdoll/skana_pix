import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart';

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
    if (settings.darkMode == "0") {
      WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
          () {
        updateValue(getUpdatedTheme());
      };
    }
  }

  bool get isDarkMode => settings.isDarkMode;

  ValueNotifier<ThemeData> theme =
      ValueNotifier<ThemeData>(getTheme('zinc', false));

  void updateValue(ThemeData themes) {
    theme.value = themes;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness:
          settings.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          settings.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    log.d(theme.value);
  }
}

ThemeData getTheme(String themeName, bool isDark) {
  switch (themeName) {
    case 'blue':
      return ThemeData(
          colorScheme:
              ColorSchemes.blue(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'green':
      return ThemeData(
          colorScheme:
              ColorSchemes.green(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'red':
      return ThemeData(
          colorScheme:
              ColorSchemes.red(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'yellow':
      return ThemeData(
          colorScheme:
              ColorSchemes.yellow(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'zinc':
      return ThemeData(
          colorScheme:
              ColorSchemes.zinc(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'neutral':
      return ThemeData(
          colorScheme:
              ColorSchemes.neutral(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'stone':
      return ThemeData(
          colorScheme:
              ColorSchemes.stone(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'rose':
      return ThemeData(
          colorScheme:
              ColorSchemes.rose(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'violet':
      return ThemeData(
          colorScheme:
              ColorSchemes.violet(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'slate':
      return ThemeData(
          colorScheme:
              ColorSchemes.slate(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'orange':
      return ThemeData(
          colorScheme:
              ColorSchemes.orange(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    case 'gray':
      return ThemeData(
          colorScheme:
              ColorSchemes.gray(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
    default:
      return ThemeData(
          colorScheme:
              ColorSchemes.zinc(isDark ? ThemeMode.dark : ThemeMode.light),
          radius: 0.5);
  }
}

List<String> getThemeNames() {
  return [
    'blue',
    'green',
    'red',
    'yellow',
    'zinc',
    'neutral',
    'stone',
    'rose',
    'violet',
    'slate',
    'orange',
    'gray'
  ];
}

class ThemeController extends GetxController {
  RxString themeName = settings.themeName.obs;
  RxString darkMode = settings.darkMode.obs;
  RxBool isAMOLED = settings.isAMOLED.obs;
  List<String> themeNames = getThemeNames();
  List<ColorScheme> themeColors = getThemeNames()
      .map((e) => getTheme(e, settings.isDarkMode).colorScheme)
      .toList();

  void changeTheme(String theme) {
    settings.settings[31] = theme;
    settings.updateSettings();
    themeName.value = theme;
    ThemeManager.instance.updateValue(getTheme(theme, settings.isDarkMode));
  }

  void changeDarkMode(String darkMode) {
    settings.settings[0] = darkMode;
    settings.updateSettings();
    this.darkMode.value = settings.darkMode;
    ThemeManager.instance
        .updateValue(getTheme(settings.themeName, settings.isDarkMode));
  }
}
