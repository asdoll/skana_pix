import 'dart:io';

import 'package:skana_pix/pixiv_dart_api.dart';

import 'package:path_provider/path_provider.dart';

class ConnectManager {
  factory ConnectManager() => instance ??= ConnectManager._();

  static ConnectManager? instance;

  ConnectManager._() {
    init();
  }

  var apiClient = ApiClient.empty();

  bool get connectionFailed => apiClient.errorCount > 5;
  bool get notLoggedIn => apiClient.account.accessToken.isEmpty;

  Future<void> init() async {
    Log.dFlag = LogLevel.warning;
    try {
      BasePath.cachePath = (await getApplicationCacheDirectory()).path;
      BasePath.dataPath = (await getApplicationSupportDirectory()).path;
    } on MissingPlatformDirectoryException catch (_, e) {
      loggerError(e.toString());
    }

    try {
      Directory(BasePath.dataPath).createSync();
      Directory(BasePath.cachePath).createSync();
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
