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

  String get atMost8 {
    if (length > 8) {
      return "${substring(0, 8)}...";
    }
    return this;
  }
}

String get copyInfoText => "${"Illust ID:".i18n} {illust_id}\n${"Title:".i18n} {title}\n${"User ID:".i18n} {user_id}\n${"User Name:".i18n} {user_name}\n${"Tags:".i18n} {tags}";

  String illustToShareInfoText(Illust illust) {
    final str = copyInfoText
        .replaceAll('{illust_id}', illust.id.toString())
        .replaceAll("{user_name}", illust.author.name)
        .replaceAll("{tags}", illust.tags.map((e) => e.toString()).join(', '))
        .replaceAll("{user_id}", illust.author.id.toString())
        .replaceAll("{title}", illust.title);
    return str;
  }
