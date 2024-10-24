import 'package:flutter/material.dart';
import 'package:skana_pix/model/novel.dart';

class NovelViewerPage extends StatefulWidget {
  final Novel novel;

  NovelViewerPage(this.novel, {super.key});

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novel Viewer'),
      ),
      body: Center(
        child: Text('Novel Viewer Page'),
      ),
    );
  }
}