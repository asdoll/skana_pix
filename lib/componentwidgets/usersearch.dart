import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'headerfooter.dart';
import 'usercard.dart';

class UserResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const UserResultPage({Key? key, required this.word, this.translatedName = ''})
      : super(key: key);

  @override
  _UserResultPageState createState() => _UserResultPageState();
}

class _UserResultPageState extends State<UserResultPage> {
 late ScrollController _scrollController;
  late ObservableList<UserPreview> users;
  late EasyRefreshController easyRefreshController;

  int index = 0;

  @override
  void initState() {
    _scrollController = ScrollController();
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    users = ObservableList<UserPreview>();
    firstLoad();
    settings.addHistory(widget.word, null);
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
                context, MediaQuery.of(context).orientation, users);
          },
        ),
      ),
    );
  }

  DateTimeRange? _dateTimeRange;

  Widget _buildWaterfall(BuildContext context, Orientation orientation,
      ObservableList<UserPreview> data) {
    return WaterfallFlow.builder(
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      controller: _scrollController,
      padding: EdgeInsets.all(5.0),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return PainterCard(user: data[index]);
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

  void nextPage() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          users.addAll(value.data);
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
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
          users.clear();
          users.addAll(value.data);
        });
        easyRefreshController.finishRefresh();
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
          }
        });
        easyRefreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  String? nextUrl;

  Future<Res<List<UserPreview>>> loadData() async {
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    Res<List<UserPreview>> res = await ConnectManager().apiClient.searchUsers(widget.word, nextUrl);
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
