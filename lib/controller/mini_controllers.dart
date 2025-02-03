import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MTab extends GetxController {
  RxInt index = 0.obs;
}

ScrollController globalScrollController = ScrollController();