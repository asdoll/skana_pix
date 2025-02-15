import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/gotop.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/model/searches.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
        floatingActionButton: const GoTop(),
        appBar: appBar(
          title: widget.translatedName.isEmpty
              ? widget.word
              : widget.translatedName,
          actions: [
            MoonButton.icon(
                icon: Icon(Icons.date_range),
                buttonSize: MoonButtonSize.sm,
                onTap: () async {
                  List<DateTime> dateTimeRange = [];
                  if (controller.dateTimeRange != null) {
                    dateTimeRange = [
                      controller.dateTimeRange!.start,
                      controller.dateTimeRange!.end
                    ];
                  }
                  await showMoonModal<void>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                            child: ListView(shrinkWrap: true, children: [
                          MoonAlert(
                              borderColor: Get.context?.moonTheme?.buttonTheme
                                  .colors.borderColor
                                  .withValues(alpha: 0.5),
                              showBorder: true,
                              label: Text("Date".tr),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CalendarDatePicker2(
                                      config: CalendarDatePicker2Config(
                                          calendarType:
                                              CalendarDatePicker2Type.range,
                                          disableMonthPicker: true,
                                          selectedRangeHighlightColor: context
                                              .moonTheme
                                              ?.tokens
                                              .colors
                                              .frieza60,
                                          selectedDayHighlightColor: context
                                              .moonTheme?.tokens.colors.frieza,
                                          selectedDayTextStyle: TextStyle(
                                              color: context.moonTheme?.tokens
                                                  .colors.bulma),
                                          firstDate: DateTime(2007, 9, 10),
                                          lastDate: DateTime.now()),
                                      value: dateTimeRange,
                                      onValueChanged: (value) =>
                                          dateTimeRange = value),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        outlinedButton(
                                          label: "Reset".tr,
                                          onPressed: () {
                                            controller.dateTimeRange =
                                                      null;
                                                  Get.back();
                                                  controller.searchOptions.value
                                                          .startTime = null;
                                                  controller.searchOptions.value
                                                          .endTime = null;
                                                  controller.searchOptions
                                                      .refresh();
                                                  controller.refreshController
                                                      ?.callRefresh();
                                          },
                                        ),
                                        Spacer(),
                                        outlinedButton(
                                          label: "Cancel".tr,
                                          onPressed: () {
                                            dateTimeRange = [];
                                            Get.back();
                                          },
                                        ).paddingRight(8),
                                        filledButton(
                                          color: context
                                              .moonTheme?.tokens.colors.frieza,
                                          label: "Confirm".tr,
                                          onPressed: () {
                                            if (dateTimeRange.length != 2) {
                                              return;
                                            }
                                            controller.dateTimeRange =
                                                DateTimeRange(
                                                    start: dateTimeRange.first,
                                                    end: dateTimeRange.last);
                                            Get.back();
                                            controller.searchOptions.value
                                                    .startTime =
                                                controller.dateTimeRange!.start;
                                            controller.searchOptions.value
                                                    .endTime =
                                                controller.dateTimeRange!.end;
                                            controller.searchOptions.refresh();
                                            controller.refreshController
                                                ?.callRefresh();
                                          },
                                        ).paddingRight(8)
                                      ])
                                ],
                              ))
                        ]));
                      });
                }),
            if (accountController.isPremium.value)
              MoonDropdown(
                  show: controller.showPremiumMenu.value,
                  maxWidth: 200,
                  content: Column(
                    children: premiumStarNum.map((List<int> value) {
                      if (value.isEmpty) {
                        return MoonMenuItem(
                            label: Text("Default".tr),
                            onTap: () {
                              controller.showPremiumMenu.value = false;
                              controller.searchOptions.value.premiumNum = value;
                              controller.searchOptions.refresh();
                              controller.refreshController?.callRefresh();
                            });
                      } else {
                        final minStr = value.elementAtOrNull(1) == null
                            ? ">${value.elementAtOrNull(0) ?? ''}"
                            : "${value.elementAtOrNull(0) ?? ''}";
                        final maxStr = value.elementAtOrNull(1) == null
                            ? ""
                            : "〜${value.elementAtOrNull(1)}";
                        return MoonMenuItem(
                            label: Text("$minStr$maxStr"),
                            onTap: () {
                              controller.showPremiumMenu.value = false;
                              controller.searchOptions.value.premiumNum = value;
                              controller.searchOptions.refresh();
                              controller.refreshController?.callRefresh();
                            });
                      }
                    }).toList(),
                  ),
                  onTapOutside: () => controller.showPremiumMenu.value = false,
                  child: MoonButton.icon(
                      icon: Icon(Icons.format_list_numbered),
                      buttonSize: MoonButtonSize.sm,
                      onTap: () {
                        controller.showPremiumMenu.value =
                            !controller.showPremiumMenu.value;
                      })),
            MoonDropdown(
                show: controller.showSortMenu.value,
                maxWidth: 200,
                content: Column(
                  children: starNum.map((int value) {
                    if (value <= 0) {
                      return MoonMenuItem(
                          label: Text("Default".tr),
                          onTap: () {
                            controller.showSortMenu.value = false;
                            controller.searchOptions.value.favoriteNumber =
                                value;
                            controller.searchOptions.refresh();
                            controller.refreshController?.callRefresh();
                          });
                    } else {
                      return MoonMenuItem(
                          label: Text("$value users入り"),
                          onTap: () {
                            controller.showSortMenu.value = false;
                            controller.searchOptions.value.favoriteNumber =
                                value;
                            controller.searchOptions.refresh();
                            controller.refreshController?.callRefresh();
                          });
                    }
                  }).toList(),
                ),
                onTapOutside: () => controller.showSortMenu.value = false,
                child: MoonButton.icon(
                    icon: Icon(Icons.star_outline),
                    buttonSize: MoonButtonSize.sm,
                    onTap: () {
                      controller.showSortMenu.value =
                          !controller.showSortMenu.value;
                    })),
            MoonButton.icon(
                icon: Icon(Icons.filter_alt_outlined),
                buttonSize: MoonButtonSize.sm,
                onTap: () {
                  showMoonModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      MoonTextButton(
                                        onTap: () {},
                                        label: Text("Filter".tr).subHeader(),
                                      ),
                                      filledButton(
                                          onPressed: () {
                                            controller.refreshController
                                                ?.callRefresh();
                                            Get.back();
                                          },
                                          label: "Apply".tr),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: Obx(
                                          () =>
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
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Obx(
                                        () => CupertinoSlidingSegmentedControl(
                                          groupValue: search_sort.indexOf(
                                              controller.searchOptions.value
                                                  .selectSort),
                                          children: <int, Widget>{
                                            0: Text(search_sort_name[0].tr),
                                            1: Text(search_sort_name[1].tr),
                                            2: Text(search_sort_name[2].tr),
                                            if (accountController
                                                .isPremium.value) ...{
                                              3: Text(search_sort_name[3].tr),
                                              4: Text(search_sort_name[4].tr),
                                            }
                                          },
                                          onValueChanged: (int? index) {
                                            if (accountController
                                                    .isLoggedIn.value &&
                                                index != null &&
                                                index > 2) {
                                              if (!accountController
                                                  .isPremium.value) {
                                                Get.back();
                                                return;
                                              }
                                            }
                                            controller.searchOptions.value
                                                    .selectSort =
                                                search_sort[index!];
                                            controller.searchOptions.refresh();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => MoonMenuItem(
                                      onTap: () {},
                                      label: Text("AI-generated".tr),
                                      trailing: MoonSwitch(
                                        value: controller
                                            .searchOptions.value.searchAI,
                                        onChanged: (v) {
                                          controller
                                              .searchOptions.value.searchAI = v;
                                          controller.searchOptions.refresh();
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 16,
                                  )
                                ],
                              )),
                        );
                      });
                }),
          ],
        ),
        body: NovelList(controllerTag: "search_${widget.word}"));
  }
}
