import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'utils/applinks.dart';
import 'utils/translate.dart';
import 'view/homepage.dart';
import 'view/defaults.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      Log.error("Unhandled", "${details.exception}\n${details.stack}");
    };
    await settings.init();
    setSystemProxy();
    await ConnectManager().init();
    await TranslateMap.init();
    await Log.init();
    handleLinks();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    runApp(const MyApp());
  }, (e, s) {
    loggerError("Unhandled Exception: $e\n$s");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skana_pix',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: DynamicData.themeData,
      darkTheme: DynamicData.darkTheme,
      themeMode: settings.themeMode,
      home: const HomePage(),
      navigatorKey: DynamicData.rootNavigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
  }
}
