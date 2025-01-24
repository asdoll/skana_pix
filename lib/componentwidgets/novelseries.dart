import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';

import '../utils/leaders.dart';
import 'avatar.dart';
import 'novelbookmark.dart';
import 'novelpage.dart';
import 'pixivimage.dart';

class NovelSeriesPage extends StatefulWidget {
  final int seriesId;

  NovelSeriesPage(this.seriesId);

  @override
  _NovelSeriesPageState createState() => _NovelSeriesPageState();
}

class _NovelSeriesPageState extends State<NovelSeriesPage> {
  NovelSeriesDetail? novelSeriesDetail;
  ObservableList<Novel> novels = ObservableList();
  bool isLoading = false;
  bool isError = false;
  Novel? last;
  String? nextUrl;
  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    super.initState();
    easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    firstLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          if (novelSeriesDetail != null) ...[
            PainterAvatar(
              url: novelSeriesDetail!.user.avatar,
              id: novelSeriesDetail!.user.id,
              size: Size(30, 30),
              onTap: () {
                Leader.push(
                    context,
                    UserPage(
                      id: novelSeriesDetail!.user.id,
                      type: ArtworkType.NOVEL,
                    ),
                    root: true);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                novelSeriesDetail!.user.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            )
          ]
        ]),
        actions: [
          Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final pos = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  Share.share(
                      "https://www.pixiv.net/novel/series/${widget.seriesId}",
                      sharePositionOrigin: pos);
                },
                icon: Icon(Icons.share));
          })
        ],
      ),
      body: EasyRefresh(
        controller: easyRefreshController,
        onLoad: () async {
          nextPage();
        },
        onRefresh: () async {
          reset();
        },
        refreshOnStart: false,
        child: Builder(builder: (context) {
          if (novelSeriesDetail != null) {
            return Container(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                        ),
                        SelectionArea(
                          child: Text(
                            novelSeriesDetail!.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        SelectionArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              novelSeriesDetail!.caption ?? "",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (last != null)
                    SliverToBoxAdapter(
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                                onPressed: () {
                                  Leader.push(context, NovelViewerPage(last!));
                                },
                                child: Text("View the latest".tr)),
                          ),
                        ),
                        Divider()
                      ]),
                    ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    final novel = novels[index];
                    return _buildItem(context, novel, index);
                  }, childCount: novels.length))
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [],
          );
        }),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Novel novel, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => NovelViewerPage(novel)));
          },
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
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              "#${index + 1} ${novel.title}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
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
                    NovelBookmarkButton(
                      novel: novel,
                      colorMode: "",
                    ),
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

  void nextPage() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          novels.addAll(value.data.novels);
          last = value.data.last ?? last;
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".tr);
          }
        });
      }
    });
  }

  void reset() {
    novels.clear();
    last = null;
    novelSeriesDetail = null;
    nextUrl = null;

    firstLoad();
  }

  void firstLoad() {
    nextUrl = null;
    loadData().then((value) {
      if (value.success) {
        setState(() {
          novels.clear();
          last = null;
          novelSeriesDetail = null;
          novelSeriesDetail = value.data.novelSeriesDetail;
          novels.addAll(value.data.novels);
          last = value.data.last;
        });
        easyRefreshController.finishRefresh();
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".tr);
          }
        });
        easyRefreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  Future<Res<NovelSeriesResponse>> loadData() async {
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    Res<NovelSeriesResponse> res = await ConnectManager()
        .apiClient
        .getNovelSeries(widget.seriesId.toString(), nextUrl);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad();
    }
    return res;
  }
}
