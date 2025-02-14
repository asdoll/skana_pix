import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DefaultHeaderFooter {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return BezierHeader(
      position: position,
      triggerOffset: 50,
      safeArea: safeArea,
      processedDuration: Duration(milliseconds: 50),
      backgroundColor: context.moonTheme?.tokens.colors.trunks,
      spinWidget: SpinKitPulse(
        color: context.moonTheme?.tokens.colors.bulma,
      ),
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
        processedDuration: Duration.zero,
        noMoreText: "No more".tr,
        textStyle: context.moonTheme?.tokens.typography.heading.text14.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ),
        messageStyle: context.moonTheme?.tokens.typography.heading.text12.apply(
          color: context.moonTheme?.tokens.colors.bulma,
        ));
  }

  static Header refreshHeader(BuildContext context) {
    return BuilderHeader(
      triggerOffset: 70,
      clamping: true,
      position: IndicatorPosition.above,
      processedDuration: Duration.zero,
      builder: (ctx, state) {
        if (state.mode == IndicatorMode.inactive ||
            state.mode == IndicatorMode.done) {
          return const SizedBox();
        }
        return Container(
          padding: const EdgeInsets.only(bottom: 100),
          width: double.infinity,
          height: state.viewportDimension,
          alignment: Alignment.center,
          child: SpinKitPulse(
            size: 40,
            color: context.moonTheme?.tokens.colors.bulma,
          ),
        );
      },
    );
  }
}
