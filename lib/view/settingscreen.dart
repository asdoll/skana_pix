import 'package:flutter/material.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingscreenState createState() => _SettingscreenState();
}

class _SettingscreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
          },
          child: const Text("Go to Main Screen"),
        ),
      ),
    );
  }
}