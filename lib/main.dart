import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'package:skana_pix/utils/applinks.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/homepage.dart';
import 'package:skana_pix/view/defaults.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      Log.error("Unhandled", "${details.exception}\n${details.stack}");
    };
    await settings.init();
    await TextConfigManager.init();
    setSystemProxy();
    await ConnectManager().init();
    await TranslateMap.init();
    await Log.init();
    handleLinks();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    runApp(MyApp());
  }, (e, s) {
    loggerError("Unhandled Exception: $e\n$s");
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeStuff appValueNotifier = ThemeStuff.instance;

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
        return MaterialApp(
          title: 'Skana_pix',
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: value.themeData,
          darkTheme: value.darkTheme,
          themeMode: value.themeMode,
          home: const HomePage(),
          navigatorKey: DynamicData.rootNavigatorKey,
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
