import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/imagetab.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../componentwidgets/pixivimage.dart';
import '../componentwidgets/searchbar.dart';
import '../componentwidgets/searchresult.dart';
import '../componentwidgets/usercard.dart';
import '../model/worktypes.dart';
import 'defaults.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      SreachRecommendPage(ArtworkType.ILLUST),
      SreachRecommendPage(ArtworkType.MANGA),
      SearchRecommmendUserPage(),
    ];
    return MaterialApp(
      theme: DynamicData.themeData,
      darkTheme: DynamicData.darkTheme,
      themeMode: ThemeMode.system,
      home: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(100), // here the desired height
            child: AppBar(
              automaticallyImplyLeading: false,
              title: SearchBar1(getAwType(_selectedIndex)),
              bottom: TabBar(
                onTap: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                tabs: [
                  Container(
                    height: 30.0,
                    width: 80,
                    child: Tab(text: 'Illust•Manga'.i18n),
                  ),
                  Container(
                    height: 30.0,
                    width: 80,
                    // color: Colors.red,
                    child: Tab(text: 'Novel'.i18n),
                  ),
                  Container(
                    height: 30.0,
                    width: 80,
                    // color: Colors.red,
                    child: Tab(text: 'User'.i18n),
                  ),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
          body: TabBarView(
            children: tabs,
          ),
        ),
      ),
    );
  }

  ArtworkType getAwType(int index) {
    switch (index) {
      case 0:
        return ArtworkType.ILLUST;
      case 1:
        return ArtworkType.NOVEL;
      default:
        return ArtworkType.ALL;
    }
  }
}

class SearchRecommmendUserPage extends StatefulWidget {
  @override
  _SearchRecommmendUserPageState createState() =>
      _SearchRecommmendUserPageState();
}

class _SearchRecommmendUserPageState extends State<SearchRecommmendUserPage> {
  late EasyRefreshController _refreshController;
  ObservableList<UserPreview> users = ObservableList();
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
        ),
        body: EasyRefresh(
          controller: _refreshController,
          onRefresh: () => firstLoad(),
          onLoad: () => nextPage(),
          refreshOnStart: users.isEmpty,
          child: _buildList(),
        ),
      );
    });
  }

  Widget _buildList() {
    return WaterfallFlow.builder(
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final data = users[index];
        return PainterCard(
          user: data,
        );
      },
    );
  }

  String? nextUrl;

  Future<Res<List<UserPreview>>> loadData() async {
    if (nextUrl == "end") {
      _refreshController.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    Res<List<UserPreview>> res =
        await ConnectManager().apiClient.getRecommendationUsers(nextUrl);
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

  nextPage() {
    if (isLoading) return;
    isLoading = true;
    loadData().then((value) {
      isLoading = false;
      if (value.success) {
        setState(() {
          users.addAll(value.data);
        });
        _refreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".i18n;
        if (message == "No more data") {}
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        isError = true;
        BotToast.showText(text: message);
        _refreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  reset() {
    setState(() {
      nextUrl = null;
      isLoading = false;
    });
    firstLoad();
    return true;
  }

  firstLoad() {
    nextUrl = null;
    loadData().then((value) {
      if (value.success) {
        setState(() {
          users.clear();
          users.addAll(value.data);
        });
        _refreshController.finishRefresh();
        return true;
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            isError = true;
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
          }
        });
        _refreshController.finishRefresh(IndicatorResult.fail);
        return false;
      }
    });
    return false;
  }
}

class SreachRecommendPage extends StatefulWidget {
  final ArtworkType type;

  const SreachRecommendPage(this.type);

  @override
  _SreachRecommendPageState createState() => _SreachRecommendPageState();
}

class _SreachRecommendPageState extends State<SreachRecommendPage> {
  ObservableList<TrendingTag> tags = ObservableList();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, snapshot) {
      return Observer(builder: (_) {
        return NestedScrollView(
          body: _buildContent(context, snapshot),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(height: MediaQuery.of(context).padding.top),
              ),
            ];
          },
        );
      });
    });
  }

  Widget _buildContent(BuildContext context, BoxConstraints snapshot) {
    final rowCount = max(3, (snapshot.maxWidth / 200).floor());
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(builder: (_) {
                        return ResultPage(
                          word: tags[index].tag.name,
                        );
                      }));
                    },
                    onLongPress: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(builder: (_) {
                        return IllustPageLite(tags[index].illust.id.toString());
                      }));
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Stack(
                        children: <Widget>[
                          PixivImage(
                            tags[index].illust.images.first.squareMedium,
                            fit: BoxFit.cover,
                          ),
                          Opacity(
                            opacity: 0.4,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "#${tags[index].tag}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  if (tags[index].tag.translatedName != null &&
                                      tags[index]
                                          .tag
                                          .translatedName!
                                          .isNotEmpty)
                                    Text(
                                      tags[index].tag.translatedName!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: tags.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowCount)),
          ),
          if (DynamicData.isAndroid)
            SliverToBoxAdapter(
              child: Container(
                height: (MediaQuery.of(context).size.width / 3) - 16,
              ),
            )
        ],
      ),
    );
  }

  _refresh() {
    return loadData().then((value) {
      if (value.success) {
        tags.clear();
        tags.addAll(value.data);
      } else {
        BotToast.showText(text: "Network error".i18n);
      }
    });
  }

  Future<Res<List<TrendingTag>>> loadData() {
    if (widget.type == ArtworkType.ILLUST) {
      return getHotTags();
    } else {
      return getHotNovelTags();
    }
  }
}
