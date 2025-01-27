import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/filters.dart';
import 'package:skana_pix/utils/leaders.dart';

class RecomImagesController extends ListIllustController {
  EasyRefreshController easyRefreshController;

  RecomImagesController(
      {required super.type, required this.easyRefreshController});

  @override
  void nextPage() {
    if (isLoading.value) {
      easyRefreshController.finishLoad();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        illusts.addAll(checkIllusts(value.data));
        illusts.refresh();
        easyRefreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          easyRefreshController.finishLoad(IndicatorResult.noMore);
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showTextToast(message);
        easyRefreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  @override
  void firstLoad() {
    if (isLoading.value) {
      easyRefreshController.finishRefresh();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        isFirstLoading.value = false;
        illusts.addAll(checkIllusts(value.data));
        illusts.refresh();
        easyRefreshController.finishRefresh();
      } else {
        isFirstLoading.value = false;
        if (value.errorMessage != null &&
            value.errorMessage!.contains("timeout")) {
          var msg = "Network Error. Please refresh to try again.".tr;
          error = msg.obs;
          Leader.showTextToast(msg);
          easyRefreshController.finishRefresh(IndicatorResult.fail);
        }
      }
    });
  }

  @override
  Future<Res<List<Illust>>> loadData() {
    if (nexturl.value != "") {
      return ConnectManager().apiClient.getIllustsWithNextUrl(nexturl.value);
    }
    return type == ArtworkType.ILLUST
        ? ConnectManager().apiClient.getRecommendedIllusts()
        : ConnectManager().apiClient.getRecommendedMangas();
  }
}

class RecomNovelsController extends ListNovelController {
  EasyRefreshController easyRefreshController;

  RecomNovelsController({required this.easyRefreshController});

  @override
  void nextPage() {
    if (isLoading.value) {
      easyRefreshController.finishLoad();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        novels.addAll(checkNovels(value.data));
        novels.refresh();
        easyRefreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          easyRefreshController.finishLoad(IndicatorResult.noMore);
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showTextToast(message);
        easyRefreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  @override
  void firstLoad() {
    if (isLoading.value) {
      easyRefreshController.finishRefresh();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        isFirstLoading.value = false;
        novels.addAll(checkNovels(value.data));
        novels.refresh();
        easyRefreshController.finishRefresh();
      } else {
        isFirstLoading.value = false;
        if (value.errorMessage != null &&
            value.errorMessage!.contains("timeout")) {
          var msg = "Network Error. Please refresh to try again.".tr;
          error = msg.obs;
          Leader.showTextToast(msg);
          easyRefreshController.finishRefresh(IndicatorResult.fail);
        }
      }
    });
  }

  @override
  Future<Res<List<Novel>>> loadData() {
    if (nexturl.value != "") {
      return ConnectManager().apiClient.getNovelsWithNextUrl(nexturl.value);
    }
    return ConnectManager().apiClient.getRecommendNovels();
  }
}

class RecomUsersController extends ListUserController {
  EasyRefreshController easyRefreshController;
  RxBool tagExpand = false.obs;

  RecomUsersController({required this.easyRefreshController});

  @override
  void reset() {
    super.reset();
    firstLoad();
  }

  @override
  void nextPage() {
    if (isLoading.value) {
      easyRefreshController.finishLoad();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        users.addAll(value.data);
        users.refresh();
        easyRefreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          easyRefreshController.finishLoad(IndicatorResult.noMore);
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showTextToast(message);
        easyRefreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  @override
  void firstLoad() {
    if (isLoading.value) {
      easyRefreshController.finishRefresh();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        isFirstLoading.value = false;
        users.addAll(value.data);
        users.refresh();
        easyRefreshController.finishRefresh();
      } else {
        isFirstLoading.value = false;
        if (value.errorMessage != null &&
            value.errorMessage!.contains("timeout")) {
          var msg = "Network Error. Please refresh to try again.".tr;
          error = msg.obs;
          Leader.showTextToast(msg);
          easyRefreshController.finishRefresh(IndicatorResult.fail);
        }
      }
    });
  }

  @override
  Future<Res<List<UserPreview>>> loadData() async {
    if (nexturl.value == "end") {
      return Res.error("No more data");
    }
    Res<List<UserPreview>> res =
        await ConnectManager().apiClient.getRecommendationUsers(nexturl.value);
    if (!res.error) {
      nexturl.value = res.subData ?? "end";
    }
    return res;
  }
}

class HotTagsController extends GetxController {
  RxList<TrendingTag> tags = RxList.empty();
  ArtworkType type;
  EasyRefreshController refreshController;
  RxBool tagExpand = false.obs;
  RxBool isLoading = false.obs;

  HotTagsController(this.type, this.refreshController);

  void reset() {
    if (isLoading.value) return;
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        tags.clear();
        tags.addAll(value.data);
        tags.refresh();
        refreshController.finishRefresh();
      } else {
        Leader.showTextToast("Network error".tr);
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  Future<Res<List<TrendingTag>>> loadData() async {
    if (type == ArtworkType.ILLUST) {
      return ConnectManager().apiClient.getHotTags();
    } else {
      return ConnectManager().apiClient.getHotNovelTags();
    }
  }
}
