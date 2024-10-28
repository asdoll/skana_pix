import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'imagetab.dart';

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

class _WorksPageState extends State<WorksPage> {
  late EasyRefreshController _easyRefreshController;
  ObservableList<Illust> illusts = ObservableList<Illust>();
  ObservableList<Illust> manga = ObservableList<Illust>();
  ObservableList<Novel> novels = ObservableList<Novel>();
  bool isError = false;
  int tab = 0;

  bool get loadError {
    if (tab == 0) {
      return illusts.isEmpty && isError;
    }
    if (tab == 1) {
      return manga.isEmpty && isError;
    }
    if (tab == 2) {
      return novels.isEmpty && isError;
    }
    return false;
  }

  @override
  void initState() {
    tab = widget.type == ArtworkType.ILLUST
        ? 0
        : widget.type == ArtworkType.MANGA
            ? 1
            : 2;
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  String now = 'illust';

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
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
                firstLoad();
              },
              child: Text("Retry".i18n)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                ("Failed to load".i18n),
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
                  firstLoad();
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
                      key: PageStorageKey<String>(widget.portal),
                      slivers: [
                        SliverPinnedOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                        ),
                        const HeaderLocator.sliver(),
                        SliverPersistentHeader(
                            delegate: SliverChipDelegate(
                                Container(
                                  child: Center(
                                    child: _buildSortChip(),
                                  ),
                                ),
                                height: 52),
                            pinned: true),
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
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      BuildContext context) {
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      return IllustCard(
        illusts,
        false,
        initialPage: index,
      );
    }, childCount: illusts.length);
  }

  int _buildSliderValue() {
    final currentValue = 100.0;
    var nowAdaptWidth = max(currentValue, 50.0);
    nowAdaptWidth = min(nowAdaptWidth, 2160.0);
    final screenWidth = MediaQuery.of(context).size.width;
    final result = max(screenWidth / nowAdaptWidth, 1.0).toInt();
    return result;
  }

  Widget _buildSortChip() {
    return Container();
    // return SortGroup(
    //   onChange: (index) {
    //     final type = index == 0 ? 'illust' : 'manga';
    //     setState(() {
    //       now = type;
    //     });
    //     _store.source = ApiForceSource(
    //         futureGet: (bool e) => apiClient.getUserIllusts(widget.id, type));
    //     _store.fetch();
    //   },
    //   children: [
    //     I18n.of(context).illust,
    //     I18n.of(context).manga,
    //   ],
    // );
  }

  bool isLoading = false;

  firstLoad() {
    if (isLoading) {
      return;
    }
    isLoading = true;
    if (tab == 0) {
      loadIllust().then((value) {
        if (value.success) {
          setState(() {
            illusts.clear();
            illusts.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    if (tab == 1) {
      loadManga().then((value) {
        if (value.success) {
          setState(() {
            manga.clear();
            manga.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    if (tab == 2) {
      loadNovel().then((value) {
        if (value.success) {
          setState(() {
            novels.clear();
            novels.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    isLoading = false;
  }

  nextPage() {
    if (isLoading) {
      return;
    }
    isLoading = true;
    if (tab == 0) {
      loadIllust().then((value) {
        if (value.success) {
          setState(() {
            illusts.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    if (tab == 1) {
      loadManga().then((value) {
        if (value.success) {
          setState(() {
            manga.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    if (tab == 2) {
      loadNovel().then((value) {
        if (value.success) {
          setState(() {
            novels.addAll(value.data);
            nextUrl = value.subData;
          });
        } else {
          isError = true;
        }
      });
    }
    isLoading = false;
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
