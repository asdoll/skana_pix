import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'imagecard.dart';
import 'novelcard.dart';

class MyBookmarksPage extends StatefulWidget {
  final String portal;
  final ArtworkType type;

  const MyBookmarksPage({super.key, required this.portal, required this.type});

  @override
  State<MyBookmarksPage> createState() => _MyBookmarksPageState();
}

class _MyBookmarksPageState extends State<MyBookmarksPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int get initialIndex {
    switch (widget.type) {
      case ArtworkType.ILLUST:
        return 0;
      case ArtworkType.NOVEL:
        return 1;
      default:
        return 0;
    }
  }

  final String id = ConnectManager().apiClient.userid;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, initialIndex: initialIndex, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookmarks".tr),
      ),
      body: Column(
        children: [
          TabBar.secondary(controller: _tabController, tabs: [
            Tab(text: "Artwork".tr),
            Tab(text: "Novel".tr),
          ]),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MyBookmarkContent(
                  id: id,
                  portal: widget.portal,
                  type: ArtworkType.ILLUST,
                ),
                MyBookmarkContent(
                  id: id,
                  portal: widget.portal,
                  type: ArtworkType.NOVEL,
                ),
              ],
            ),
          ),
        ],
      ),
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

class MyBookmarkContent extends StatefulWidget {
  final String id;
  final String portal;
  final ArtworkType type;

  const MyBookmarkContent(
      {Key? key, required this.id, required this.portal, required this.type})
      : super(key: key);

  @override
  State<MyBookmarkContent>  createState() => _MyBookmarkContentState();
}

class _MyBookmarkContentState extends State<MyBookmarkContent> {
  late EasyRefreshController _easyRefreshController;
  String restrict = 'public';

  bool isError = false;
  ObservableList<Illust> illusts = ObservableList();
  ObservableList<Novel> novels = ObservableList();
  get data {
    switch (widget.type) {
      case ArtworkType.ILLUST:
        return illusts;
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
    return Column(
      children: [
        _buildMyPage(context),
        Expanded(
          child: Observer(
              warnWhenNoObservables: false,
              builder: (_) {
                return _buildContent(context);
              }),
        ),
      ],
    );
  }

  Widget _buildContent(context) {
    return loadError ? _buildErrorContent(context) : _buildWorks(context);
  }

  Widget _buildErrorContent(context) {
    return Column(
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
    );
  }

  List<bool> isSelected = [true, false];

  Widget _buildMyPage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
            isSelected: isSelected,
            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                  if (isSelected[i]) {
                    restrict = i == 0 ? 'public' : 'private';
                  }
                }
                reset();
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            children: [
              Text("Public".tr),
              Text("Private".tr),
            ]),
      ],
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
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      return IllustCard(
        illusts,
        true,
        index: index,
      );
    }, childCount: illusts.length);
  }

  bool isLoading = false;

  reset() {
    illusts.clear();
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
    return ConnectManager().apiClient.getBookmarkedIllusts(restrict, nextUrl);
  }

  Future<Res<List<Novel>>> loadNovel() async {
    return ConnectManager().apiClient.getBookmarkedNovels(restrict, nextUrl);
  }
}
