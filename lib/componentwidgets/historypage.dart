import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/imagetab.dart';
import 'package:skana_pix/componentwidgets/novelpage.dart';
import 'package:skana_pix/componentwidgets/pixivimage.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Illust•Manga".i18n),
            Tab(text: "Novel".i18n),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IllustsHistory(),
          NovelsHistory(),
        ],
      ),
    );
  }
}

class IllustsHistory extends StatefulWidget {
  @override
  _IllustsHistoryState createState() => _IllustsHistoryState();
}

class _IllustsHistoryState extends State<IllustsHistory> {
  ObservableList<IllustHistory> illusts = ObservableList();
  ObservableList<IllustHistory> filteredIllusts = ObservableList();
  bool isLoading = false;
  EasyRefreshController refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    load();
  }

  void load() async {
    isLoading = true;
    var his = await historyManager.getIllusts();
    setState(() {
      illusts.clear();
      illusts.addAll(his);
      filteredIllusts.clear();
      filteredIllusts.addAll(his);
    });
    isLoading = false;
    refreshController.finishRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return EasyRefresh(
            controller: refreshController,
            onRefresh: load,
            header: DefaultHeaderFooter.header(context),
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.delete),
                onPressed: () {
                  _cleanAll(context);
                },
              ),
              body: Column(
                children: [
                  buildSearchbar(context).paddingHorizontal(8),
                  Expanded(
                    child: buildBody(filteredIllusts, context),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Future<void> _cleanAll(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${"Delete".i18n} ${"All".i18n}?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".i18n),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Ok".i18n),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    if (result == "OK") {
      historyManager.clearIllusts();
      setState(() {
        illusts.clear();
        filteredIllusts.clear();
      });
    }
  }

  Widget buildSearchbar(BuildContext context) {
    return AnimatedSearchBar(
      label: "Search Illusts or Authors".i18n,
      searchDecoration: InputDecoration(
          labelText: 'Search'.i18n,
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)))),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      searchStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      onChanged: (value) {
        _filterLogListBySearchText(value);
      },
    );
  }

  void _filterLogListBySearchText(String searchText) {
    setState(() {
      var tmp = illusts
          .where((obj) =>
              obj.title!.toLowerCase().contains(searchText.toLowerCase()) ||
              obj.userName!.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
      filteredIllusts.clear();
      filteredIllusts.addAll(tmp);
    });
  }

  Widget buildBody(List<IllustHistory> data, BuildContext context) {
    final reIllust = data.reversed.toList();
    if (reIllust.isNotEmpty) {
      return LayoutBuilder(builder: (context, snapshot) {
        final rowCount = max(2, (snapshot.maxWidth / 200).floor());
        return GridView.builder(
            itemCount: reIllust.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowCount),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return IllustPageLite(
                          reIllust[index].illustId.toString());
                    }));
                  },
                  onLongPress: () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("${"Delete".i18n}?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel".i18n),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Ok".i18n),
                                onPressed: () {
                                  Navigator.of(context).pop("OK");
                                },
                              ),
                            ],
                          );
                        });
                    if (result == "OK") {
                      historyManager.removeIllust(reIllust[index].illustId);
                      setState(() {
                        illusts.removeWhere((element) =>
                            element.illustId == reIllust[index].illustId);
                        filteredIllusts.removeWhere((element) =>
                            element.illustId == reIllust[index].illustId);
                      });
                    }
                  },
                  child: Card(
                      margin: EdgeInsets.all(8),
                      child: PixivImage(reIllust[index].pictureUrl)));
            });
      });
    }
    return Center(
      child: Container(),
    );
  }
}

class NovelsHistory extends StatefulWidget {
  @override
  _NovelsHistoryState createState() => _NovelsHistoryState();
}

class _NovelsHistoryState extends State<NovelsHistory> {
  ObservableList<NovelHistory> novels = ObservableList();
  ObservableList<NovelHistory> filteredNovels = ObservableList();
  bool isLoading = false;
  EasyRefreshController refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    load();
  }

  void load() async {
    isLoading = true;
    var his = await historyManager.getNovels();
    setState(() {
      novels.clear();
      novels.addAll(his);
      filteredNovels.clear();
      filteredNovels.addAll(his);
    });
    isLoading = false;
    refreshController.finishRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return EasyRefresh(
            controller: refreshController,
            onRefresh: load,
            header: DefaultHeaderFooter.header(context),
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.delete),
                onPressed: () {
                  _cleanAll(context);
                },
              ),
              body: Column(
                children: [
                  buildSearchbar(context).paddingHorizontal(8),
                  Expanded(
                    child: buildBody(filteredNovels, context),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Future<void> _cleanAll(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${"Delete".i18n} ${"All".i18n}?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".i18n),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Ok".i18n),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    if (result == "OK") {
      historyManager.clearIllusts();
      setState(() {
        novels.clear();
        filteredNovels.clear();
      });
    }
  }

  Widget buildSearchbar(BuildContext context) {
    return AnimatedSearchBar(
      label: "Search Novels or Authors".i18n,
      searchDecoration: InputDecoration(
          labelText: 'Search'.i18n,
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)))),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      searchStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      onChanged: (value) {
        _filterLogListBySearchText(value);
      },
    );
  }

  void _filterLogListBySearchText(String searchText) {
    setState(() {
      var tmp = novels
          .where((obj) =>
              obj.title!.toLowerCase().contains(searchText.toLowerCase()) ||
              obj.userName!.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
      filteredNovels.clear();
      filteredNovels.addAll(tmp);
    });
  }

  Widget buildBody(List<NovelHistory> data, BuildContext context) {
    final reNovel = data.reversed.toList();
    if (reNovel.isNotEmpty) {
      return LayoutBuilder(builder: (context, snapshot) {
        final rowCount = max(2, (snapshot.maxWidth / 200).floor());
        return GridView.builder(
            itemCount: reNovel.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowCount),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return NovelPageLite(
                          reNovel[index].novelId.toString());
                    }));
                  },
                  onLongPress: () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("${"Delete".i18n}?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel".i18n),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Ok".i18n),
                                onPressed: () {
                                  Navigator.of(context).pop("OK");
                                },
                              ),
                            ],
                          );
                        });
                    if (result == "OK") {
                      historyManager.removeIllust(reNovel[index].novelId);
                      setState(() {
                        novels.removeWhere((element) =>
                            element.novelId == reNovel[index].novelId);
                        filteredNovels.removeWhere((element) =>
                            element.novelId == reNovel[index].novelId);
                      });
                    }
                  },
                  child: Card(
                      margin: EdgeInsets.all(8),
                      child: PixivImage(reNovel[index].pictureUrl)));
            });
      });
    }
    return Center(
      child: Container(),
    );
  }
}
