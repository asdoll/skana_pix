import 'dart:math';

import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/soup_controller.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import '../componentwidgets/spotlightcard.dart';

class SpotlightPage extends StatefulWidget {
  const SpotlightPage({super.key});

  @override
  State<SpotlightPage> createState() => _SpotlightPageState();
}

class _SpotlightPageState extends State<SpotlightPage> {
  late SpotlightStoreBase spotlightStore;

  @override
  void initState() {
    super.initState();
    spotlightStore = Get.put(SpotlightStoreBase());
    spotlightStore.fetch();
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<SpotlightStoreBase>();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<SpotlightStoreBase>(
        builder: (_) => spotlightStore.loadingState.value == LoadingState.loading && spotlightStore.articles.isEmpty
            ? progressIndicator(context)
            : CustomScrollView(
                controller: globalScrollController,
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    refreshTriggerPullDistance: 70,
                    onRefresh: () => spotlightStore.fetch(),
                    builder: buildRefreshIndicator,
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverWaterfallFlow(
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            crossAxisCount: spotlightStore.articles.isEmpty
                                ? 1
                                : max(2, (context.width / 250).floor())),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (spotlightStore.error.value != null &&
                            spotlightStore.error.value!.isNotEmpty &&
                            spotlightStore.articles.isEmpty) {
                          return SizedBox(
                              height: context.height / 1.5,
                              child: Center(
                                child: Column(
                                  children: [
                                    Text("Error".tr)
                                        .h2()
                                        .paddingTop(context.height / 4),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    filledButton(
                                      onPressed: () {
                                        spotlightStore.fetch();
                                      },
                                      label: "Retry".tr,
                                    )
                                  ],
                                ),
                              ));
                        }
                        if (index == spotlightStore.articles.length) {
                          if (spotlightStore.loadingState.value ==
                              LoadingState.idle) {
                            Future.delayed(const Duration(microseconds: 100),
                                () {
                              spotlightStore.next();
                            });
                          }
                          return Container();
                        }
                        return SpotlightCard(
                            spotlight: spotlightStore.articles[index]);
                      },
                      childCount: spotlightStore.articles.length + 1,
                    ),
                  ),
                  buildLoadMoreIndicator(
                      spotlightStore.loadingState.value,
                      () => spotlightStore.next()),
                ],
              ));
  }
}
