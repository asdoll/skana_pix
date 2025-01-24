import 'dart:convert';
import 'dart:io';

import '../controller/bases.dart';
import '../controller/logging.dart';

import '../model/user.dart' show Account;

class Savers {
  static void createPathIfNotExists(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  static Future<bool> writeAccountJson(Account account) async {
    try {
      final encoder = JsonEncoder.withIndent(' ' * 4);
      final file = File(BasePath.accountJsonPath);
      await file.writeAsString(encoder.convert(account.toJson()));
      return true;
    } on FileSystemException catch (e) {
      log.e("Error writing account json: $e");
      return false;
    }
  }

  static Future<bool> writeText(String path, String text) async {
    try {
      final file = File(path);
      await file.writeAsString(text);
      return true;
    } on FileSystemException catch (e) {
      log.e("Error writing text: $e");
      return false;
    }
  }
}
