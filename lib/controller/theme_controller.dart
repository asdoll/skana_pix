import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart';

class ThemeManager {
  static ThemeManager? _instance;

  static ThemeManager get instance {
    _instance ??= ThemeManager._init();

    return _instance!;
  }

  ThemeData getUpdatedTheme() {
    return getTheme(settings.isDarkMode);
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

  ValueNotifier<ThemeData> theme = ValueNotifier<ThemeData>(getTheme(false));

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

ThemeData getTheme(bool isDark) {
  return (isDark
          ? ThemeData.dark().copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(
                Get.theme.textTheme,
              ),
              appBarTheme: AppBarTheme(
                titleSpacing: 0,
                backgroundColor:
                    MoonTheme(tokens: MoonTokens.dark).tokens.colors.popo,
              ),
              scaffoldBackgroundColor:
                  MoonTheme(tokens: MoonTokens.light).tokens.colors.bulma)
          : ThemeData.light().copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(
                Get.theme.textTheme,
              ),
              appBarTheme: AppBarTheme(
                titleSpacing: 0,
                backgroundColor:
                    MoonTheme(tokens: MoonTokens.dark).tokens.colors.goten,
              ),
              scaffoldBackgroundColor:
                  MoonTheme(tokens: MoonTokens.light).tokens.colors.goten))
      .copyWith(extensions: <ThemeExtension<dynamic>>[
    MoonTheme(tokens: isDark ? MoonTokens.dark.copyWith(
      typography: MoonTypography.typography.copyWith(
        heading: MoonTypography.typography.heading.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        body: MoonTypography.typography.body.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        )
      )
    ) : MoonTokens.light)
  ]);
}

late ThemeController tc;

class ThemeController extends GetxController {
  RxString darkMode = settings.darkMode.obs;
  RxBool dmMenu = false.obs;

  void changeDarkMode(String darkMode) {
    settings.settings[0] = darkMode;
    settings.updateSettings();
    this.darkMode.value = settings.darkMode;
    ThemeManager.instance.updateValue(getTheme(settings.isDarkMode));
  }
}
