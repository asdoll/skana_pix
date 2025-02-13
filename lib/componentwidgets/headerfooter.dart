import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class DefaultHeaderFooter {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return ClassicHeader(
        position: position,
        safeArea: safeArea,
        dragText: 'Pull to refresh'.tr,
        armedText: 'Release ready'.tr,
        readyText: 'Refreshing...'.tr,
        processingText: 'Refreshing...'.tr,
        processedText: 'Succeeded'.tr,
        processedDuration: Duration(milliseconds: 50),
        noMoreText: 'No more'.tr,
        failedText: 'Failed'.tr,
        showText: true,
        messageText: '${'Last updated at'.tr} %T',
        textStyle: context.moonTheme?.tokens.typography.heading.text14.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ),
        messageStyle: context.moonTheme?.tokens.typography.heading.text12.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ));
  }

  static Footer footer(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above}) {
    return ClassicFooter(
        position: position,
        processingText: "Loading".tr,
        failedText: "Failed".tr,
        showMessage: false,
        processedText: "Successed".tr,
        processedDuration: Duration.zero,
        noMoreText: "No more".tr,
        textStyle: context.moonTheme?.tokens.typography.heading.text14.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ),
        messageStyle: context.moonTheme?.tokens.typography.heading.text12.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ));
  }
}
