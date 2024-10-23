import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'headerfooter.dart';
import 'spotlightcard.dart';

class SpotlightPage extends StatelessWidget {
  const SpotlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    final EasyRefreshController refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    SpotlightStoreBase spotlightStore = SpotlightStoreBase(refreshController);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
        DynamicData.isDarkMode
            ? Image.asset(
                'assets/images/pixivision-white-logo.png',
                fit: BoxFit.fitHeight,
                height: 40,
              )
            : Image.asset(
                'assets/images/pixivision-black-logo.png',
                fit: BoxFit.fitHeight,
                height: 40,
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: () {
              controller.animateTo(0,
                  duration: Duration(seconds: 1), curve: Curves.ease);
            },
          )
        ],
      ),
      body: EasyRefresh(
        onLoad: () => spotlightStore.next(),
        onRefresh: () => spotlightStore.fetch(),
        header: DefaultHeaderFooter.header(context),
        refreshOnStart: true,
        controller: refreshController,
        child: WaterfallFlow.builder(
          gridDelegate: _buildGridDelegate(context),
          controller: controller,
          itemBuilder: (BuildContext context, int index) {
            return SpotlightCard(spotlight: spotlightStore.articles[index]);
          },
          itemCount: spotlightStore.articles.length,
        ),
      ),
    );
  }

  SliverWaterfallFlowDelegate _buildGridDelegate(BuildContext context) {
    var count = 2;
    // if (userSetting.crossAdapt) {
    //   count = _buildSliderValue(context);
    // } else {
    count =
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 4;
    // ? userSetting.crossCount
    // : userSetting.hCrossCount;
    // }
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  // int _buildSliderValue(BuildContext context) {
  //   final currentValue =
  //       (MediaQuery.of(context).orientation == Orientation.portrait
  //               ? userSetting.crossAdapterWidth
  //               : userSetting.hCrossAdapterWidth)
  //           .toDouble();
  //   var nowAdaptWidth = max(currentValue, 50.0);
  //   nowAdaptWidth = min(nowAdaptWidth, 2160.0);
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final result = max(screenWidth / nowAdaptWidth, 1.0).toInt();
  //   return result;
  // }
}

class SpotlightStoreBase {
  List<SpotlightArticle> articles = [];
  String? nextUrl;
  final EasyRefreshController? _controller;

  SpotlightStoreBase(this._controller);

  bool _lock = false;

  Future<bool> fetch() async {
    if (_lock) return false;
    _lock = true;
    nextUrl = null;
    try {
      SpotlightResponse response = await getSpotlightArticles("all");
      if (response.nextUrl != null && response.nextUrl == "error") {
        _controller?.finishRefresh(IndicatorResult.fail);
        return false;
      }
      articles.clear();
      articles.addAll(response.spotlightArticles);
      nextUrl = response.nextUrl;
      BotToast.showText(text: articles.first.title);
      _controller?.finishRefresh(IndicatorResult.success);
      return true;
    } catch (e) {
      _controller?.finishRefresh(IndicatorResult.fail);
      return false;
    } finally {
      _lock = false;
    }
  }

  Future<bool> next() async {
    if (_lock) return false;
    _lock = true;
    try {
      if (nextUrl != null && nextUrl!.isNotEmpty) {
        try {
          SpotlightResponse response = await getNextSpotlightArticles(nextUrl!);
          if (response.nextUrl != null && response.nextUrl == "error") {
            _controller?.finishRefresh(IndicatorResult.fail);
            return false;
          }
          nextUrl = response.nextUrl;
          articles.addAll(response.spotlightArticles);
          _controller?.finishLoad(nextUrl == null
              ? IndicatorResult.noMore
              : IndicatorResult.success);
          return true;
        } catch (e) {
          _controller?.finishLoad(IndicatorResult.fail);
          return false;
        }
      } else {
        _controller?.finishLoad(IndicatorResult.noMore);
        return true;
      }
    } finally {
      _lock = false;
    }
  }
}
