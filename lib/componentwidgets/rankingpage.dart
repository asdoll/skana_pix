import 'package:flutter/material.dart';

import '../model/worktypes.dart';

class RankingPage extends StatelessWidget {
  final ArtworkType type;
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
