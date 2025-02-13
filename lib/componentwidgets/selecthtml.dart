import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:moon_design/moon_design.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/controller/logging.dart';
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
          return {'color': '#${Colors.blue.toHexString()}'};
        }
        return null;
      },
      textStyle: context.moonTheme?.tokens.typography.heading.text14.apply(color: context.moonTheme?.textAreaTheme.colors.textColor),
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
