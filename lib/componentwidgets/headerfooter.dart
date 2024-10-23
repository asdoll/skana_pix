import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/utils/translate.dart';

class DefaultHeaderFooter {
  static Header header(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above,
      bool safeArea = true}) {
    return MaterialHeader(
        position: position,
        safeArea: safeArea,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }

  static Footer footer(BuildContext context,
      {IndicatorPosition position = IndicatorPosition.above}) {
    return ClassicFooter(
        position: position,
        processingText: "Loading".i18n,
        failedText: "Failed".i18n,
        showMessage: false,
        processedText: "Successed".i18n);
  }
}