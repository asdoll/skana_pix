import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/soup_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
  void dispose() {
    super.dispose();
    Get.delete<SpotlightStoreBase>();
  }

  @override
  Widget build(BuildContext context) {
    final EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    SpotlightStoreBase spotlightStore = Get.put(SpotlightStoreBase());
    spotlightStore.controller = refreshController;
    return Obx(() {
      return EasyRefresh(
        onLoad: () => spotlightStore.next(),
        onRefresh: () => spotlightStore.fetch(),
        header: DefaultHeaderFooter.header(context),
        refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
        refreshOnStart: true,
        scrollController: globalScrollController,
        controller: refreshController,
        child: WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: spotlightStore.articles.isEmpty
                  ? 1
                  : max(2, (context.width / 250).floor())),
          controller: globalScrollController,
          itemBuilder: (BuildContext context, int index) {
            if (spotlightStore.error.value != null &&
                spotlightStore.error.value!.isNotEmpty &&
                spotlightStore.articles.isEmpty) {
              return SizedBox(
                  height: context.height / 1.5,
                  child: Center(
                    child: Column(
                      children: [
                        Text("Error".tr).h2().paddingTop(context.height / 4),
                        SizedBox(
                          height: 10,
                        ),
                        filledButton(
                          onPressed: () {
                            refreshController.callRefresh();
                          },
                          label: "Retry".tr,
                        )
                      ],
                    ),
                  ));
            }
            if (index == spotlightStore.articles.length) {
              return Container();
            }
            return SpotlightCard(spotlight: spotlightStore.articles[index]);
          },
          itemCount: spotlightStore.articles.length + 1,
        ).paddingTop(4),
      );
    });
  }
}
