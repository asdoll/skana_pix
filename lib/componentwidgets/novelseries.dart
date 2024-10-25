import 'package:flutter/material.dart';

class NovelSeriesPage extends StatefulWidget {
  final int seriesId;

  NovelSeriesPage(this.seriesId);

  @override
  _NovelSeriesPageState createState() => _NovelSeriesPageState();
}

class _NovelSeriesPageState extends State<NovelSeriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novel Series'),
      ),
      body: Center(
        child: Text('Novel Series Page'),
      ),
    );
  }
}