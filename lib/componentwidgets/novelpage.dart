import 'package:flutter/material.dart';
import 'package:skana_pix/model/novel.dart';
import 'data.dart';

class NovelViewerPage extends StatefulWidget {
  final Novel novel;

  NovelViewerPage(this.novel, {super.key});

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  @override
  Widget build(BuildContext context) {
    String tempStr = bookData;
    List<String> pageConfig = [];
    var textPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: tempStr,
        style: TextStyle(fontSize: 20),
      ),
    );
    var width = MediaQuery.of(context).size.width - 20;
    textPainter.layout(maxWidth: width);
    double lineHeight = textPainter.preferredLineHeight;

    // int lineNumber = textHeight ~/ lineHeight;
    int lineNumberPerPage =
        (MediaQuery.of(context).size.height - kToolbarHeight) ~/ lineHeight;
    // int pageNum = (lineNumber / lineNumberPerPage).ceil();
    double actualPageHeight = lineNumberPerPage * lineHeight;
    while (true) {
      textPainter = TextPainter(
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: tempStr,
          style: TextStyle(fontSize: 20),
        ),
      );
      textPainter.layout(maxWidth: width);

      var end = textPainter
          .getPositionForOffset(Offset(width, actualPageHeight))
          .offset;

      if (end == 0) {
        break;
      }

      pageConfig.add(end.toString());

      tempStr = tempStr.substring(end, tempStr.length);

      while (tempStr.startsWith("\n")) {
        tempStr = tempStr.substring(1);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Novel Viewer'),
        ),
        body: Container(
          width: width + 20,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text.rich(
            TextSpan(
              text: bookData.substring(0, int.parse(pageConfig[0])),
            ),
            style: TextStyle(fontSize: 19),
          ),
        ));
  }
}
