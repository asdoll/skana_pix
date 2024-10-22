import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const ResultPage({Key? key, required this.word, this.translatedName = ''})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
     super.initState();
    // tagHistoryStore.insert(
    //     TagsPersist(name: widget.word, translatedName: widget.translatedName));
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              onTap: (i) {
                if (i == index) {
                  //topStore.setTop("401");
                }
                index = i;
              },
              tabs: [
                Tab(
                  //text: I18n.of(context).illust,
                ),
                Tab(
                  //text: I18n.of(context).painter,
                ),
              ]),
        ),
        body: TabBarView(children: [
          // ResultIllustList(word: widget.word),
          // SearchResultPainterPage(
          //   word: widget.word,
          // ),
        ]),
      ),
    );
  }
}
