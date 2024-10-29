import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'imagetab.dart';

class FeedIllust extends StatefulWidget {
  FeedIllust({super.key});

  @override
  _FeedIllustState createState() => _FeedIllustState();
}

class _FeedIllustState extends State<FeedIllust> {
  List<bool> isSelected = [true, false, false];
  int tab = 0;
  ObservableList<Illust> illusts = ObservableList();
  bool isLoading = false;
  bool isError = false;
  late EasyRefreshController refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = EasyRefreshController();
    reset();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleButtons(
            isSelected: isSelected,
            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                  if (isSelected[i]) {
                    tab = i;
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
              Text("All".i18n),
              Text("Public".i18n),
              Text("Private".i18n),
            ]),
        Expanded(
          child: buildContent(context),
        ),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    return EasyRefresh(
      controller: refreshController,
      onRefresh: reset,
      onLoad: nextPage,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      child: Observer(
        builder: (context) {
          if (isError && illusts.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text("Error".i18n),
                  ElevatedButton(
                    onPressed: () {
                      reset();
                    },
                    child: Text("Retry".i18n),
                  )
                ],
              ),
            );
          }
          if (illusts.isEmpty) {
            return Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('[ ]',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
              ),
            );
          }
          return WaterfallFlow.builder(
            gridDelegate: _buildGridDelegate(),
            itemBuilder: (BuildContext context, int index) {
              return IllustCard(illusts, true, initialPage: index);
            },
            itemCount: illusts.length,
          );
        },
      ),
    );
  }

  SliverWaterfallFlowDelegate _buildGridDelegate() {
    var count =
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 4;
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  String? nextUrl;

  nextPage() {
    if (isLoading) {
      refreshController.finishLoad();
      return;
    }
    if (nextUrl == "end") {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    isError = false;
    isLoading = true;
    loadIllust().then((value) {
      isLoading = false;
      if (value.success) {
        setState(() {
          illusts.addAll(value.data);
          nextUrl = value.subData ?? "end";
          refreshController.finishLoad();
        });
      } else {
        isError = true;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    });
  }

  reset() {
    illusts.clear();
    nextUrl = null;
    isError = false;
    isLoading = false;
    firstLoad();
  }

  firstLoad() {
    if (isLoading) {
      refreshController.finishRefresh();
      return;
    }
    isLoading = true;
    loadIllust().then((value) {
      isLoading = false;
      if (value.success) {
        setState(() {
          illusts.clear();
          illusts.addAll(value.data);
          nextUrl = value.subData ?? "end";
          refreshController.finishRefresh();
        });
      } else {
        isError = true;
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  Future<Res<List<Illust>>> loadIllust() async {
    String restrict;
    if (tab == 1) {
      restrict = "public";
    } else if (tab == 2) {
      restrict = "private";
    } else {
      restrict = "all";
    }
    return ConnectManager().apiClient.getFollowingArtworks(restrict, nextUrl);
  }
}
