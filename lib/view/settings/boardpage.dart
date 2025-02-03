import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/update_controller.dart';
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
      headers: [
        AppBar(
          title: Text("Bulletin Board".tr),
          padding: EdgeInsets.all(10),
          leading: [
            const NormalBackButton(),
          ],
        ),
        const Divider()
      ],
      child: Obx(() {
        return EasyRefresh(
          controller: controller,
          onRefresh: () async {
            boardController.fetchBoard(controller: controller);
          },
          refreshOnStart: true,
          header: DefaultHeaderFooter.header(context),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final board in boardController.boardList)
                Card(
                    child: Basic(
                  title: Text(
                    board.title,
                  ),
                  content: HtmlWidget(
                    board.content,
                    onTapUrl: (url) {
                      return launchUrl(Uri.parse(url));
                    },
                  ),
                )),
            ],
          ),
        );
      }),
    );
  }
}
