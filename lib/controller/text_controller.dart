import 'package:hive_flutter/hive_flutter.dart';
import 'package:skana_pix/utils/text_composition/text_composition.dart';

class TextConfigManager {
  static final _box = Hive.box("textConfigData");
  static TextCompositionConfig get config =>
      TextCompositionConfig.fromJSON(_box.toMap().cast<String, dynamic>());
  static set config(TextCompositionConfig config) =>
      _box.putAll(config.toJSON());
  static Future<void> init() async {
    await Hive.initFlutter("textConfigData");
    await Hive.openBox("textConfigData");
  }
  static void reset() {
    _box.clear();
  }
}