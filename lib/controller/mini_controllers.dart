import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/worktypes.dart';

class MTab extends GetxController {
  RxInt index = 0.obs;
}

class SearchPageController extends GetxController {
  RxInt selectedIndex = (settings.awPrefer == "novel") ? 1.obs : 0.obs;
  ArtworkType getAwType(int index) {
    switch (index) {
      case 0:
        return ArtworkType.ILLUST;
      case 1:
        return ArtworkType.NOVEL;
      default:
        return ArtworkType.USER;
    }
  }
}

late SearchPageController searchPageController;

ScrollController globalScrollController = ScrollController();
