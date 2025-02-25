import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController controller =
        EasyRefreshController(controlFinishRefresh: true);

    return Scaffold(
      appBar: appBar(title: "Bulletin Board".tr),
      body: Obx(() {
        return EasyRefresh(
          controller: controller,
          onRefresh: () async {
            boardController.fetchBoard(controller: controller);
          },
          refreshOnStart: true,
          header: DefaultHeaderFooter.header(context),
          refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final board in boardController.boardList)
                moonListTileWidgets(
                  label: Text(
                    board.title,
                  ).header(),
                  content: HtmlWidget(
                    board.content,
                    onTapUrl: (url) {
                      return launchUrl(Uri.parse(url));
                    },
                    textStyle: context
                        .moonTheme?.tokens.typography.heading.text14
                        .apply(
                      color: context.moonTheme?.tokens.colors.bulma,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
