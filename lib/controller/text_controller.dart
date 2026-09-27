import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/utils/text_composition/text_composition.dart';

/// Persists [TextCompositionConfig] in SharedPreferences as a JSON string.
///
/// Replaces the previous hive_flutter box: hive_flutter depends on
/// path_provider and has no HarmonyOS implementation, whereas
/// SharedPreferences is available on every platform this app targets.
class TextConfigManager {
  /// Key holding the JSON encoded [TextCompositionConfig].
  static const String _key = "textConfigData";

  /// In-memory copy so [config] can stay a synchronous getter.
  static TextCompositionConfig _config = TextCompositionConfig();

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) {
        return;
      }
      _config = TextCompositionConfig.fromJSON(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, s) {
      // Fall back to the defaults instead of taking the whole app down.
      log.e("TextConfigManager.init failed: $e", error: "$s");
    }
  }

  static TextCompositionConfig get config => _config;

  static set config(TextCompositionConfig config) {
    _config = config;
    _persist();
  }

  /// Restores the defaults and drops the stored value.
  static void reset() {
    _config = TextCompositionConfig();
    _remove();
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_config.toJSON()));
    } catch (e) {
      log.e("TextConfigManager: failed to save config: $e");
    }
  }

  static Future<void> _remove() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      log.e("TextConfigManager: failed to clear config: $e");
    }
  }
}
