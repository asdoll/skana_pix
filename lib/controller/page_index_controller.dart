import 'package:get/get.dart';
import 'package:skana_pix/controller/settings.dart';

class HomeController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool showBackArea = false.obs;

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
