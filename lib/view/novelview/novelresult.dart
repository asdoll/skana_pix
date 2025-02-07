import 'package:flutter/cupertino.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/gotop.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/view/novelview/novellist.dart';

class NovelResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const NovelResultPage(
      {super.key, required this.word, this.translatedName = ''});

  @override
  State<NovelResultPage> createState() => _NovelResultPageState();
}

class _NovelResultPageState extends State<NovelResultPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ListNovelController>(tag: "search_${widget.word}");
  }

  @override
  Widget build(BuildContext context) {
    ListNovelController controller = Get.put(
        ListNovelController(controllerType: ListType.search, tag: widget.word),
        tag: "search_${widget.word}");
    return Scaffold(
        floatingFooter: true,
        footers: [const GoTop()],
        headers: [
          AppBar(
            title: Text(
              widget.translatedName.isEmpty
                  ? widget.word
                  : widget.translatedName,
              overflow: TextOverflow.ellipsis,
            ),
            leading: [const NormalBackButton()],
            trailing: <Widget>[
              IconButton.ghost(
                  icon: Icon(Icons.date_range),
                  onPressed: () async {
                    DateTimeRange? dateTimeRange;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: DatePickerDialog(
                                initialViewType: CalendarViewType.date,
                                selectionMode: CalendarSelectionMode.range,
                                viewMode: context.width < 500
                                    ? CalendarSelectionMode.single
                                    : CalendarSelectionMode.range,
                                initialValue: controller.dateTimeRange == null
                                    ? null
                                    : CalendarValue.range(
                                        controller.dateTimeRange!.start,
                                        controller.dateTimeRange!.end,
                                      ),
                                stateBuilder: (date) {
                                  if (date.isBefore(DateTime(2007, 9))) {
                                    return DateState.disabled;
                                  } //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
                                  if (date.isAfter(DateTime.now())) {
                                    return DateState.disabled;
                                  }
                                  return DateState.enabled;
                                },
                                onChanged: (value) {
                                  if (value == null) return;
                                  final range = value.toRange();
                                  dateTimeRange =
                                      DateTimeRange(range.start, range.end);
                                }),
                            actions: [
                              OutlineButton(
                                child: Text("Cancel".tr),
                                onPressed: () {
                                  dateTimeRange = null;
                                  Get.back();
                                },
                              ),
                              PrimaryButton(
                                child: Text("Confirm".tr),
                                onPressed: () {
                                  Get.back();
                                },
                              )
                            ],
                          );
                        });
                    if (dateTimeRange != null) {
                      controller.dateTimeRange = dateTimeRange;
                      controller.searchOptions.value.startTime =
                          dateTimeRange!.start;
                      controller.searchOptions.value.endTime =
                          dateTimeRange!.end;
                      controller.searchOptions.refresh();
                      controller.refreshController?.callRefresh();
                    }
                  }),
              if (ConnectManager().apiClient.isPremium)
                IconButton.ghost(
                    icon: Icon(Icons.format_list_numbered),
                    onPressed: () {
                      showDropdown(
                          context: context,
                          builder: (context) {
                            return DropdownMenu(
                              children: premiumStarNum.map((List<int> value) {
                                if (value.isEmpty) {
                                  return MenuButton(
                                    child: Text("Default".tr),
                                    onPressed: (context) {
                                      controller.searchOptions.value
                                          .premiumNum = value;
                                      controller.searchOptions.refresh();
                                      controller.refreshController
                                          ?.callRefresh();
                                    },
                                  );
                                } else {
                                  final minStr =
                                      value.elementAtOrNull(1) == null
                                          ? ">${value.elementAtOrNull(0) ?? ''}"
                                          : "${value.elementAtOrNull(0) ?? ''}";
                                  final maxStr =
                                      value.elementAtOrNull(1) == null
                                          ? ""
                                          : "〜${value.elementAtOrNull(1)}";

                                  return MenuButton(
                                      child: Text("$minStr$maxStr"),
                                      onPressed: (context) {
                                        controller.searchOptions.value
                                            .premiumNum = value;
                                        controller.searchOptions.refresh();
                                        controller.refreshController
                                            ?.callRefresh();
                                      });
                                }
                              }).toList(),
                            );
                          });
                    }),
              IconButton.ghost(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    showDropdown(
                        context: context,
                        builder: (context) {
                          return DropdownMenu(
                              children: starNum.map((int value) {
                            if (value > 0) {
                              return MenuButton(
                                child: Text("$value users入り"),
                                onPressed: (context) {
                                  controller.searchOptions.value
                                      .favoriteNumber = value;
                                  controller.searchOptions.refresh();
                                  controller.refreshController?.callRefresh();
                                },
                              );
                            } else {
                              return MenuButton(
                                child: Text("Default".tr),
                                onPressed: (context) {
                                  controller.searchOptions.value
                                      .favoriteNumber = value;
                                  controller.searchOptions.refresh();
                                  controller.refreshController?.callRefresh();
                                },
                              );
                            }
                          }).toList());
                        });
                  }),
              IconButton.ghost(
                  icon: Icon(Icons.filter_alt_outlined),
                  onPressed: () {
                    openSheet(
                        context: context,
                        position: OverlayPosition.bottom,
                        builder: (context) {
                          return StatefulBuilder(builder: (_, setS) {
                            return SafeArea(
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          TextButton(
                                              onPressed: () {},
                                              child: Text("Filter".tr,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary))),
                                          TextButton(
                                              onPressed: () {
                                                controller.refreshController
                                                    ?.callRefresh();
                                                Get.back();
                                              },
                                              child: Text("Apply".tr,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary))),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child:
                                              CupertinoSlidingSegmentedControl(
                                            groupValue: search_target.indexOf(
                                                controller.searchOptions.value
                                                    .searchTarget),
                                            children: <int, Widget>{
                                              0: Text(
                                                  search_target_name_novel[0]
                                                      .tr),
                                              1: Text(
                                                  search_target_name_novel[1]
                                                      .tr),
                                              2: Text(
                                                  search_target_name_novel[2]
                                                      .tr),
                                              3: Text(
                                                  search_target_name_novel[3]
                                                      .tr),
                                            },
                                            onValueChanged: (int? index) {
                                              controller.searchOptions.value
                                                      .searchTarget =
                                                  search_target[index!];
                                              controller.searchOptions
                                                  .refresh();
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child:
                                              CupertinoSlidingSegmentedControl(
                                            groupValue: search_sort.indexOf(
                                                controller.searchOptions.value
                                                    .selectSort),
                                            children: <int, Widget>{
                                              0: Text(search_sort_name[0].tr),
                                              1: Text(search_sort_name[1].tr),
                                              2: Text(search_sort_name[2].tr),
                                              if (!ConnectManager()
                                                      .notLoggedIn &&
                                                  ConnectManager()
                                                      .apiClient
                                                      .isPremium) ...{
                                                3: Text(search_sort_name[3].tr),
                                                4: Text(search_sort_name[4].tr),
                                              }
                                            },
                                            onValueChanged: (int? index) {
                                              if (accountController
                                                      .isLoggedIn.value &&
                                                  index! == 2) {
                                                if (!accountController
                                                    .isPremium.value) {
                                                  controller.refreshController
                                                      ?.callRefresh();
                                                  Get.back();
                                                  return;
                                                }
                                              }
                                              controller.searchOptions.value
                                                      .selectSort =
                                                  search_sort[index!];
                                              controller.searchOptions
                                                  .refresh();
                                            },
                                          ),
                                        ),
                                      ),
                                      Basic(
                                        title: Text("AI-generated".tr),
                                        trailing: Switch(
                                          value: controller
                                              .searchOptions.value.searchAI,
                                          onChanged: (v) {
                                            controller.searchOptions.value
                                                .searchAI = v;
                                            controller.searchOptions.refresh();
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 16,
                                      )
                                    ],
                                  )),
                            );
                          });
                        });
                  }),
            ],
          ),
          const Divider()
        ],
        child: NovelList(controllerTag: "search_${widget.word}"));
  }
}
