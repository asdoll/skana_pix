import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool showBackArea = false.obs;
}

List<String> pages = [
  "Recommended:Illusts", "Recommended:Mangas", "Recommended:Novels", //recom
  "Feed:Illust•Manga", "Feed:Novel", //feed
  "Ranking", "Pixivision",
  "Search", "Bookmarks", "My Tags", "Following", "History", "Settings"
];

late HomeController homeController;
