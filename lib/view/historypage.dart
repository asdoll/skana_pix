import 'dart:math';
import 'package:flutter/material.dart' as m;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/view/novelview/novelpage.dart';
import 'package:skana_pix/componentwidgets/pixivimage.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<MTab>(tag: "history");
  }

  @override
  Widget build(BuildContext context) {
    MTab mTab = Get.put(MTab(), tag: "history");
    return Obx(() => Scaffold(
          headers: [
            TabList(
              index: mTab.index.value,
              children: [
                TabButton(
                    child: Text("Illust•Manga".tr),
                    onPressed: () {
                      mTab.index.value = 0;
                    }),
                TabButton(
                    child: Text("Novel".tr),
                    onPressed: () {
                      mTab.index.value = 1;
                    }),
              ],
            ),
            const Divider(),
          ],
          child: (mTab.index.value == 0) ? IllustsHistory() : NovelsHistory(),
        ));
  }
}

class IllustsHistory extends StatefulWidget {
  const IllustsHistory({super.key});

  @override
  State<IllustsHistory> createState() => _IllustsHistoryState();
}

class _IllustsHistoryState extends State<IllustsHistory> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<HistoryIllust>(tag: "history_illust");
  }

  @override
  Widget build(BuildContext context) {
    HistoryIllust controller = Get.put(HistoryIllust(), tag: "history_illust");
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = refreshController;
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      child: Column(
        children: [
          TextField(
            placeholder: Text("Search Illusts or Pianters".tr),
            controller: searchController,
            leading: StatedWidget.builder(
              builder: (context, states) {
                if (states.focused) {
                  return Icon(Icons.search);
                } else {
                  return Icon(Icons.search).iconMutedForeground();
                }
              },
            ),
            trailing: IconButton.text(
              icon: Icon(Icons.close),
              density: ButtonDensity.compact,
              onPressed: () {
                setState(() {
                  searchController.clear();
                  controller.search("");
                });
              },
            ),
            onChanged: (value) {
              controller.search(value);
            },
          ).paddingAll(8),
          Expanded(
            child: Obx(
              () => EasyRefresh(
                  controller: refreshController,
                  scrollController: globalScrollController,
                  onRefresh: controller.load,
                  refreshOnStart: true,
                  header: DefaultHeaderFooter.header(context),
                  child: WaterfallFlow.builder(
                    padding: const EdgeInsets.only(top: 8),
                    controller: globalScrollController,
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: max(2, (context.width / 200).floor()),
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Get.to(
                                IllustPageLite(controller
                                    .searchResult[index].illustId
                                    .toString()),
                                preventDuplicates: false);
                          },
                          onLongPress: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("${"Delete".tr}?")
                                        .withAlign(Alignment.centerLeft),
                                    actions: <Widget>[
                                      OutlineButton(
                                        child: Text("Cancel".tr),
                                        onPressed: () {
                                          Get.back();
                                        },
                                      ),
                                      PrimaryButton(
                                        child: Text("Ok".tr),
                                        onPressed: () {
                                          Get.back(result: "OK");
                                        },
                                      ),
                                    ],
                                  );
                                });
                            if (result == "OK") {
                              controller.remove(
                                  controller.searchResult[index].illustId);
                            }
                          },
                          child: m.Card(
                              child: PixivImage(
                                      controller.searchResult[index].pictureUrl)
                                  .rounded(16.0)));
                    },
                    itemCount: controller.searchResult.length,
                  )),
            ),
          )
        ],
      ),
    );
  }
}

class NovelsHistory extends StatefulWidget {
  const NovelsHistory({super.key});

  @override
  State<NovelsHistory> createState() => _NovelsHistoryState();
}

class _NovelsHistoryState extends State<NovelsHistory> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<HistoryNovel>(tag: "history_novel");
  }

  @override
  Widget build(BuildContext context) {
    HistoryNovel controller = Get.put(HistoryNovel(), tag: "history_novel");
    EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    controller.refreshController = refreshController;
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      child: Column(
        children: [
          TextField(
            placeholder: Text("Search Novels or Authors".tr),
            controller: searchController,
            leading: StatedWidget.builder(
              builder: (context, states) {
                if (states.focused) {
                  return Icon(Icons.search);
                } else {
                  return Icon(Icons.search).iconMutedForeground();
                }
              },
            ),
            trailing: IconButton.text(
              icon: Icon(Icons.close),
              density: ButtonDensity.compact,
              onPressed: () {
                setState(() {
                  searchController.clear();
                });
                controller.search("");
              },
            ),
            onChanged: (value) {
              controller.search(value);
            },
          ).paddingAll(8),
          Expanded(
            child: Obx(() => EasyRefresh(
                  controller: refreshController,
                  scrollController: globalScrollController,
                  onRefresh: controller.load,
                  refreshOnStart: true,
                  header: DefaultHeaderFooter.header(context),
                  child: WaterfallFlow.builder(
                    padding: const EdgeInsets.only(top: 8),
                    controller: globalScrollController,
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: max(2, (context.width / 200).floor()),
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Get.to(
                                NovelPageLite(controller
                                    .searchResult[index].novelId
                                    .toString()),
                                preventDuplicates: false);
                          },
                          onLongPress: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("${"Delete".tr}?")
                                        .withAlign(Alignment.centerLeft),
                                    actions: <Widget>[
                                      OutlineButton(
                                        child: Text("Cancel".tr),
                                        onPressed: () {
                                          Get.back();
                                        },
                                      ),
                                      PrimaryButton(
                                        child: Text("Ok".tr),
                                        onPressed: () {
                                          Get.back(result: "OK");
                                        },
                                      ),
                                    ],
                                  );
                                });
                            if (result == "OK") {
                              controller.remove(
                                  controller.searchResult[index].novelId);
                            }
                          },
                          child: m.Card(
                              child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: PixivImage(
                                    controller.searchResult[index].pictureUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.4,
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.black),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      controller.searchResult[index].title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ).textSmall(),
                                  ),
                                )
                              ],
                            ),
                          ).rounded(16.0)));
                    },
                    itemCount: controller.searchResult.length,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
