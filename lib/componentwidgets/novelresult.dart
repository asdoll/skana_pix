import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/filters.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'headerfooter.dart';

class NovelResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const NovelResultPage(
      {Key? key, required this.word, this.translatedName = ''})
      : super(key: key);

  @override
  _NovelResultPageState createState() => _NovelResultPageState();
}

class _NovelResultPageState extends State<NovelResultPage> {
  late ScrollController _scrollController;
  late ObservableList<Novel> novels;
  late EasyRefreshController easyRefreshController;

  int index = 0;

  @override
  void initState() {
    _scrollController = ScrollController();
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    novels = ObservableList<Novel>();
    firstLoad();
    settings.addHistoryTag(widget.word, ArtworkType.NOVEL);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    easyRefreshController.dispose();
    super.dispose();
  }

  SearchOptions searchOptions = SearchOptions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.translatedName.isEmpty ? widget.word : widget.translatedName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          InkWell(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.date_range),
              ),
              onTap: () {
                _buildShowDateRange(context);
              }),
          if (ConnectManager().apiClient.isPremium)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildPremiumStar(),
            ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: _buildStar(),
          ),
          InkWell(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.filter_alt_outlined),
              ),
              onTap: () {
                _buildShowBottomSheet(context);
              }),
        ],
      ),
      body: EasyRefresh(
        controller: easyRefreshController,
        header: DefaultHeaderFooter.header(context),
        scrollController: _scrollController,
        onRefresh: () async {
          firstLoad();
        },
        onLoad: () async {
          nextPage();
        },
        child: Observer(
          builder: (context) {
            return _buildWaterfall(
                context, MediaQuery.of(context).orientation, novels);
          },
        ),
      ),
    );
  }

  DateTimeRange? _dateTimeRange;

  Widget _buildWaterfall(BuildContext context, Orientation orientation,
      ObservableList<Novel> data) {
    return WaterfallFlow.builder(
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      controller: _scrollController,
      padding: EdgeInsets.all(5.0),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return NovelCard(data[index]);
      },
    );
  }

  Future _buildShowDateRange(BuildContext context) async {
    DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: _dateTimeRange,
        firstDate: DateTime(2007, 8),
        lastDate: DateTime.now());
    if (dateTimeRange != null) {
      _dateTimeRange = dateTimeRange;
      searchOptions.startTime = dateTimeRange.start;
      searchOptions.endTime = dateTimeRange.end;
      setState(() {
        _changeQueryParams();
      });
    }
  }

  _changeQueryParams() {
    firstLoad();
  }

  void _buildShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        builder: (context) {
          return StatefulBuilder(builder: (_, setS) {
            return SafeArea(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                              onPressed: () {},
                              child: Text("Filter".tr,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _changeQueryParams();
                                });
                                Navigator.of(context).pop();
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
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: search_target
                                .indexOf(searchOptions.searchTargetNovel),
                            children: <int, Widget>{
                              0: Text(search_target_name_novel[0].tr),
                              1: Text(search_target_name_novel[1].tr),
                              2: Text(search_target_name_novel[2].tr),
                              3: Text(search_target_name_novel[3].tr),
                            },
                            onValueChanged: (int? index) {
                              setS(() {
                                searchOptions.searchTargetNovel =
                                    search_target_novel[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue:
                                search_sort.indexOf(searchOptions.selectSort),
                            children: <int, Widget>{
                              0: Text(search_sort_name[0].tr),
                              1: Text(search_sort_name[1].tr),
                              2: Text(search_sort_name[2].tr),
                              if (!ConnectManager().notLoggedIn &&
                                  ConnectManager().apiClient.isPremium) ...{
                                3: Text(search_sort_name[3].tr),
                                4: Text(search_sort_name[4].tr),
                              }
                            },
                            onValueChanged: (int? index) {
                              if (!ConnectManager().notLoggedIn &&
                                  index! == 2) {
                                if (!ConnectManager().apiClient.isPremium) {
                                  firstLoad();
                                  Navigator.of(context).pop();
                                  return;
                                }
                              }
                              setS(() {
                                searchOptions.selectSort = search_sort[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      SwitchListTile(
                        value: searchOptions.searchAI,
                        onChanged: (v) {
                          setS(() {
                            searchOptions.searchAI = v;
                          });
                        },
                        title: Text("AI-generated".tr),
                      ),
                      Container(
                        height: 16,
                      )
                    ],
                  )),
            );
          });
        });
  }

  int _starValue = 0;

  Widget _buildPremiumStar() {
    return PopupMenuButton<List<int>>(
      initialValue: searchOptions.premiumNum,
      child: Icon(
        Icons.format_list_numbered,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      itemBuilder: (context) {
        return premiumStarNum.map((List<int> value) {
          if (value.isEmpty) {
            return PopupMenuItem(
              value: value,
              child: Text("Default"),
              onTap: () {
                setState(() {
                  searchOptions.premiumNum = value;
                  _changeQueryParams();
                });
              },
            );
          } else {
            final minStr = value.elementAtOrNull(1) == null
                ? ">${value.elementAtOrNull(0) ?? ''}"
                : "${value.elementAtOrNull(0) ?? ''}";
            final maxStr = value.elementAtOrNull(1) == null
                ? ""
                : "〜${value.elementAtOrNull(1)}";

            return PopupMenuItem(
              value: value,
              child: Text("${minStr}${maxStr}"),
              onTap: () {
                setState(() {
                  searchOptions.premiumNum = value;
                  _changeQueryParams();
                });
              },
            );
          }
        }).toList();
      },
    );
  }

  Widget _buildStar() {
    return PopupMenuButton(
      initialValue: _starValue,
      child: Icon(
        Icons.sort,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      itemBuilder: (context) {
        return starNum.map((int value) {
          if (value > 0) {
            return PopupMenuItem(
              value: value,
              child: Text("${value} users入り"),
              onTap: () {
                setState(() {
                  _starValue = value;
                  searchOptions.favoriteNumber = value;
                  _changeQueryParams();
                });
              },
            );
          } else {
            return PopupMenuItem(
              value: value,
              child: Text("Default"),
              onTap: () {
                setState(() {
                  _starValue = value;
                  searchOptions.favoriteNumber = value;
                  _changeQueryParams();
                });
              },
            );
          }
        }).toList();
      },
    );
  }

  void nextPage() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          novels.addAll(checkNovels(value.data));
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".tr);
          }
        });
      }
    });
  }

  void firstLoad() {
    nextUrl = null;
    loadData().then((value) {
      if (value.success) {
        setState(() {
          novels.clear();
          novels.addAll(checkNovels(value.data));
        });
        easyRefreshController.finishRefresh();
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".tr);
          }
        });
        easyRefreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  String? nextUrl;

  Future<Res<List<Novel>>> loadData() async {
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    Res<List<Novel>> res;
    if (nextUrl != null) {
      res = await ConnectManager().apiClient.getNovelsWithNextUrl(nextUrl!);
    } else {
      res = await ConnectManager()
          .apiClient
          .searchNovels(widget.word, searchOptions);
    }
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad();
    }
    return res;
  }
}
