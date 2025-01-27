import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/api_client.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/utils/leaders.dart';

class FeedIllustController extends ListIllustController {
  RxString restrict = "all".obs;
  FeedIllustController({required super.type, required this.refreshController});
  EasyRefreshController refreshController;

  @override
  void nextPage() {
    if (isLoading.value) {
      refreshController.finishLoad();
      return;
    }
    if (nexturl.value == "end") {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    isLoading.value = true;
    error = null;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        illusts.addAll(value.data);
        illusts.refresh();
        nexturl.value = value.subData ?? "end";
        refreshController.finishLoad();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController.finishLoad(IndicatorResult.noMore);
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showTextToast(message);
        refreshController.finishLoad(IndicatorResult.fail);
      }
    });
  }

  @override
  firstLoad() {
    if (isLoading.value) {
      refreshController.finishRefresh();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
          illusts.clear();
          illusts.addAll(value.data);
          illusts.refresh();
          nexturl.value = value.subData ?? "end";
          refreshController.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController.finishRefresh(IndicatorResult.noMore);
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showTextToast(message);
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  @override
  Future<Res<List<Illust>>> loadData() async {
    return ConnectManager().apiClient.getFollowingArtworks(restrict.value, nexturl.value);
  }
}

class FeedNovelController extends ListNovelController {
  RxString restrict = "all".obs;
  FeedNovelController({required this.refreshController});
  EasyRefreshController refreshController;

  @override
  void nextPage() {
    if (isLoading.value) {
      refreshController.finishLoad();
      return;
    }
    if (nexturl.value == "end") {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    isLoading.value = true;
    error = null;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        novels.addAll(value.data);
        novels.refresh();
        nexturl.value = value.subData ?? "end";
        refreshController.finishLoad();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController.finishLoad(IndicatorResult.noMore);
          return false;
        }
        error = message.obs;
        Leader.showTextToast(message);
        refreshController.finishLoad(IndicatorResult.fail);
      }
    });
  }

  @override
  void firstLoad() {
    if (isLoading.value) {
      refreshController.finishRefresh();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        novels.clear();
        novels.addAll(value.data);
        novels.refresh();
        nexturl.value = value.subData ?? "end";
        refreshController.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController.finishRefresh(IndicatorResult.noMore);
          return false;
        }
        error = message.obs;
        Leader.showTextToast(message);
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  @override
  Future<Res<List<Novel>>> loadData() async {
    return ConnectManager().apiClient.getNovelFollowing(restrict.value, nexturl.value);
  }
}