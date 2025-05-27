import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/page_index_controller.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/author.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/model/searches.dart';
import 'package:skana_pix/model/tag.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/filters.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/loading_indicator.dart' show LoadingState;

enum ListType {
  single,
  related,
  feed,
  ranking,
  recom,
  search,
  userbookmarks,
  mybookmarks,
  works
}

class ListIllustController extends GetxController {
  ArtworkType type;
  RxList<Illust> illusts = RxList.empty();
  RxString nexturl = "".obs;
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  RxBool isFirstLoading = true.obs;
  RxString error = "".obs;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  String id;
  String tag;
  String restrict;
  ListType controllerType;
  Rx<SearchOptions> searchOptions = SearchOptions().obs;
  DateTimeRange? dateTimeRange;
  RxBool showBackArea = false.obs;
  RxBool showDropdown = false.obs;
  RxBool showPremiumMenu = false.obs;
  RxBool showSortMenu = false.obs;
  static RxList<int> historyIds = RxList.empty();

  bool get showMangaBadage => type != ArtworkType.MANGA;

  double get callLoadOverOffset => GetPlatform.isIOS ? 2 : 5;

  bool get noNextPage => controllerType == ListType.single;

  bool get showOriginal => settings.showOriginal;

  static void sendHistory() {
    if (historyIds.length > 5) {
      ConnectManager().apiClient.sendHistory(historyIds.reversed.toList());
    }
    historyIds.clear();
    historyIds.refresh();
  }

  ListIllustController({
    required this.controllerType,
    required this.type,
    this.id = "",
    this.tag = "",
    this.restrict = "public",
  });

  Future<Res<List<Illust>>> loadData() async {
    if (loadingState.value == LoadingState.loading) {
      return Res(null);
    }
    if (nexturl.value == "end") {
      loadingState.value = LoadingState.noMore;
      loadingState.refresh();
      return Res.error("No more data");
    }
    loadingState.value = LoadingState.loading;
    loadingState.refresh();
    switch (controllerType) {
      case ListType.single:
        return ConnectManager().apiClient.getIllustByID(id);
      case ListType.related:
        return ConnectManager()
            .apiClient
            .relatedIllusts(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.feed:
        return ConnectManager().apiClient.getFollowingArtworks(
            restrict, nexturl.isEmpty ? null : nexturl.value);
      case ListType.ranking:
        return ConnectManager().apiClient.getRanking(
            type == ArtworkType.ILLUST
                ? modeIllust[homeController.tagIndex.value]
                : modeManga[homeController.tagIndex.value],
            homeController.dateTime.value == null
                ? null
                : toRequestDate(homeController.dateTime.value!),
            nexturl.isEmpty ? null : nexturl.value);
      case ListType.recom:
        if (type == ArtworkType.ILLUST) {
          return ConnectManager()
              .apiClient
              .getRecommendedIllusts(nexturl.isEmpty ? null : nexturl.value);
        } else {
          return ConnectManager()
              .apiClient
              .getRecommendedMangas(nexturl.isEmpty ? null : nexturl.value);
        }
      case ListType.search:
        if (nexturl.isNotEmpty) {
          return ConnectManager()
              .apiClient
              .getIllustsWithNextUrl(nexturl.value);
        } else {
          return ConnectManager().apiClient.search(tag, searchOptions.value);
        }
      case ListType.userbookmarks:
        return ConnectManager()
            .apiClient
            .getUserBookmarks(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.mybookmarks:
        return ConnectManager().apiClient.getBookmarkedIllusts(
            restrict, nexturl.isEmpty ? null : nexturl.value);
      case ListType.works:
        return ConnectManager().apiClient.getUserIllusts(
            id,
            type == ArtworkType.ILLUST ? "illust" : "manga",
            nexturl.isEmpty ? null : nexturl.value);
    }
  }

  Future<void> reset() async {
    if (likeController.illusts.length > 500) {
      likeController.illusts.clear();
    }
    loadingState.value = LoadingState.idle;
    loadingState.refresh();
    illusts.clear();
    illusts.refresh();
    error.value = "";
    page.value = 1;
    nexturl.value = "";
    await firstLoad();
  }

  List<Illust> filterIllusts(List<Illust> datas) {
    if (controllerType == ListType.userbookmarks ||
        controllerType == ListType.mybookmarks ||
        controllerType == ListType.works) {
      return checkIllusts(datas);
    }

    if (!["all", "illust", "manga"].contains(restrict)) {
      restrict = "all";
    }
    if (restrict == "all") {
      return checkIllusts(datas);
    }
    if (illusts.length < 10 && nexturl.value != "end") {
      nextPage();
    }
    datas.retainWhere((element) => element.type == restrict);
    return checkIllusts(datas);
  }

  Future<void> firstLoad() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    if (isFirstLoading.value) {
      if (controllerType == ListType.search) {
        localManager.add("historyIllustTag", [tag]);
      }
    }
    var value = await loadData();
    if (value.success) {
      nexturl.value = value.subData ?? "end";
      illusts.addAll(filterIllusts(value.data));
      illusts.refresh();
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<void> nextPage() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      page.value++;
      nexturl.value = value.subData ?? "end";
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
      illusts.addAll(filterIllusts(value.data));
      illusts.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }
}

class ListNovelController extends GetxController {
  RxList<Novel> novels = RxList.empty();
  RxString nexturl = "".obs;
  RxBool isFirstLoading = true.obs;
  String restrict;
  RxString error = "".obs;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  String tag;
  ListType controllerType;
  String id;
  DateTimeRange? dateTimeRange;
  Rx<SearchOptions> searchOptions = SearchOptions().obs;
  bool get noNextPage => controllerType == ListType.single;
  RxInt tagIndex = 0.obs;
  RxBool showPremiumMenu = false.obs;
  RxBool showSortMenu = false.obs;

  bool get novelDirectEntry => settings.novelDirectEntry;

  ListNovelController(
      {required this.controllerType,
      this.tag = "",
      this.id = "",
      this.restrict = "public"});

  Future<Res<List<Novel>>> loadData() async {
    if (loadingState.value == LoadingState.loading) {
      return Res(null);
    }
    if (nexturl.value == "end") {
      loadingState.value = LoadingState.noMore;
      loadingState.refresh();
      return Res.error("No more data");
    }
    loadingState.value = LoadingState.loading;
    loadingState.refresh();
    switch (controllerType) {
      case ListType.single:
        return ConnectManager().apiClient.getNovelById(id);
      case ListType.recom:
        return ConnectManager()
            .apiClient
            .getRecommendNovels(nexturl.isEmpty ? null : nexturl.value);
      case ListType.ranking:
        return ConnectManager().apiClient.getNovelRanking(
            modeNovel[homeController.tagIndex.value],
            homeController.dateTime.value == null
                ? null
                : toRequestDate(homeController.dateTime.value!),
            nexturl.isEmpty ? null : nexturl.value);
      case ListType.userbookmarks:
        return ConnectManager().apiClient.getUserBookmarksNovel(
            id.toString(), nexturl.isEmpty ? null : nexturl.value);
      case ListType.mybookmarks:
        return ConnectManager().apiClient.getBookmarkedNovels(
            restrict, nexturl.isEmpty ? null : nexturl.value);

      case ListType.related:
        return ConnectManager()
            .apiClient
            .relatedNovels(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.feed:
        return ConnectManager().apiClient.getNovelFollowing(
            restrict, nexturl.isEmpty ? null : nexturl.value);
      case ListType.search:
        if (nexturl.isNotEmpty) {
          return ConnectManager().apiClient.getNovelsWithNextUrl(nexturl.value);
        } else {
          return ConnectManager()
              .apiClient
              .searchNovels(tag, searchOptions.value);
        }
      case ListType.works:
        return ConnectManager()
            .apiClient
            .getUserNovels(id, nexturl.isEmpty ? null : nexturl.value);
    }
  }

  Future<void> reset() async {
    if (likeController.novels.length > 100) {
      likeController.novels.clear();
    }
    loadingState.value = LoadingState.idle;
    novels.clear();
    novels.refresh();
    error.value = "";
    page.value = 1;
    nexturl.value = "";
    await firstLoad();
  }

  Future<void> firstLoad() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    if (isFirstLoading.value) {
      if (controllerType == ListType.search) {
        localManager.add("historyNovelTag", [tag]);
      }
    }
    var value = await loadData();
    isFirstLoading.value = false;
    if (value.success) {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      novels.addAll(checkNovels(value.data));
      novels.refresh();
      nexturl.value = value.subData ?? "end";
      if (nexturl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<void> nextPage() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      page.value++;
      nexturl.value = value.subData ?? "end";
      novels.addAll(checkNovels(value.data));
      novels.refresh();
      if (nexturl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }
}

enum UserListType {
  recom,
  usermypixiv,
  following,
  myfollowing,
  mymypixiv,
  search
}

class ListUserController extends GetxController {
  RxList<UserPreview> users = RxList.empty();
  RxString nexturl = "".obs;
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  RxBool isFirstLoading = true.obs;
  RxString error = "".obs;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  RxBool tagExpand = false.obs;
  UserListType userListType;
  String id;
  String restrict;
  ListUserController(
      {required this.userListType, this.id = "", this.restrict = "public"});

  Future<Res<List<UserPreview>>> loadData() async {
    if (loadingState.value == LoadingState.loading) {
      return Res.error("Loading");
    }
    if (nexturl.value == "end") {
      return Res.error("No more data");
    }
    loadingState.value = LoadingState.loading;
    loadingState.refresh();
    Res<List<UserPreview>> res;
    switch (userListType) {
      case UserListType.recom:
        res = await ConnectManager().apiClient.getRecommendationUsers(
            nexturl.value.isEmpty ? null : nexturl.value);
        break;
      case UserListType.myfollowing:
      case UserListType.following:
        res = await ConnectManager().apiClient.getFollowing(id.toString(),
            restrict, nexturl.value.isEmpty ? null : nexturl.value);
        break;
      case UserListType.mymypixiv:
      case UserListType.usermypixiv:
        res = await ConnectManager().apiClient.getMypixiv(
            id.toString(), nexturl.value.isEmpty ? null : nexturl.value);
        break;
      case UserListType.search:
        res = await ConnectManager()
            .apiClient
            .searchUsers(id, nexturl.value.isEmpty ? null : nexturl.value);
        break;
    }
    return res;
  }

  Future<void> firstLoad() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    if (isFirstLoading.value) {
      if (userListType == UserListType.search) {
        localManager.add("historyUserTag", [id]);
      }
    }
    var value = await loadData();
    isFirstLoading.value = false;
    if (value.success) {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      users.addAll(value.data);
      users.refresh();
      nexturl.value = value.subData ?? "end";
      if (nexturl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<void> reset() async {
    if (likeController.users.length > 100) {
      likeController.users.clear();
    }
    loadingState.value = LoadingState.idle;
    users.clear();
    users.refresh();
    error.value = "";
    page.value = 1;
    nexturl.value = "";
    await firstLoad();
  }

  Future<void> nextPage() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      page.value++;
      nexturl.value = value.subData ?? "end";
      users.addAll(value.data);
      users.refresh();
      if (nexturl.value == "end") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        error.value = "";
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }
}

class HotTagsController extends GetxController {
  RxList<TrendingTag> tags = RxList.empty();
  ArtworkType type;
  RxBool tagExpand = false.obs;
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  RxString error = "".obs;

  HotTagsController(this.type);

  Future<void> reset() async {
    if (loadingState.value == LoadingState.loading) return;
    loadingState.value = LoadingState.loading;
    var value = await loadData();
    if (value.success) {
      tags.clear();
      tags.addAll(value.data);
      tags.refresh();
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      error.value = message;
      failedLoadToast(text: message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<Res<List<TrendingTag>>> loadData() async {
    if (type == ArtworkType.ILLUST) {
      return ConnectManager().apiClient.getHotTags();
    } else {
      return ConnectManager().apiClient.getHotNovelTags();
    }
  }
}

String toRequestDate(DateTime dateTime) {
  return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
}

final modeIllust = [
  "day",
  "day_male",
  "day_female",
  "week_original",
  "week_rookie",
  "week",
  "month",
  "day_ai",
  "day_r18_ai",
  "day_r18",
  "week_r18",
  "week_r18g"
];
final modeManga = [
  "day_manga",
  "week_manga",
  "month_manga",
  "week_rookie_manga",
  "day_r18_manga",
  "week_r18_manga"
];
final modeNovel = [
  "day",
  "day_male",
  "day_female",
  "week",
  "week_ai",
  "week_ai_r18",
  "day_r18",
  "week_r18",
  "week_r18g"
];

Map<String, String> rankTagsMap = {
  "day": "Daily".tr,
  "day_male": "For male".tr,
  "day_female": "For female".tr,
  "week_original": "Originals".tr,
  "week_rookie": "Rookies".tr,
  "week": "Weekly".tr,
  "month": "Monthly".tr,
  "day_ai": "Daily AI".tr,
  "day_r18_ai": "Daily R18 AI".tr,
  "day_r18": "Daily R18".tr,
  "week_r18": "Weekly R18".tr,
  "week_r18g": "Weekly R18G".tr,
  "day_manga": "Daily Manga".tr,
  "week_manga": "Weekly Manga".tr,
  "month_manga": "Monthly Manga".tr,
  "week_rookie_manga": "Rookies Manga".tr,
  "day_r18_manga": "Daily R18 Manga".tr,
  "week_r18_manga": "Weekly R18 Manga".tr,
  "week_ai": "Weekly AI".tr,
  "week_ai_r18": "Weekly AI R18".tr,
};
