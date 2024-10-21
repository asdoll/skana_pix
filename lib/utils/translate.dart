import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class TranslateMap {
  static late final Map<String, Map<String, dynamic>> translation;

  static bool loaded = false;

  static Future<void> init() async {
    var data = await rootBundle.loadString("assets/i18n/i18n.json");
    translation = Map<String, Map<String, dynamic>>.from(jsonDecode(data));
    if (translation.isNotEmpty) {
      loaded = true;
    }
  }
}

extension Translation on String {
  String get i18n {
    if (!TranslateMap.loaded) {
      TranslateMap.init();
    }
    return TranslateMap
                  .translation[settings.locale]
              ?[this] ?? this;

  }
}
