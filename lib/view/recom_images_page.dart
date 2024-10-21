import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/view/defaults.dart';

import '../componentwidgets/imagetab.dart';
import '../componentwidgets/loading.dart';
import '../utils/filters.dart';

class RecomImagesPage extends StatefulWidget {
  final int type;

  RecomImagesPage(this.type, {super.key});
  @override
  _RecomImagesPageState createState() => _RecomImagesPageState();
}

class _RecomImagesPageState
    extends MultiPageLoadingState<RecomImagesPage, Illust> {
  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    checkIllusts(data);
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(builder: (context, constrains) {
          return MasonryGridView.builder(
            controller: DynamicData.recommendScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8) +
                EdgeInsets.only(bottom: context.padding.bottom),
            gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              if (index == data.length - 1) {
                nextPage();
              }
              return IllustCard(data, false,
                  initialPage: index, type: widget.type);
            },
          );
        }));
  }

  Future<void> _onRefresh() async {
    reset();
  }

  @override
  Future<Res<List<Illust>>> loadData(page) {
    return widget.type == 0 ? getRecommendedIllusts() : getRecommendedMangas();
  }
}
