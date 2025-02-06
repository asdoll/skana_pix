import 'package:get/get.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart';

class HomeController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool showBackArea = false.obs;

  RxInt tagIndex = 0.obs;
  RxInt workIndex = 0.obs;
  Rx<DateTime?> dateTime = Rxn<DateTime>();

  List<String> tagList(int index){
    if(index == 0){
      return modeIllust;
    } else if(index == 1){
      return modeManga;
    } else {
      return modeNovel;
    }
  }

  void refreshRanking(){
    try{
      switch(workIndex.value){
        case 0:
          Get.find<ListIllustController>(tag: "rankingIllust").refreshController?.callRefresh();
          break;
        case 1:
          Get.find<ListIllustController>(tag: "rankingManga").refreshController?.callRefresh();
          break;
        case 2:
          Get.find<ListNovelController>(tag: "rankingNovel").refreshController?.callRefresh();
          break;
      }
    } catch (e) {
      log.e(e);
    }
  }

  void resetRanking(){
    tagIndex.value = 0;
    dateTime.value = null;
  }

  void init() {
    switch (settings.awPrefer) {
      case "illust":
        pageIndex.value = 0;
        break;
      case "manga":
        pageIndex.value = 1;
        break;
      case "novel":
        pageIndex.value = 2;
        break;
    }
  }
}

List<String> pages = [
  "Recommended:Illusts", "Recommended:Mangas", "Recommended:Novels", //recom
  "Feed:Illust•Manga", "Feed:Novel", //feed
  "Ranking", "Pixivision",
  "Search", "Bookmarks", "My Tags", "Following", "History", "Settings"
];

late HomeController homeController;
