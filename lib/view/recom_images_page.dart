import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/recom_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../componentwidgets/imagetab.dart';

class RecomImagesPage extends StatefulWidget {
  final ArtworkType type;

  const RecomImagesPage(this.type, {super.key});
  @override
  State<RecomImagesPage> createState() => _RecomImagesPageState();
}

class _RecomImagesPageState extends State<RecomImagesPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    RecomImagesController recomImagesController = Get.put(
        RecomImagesController(
            type: widget.type, easyRefreshController: easyRefreshController),
        tag: "recom_${widget.type.name}");
    return EasyRefresh.builder(
      controller: easyRefreshController,
      callLoadOverOffset: DynamicData.isIOS ? 2 : 5,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      refreshOnStart: true,
      onRefresh: () {
        recomImagesController.reset();
      },
      onLoad: () {
        recomImagesController.nextPage();
      },
      childBuilder: (context, physics) => Obx(
        () => CustomScrollView(
          physics: physics,
          slivers: [
            SliverToBoxAdapter(
              child: Container(height: MediaQuery.of(context).padding.top),
            ),
            SliverWaterfallFlow(
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    context.orientation == Orientation.portrait ? 2 : 4,
              ),
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return IllustCard(
                    index: index,
                    type: widget.type,
                    controllerTag: "recom_${widget.type.name}");
              }, childCount: recomImagesController.illusts.length),
            )
          ],
        ),
      ),
    );
  }
}
