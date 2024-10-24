import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  final int type;
  RankingPage(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
      ),
      body: Center(
        child: Text('Ranking Page'),
      ),
    );
  }
}