import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/souppage.dart';
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
            _buildSliverList(context,data),
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
      return _buildItem(context, novel, index);
    }, childCount: novels.length));
  }

  Widget _buildItem(BuildContext context, Novel novel, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (BuildContext context) => NovelViewerPage(novels[index])));
        },
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PixivImage(
                        novel.coverImageUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ).rounded(8.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              novel.title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  novel.author.name,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.article,
                                        size: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .color,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '${novel.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2, // gap between adjacent chips
                              runSpacing: 0,
                              children: [
                                for (var f in novel.tags)
                                  Text(
                                    f.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  )
                              ],
                            ),
                          ),
                          Container(
                            height: 8.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NovelBookmarkButton(novel: novel),
                    Text('${novel.totalBookmarks}',
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              )
            ],
          ),
        ),
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
    var expectCardWidget = MediaQuery.of(context).size.width * 0.4;
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
                  child: Container(),
                );
              },
              itemCount: tops.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
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
  void reset(){
    tops.clear();
    novels.clear();
    super.reset();
    if(parseTops()&& errors == null){
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
