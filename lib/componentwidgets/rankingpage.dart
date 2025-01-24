import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../model/ranktagsmap.dart';
import '../model/worktypes.dart';
import 'imagetab.dart';
import 'loading.dart';
import 'novelcard.dart';

class RankingPage extends StatefulWidget {
  final ArtworkType type;
  RankingPage(this.type, {super.key});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late DateTime nowDate;
  String? dateTime;
  List<String> get modeList => widget.type == ArtworkType.ILLUST
      ? modeIllust
      : widget.type == ArtworkType.MANGA
          ? modeMange
          : modeNovel;
  late TabController _tabController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: modeList.length, vsync: this);
    nowDate = DateTime.now();
    super.initState();
  }

  String? toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  DateTime nowDateTime = DateTime.now();
  int index = 0;
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> titles = [];
    for (String i in modeList) {
      titles.add(rankTagsMap[i]!.tr);
    }
    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          child: AppBar(
            automaticallyImplyLeading: true,
            title: TabBar(
              controller: _tabController,
              onTap: (i) => setState(() {
                index = i;
              }),
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs: <Widget>[
                for (var i in titles)
                  Tab(
                    text: i,
                  ),
              ],
            ),
            actions: <Widget>[],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            if (widget.type == ArtworkType.ILLUST)
              for (var element in modeList)
                _OneRankingIllustPage(element, widget.type, dateTime,
                    key: Key(element)),
            if (widget.type == ArtworkType.MANGA)
              for (var element in modeList)
                _OneRankingIllustPage(element, widget.type, dateTime,
                    key: Key(element)),
            if (widget.type == ArtworkType.NOVEL)
              for (var element in modeList)
                _OneRankingNovelPage(element, widget.type, dateTime,
                    key: Key(element)),
          ]),
        )
      ],
    );
  }

  Widget _buildChoicePage(BuildContext context, List<String> rankListMean) {
    return Container(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: 0.0,
            title: Text("Choose ranking tags"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  // await rankStore.saveChange(boolList);
                  // rankStore.inChoice = false;
                },
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                children: [
                  for (var e in rankListMean)
                    FilterChip(
                        label: Text(e),
                        selected: _rankFilters.contains(e),
                        onSelected: (v) {
                          //boolList[rankListMean.indexOf(e)] = v;
                          if (v) {
                            setState(() {
                              _rankFilters.add(e);
                            });
                          } else {
                            setState(() {
                              _rankFilters.remove(e);
                            });
                          }
                        }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<String> _rankFilters = [];

  @override
  bool get wantKeepAlive => true;
}

class _OneRankingIllustPage extends StatefulWidget {
  const _OneRankingIllustPage(this.type, this.awType, this.dateTime,
      {super.key});

  final String type;
  final ArtworkType awType;
  final String? dateTime;

  @override
  _OneRankingIllustPageState createState() => _OneRankingIllustPageState();
}

class _OneRankingIllustPageState
    extends MultiPageLoadingState<_OneRankingIllustPage, Illust> {
  late EasyRefreshController _refreshController;
  late ScrollController _scrollController;
  String? dateTime;

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: true,
              child: IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () async {
                  await _showTimePicker(context);
                },
              ),
            ),
          ],
        ),
        builds(context)
      ],
    );
  }

  Widget builds(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = buildLoading(context);
    } else if (errors != null) {
      child = buildError(context, errors!);
    } else {
      child = buildContent(context, datas!);
    }

    return buildFrame(context, child) ?? child;
  }

  String? toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  DateTime nowDateTime = DateTime.now();

  Future _showTimePicker(BuildContext context) async {
    var nowdate = DateTime.now();
    showDatePicker(
            context: context,
            initialDate: nowDateTime,
            firstDate: DateTime(2007, 8),
            //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
            lastDate: nowdate)
        .then((date) {
      if (date == null) return;
      nowDateTime = date;
      dateTime = toRequestDate(date);
      reset();
    });
  }

  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          kToolbarHeight * 2 -
          MediaQuery.of(context).padding.top,
      child: EasyRefresh.builder(
        controller: _refreshController,
        header: DefaultHeaderFooter.header(context),
        footer: DefaultHeaderFooter.footer(context),
        scrollController: _scrollController,
        onRefresh: () {
          firstLoad();
        },
        onLoad: () {
          nextPage();
        },
        childBuilder: (context, physics) => WaterfallFlow.builder(
          physics: physics,
          controller: _scrollController,
          padding: EdgeInsets.all(5.0),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return IllustCard(data, false,
                index: index, type: widget.awType);
          },
          gridDelegate: _buildGridDelegate(context),
        ),
      ),
    );
  }

  SliverWaterfallFlowDelegate _buildGridDelegate(BuildContext context) {
    var count = 2;
    count =
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 4;
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  @override
  Future<Res<List<Illust>>> loadData(page) async {
    if (nexturl == "end") {
      return Res.error("No more data");
    }
    var res = await getRanking(widget.type, dateTime, nexturl);
    if (!res.error) {
      nexturl = res.subData;
      nexturl ??= "end";
    }
    return res;
  }
}

class _OneRankingNovelPage extends StatefulWidget {
  const _OneRankingNovelPage(this.type, this.awType, this.dateTime,
      {super.key});

  final String type;
  final ArtworkType awType;
  final String? dateTime;

  @override
  _OneRankingNovelPageState createState() => _OneRankingNovelPageState();
}

class _OneRankingNovelPageState extends State<_OneRankingNovelPage> {
  late EasyRefreshController _refreshController;
  ObservableList<Novel> novels = ObservableList();
  bool _isFirstLoading = true;
  String? dateTime;

  bool _isLoading = false;

  String? _error;

  int _page = 1;

  Widget? buildFrame(BuildContext context, Widget child) => null;

  bool get isLoading => _isLoading || _isFirstLoading;

  bool get isFirstLoading => _isFirstLoading;

  String? get errors => _error;

  nextPage() {
    if (_isLoading) return;
    _isLoading = true;
    loadData(_page).then((value) {
      _isLoading = false;
      if (value.success) {
        _page++;
        nextUrl = value.subData;
        setState(() {
          novels.addAll(value.data);
        });
        _refreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        _refreshController.finishLoad(IndicatorResult.fail);
        BotToast.showText(text: message);
        return false;
      }
    });
  }

  void reset() {
    setState(() {
      _isFirstLoading = true;
      _isLoading = false;
      novels.clear();
      _error = null;
      nextUrl = null;
      _page = 1;
    });
    firstLoad();
  }

  void firstLoad() {
    nextUrl = null;
    loadData(_page).then((value) {
      if (value.success) {
        _page++;
        nextUrl = value.subData;
        setState(() {
          _isFirstLoading = false;
          novels.clear();
          novels.addAll(value.data);
        });
        _refreshController.finishLoad();
      } else {
        setState(() {
          _isFirstLoading = false;
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            _error = "Network Error. Please refresh to try again.".tr;
          }
          _refreshController.finishLoad(IndicatorResult.fail);
        });
      }
    });
  }

  String? toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  DateTime nowDateTime = DateTime.now();

  Future _showTimePicker(BuildContext context) async {
    var nowdate = DateTime.now();
    showDatePicker(
            context: context,
            initialDate: nowDateTime,
            firstDate: DateTime(2007, 8),
            //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
            lastDate: nowdate)
        .then((date) {
      if (date == null) return;
      nowDateTime = date;
      dateTime = toRequestDate(date);
      reset();
    });
  }

  @override
  void initState() {
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    firstLoad();
    super.initState();
  }

  Widget buildLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error),
          const SizedBox(height: 12),
          IconButton(
            onPressed: () {
              _refreshController.callRefresh();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
    ).paddingHorizontal(16);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isFirstLoading) {
      child = buildLoading(context);
    } else if (_error != null) {
      child = buildError(context, _error!);
    } else {
      child = buildContent(context);
    }

    return Material(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: true,
                child: IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: () async {
                    await _showTimePicker(context);
                  },
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          kToolbarHeight * 2 -
          MediaQuery.of(context).padding.top,
      child: EasyRefresh(
        onLoad: () => nextPage(),
        onRefresh: () => reset(),
        refreshOnStart: false,
        controller: _refreshController,
        header: DefaultHeaderFooter.header(context),
        child: Observer(builder: (context) {
          return ListView.builder(
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index) {
                Novel novel = novels[index];
                return NovelCard(novel);
              },
              itemCount: novels.length);
        }),
      ),
    );
  }

  String? nextUrl;

  Future<Res<List<Novel>>> loadData(page) async {
    if (nextUrl == "end") {
      _refreshController.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    var res = await ConnectManager()
        .apiClient
        .getNovelRanking(widget.type, dateTime, nextUrl);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      _refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      _refreshController.finishLoad();
    }
    return res;
  }
}
