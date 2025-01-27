import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'package:skana_pix/utils/applinks.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
    Get.addTranslations(TranslateMap.translation);
    Get.updateLocale(settings.localeObj());
    handleLinks();
    pageIndexController = Get.put(PageIndexController(),permanent: true);
    accountController = Get.put(AccountController(),permanent: true);
    localManager = Get.put(LocalManager(),permanent: true);
    localManager.init();
    likeController = Get.put(LikeController(),permanent: true);
    boardController = Get.put(BoardController(),permanent: true);
    updateController = Get.put(UpdateController(),permanent: true);
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
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
    if(Platform.isAndroid && settings.isHighRefreshRate) {
      FlutterDisplayMode.setHighRefreshRate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appValueNotifier.theme,
      builder: (context, value, child) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return ShadcnApp(
          title: 'Skana_pix',
          navigatorObservers: [GetObserver()],
          theme: value,
          home: const HomePage(),
          navigatorKey: Get.key,
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
