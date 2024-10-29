import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'imagetab.dart';

class FeedNovel extends StatefulWidget {
  FeedNovel({super.key});

  @override
  _FeedNovelState createState() => _FeedNovelState();
}

class _FeedNovelState extends State<FeedNovel> {
  List<bool> isSelected = [true, false, false];
  int tab = 0;
  ObservableList<Novel> novels = ObservableList();
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
          if (isError && novels.isEmpty) {
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
          if (novels.isEmpty) {
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
              return NovelCard(novels[index]);
            },
            itemCount: novels.length,
          );
        },
      ),
    );
  }

  SliverWaterfallFlowDelegate _buildGridDelegate() {
    var count = 1;
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
          novels.addAll(value.data);
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
    novels.clear();
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
          novels.clear();
          novels.addAll(value.data);
          nextUrl = value.subData ?? "end";
          refreshController.finishRefresh();
        });
      } else {
        isError = true;
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  Future<Res<List<Novel>>> loadIllust() async {
    String restrict;
    if (tab == 1) {
      restrict = "public";
    } else if (tab == 2) {
      restrict = "private";
    } else {
      restrict = "all";
    }
    return ConnectManager().apiClient.getNovelFollowing(restrict, nextUrl);
  }
}
