import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'usercard.dart';

typedef Future<Res<List<UserPreview>>> FutureGet();

class FollowList extends StatefulWidget {
  final int id;
  final bool isNovel;
  final bool isMyPixiv;

  FollowList(
      {Key? key,
      required this.id,
      this.isNovel = false,
      this.isMyPixiv = false})
      : super(key: key);

  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList>
    with AutomaticKeepAliveClientMixin {
  String restrict = 'public';
  late ScrollController _scrollController;
  late ObservableList<UserPreview> users;
  late EasyRefreshController easyRefreshController;

  @override
  void dispose() {
    _scrollController.dispose();
    easyRefreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    users = ObservableList<UserPreview>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (_) {
      return EasyRefresh(
        controller: easyRefreshController,
        header: DefaultHeaderFooter.header(context),
        onLoad: () => nextPage(),
        onRefresh: () => firstLoad(),
        refreshOnStart: true,
        child: CustomScrollView(
          slivers: [
            _buildList(),
          ],
        ),
      );
    });
  }

  Widget _buildList() {
    return SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate((context, index) {
        final data = users[index];
        return PainterCard(
          user: data,
        );
      }, childCount: users.length),
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600),
    );
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
    Res<List<UserPreview>> res = widget.isMyPixiv
        ? await ConnectManager()
            .apiClient
            .getMypixiv(widget.id.toString(), restrict, nextUrl)
        : await ConnectManager()
            .apiClient
            .getFollowing(widget.id.toString(), restrict, nextUrl);
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

  @override
  bool get wantKeepAlive => true;
}
