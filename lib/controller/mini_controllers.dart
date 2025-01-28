import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MTab extends GetxController {
  RxInt index = 0.obs;
}

ScrollController globalScrollController = ScrollController();