import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/soup_controller.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../componentwidgets/headerfooter.dart';
import '../componentwidgets/spotlightcard.dart';

class SpotlightPage extends StatefulWidget {
  const SpotlightPage({super.key});

  @override
  State<SpotlightPage> createState() => _SpotlightPageState();
}

class _SpotlightPageState extends State<SpotlightPage> {
  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    final EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    SpotlightStoreBase spotlightStore = Get.put(SpotlightStoreBase(refreshController));
    return Obx(() { 
      return EasyRefresh(
          onLoad: () => spotlightStore.next(),
          onRefresh: () => spotlightStore.fetch(),
          header: DefaultHeaderFooter.header(context),
          refreshOnStart: true,
          controller: refreshController,
          child: WaterfallFlow.builder(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(crossAxisCount: context.isPortrait ? 2 : 4),
            controller: controller,
            itemBuilder: (BuildContext context, int index) {
              return SpotlightCard(spotlight: spotlightStore.articles[index]);
            },
            itemCount: spotlightStore.articles.length,
          ),
        );
    });
  }
}