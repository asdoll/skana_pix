import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';

class RankingPageController extends GetxController {
  RxInt index = 0.obs;
  RxInt tagIndex = 0.obs;
  RxList<String> tagList = RxList.empty();
  Rx<DateTime> dateTime = DateTime.now().obs;

  void setIndex(int i) {
    index.value = i;
    switch (i) {
      case 0:
        tagIndex.value = 0;
        tagList.value = modeIllust;
        break;
      case 1:
        tagIndex.value = 0;
        tagList.value = modeMange;
        break;
      case 2:
        tagIndex.value = 0;
        tagList.value = modeNovel;
        break;
    }
    tagList.refresh();
  }
}

class RankingIllustController extends ListIllustController {
  EasyRefreshController refreshController;
  String tag;
  String dateTime;
  RankingIllustController(this.refreshController, this.tag, {required super.type, required this.dateTime});


  @override
  void nextPage() {
    if (isLoading.value) {
      refreshController.finishLoad();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData;
        illusts.addAll(value.data);
        illusts.refresh();
        refreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        refreshController.finishLoad(IndicatorResult.fail);
        Leader.showTextToast(message);
        return false;
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
        page.value++;
        nexturl.value = value.subData;
        illusts.clear();
        illusts.addAll(value.data);
        illusts.refresh();
        refreshController.finishRefresh();
      } else {
        var message = value.errorMessage ?? "Network Error. Please refresh to try again.".tr;
        if (message.contains("timeout")) {
          message = "Network Error. Please refresh to try again.".tr;
        }
        error = message.obs;
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  @override
  Future<Res<List<Illust>>> loadData() async {
    return await ConnectManager().apiClient.getRanking(tag, dateTime, nexturl.value);
  }
}

class RankingNovelController extends ListNovelController {
  EasyRefreshController refreshController;
  String tag;
  String dateTime;
  RankingNovelController(this.refreshController, this.tag, {required this.dateTime});

  @override
  void nextPage() {
    if (isLoading.value) {
      refreshController.finishLoad();
      return;
    }
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData ?? "end";
        novels.addAll(value.data);
        novels.refresh();
        refreshController.finishLoad();
        return true;
      } else {
        var message = value.errorMessage ?? "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
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
        page.value++;
        nexturl.value = value.subData ?? "end";
        novels.clear();
        novels.addAll(value.data);
        novels.refresh();
        refreshController.finishRefresh();
      } else {
        var message = value.errorMessage ?? "Network Error. Please refresh to try again.".tr;
        if (message.contains("timeout")) {
          message = "Network Error. Please refresh to try again.".tr;
        }
        error = message.obs;
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  @override
  Future<Res<List<Novel>>> loadData() async {
    return await ConnectManager().apiClient.getNovelRanking(tag, dateTime, nexturl.value);
  }
}


String? toRequestDate(DateTime dateTime) {
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
final modeMange = [
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