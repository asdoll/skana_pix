import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  void initState() {
    super.initState();
    boardController.fetchBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(title: "Bulletin Board".tr),
        body: GetX<BoardController>(
          builder: (_) => boardController.loadingState.value ==
                      LoadingState.loading &&
                  boardController.boardList.isEmpty
              ? progressIndicator(context)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                      CupertinoSliverRefreshControl(
                        refreshTriggerPullDistance: 70,
                        onRefresh: boardController.fetchBoard,
                        builder: buildRefreshIndicator,
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 4)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return moonListTileWidgets(
                              label: Text(
                                boardController.boardList[index].title,
                              ).header(),
                              content: HtmlWidget(
                                boardController.boardList[index].content,
                                onTapUrl: (url) {
                                  return launchUrl(Uri.parse(url));
                                },
                                textStyle: context
                                    .moonTheme?.tokens.typography.heading.text14
                                    .apply(
                                  color: context.moonTheme?.tokens.colors.bulma,
                                ),
                              ),
                            );
                          },
                          childCount: boardController.boardList.length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 4)),
                      if(boardController.boardList.length < 10)
                        SliverToBoxAdapter(
                          child: Container(
                            height: Get.size.height,
                          ),
                        ),
                      // SliverToBoxAdapter(
                      //     child: Center(
                      //         child: filledButton(
                      //             onPressed: () => boardController.fetchBoard(),
                      //             label: "Refresh".tr))),
                    ]),
        ));
  }
}
