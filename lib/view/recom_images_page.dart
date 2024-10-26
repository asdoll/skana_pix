import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/spotlightpage.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../componentwidgets/imagetab.dart';
import '../componentwidgets/loading.dart';
import '../componentwidgets/pixivimage.dart';
import '../componentwidgets/rankingpage.dart';
import '../componentwidgets/souppage.dart';
import '../utils/filters.dart';

class RecomImagesPage extends StatefulWidget {
  final ArtworkType type;

  RecomImagesPage(this.type, {super.key});
  @override
  _RecomImagesPageState createState() => _RecomImagesPageState();
}

class _RecomImagesPageState
    extends MultiPageLoadingState<RecomImagesPage, Illust> {
  List<SpotlightArticle> spotlights = [];
  ObservableList<Illust> illusts = ObservableList();
  ObservableList<Illust> tops = ObservableList();
  late EasyRefreshController _easyRefreshController;

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    super.initState();
    parseTops();
    parseSpotlightArticles();
  }

  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    checkIllusts(data);
    return EasyRefresh.builder(
      controller: _easyRefreshController,
      callLoadOverOffset: DynamicData.isIOS ? 2 : 5,
      header: DefaultHeaderFooter.header(context),
      footer: DefaultHeaderFooter.footer(context),
      onRefresh: () {
        _onRefresh();
      },
      onLoad: () {
        nextPage();
      },
      childBuilder: (context, physics) => Observer(
        builder: (context) => CustomScrollView(
          controller: DynamicData.recommendScrollController,
          physics: physics,
          slivers: [
            SliverToBoxAdapter(
              child: Container(height: MediaQuery.of(context).padding.top),
            ),
            SliverToBoxAdapter(
              child: _buildFirstRow(context),
            ),
            SliverToBoxAdapter(
              child: _buidRankingRow(context),
            ),
            if (widget.type == ArtworkType.ILLUST)
              SliverToBoxAdapter(
                child: _buildPixivisionRow(context),
              ),
            if (widget.type == ArtworkType.ILLUST)
              SliverToBoxAdapter(
                child: _buidTagSpotlightRow(context),
              ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    child: Center(
                      child: Text(
                        "Recommend".i18n,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 24.0),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 20.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            _buildWaterfall(context, MediaQuery.of(context).orientation, data)
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfall(
      BuildContext context, Orientation orientation, List<Illust> data) {
    illusts.addAll(data);
    var count = (orientation == Orientation.portrait) ? 2 : 4;
    return SliverWaterfallFlow(
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return IllustCard(illusts, false,
            initialPage: index, type: widget.type);
      }, childCount: illusts.length),
    );
  }

  Widget _buidTagSpotlightRow(BuildContext context) {
    var expectCardWidget = MediaQuery.of(context).size.width * 0.7;
    expectCardWidget = expectCardWidget > 244 ? 244 : expectCardWidget;
    final expectCardHeight = expectCardWidget * 0.525;
    return Container(
      height: expectCardHeight,
      padding: EdgeInsets.only(left: 0.0),
      child: spotlights.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                final spotlight = spotlights[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Hero(
                    tag: "spotlight_image_${spotlight.hashCode}",
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(
                                  builder: (BuildContext context) => SoupPage(
                                        url: spotlight.articleUrl,
                                        spotlight: spotlight,
                                        heroTag:
                                            'spotlight_image_${spotlight.hashCode}',
                                      )));
                        },
                        child: Container(
                            width: expectCardWidget,
                            height: expectCardHeight,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: PixivProvider.url(
                                        spotlight.thumbnail))),
                            child: Container(
                                child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.5),
                                  ],
                                )),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${spotlight.title}",
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            // shadows: [
                                            //   Shadow(
                                            //       color: Colors.black,
                                            //       offset: Offset(0.5, 0.5),
                                            //       blurRadius: 1.0)
                                            // ]
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))),
                      ),
                    ),
                  ),
                );
              },
              itemCount: spotlights.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
    );
  }

  Widget _buidRankingRow(BuildContext context) {
    var expectCardWidget = MediaQuery.of(context).size.width * 0.6;
    expectCardWidget = expectCardWidget > 244 ? 244 : expectCardWidget;
    final expectCardHeight = expectCardWidget + 40;
    return Container(
      height: expectCardHeight,
      padding: EdgeInsets.only(left: 0.0),
      child: tops.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                return SizedBox(
                  width: expectCardWidget,
                  height: expectCardHeight,
                  child: IllustCard(
                    tops,
                    false,
                    initialPage: index,
                    type: widget.type,
                    useSquare: true,
                  ),
                );
              },
              itemCount: tops.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
    );
  }

  Widget _buildPixivisionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: DynamicData.isDarkMode
                  ? Image.asset(
                      'assets/images/pixivision-white-logo.png',
                      fit: BoxFit.fitHeight,
                      height: 25,
                    )
                  : Image.asset(
                      'assets/images/pixivision-black-logo.png',
                      fit: BoxFit.fitHeight,
                      height: 25,
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.0),
            child: TextButton(
              child: Text(
                "More".i18n,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SpotlightPage(widget.type)));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFirstRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "Ranking".i18n,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.0),
            child: TextButton(
              child: Text(
                "More".i18n,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return RankingPage(widget.type);
                }));
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  nextPage() {
    super.nextPage();
    if (errors == null) {
      _easyRefreshController.finishLoad();
    } else {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> _onRefresh() async {
    reset();
  }

  @override
  void reset() {
    tops.clear();
    spotlights.clear();
    illusts.clear();
    super.reset();
    if (parseTops() && parseSpotlightArticles() && errors == null) {
      _easyRefreshController.finishRefresh();
    } else {
      _easyRefreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  parseTops() {
    loadTops().then((value) {
      if (value.success) {
        setState(() {
          tops.addAll(value.data);
        });
      } else {
        BotToast.showText(text: "Failed to load Ranking".i18n);
        return false;
      }
    });
    return true;
  }

  Future<Res<List<Illust>>> loadTops() {
    return widget.type == ArtworkType.ILLUST
        ? getRanking("day")
        : getRanking("day_manga");
  }

  parseSpotlightArticles() {
    if (widget.type == ArtworkType.MANGA) {
      return true;
    }
    loadSpotlightArticles().then((value) {
      if (value.nextUrl != null && value.nextUrl == "error") {
        BotToast.showText(text: "Failed to load Pixivision articles".i18n);
        return false;
      }
      setState(() {
        spotlights.addAll(value.spotlightArticles);
      });
    });
    return true;
  }

  Future<SpotlightResponse> loadSpotlightArticles() {
    return getSpotlightArticles("all");
  }

  @override
  Future<Res<List<Illust>>> loadData(page) {
    if (nexturl != null) {
      return widget.type == ArtworkType.ILLUST
          ? getIllustsWithNextUrl(nexturl)
          : getIllustsWithNextUrl(nexturl);
    }
    return widget.type == ArtworkType.ILLUST
        ? getRecommendedIllusts()
        : getRecommendedMangas();
  }
}
