import 'dart:io';

import 'package:skana_pix/pixiv_dart_api.dart';

class ConnectManager {
  factory ConnectManager() => instance ??= ConnectManager._();

  static ConnectManager? instance;

  ConnectManager._() {
    init();
  }

  var apiClient = ApiClient.empty();

  bool get connectionFailed => apiClient.errorCount > 5;

  Future<void> init() async {
    BasePath.dataPath = 'data/';
    Log.dFlag = LogLevel.warning;
    try {
      Directory(BasePath.dataPath).createSync();
      if (!File(BasePath.accountJsonPath).existsSync()) {
        logger('user not logged in.');
      } else {
        var account = await Account.fromPath();
        if (account == null) {
          logger('user not logged in.');
          return;
        }
        apiClient = ApiClient(account, PDio());
        logger('user logged in.');
      }
    } catch (e) {
      loggerError('init error: $e');
    }
  }

}
