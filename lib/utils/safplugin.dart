import 'package:flutter/services.dart';
import 'package:skana_pix/controller/logging.dart';

class SAFPlugin {
  static const platform = MethodChannel('com.skanaone.dev/saf');

  /// Asks the platform for a destination and returns its uri, or null when the
  /// user cancels / the platform refuses.
  static Future<String?> createFile(String name, String type) async {
    try {
      final result = await platform
          .invokeMethod("createFile", {'name': name, 'mimeType': type});
      if (result is String && result.isNotEmpty) {
        return result;
      }
    } catch (e, s) {
      log.e("createFile failed: $e", error: "$s");
    }
    return null;
  }

  static Future<void> writeUri(String uri, Uint8List data) async {
    try {
      await platform.invokeMethod("writeUri", {'uri': uri, 'data': data});
    } catch (e, s) {
      log.e("writeUri failed: $e", error: "$s");
    }
  }

  static Future<Uint8List?> openFile() async {
    try {
      return await platform
          .invokeMethod<Uint8List>("openFile", {'type': "application/json"});
    } catch (e, s) {
      log.e("openFile failed: $e", error: "$s");
      return null;
    }
  }
}
