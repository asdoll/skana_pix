import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({super.key, required this.data});

  @override
  State<SelectableHtml> createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      widget.data,
      customStylesBuilder: (e) {
        if (e.attributes.containsKey('href')) {
          final color = Theme.of(context).colorScheme.primary;
          return {'color': '#${color.value.toRadixString(16).substring(2, 8)}'};
        }
        return null;
      },
      textStyle: TextStyle(fontSize: 14),
      onTapUrl: (String url) async {
        try {
          log.d("html tap url: $url");
          await launchUrl(Uri.parse(url),
              mode: LaunchMode.externalNonBrowserApplication);
        } catch (e) {
          Share.share(url);
        }
        return true;
      },
    );
  }
}
