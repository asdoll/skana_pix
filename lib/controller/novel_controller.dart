import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/exceptions.dart';
import 'package:skana_pix/controller/histories.dart' show M;
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/model/objectbox_models.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;

class NovelSeriesDetailController extends GetxController {
  Rx<NovelSeriesDetail?> novelSeriesDetail = Rxn<NovelSeriesDetail>();
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  RxString nextUrl = "".obs;
  String seriesId;
  RxList<Novel> novels = <Novel>[].obs;
  Rx<Novel?> last = Rxn<Novel>();
  NovelSeriesDetailController({required this.seriesId});

  Future<void> nextPage() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      novels.addAll(value.data.novels);
      novels.refresh();
      last.value = value.data.last ?? last.value;
      last.refresh();
      if (nextUrl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      if (value.errorMessage == "No more data") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (value.errorMessage != null &&
          value.errorMessage!.contains("timeout")) {
        failedLoadToast(text: "Network Error. Please refresh to try again.".tr);
      }
    }
  }

  Future<void> reset() async {
    novels.clear();
    novels.refresh();
    last.value = null;
    last.refresh();
    novelSeriesDetail.value = null;
    novelSeriesDetail.refresh();
    nextUrl.value = "";
    await firstLoad();
  }

  Future<void> firstLoad() async {
    if (loadingState.value == LoadingState.loading) return;
    nextUrl.value = "";
    var value = await loadData();
    if (value.success) {
      novels.clear();
      last.value = null;
      novelSeriesDetail.value = null;
      novelSeriesDetail.value = value.data.novelSeriesDetail;
      novelSeriesDetail.refresh();
      novels.addAll(value.data.novels);
      novels.refresh();
      last.value = value.data.last;
      last.refresh();
      if (nextUrl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      if (value.errorMessage == "No more data") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (value.errorMessage != null &&
          value.errorMessage!.contains("timeout")) {
        failedLoadToast(text: "Network Error. Please refresh to try again.".tr);
      }
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<Res<NovelSeriesResponse>> loadData() async {
    if (loadingState.value == LoadingState.loading) return Res(null);
    if (nextUrl.value == "end") {
      return Res.error("No more data");
    }
    loadingState.value = LoadingState.loading;

    Res<NovelSeriesResponse> res = await ConnectManager()
        .apiClient
        .getNovelSeries(seriesId, nextUrl.value.isEmpty ? null : nextUrl.value);
    if (!res.error) {
      nextUrl.value = res.subData ?? "end";
    }
    return res;
  }
}

class NovelStore extends GetxController {
  final Novel novel;
  late String stringContent;
  List<String> result = [];
  String? errorMessage;
  NovelWebResponse? novelWebResponse;
  TextSpan? textSpan;

  NovelStore(this.novel);

  Future<double> historyPercent(int id) async {
    NovelHistory? novelHistory = await M.getNovelHistoryByNovelId(novel.id);
    return novelHistory?.lastRead ?? 0;
  }

  Future<void> updateHistory(double percent) async {
    await M.addNovel(novel, lastRead: percent);
  }

  Future<List<String>> fetch() async {
    errorMessage = null;
    try {
      Res<NovelWebResponse> response =
          await ConnectManager().apiClient.getNovelContent(novel.id.toString());
      if (response.error) {
        throw BadResponseException(response.errMsg);
      }
      novelWebResponse = response.data;
      stringContent = novelWebResponse!.text;
      result = stringContent.split(RegExp(r"\n\s*|\s{2,}"));
      if (result.isEmpty) {
        throw BadResponseException("No content");
      }
      return result;
    } catch (e) {
      log.e(e.toString());
      errorMessage = e.toString();
    }
    return result;
  }
}
