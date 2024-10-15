import 'package:flutter/material.dart';

import 'view/homepage.dart';
import 'view/defaults.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skana_pix',
      theme: DynamicData.themeData,
      darkTheme: DynamicData.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(title: 'Skana_pix'),
    );
  }
}
