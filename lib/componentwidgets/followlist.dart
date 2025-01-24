import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
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
  final bool setAppBar;
  final bool isMe;

  FollowList(
      {Key? key,
      required this.id,
      this.isNovel = false,
      this.isMyPixiv = false,
      this.setAppBar = false,
      this.isMe = false})
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
    return Scaffold(
      appBar: widget.setAppBar
          ? AppBar(
              title: Text(widget.isMyPixiv
                  ? "My Pixiv".tr
                  : widget.isMe
                      ? "My Follow".tr
                      : "Following".tr),
            )
          : null,
      body: Observer(builder: (_) {
        return EasyRefresh(
          controller: easyRefreshController,
          header: DefaultHeaderFooter.header(context),
          onLoad: () => nextPage(),
          onRefresh: () => firstLoad(),
          refreshOnStart: true,
          child: CustomScrollView(
            slivers: [
              if (widget.isMe && !widget.isMyPixiv)
                SliverToBoxAdapter(
                  child: _buildMyPage(context),
                ),
              _buildList(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildList(BuildContext context) {
    return SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate((context, index) {
        final data = users[index];
        return PainterCard(
          user: data,
        );
      }, childCount: users.length),
      gridDelegate: const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600),
    );
  }

  List<bool> isSelected = [true, false];

  Widget _buildMyPage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
            isSelected: isSelected,
            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                  if (isSelected[i]) {
                    restrict = i == 0 ? 'public' : 'private';
                  }
                }
                reset();
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            children: [
              Text("Public".tr),
              Text("Private".tr),
            ]),
      ],
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
                text: "Network Error. Please refresh to try again.".tr);
          }
        });
      }
    });
  }

  void reset() {
    users.clear();
    nextUrl = null;

    firstLoad();
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
                text: "Network Error. Please refresh to try again.".tr);
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
            .getMypixiv(widget.id.toString(), nextUrl)
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
