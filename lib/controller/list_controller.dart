import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/filters.dart';
import 'package:skana_pix/utils/leaders.dart';

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
  RxBool isLoading = false.obs;
  RxBool isFirstLoading = true.obs;
  RxString error = "".obs;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  EasyRefreshController? refreshController;
  String id;
  String tag;
  Rx<DateTime?> dateTime = Rxn<DateTime>();
  RxString restrict = "public".obs;
  ListType controllerType;
  Rx<SearchOptions?> searchOptions = Rxn<SearchOptions>();
  DateTimeRange? dateTimeRange;
  static RxList<int> historyIds = RxList.empty();
  RxInt tagIndex = 0.obs;

  bool get showMangaBadage => type != ArtworkType.MANGA;

  double get callLoadOverOffset => GetPlatform.isIOS ? 2 : 5;

  bool get noNextPage => controllerType == ListType.single;

  static void sendHistory() {
    if (historyIds.length > 5) {
      ConnectManager().apiClient.sendHistory(historyIds.reversed.toList());
      historyIds.clear();
      historyIds.refresh();
    }
  }

  ListIllustController(
      {required this.controllerType,
      required this.type,
      this.id = "",
      this.tag = ""});

  Future<Res<List<Illust>>> loadData() async {
    if (isLoading.value) {
      return Res.error("Loading");
    }
    if (nexturl.value == "end") {
      refreshController?.finishLoad(IndicatorResult.noMore);
      refreshController?.finishRefresh(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    isLoading.value = true;
    switch (controllerType) {
      case ListType.single:
        return ConnectManager().apiClient.getIllustByID(id);
      case ListType.related:
        return ConnectManager()
            .apiClient
            .relatedIllusts(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.feed:
        return ConnectManager().apiClient.getFollowingArtworks(
            restrict.value, nexturl.isEmpty ? null : nexturl.value);
      case ListType.ranking:
        return ConnectManager().apiClient.getRanking(
            type == ArtworkType.ILLUST
                ? modeIllust[tagIndex.value]
                : modeManga[tagIndex.value],
            dateTime.value == null ? null : toRequestDate(dateTime.value!),
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
          return ConnectManager()
              .apiClient
              .search(tag, searchOptions.value ?? SearchOptions());
        }
      case ListType.userbookmarks:
        return ConnectManager()
            .apiClient
            .getUserBookmarks(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.mybookmarks:
        return ConnectManager().apiClient.getBookmarkedIllusts(
            restrict.value, nexturl.isEmpty ? null : nexturl.value);
      case ListType.works:
        return ConnectManager().apiClient.getUserIllusts(
            id,
            type == ArtworkType.ILLUST ? "illust" : "manga",
            nexturl.isEmpty ? null : nexturl.value);
    }
  }

  void reset() {
    if (likeController.illusts.length > 500) {
      likeController.illusts.clear();
    }
    isLoading.value = false;
    illusts.clear();
    illusts.refresh();
    error.value = "";
    page.value = 1;
    nexturl.value = "";
    searchOptions.value = null;
    searchOptions.refresh();
    firstLoad();
  }

  List<Illust> filterIllusts(List<Illust> datas) {
    if (controllerType == ListType.userbookmarks || controllerType == ListType.mybookmarks || controllerType == ListType.works) return checkIllusts(datas);

    if (!["all", "illust", "manga"].contains(restrict.value)) {
      restrict.value = "all";
    }
    if (restrict.value == "all") {
      return checkIllusts(datas);
    }
    if (illusts.length < 10 && nexturl.value != "end") {
      nextPage();
    }
    datas.retainWhere((element) => element.type == restrict.value);
    return checkIllusts(datas);
  }

  void firstLoad() {
    if (isFirstLoading.value) {
      if (controllerType == ListType.search) {
        localManager.add("historyIllustTag", [tag]);
      }
    }
    loadData().then((value) {
      isLoading.value = false;
      isFirstLoading.value = false;
      if (value.success) {
        illusts.addAll(filterIllusts(value.data));
        illusts.refresh();
        nexturl.value = value.subData ?? "end";
        refreshController?.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishRefresh(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showToast(message);
        refreshController?.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  void nextPage() {
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        refreshController?.finishLoad();
        illusts.addAll(filterIllusts(value.data));
        illusts.refresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishLoad(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showToast(message);
        refreshController?.finishLoad(IndicatorResult.fail);
      }
    });
  }
}

class ListNovelController extends GetxController {
  RxList<Novel> novels = RxList.empty();
  RxString nexturl = "".obs;
  RxBool isLoading = false.obs;
  RxBool isFirstLoading = true.obs;
  RxString restrict = "public".obs;
  RxString? error;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  EasyRefreshController? refreshController;
  String tag;
  Rx<DateTime?> dateTime = Rxn<DateTime>();
  ListType controllerType;
  String id;
  DateTimeRange? dateTimeRange;
  Rx<SearchOptions?> searchOptions = Rxn<SearchOptions>();
  bool get noNextPage => controllerType == ListType.single;
  RxInt tagIndex = 0.obs;

  ListNovelController(
      {required this.controllerType, this.tag = "", this.id = ""});

  Future<Res<List<Novel>>> loadData() async {
    if (isLoading.value) {
      return Res.error("Loading");
    }
    if (nexturl.value == "end") {
      refreshController?.finishLoad(IndicatorResult.noMore);
      refreshController?.finishRefresh(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    isLoading.value = true;
    switch (controllerType) {
      case ListType.single:
        return ConnectManager().apiClient.getNovelById(id);
      case ListType.recom:
        return ConnectManager()
            .apiClient
            .getRecommendNovels(nexturl.isEmpty ? null : nexturl.value);
      case ListType.ranking:
        return ConnectManager().apiClient.getNovelRanking(
            modeNovel[tagIndex.value],
            dateTime.value == null ? null : toRequestDate(dateTime.value!),
            nexturl.isEmpty ? null : nexturl.value);
      case ListType.userbookmarks:
        return ConnectManager().apiClient.getUserBookmarksNovel(
            id.toString(), nexturl.isEmpty ? null : nexturl.value);
      case ListType.mybookmarks:
        return ConnectManager().apiClient.getBookmarkedNovels(
            restrict.value, nexturl.isEmpty ? null : nexturl.value);

      case ListType.related:
        return ConnectManager()
            .apiClient
            .relatedNovels(id, nexturl.isEmpty ? null : nexturl.value);
      case ListType.feed:
        return ConnectManager().apiClient.getNovelFollowing(
            restrict.value, nexturl.isEmpty ? null : nexturl.value);
      case ListType.search:
        if (nexturl.isNotEmpty) {
          return ConnectManager().apiClient.getNovelsWithNextUrl(nexturl.value);
        } else {
          return ConnectManager()
              .apiClient
              .searchNovels(tag, searchOptions.value ?? SearchOptions());
        }
      case ListType.works:
        return ConnectManager()
            .apiClient
            .getUserNovels(id, nexturl.isEmpty ? null : nexturl.value);
    }
  }

  void reset() {
    if (likeController.novels.length > 100) {
      likeController.novels.clear();
    }
    isLoading.value = false;
    novels.clear();
    novels.refresh();
    error = null;
    page.value = 1;
    nexturl.value = "";
    firstLoad();
  }

  void firstLoad() {
    if (isFirstLoading.value) {
      if (controllerType == ListType.search) {
        localManager.add("historyNovelTag", [tag]);
      }
    }
    loadData().then((value) {
      isLoading.value = false;
      isFirstLoading.value = false;
      if (value.success) {
        novels.addAll(checkNovels(value.data));
        novels.refresh();
        nexturl.value = value.subData ?? "end";
        refreshController?.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishRefresh(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showToast(message);
        refreshController?.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  void nextPage() {
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        refreshController?.finishLoad();
        novels.addAll(checkNovels(value.data));
        novels.refresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishLoad(IndicatorResult.noMore);
          return;
        }
        error = message.obs;
        Leader.showToast(message);
        refreshController?.finishLoad(IndicatorResult.fail);
      }
    });
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
  RxBool isLoading = false.obs;
  RxBool isFirstLoading = true.obs;
  RxString error = "".obs;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  EasyRefreshController? refreshController;
  RxBool tagExpand = false.obs;
  UserListType userListType;
  String id;
  RxString restrict = "public".obs;
  ListUserController({required this.userListType, this.id = ""});

  Future<Res<List<UserPreview>>> loadData() async {
    if (isLoading.value) {
      return Res.error("Loading");
    }
    if (nexturl.value == "end") {
      return Res.error("No more data");
    }
    isLoading.value = true;
    Res<List<UserPreview>> res;
    switch (userListType) {
      case UserListType.recom:
        res = await ConnectManager()
            .apiClient
            .getRecommendationUsers(nexturl.value.isEmpty ? null : nexturl.value);
        break;
      case UserListType.myfollowing:
      case UserListType.following:
        res = await ConnectManager()
            .apiClient
            .getFollowing(id.toString(), restrict.value, nexturl.value);
        break;
      case UserListType.mymypixiv:
      case UserListType.usermypixiv:
        res = await ConnectManager()
            .apiClient
            .getMypixiv(id.toString(), nexturl.value);
        break;
      case UserListType.search:
        res = await ConnectManager().apiClient.searchUsers(id, nexturl.value);
        break;
    }
    return res;
  }

  void firstLoad() {
    if (isFirstLoading.value) {
      if (userListType == UserListType.search) {
        localManager.add("historyUserTag", [id]);
      }
    }
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        isFirstLoading.value = false;
        users.addAll(value.data);
        users.refresh();
        refreshController?.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishRefresh(IndicatorResult.noMore);
          return;
        }
        error.value = message;
        Leader.showToast(message);
        refreshController?.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  void reset() {
    if (likeController.users.length > 100) {
      likeController.users.clear();
    }
    isLoading.value = false;
    users.clear();
    users.refresh();
    error.value = "";
    page.value = 1;
    nexturl.value = "";
    firstLoad();
  }

  void nextPage() {
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        users.addAll(value.data);
        users.refresh();
        refreshController?.finishLoad();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          refreshController?.finishLoad(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error.value = message;
        Leader.showToast(message);
        refreshController?.finishLoad(IndicatorResult.fail);
      }
    });
  }
}

class RankingPageController extends GetxController {
  RxInt index = 0.obs;

  void init() {
    switch (settings.awPrefer) {
      case "illust":
        setIndex(0);
        break;
      case "manga":
        setIndex(1);
        break;
      case "novel":
        setIndex(2);
        break;
    }
  }

  void setIndex(int i) {
    index.value = i;
  }
}

class HotTagsController extends GetxController {
  RxList<TrendingTag> tags = RxList.empty();
  ArtworkType type;
  EasyRefreshController? refreshController;
  RxBool tagExpand = false.obs;
  RxBool isLoading = false.obs;

  HotTagsController(this.type);

  void reset() {
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        tags.clear();
        tags.addAll(value.data);
        tags.refresh();
        refreshController?.finishRefresh();
      } else {
        Leader.showToast("Network error".tr);
        refreshController?.finishRefresh(IndicatorResult.fail);
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
