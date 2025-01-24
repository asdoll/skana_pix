import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
class DefaultHeaderFooter {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return ClassicHeader(
      position: position,
      safeArea: safeArea,
      dragText: 'Pull to refresh',
      armedText: 'Release ready',
      readyText: 'Refreshing...',
      processingText: 'Refreshing...',
      processedText: 'Succeeded',
      noMoreText: 'No more',
      failedText: 'Failed',
      showText: true,
      messageText: 'Last updated at %T',
    );
  }

  static Footer footer(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above}) {
    return ClassicFooter(
        position: position,
        processingText: "Loading".tr,
        failedText: "Failed".tr,
        showMessage: false,
        processedText: "Successed".tr,
        noMoreText: "No more".tr);
  }
}
