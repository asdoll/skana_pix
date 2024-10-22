import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key? key, required this.data}) : super(key: key);

  @override
  _SelectableHtmlState createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: HtmlWidget(
        widget.data,
        customStylesBuilder: (e) {
          if (e.attributes.containsKey('href')) {
            final color = Theme.of(context).colorScheme.primary;
            return {
              'color': '#${color.value.toRadixString(16).substring(2, 8)}'
            };
          }
          return null;
        },
        onTapUrl: (String url) async {
          try {
            logger("html tap url: $url");
            bool result = await launchUrl(Uri.parse(url),mode: LaunchMode.externalNonBrowserApplication);
            // if (!result) {
            //   await launchUrl(Uri.parse(url),
            //       mode: LaunchMode.externalNonBrowserApplication);
            // }
          } catch (e) {
            Share.share(url);
          }
          return true;
        },
      ),
    );
  }

  bool supportTranslate = false;

  Future<void> initMethod() async {
    if (!DynamicData.isAndroid) return;
    bool results = false;
    setState(() {
      supportTranslate = results;
    });
  }
}