import 'dart:io';
import 'package:get/get.dart';

class Constants {
  static const String appName = 'SkanaPix';
  static const String appVersion = '1.0.3';
  static const isGooglePlay =
      bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
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
