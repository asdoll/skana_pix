import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/avatar.dart';
import 'package:skana_pix/componentwidgets/novelcard.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../componentwidgets/headerfooter.dart';
import '../componentwidgets/loading.dart';
import '../componentwidgets/novelbookmark.dart';
import '../componentwidgets/novelpage.dart';
import '../componentwidgets/pixivimage.dart';
import '../componentwidgets/rankingpage.dart';
import '../utils/filters.dart';
import 'defaults.dart';

class RecomNovelsPage extends StatefulWidget {
  RecomNovelsPage({super.key});
  @override
  _RecomNovelsPageState createState() => _RecomNovelsPageState();
}

class _RecomNovelsPageState
    extends MultiPageLoadingState<RecomNovelsPage, Novel> {
  late EasyRefreshController _easyRefreshController;
  ObservableList<Novel> novels = ObservableList();
  ObservableList<Novel> tops = ObservableList();

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    super.initState();
    parseTops();
  }

  @override
  Widget buildContent(BuildContext context, List<Novel> data) {
    checkNovels(data);
    return EasyRefresh.builder(
      controller: _easyRefreshController,
      callRefreshOverOffset: 10,
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
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Center(
                      child: Text(
                        "Recommend".i18n,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 24.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSliverList(context, data),
          ],
        ),
      ),
    );
  }

  SliverList _buildSliverList(BuildContext context, List<Novel> data) {
    novels.addAll(data);
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      Novel novel = novels[index];
      return NovelCard(novel);
    }, childCount: novels.length));
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return RankingPage(2);
                }));
              },
            ),
          )
        ],
      ),
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
                  child: _buildRankingCard(
                      context, tops[index], expectCardWidget, expectCardHeight),
                );
              },
              itemCount: tops.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
    );
  }

  Widget _buildRankingCard(BuildContext context, Novel novel,
      double expectwidth, double expectHeight) {
    List<Tag> tags = novel.tags;
    if (tags.length > 5) {
      tags = tags.sublist(0, 5);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Hero(
          tag: "novel_cover_image_${novel.image.hashCode}",
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return NovelViewerPage(novel);
                    }));
                  },
                  child: Container(
                    width: expectwidth,
                    height: expectHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.colorBurn),
                          fit: BoxFit.cover,
                          image: PixivProvider.url(novel.coverImageUrl)),
                    ),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    "${novel.totalViews} ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.sticky_note_2_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              Text(
                                "${novel.length} ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${novel.title}",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ).paddingHorizontal(8),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    alignment: WrapAlignment.center,
                                    spacing: 2, // gap between adjacent chips
                                    runSpacing: 0,
                                    children: [
                                      for (var f in tags)
                                        Text(
                                          "#${f.name} ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      if (tags.length != novel.tags.length)
                                        Text(
                                          "...",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                    ],
                                  ).paddingHorizontal(8),
                                ]),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      PainterAvatar(
                                        url: novel.author.avatar,
                                        id: novel.author.id,
                                        size: Size(16, 16),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 6.0),
                                        child: Text(
                                          novel.author.name.atMost8,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ]),
                                NovelBookmarkButton(novel: novel),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))),
        ),
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
    novels.clear();
    super.reset();
    if (parseTops() && errors == null) {
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

  Future<Res<List<Novel>>> loadTops() {
    return getNovelRanking("day");
  }

  @override
  Future<Res<List<Novel>>> loadData(int page) {
    if (nexturl == null) {
      return getRecommendedNovels();
    } else {
      return getNovelsWithNextUrl(nexturl);
    }
  }
}
