import 'dart:math';

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
            AppBar(
              title: Tabs(
                index: mTab.index.value,
                tabs: [
                  Text("Illust•Manga".tr),
                  Text("Novel".tr),
                ],
                onChanged: (int value) {
                  mTab.index.value = value;
                },
              ),
              trailing: [
                IconButton.ghost(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      if (mTab.index.value == 0) {
                        Get.find<HistoryIllust>().clear();
                      } else {
                        Get.find<HistoryNovel>().clear();
                      }
                    })
              ],
            ),
            const Divider()
          ],
          child: IndexedStack(
            index: mTab.index.value,
            children: [
              IllustsHistory(),
              NovelsHistory(),
            ],
          ),
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
    return Obx(() => EasyRefresh(
        controller: refreshController,
        onRefresh: controller.load,
        header: DefaultHeaderFooter.header(context),
        child: Scaffold(
          child: Column(
            children: [
              TextField(
                placeholder: Text("Search Illusts or Pianters".tr),
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
                    searchController.clear();
                  },
                ),
                onChanged: (value) {
                  controller.search(value);
                },
              ).paddingHorizontal(8),
              Expanded(
                child: LayoutBuilder(builder: (context, snapshot) {
                  final rowCount = max(2, (snapshot.maxWidth / 200).floor());
                  return GridView.builder(
                      itemCount: controller.searchResult.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowCount),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Get.to(IllustPageLite(controller
                                    .searchResult[index].illustId
                                    .toString()),preventDuplicates: false);
                            },
                            onLongPress: () async {
                              final result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("${"Delete".tr}?").withAlign(Alignment.centerLeft),
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
                            child: Card(
                                padding: EdgeInsets.all(8),
                                child: PixivImage(controller
                                        .searchResult[index].pictureUrl)
                                    .rounded(16.0)));
                      });
                }),
              ),
            ],
          ),
        )));
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

    return Obx(() => EasyRefresh(
        controller: refreshController,
        onRefresh: controller.load,
        header: DefaultHeaderFooter.header(context),
        child: Scaffold(
          child: Column(
            children: [
              TextField(
                placeholder: Text("Search Novels or Authors".tr),
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
                    searchController.clear();
                  },
                ),
                onChanged: (value) {
                  controller.search(value);
                },
              ).paddingHorizontal(8),
              Expanded(
                child: LayoutBuilder(builder: (context, snapshot) {
                  final rowCount = max(2, (snapshot.maxWidth / 200).floor());
                  return GridView.builder(
                      itemCount: controller.searchResult.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowCount),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Get.to(NovelPageLite(controller
                                    .searchResult[index].novelId
                                    .toString()),preventDuplicates: false);
                            },
                            onLongPress: () async {
                              final result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("${"Delete".tr}?").withAlign(Alignment.centerLeft),
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
                            child: Card(
                                padding: EdgeInsets.all(8),
                                child: PixivImage(controller
                                        .searchResult[index].pictureUrl)
                                    .rounded(16.0)));
                      });
                }),
              ),
            ],
          ),
        )));
  }
}
