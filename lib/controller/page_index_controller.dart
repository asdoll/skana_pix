import 'package:get/get.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

}

List<String> pages = ["Illust","Manga","Novel",//recom
"Ranking","Pixivision",
"Illust/Manga","Novel",//feed
"Search","Bookmarks","My Tags","Following","History","Settings"];

late PageIndexController pageIndexController;