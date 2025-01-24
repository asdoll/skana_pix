import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';

abstract class ListController extends GetxController {
  ArtworkType type;
  RxList<Illust> illusts = RxList.empty();
  RxString nexturl = "".obs;
  RxBool isLoading = false.obs;
  RxBool isFirstLoading = true.obs;
  RxString? error;
  RxInt index = 0.obs;
  RxInt page = 1.obs;
  static RxList<int> historyIds = RxList.empty();

  static void sendHistory() {
    if (historyIds.length > 5) {
      ConnectManager().apiClient.sendHistory(
          historyIds.reversed.toList());
      historyIds.clear();
    }
  }

  ListController({required this.type});

  void nextPage();

  Future<Res<List<Illust>>> loadData();

  void reset() {
    if(likeController.illusts.length> 500){
      likeController.illusts.clear();
    }
    isFirstLoading.value = true;
    isLoading.value = false;
    illusts.clear();
    error = null;
    page.value = 1;
    nexturl.value = "";
    firstLoad();
  }

  void firstLoad();
}

class SingleListController extends ListController {
  String id;
  SingleListController({required this.id, required super.type});

  @override
  Future<Res<List<Illust>>> loadData() async {
    if (isLoading.value) return Res.error("Loading");
    isLoading.value = true;
    Res<Illust> res = await ConnectManager().apiClient.getIllustByID(id);
    isLoading.value = false;
    if (res.error) {
      error = (res.errorMessage ?? "Network Error".tr).obs;
      Leader.showTextToast(res.errorMessage ?? "Network Error".tr);
      return Res.error(res.errorMessage);
    } else {
      return Res([res.data]);
    }
  }

  @override
  void firstLoad() {
    loadData().then((value) {
      if (value.success) {
        illusts.addAll(value.data);
      }
    });
  }

  @override
  void nextPage() {
    log.t("don't have next page");
  }
}

class RelatedListController extends ListController {
  String id;
  EasyRefreshController refreshController;
  RelatedListController(
      {required this.id, required super.type, required this.refreshController});

  @override
  Future<Res<List<Illust>>> loadData() async {
    if (nexturl.value == "end") {
      return Res.error("No more data");
    }
    Res<List<Illust>> res = nexturl.value.isEmpty
        ? await relatedIllusts(id.toString())
        : await getIllustsWithNextUrl(nexturl.value);
    if (!res.error) {
      nexturl.value = res.subData ?? "end";
    } else {
      Leader.showTextToast(res.errorMessage ?? "Network Error".tr);
    }
    if (nexturl.value == "end") {
      refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      refreshController.finishLoad();
    }
    return res;
  }

  @override
  void nextPage() {
    loadData().then((value) {
      if (value.success) {
        illusts.addAll(value.data);
      }
    });
  }

  @override
  void firstLoad() {
    loadData().then((value) {
      if (value.success) {
        illusts.addAll(value.data);
      }
    });
  }
}
