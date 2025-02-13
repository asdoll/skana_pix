import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/exceptions.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/utils/leaders.dart';

class NovelSeriesDetailController extends GetxController {
  Rx<NovelSeriesDetail?> novelSeriesDetail = Rxn<NovelSeriesDetail>();
  EasyRefreshController? easyRefreshController;
  RxString nextUrl = "".obs;
  String seriesId;
  RxList<Novel> novels = <Novel>[].obs;
  Rx<Novel?> last = Rxn<Novel>();
  NovelSeriesDetailController(
      {required this.seriesId});

  void nextPage() {
    loadData().then((value) {
      if (value.success) {
        novels.addAll(value.data.novels);
        novels.refresh();
        last.value = value.data.last ?? last.value;
        last.refresh();
      } else {
        if (value.errorMessage != null &&
            value.errorMessage!.contains("timeout")) {
          Leader.showToast("Network Error. Please refresh to try again.".tr);
        }
      }
    });
  }

  void reset() {
    novels.clear();
    novels.refresh();
    last.value = null;
    last.refresh();
    novelSeriesDetail.value = null;
    novelSeriesDetail.refresh();
    nextUrl.value = "";

    firstLoad();
  }

  void firstLoad() {
    nextUrl.value = "";
    loadData().then((value) {
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
        easyRefreshController?.finishRefresh();
      } else {
        if (value.errorMessage != null &&
            value.errorMessage!.contains("timeout")) {
          Leader.showToast("Network Error. Please refresh to try again.".tr);
        }
        easyRefreshController?.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  Future<Res<NovelSeriesResponse>> loadData() async {
    if (nextUrl.value == "end") {
      easyRefreshController?.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    Res<NovelSeriesResponse> res = await ConnectManager()
        .apiClient
        .getNovelSeries(seriesId, nextUrl.value.isEmpty ? null : nextUrl.value);
    if (!res.error) {
      nextUrl.value = res.subData ?? "end";
    }
    if (nextUrl.value == "end") {
      easyRefreshController?.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController?.finishLoad();
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