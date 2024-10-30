import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagetab.dart';
import 'package:skana_pix/componentwidgets/usersearch.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';

import '../componentwidgets/novelresult.dart';
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

  int getInitialIndex() => (settings.awPrefer == "novel")? 1 : 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = getInitialIndex();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      SearchRecommendPage(ArtworkType.ILLUST),
      SearchRecommendPage(ArtworkType.NOVEL),
      SearchRecommmendUserPage(),
    ];
    return Material(
      child: DefaultTabController(
        initialIndex: getInitialIndex(),
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
  ObservableList<String> tagHistory = ObservableList();

  @override
  void initState() {
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    tagHistory.addAll(settings.getHistoryTag(null).reversed);
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      body: EasyRefresh(
        header: DefaultHeaderFooter.header(context),
        controller: _refreshController,
        onRefresh: () => reset(),
        onLoad: () => nextPage(),
        refreshOnStart: users.isEmpty,
        child: _buildList(context),
      ),
    );
  }

  bool _tagExpand = false;

  Widget _buildList(BuildContext context) {
    return Observer(builder: (context) {
      return CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagHistory.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "History".i18n,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .color),
                      ),
                    ],
                  ),
                );
              } else
                return Container();
            }),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Observer(
                builder: (BuildContext context) {
                  if (tagHistory.isNotEmpty) {
                    if (tagHistory.length > 20) {
                      final resultTags = tagHistory.sublist(0, 12);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Wrap(
                          runSpacing: 0.0,
                          spacing: 5.0,
                          children: [
                            for (var f in _tagExpand ? tagHistory : resultTags)
                              buildActionChip(f, context),
                            ActionChip(
                                label: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) {
                                    return ScaleTransition(
                                        child: child, scale: anim);
                                  },
                                  child: Icon(!_tagExpand
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _tagExpand = !_tagExpand;
                                  });
                                })
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Wrap(
                        runSpacing: 0.0,
                        spacing: 3.0,
                        children: [
                          for (var f in tagHistory) buildActionChip(f, context),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagHistory.isNotEmpty) {
                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Clean history?".i18n),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel".i18n)),
                              TextButton(
                                  onPressed: () {
                                    settings.clearHistoryTag(null);
                                    reset();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Ok".i18n)),
                            ],
                          );
                        });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18.0,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text(
                            "Clear search history".i18n,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Container();
            }),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Recommended Users".i18n,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textTheme.titleLarge!.color),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return PainterCard(user: users[index]);
          }, childCount: users.length)),
        ],
      );
    });
  }

  Widget buildActionChip(String f, BuildContext context) {
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('${"Delete".i18n}?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        settings.deleteHistoryTag(null, f);
                        reset();
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok".i18n)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel".i18n)),
                ],
              );
            });
      },
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => UserResultPage(
                  word: f,
                )));
      },
      child: Chip(
        padding: EdgeInsets.all(0.0),
        label: Text(
          f,
          style: TextStyle(fontSize: 12.0),
        ),
      ),
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
      users.clear();
      tagHistory.clear();
      tagHistory.addAll(settings.getHistoryTag(null).reversed);
    });
    firstLoad();
    return true;
  }

  firstLoad() {
    if (isLoading) return;
    isLoading = true;
    nextUrl = null;
    loadData().then((value) {
      isLoading = false;
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

class SearchRecommendPage extends StatefulWidget {
  final ArtworkType type;

  const SearchRecommendPage(this.type);

  @override
  _SearchRecommendPageState createState() => _SearchRecommendPageState();
}

class _SearchRecommendPageState extends State<SearchRecommendPage> {
  ObservableList<TrendingTag> tags = ObservableList();
  ObservableList<String> tagHistory = ObservableList();
  late EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    tagHistory.addAll(settings.getHistoryTag(widget.type).reversed);
    _refresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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

  bool _tagExpand = false;

  Widget _buildContent(BuildContext context, BoxConstraints snapshot) {
    final rowCount = max(3, (snapshot.maxWidth / 200).floor());
    return EasyRefresh(
      onRefresh: () => _refresh(),
      header: DefaultHeaderFooter.header(context),
      controller: _refreshController,
      refreshOnStart: tags.isEmpty,
      child: CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagHistory.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "History".i18n,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .color),
                      ),
                    ],
                  ),
                );
              } else
                return Container();
            }),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Observer(
                builder: (BuildContext context) {
                  if (tagHistory.isNotEmpty) {
                    if (tagHistory.length > 20) {
                      final resultTags = tagHistory.sublist(0, 12);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Wrap(
                          runSpacing: 0.0,
                          spacing: 5.0,
                          children: [
                            for (var f in _tagExpand ? tagHistory : resultTags)
                              buildActionChip(f, context),
                            ActionChip(
                                label: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) {
                                    return ScaleTransition(
                                        child: child, scale: anim);
                                  },
                                  child: Icon(!_tagExpand
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _tagExpand = !_tagExpand;
                                  });
                                })
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Wrap(
                        runSpacing: 0.0,
                        spacing: 3.0,
                        children: [
                          for (var f in tagHistory) buildActionChip(f, context),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagHistory.isNotEmpty) {
                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Clean history?".i18n),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel".i18n)),
                              TextButton(
                                  onPressed: () {
                                    settings.clearHistoryTag(widget.type);
                                    _refresh();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Ok".i18n)),
                            ],
                          );
                        });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18.0,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text(
                            "Clear search history".i18n,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Container();
            }),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Recommended Tags".i18n,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textTheme.titleLarge!.color),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(builder: (_) {
                        if (widget.type == ArtworkType.NOVEL) {
                          return NovelResultPage(
                            word: tags[index].tag.name,
                          );
                        }
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

  Widget buildActionChip(String f, BuildContext context) {
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('${"Delete".i18n}?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        settings.deleteHistoryTag(widget.type, f);
                        _refresh();
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok".i18n)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel".i18n)),
                ],
              );
            });
      },
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => (widget.type == ArtworkType.NOVEL) ?NovelResultPage(
                  word: f,
                ):ResultPage(word: f)));
      },
      child: Chip(
        padding: EdgeInsets.all(0.0),
        label: Text(
          f,
          style: TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  _refresh() {
    setState(() {
      tagHistory.clear();
      tagHistory.addAll(settings.getHistoryTag(widget.type).reversed);
    });
    return loadData().then((value) {
      if (value.success) {
        setState(() {
          tags.clear();
          tags.addAll(value.data);
        });
        _refreshController.finishRefresh();
      } else {
        BotToast.showText(text: "Network error".i18n);
        _refreshController.finishRefresh(IndicatorResult.fail);
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
