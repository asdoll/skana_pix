import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingscreenState createState() => _SettingscreenState();
}

class _SettingscreenState extends State<SettingScreen> {
  String setting = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings Screen"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                moveUserData();
              },
              child: const Text("remove login data"),
            ),
            ElevatedButton(
              onPressed: () {
                putBackUserData();
              },
              child: const Text("put back login data"),
            ),
            ElevatedButton(
              onPressed: () {
                getSettings();
              },
              child: const Text("settings"),
            ),
            Text(setting),
          ],
        ),
      ),
    );
  }

  void getSettings() {
    setting = settings.toJson();
    setState(() {});
  }
}
