import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'imagetab.dart';
import 'novelcard.dart';

class WorksPage extends StatefulWidget {
  final int id;
  final String portal;
  final ArtworkType type;

  const WorksPage(
      {Key? key, required this.id, required this.portal, required this.type})
      : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> with TickerProviderStateMixin {
  late TabController _tabController;

  int get initialIndex {
    switch (widget.type) {
      case ArtworkType.ILLUST:
        return 0;
      case ArtworkType.MANGA:
        return 1;
      case ArtworkType.NOVEL:
        return 2;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: initialIndex, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar.secondary(controller: _tabController, tabs: [
          Tab(text: "Illust".tr),
          Tab(text: "Manga".tr),
          Tab(text: "Novel".tr),
        ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              WorkContent(
                id: widget.id,
                portal: widget.portal,
                type: ArtworkType.ILLUST,
              ),
              WorkContent(
                id: widget.id,
                portal: widget.portal,
                type: ArtworkType.MANGA,
              ),
              WorkContent(
                id: widget.id,
                portal: widget.portal,
                type: ArtworkType.NOVEL,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SliverPinnedOverlapInjector extends SingleChildRenderObjectWidget {
  const SliverPinnedOverlapInjector({
    required this.handle,
    Key? key,
  }) : super(key: key);

  final SliverOverlapAbsorberHandle handle;

  @override
  RenderSliverPinnedOverlapInjector createRenderObject(BuildContext context) {
    return RenderSliverPinnedOverlapInjector(
      handle: handle,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPinnedOverlapInjector renderObject,
  ) {
    renderObject.handle = handle;
  }
}

class RenderSliverPinnedOverlapInjector extends RenderSliver {
  RenderSliverPinnedOverlapInjector({
    required SliverOverlapAbsorberHandle handle,
  }) : _handle = handle;

  double? _currentLayoutExtent;
  double? _currentMaxExtent;

  SliverOverlapAbsorberHandle get handle => _handle;
  SliverOverlapAbsorberHandle _handle;

  set handle(SliverOverlapAbsorberHandle value) {
    if (handle == value) return;
    if (attached) {
      handle.removeListener(markNeedsLayout);
    }
    _handle = value;
    if (attached) {
      handle.addListener(markNeedsLayout);
      if (handle.layoutExtent != _currentLayoutExtent ||
          handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    handle.addListener(markNeedsLayout);
    if (handle.layoutExtent != _currentLayoutExtent ||
        handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
  }

  @override
  void detach() {
    handle.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    _currentLayoutExtent = handle.layoutExtent;

    final paintedExtent = min(
      _currentLayoutExtent!,
      constraints.remainingPaintExtent - constraints.overlap,
    );

    geometry = SliverGeometry(
      paintExtent: paintedExtent,
      maxPaintExtent: _currentLayoutExtent!,
      maxScrollObstructionExtent: _currentLayoutExtent!,
      paintOrigin: constraints.overlap,
      scrollExtent: _currentLayoutExtent!,
      layoutExtent: max(0, paintedExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedExtent < _currentLayoutExtent!,
    );
  }
}

class SliverChipDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  double height = 45;

  SliverChipDelegate(this.child, {this.height = 45});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(SliverChipDelegate oldDelegate) {
    return false;
  }
}

class WorkContent extends StatefulWidget {
  final int id;
  final String portal;
  final ArtworkType type;

  const WorkContent(
      {Key? key, required this.id, required this.portal, required this.type})
      : super(key: key);

  @override
  _WorkContentState createState() => _WorkContentState();
}

class _WorkContentState extends State<WorkContent> {
  late EasyRefreshController _easyRefreshController;

  bool isError = false;
  ObservableList<Illust> illusts = ObservableList();
  ObservableList<Illust> manga = ObservableList();
  ObservableList<Novel> novels = ObservableList();
  get data {
    switch (widget.type) {
      case ArtworkType.ILLUST:
        return illusts;
      case ArtworkType.MANGA:
        return manga;
      case ArtworkType.NOVEL:
        return novels;
      default:
        return illusts;
    }
  }

  bool get loadError => isError && data.isEmpty;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    firstLoad();
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        warnWhenNoObservables: false,
        builder: (_) {
          return _buildContent(context);
        });
  }

  Widget _buildContent(context) {
    return loadError ? _buildErrorContent(context) : _buildWorks(context);
  }

  Widget _buildErrorContent(context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(':(', style: Theme.of(context).textTheme.headlineMedium),
          ),
          TextButton(
              onPressed: () {
                reset();
              },
              child: Text("Retry".tr)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                ("Failed to load".tr),
              ))
        ],
      ),
    );
  }

  Widget _buildWorks(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (BuildContext context) {
            return EasyRefresh.builder(
                controller: _easyRefreshController,
                onLoad: () {
                  nextPage();
                },
                onRefresh: () {
                  reset();
                },
                header: DefaultHeaderFooter.header(
                  context,
                  position: IndicatorPosition.locator,
                  safeArea: false,
                ),
                footer: DefaultHeaderFooter.footer(
                  context,
                  position: IndicatorPosition.locator,
                ),
                childBuilder: (context, phy) {
                  return Observer(builder: (_) {
                    return CustomScrollView(
                      physics: phy,
                      key: PageStorageKey<String>(
                          "${widget.portal}_${widget.type}"),
                      slivers: [
                        if (isLoading)
                          SliverToBoxAdapter(
                            child: Container(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        SliverWaterfallFlow(
                          gridDelegate: _buildGridDelegate(),
                          delegate: _buildSliverChildBuilderDelegate(context),
                        ),
                        const FooterLocator.sliver(),
                      ],
                    );
                  });
                });
          },
        ));
  }

  SliverWaterfallFlowDelegate _buildGridDelegate() {
    var count =
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 4;
    if (widget.type == ArtworkType.NOVEL) {
      count = 1;
    }
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      BuildContext context) {
    if (widget.type == ArtworkType.NOVEL) {
      return SliverChildBuilderDelegate((BuildContext context, int index) {
        return NovelCard(novels[index]);
      }, childCount: novels.length);
    }
    if (widget.type == ArtworkType.MANGA) {
      return SliverChildBuilderDelegate((BuildContext context, int index) {
        return IllustCard(
          manga,
          false,
          index: index,
        );
      }, childCount: manga.length);
    }
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      return IllustCard(
        illusts,
        false,
        index: index,
      );
    }, childCount: illusts.length);
  }

  bool isLoading = false;

  reset() {
    illusts.clear();
    manga.clear();
    novels.clear();
    nextUrl = null;
    isError = false;
    firstLoad();
  }

  firstLoad() {
    isError = false;
    if (isLoading) {
      _easyRefreshController.finishRefresh();
      return;
    }
    isLoading = true;
    if (widget.type == ArtworkType.ILLUST) {
      loadIllust().then((value) {
        if (value.success) {
          setState(() {
            illusts.clear();
            illusts.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    if (widget.type == ArtworkType.MANGA) {
      loadManga().then((value) {
        if (value.success) {
          setState(() {
            manga.clear();
            manga.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    if (widget.type == ArtworkType.NOVEL) {
      loadNovel().then((value) {
        if (value.success) {
          setState(() {
            novels.clear();
            novels.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    isLoading = false;
    if (isError) {
      _easyRefreshController.finishRefresh(IndicatorResult.fail);
    } else {
      _easyRefreshController.finishRefresh();
    }
  }

  nextPage() {
    if (isLoading) {
      _easyRefreshController.finishLoad();
      return;
    }
    if (nextUrl == "end") {
      _easyRefreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    isError = false;
    isLoading = true;
    if (widget.type == ArtworkType.ILLUST) {
      loadIllust().then((value) {
        if (value.success) {
          setState(() {
            illusts.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    if (widget.type == ArtworkType.MANGA) {
      loadManga().then((value) {
        if (value.success) {
          setState(() {
            manga.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    if (widget.type == ArtworkType.NOVEL) {
      loadNovel().then((value) {
        if (value.success) {
          setState(() {
            novels.addAll(value.data);
            nextUrl = value.subData;
            nextUrl ??= "end";
          });
        } else {
          isError = true;
        }
      });
    }
    isLoading = false;
    if (isError) {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    } else {
      _easyRefreshController.finishLoad();
    }
  }

  String? nextUrl;

  Future<Res<List<Illust>>> loadIllust() async {
    return ConnectManager()
        .apiClient
        .getUserIllusts(widget.id.toString(), "illust", nextUrl);
  }

  Future<Res<List<Illust>>> loadManga() async {
    return ConnectManager()
        .apiClient
        .getUserIllusts(widget.id.toString(), "manga", nextUrl);
  }

  Future<Res<List<Novel>>> loadNovel() async {
    return ConnectManager()
        .apiClient
        .getUserNovels(widget.id.toString(), nextUrl);
  }
}
