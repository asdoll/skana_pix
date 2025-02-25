import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/controller/text_controller.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'package:skana_pix/utils/applinks.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:flutter/material.dart';

import 'controller/like_controller.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      // ignore: avoid_print
      print("Unhandled:${details.exception}\n${details.stack}");
    };
    initLogger();
    await settings.init();
    await TextConfigManager.init();
    //setSystemProxy();
    await ConnectManager().init();
    await M.init();
    handleLinks();
    homeController = Get.put(HomeController(), permanent: true);
    accountController = Get.put(AccountController(), permanent: true);
    localManager = Get.put(LocalManager(), permanent: true);
    localManager.init();
    likeController = Get.put(LikeController(), permanent: true);
    boardController = Get.put(BoardController(), permanent: true);
    boardController.fetchBoard();
    updateController = Get.put(UpdateController(), permanent: true);
    updateController.check();
    tc = Get.put(ThemeController(), permanent: true);
    searchPageController = Get.put(SearchPageController(), permanent: true);
    homeController.init();
    runApp(MyApp());
  }, (e, s) {
    log.e("Unhandled Exception: $e\n$s");
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeManager appValueNotifier = ThemeManager.instance;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid && settings.isHighRefreshRate) {
      FlutterDisplayMode.setHighRefreshRate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appValueNotifier.theme,
      builder: (context, value, child) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        resetOrientation();
        return GetMaterialApp(
          title: 'Skana_pix',
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          ),
          theme: value,
          home: const HomePage(),
          translations: TranslateMap(),
          locale: settings.localeObj(),
          fallbackLocale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('zh', 'CN'),
            const Locale('zh', 'TW'),
          ],
        );
      },
    );
  }
}
