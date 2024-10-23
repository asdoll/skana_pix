import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

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
      home: const HomePage(title: 'Skana_pix'),
      navigatorKey: DynamicData.rootNavigatorKey,
    );
  }
}
