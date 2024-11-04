import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/utils/translate.dart';

import '../model/worktypes.dart';
import '../pixiv_dart_api.dart';
import '../view/defaults.dart';
import 'headerfooter.dart';
import 'novelresult.dart';
import 'searchresult.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage> {
  ObservableList<String> tagIllust = ObservableList();
  ObservableList<String> tagNovel = ObservableList();
  late EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Book Tags'),
        ),
        body: _buildContent(context));
  }

  bool _tagExpand = false;
  bool _tagExpandNovel = false;

  Widget _buildContent(BuildContext context) {
    return EasyRefresh(
      onRefresh: () => _refresh(),
      header: DefaultHeaderFooter.header(context),
      controller: _refreshController,
      refreshOnStart: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverToBoxAdapter(
            child: Observer(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Illust•Manga".i18n,
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
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Observer(
                builder: (BuildContext context) {
                  if (tagIllust.isNotEmpty) {
                    if (tagIllust.length > 20) {
                      final resultTags = tagIllust.sublist(0, 12);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Wrap(
                          runSpacing: 0.0,
                          spacing: 5.0,
                          children: [
                            for (var f in _tagExpand ? tagIllust : resultTags)
                              buildActionChip(f, context, ArtworkType.ILLUST),
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
                          for (var f in tagIllust)
                            buildActionChip(f, context, ArtworkType.ILLUST),
                        ],
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(children: [
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No bookmarked tags".i18n),
                          ]),
                    ]),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagIllust.isNotEmpty) {
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
                                    settings.clearBookmarkedTags();
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
          if (DynamicData.isAndroid)
            SliverToBoxAdapter(
              child: Container(
                height: (MediaQuery.of(context).size.width / 3) - 16,
              ),
            ),
          SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          SliverToBoxAdapter(
            child: Observer(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Novel".i18n,
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
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Observer(
                builder: (BuildContext context) {
                  if (tagNovel.isNotEmpty) {
                    if (tagNovel.length > 20) {
                      final resultTags = tagNovel.sublist(0, 12);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Wrap(
                          runSpacing: 0.0,
                          spacing: 5.0,
                          children: [
                            for (var f
                                in _tagExpandNovel ? tagNovel : resultTags)
                              buildActionChip(f, context, ArtworkType.NOVEL),
                            ActionChip(
                                label: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) {
                                    return ScaleTransition(
                                        child: child, scale: anim);
                                  },
                                  child: Icon(!_tagExpandNovel
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _tagExpandNovel = !_tagExpandNovel;
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
                          for (var f in tagNovel)
                            buildActionChip(f, context, ArtworkType.NOVEL),
                        ],
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(children: [
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No bookmarked tags".i18n),
                          ]),
                    ]),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Observer(builder: (context) {
              if (tagNovel.isNotEmpty) {
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
                                    settings.clearBookmarkedNovelTags();
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

  void _refresh() {
    setState(() {
      tagIllust.clear();
      tagNovel.clear();
      tagIllust.addAll(settings.bookmarkedTags);
      tagNovel.addAll(settings.bookmarkedNovelTags);
    });
  }

  Widget buildActionChip(String f, BuildContext context, ArtworkType type) {
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
                        if (type == ArtworkType.ILLUST) {
                          settings.removeBookmarkedTags([f]);
                        } else {
                          settings.removeBookmarkedNovelTags([f]);
                        }
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
            builder: (context) => (type == ArtworkType.NOVEL)
                ? NovelResultPage(
                    word: f,
                  )
                : ResultPage(word: f)));
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
}
