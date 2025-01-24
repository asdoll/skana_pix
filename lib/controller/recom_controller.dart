import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/filters.dart';
import 'package:skana_pix/utils/leaders.dart';

class RecomImagesController extends ListController {
  EasyRefreshController easyRefreshController;
  
  RecomImagesController({required super.type,required this.easyRefreshController});

  @override
  void nextPage() {
    if (isLoading.value) return;
    isLoading.value = true;
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        page.value++;
        nexturl.value = value.subData;
        illusts.addAll(checkIllusts(value.data));
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
        Leader.showTextToast(message);
        easyRefreshController.finishLoad(IndicatorResult.fail);
        return false;
      }
    });
  }

  @override
  void firstLoad() {
    nexturl.value = "";
    loadData().then((value) {
      if (value.success) {
        page.value++;
        nexturl = value.subData;
        isFirstLoading.value = false;
        illusts.addAll(checkIllusts(value.data));
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

class RecomNovelsController extends GetxController {

}