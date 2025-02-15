import 'dart:io';

import 'package:skana_pix/controller/PDio.dart';
import 'package:skana_pix/controller/account_controller.dart';

import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/api_client.dart';
import 'package:skana_pix/controller/bases.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/model/user.dart';
import 'package:skana_pix/utils/io_extension.dart';

typedef UpdateFollowCallback = void Function(bool isFollowed);

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
    try {
      BasePath.cachePath = (await getApplicationCacheDirectory()).path;
      BasePath.dataPath = (await getApplicationSupportDirectory()).path;
    } on MissingPlatformDirectoryException catch (_, e) {
      log.e(e.toString());
    }

    try {
      Directory(BasePath.dataPath).createSync();
      Directory(BasePath.cachePath).createSync();
      if (!File(BasePath.accountJsonPath).existsSync()) {
        log.i('user not logged in.');
      } else {
        var account = await Account.fromPath();
        if (account == null) {
          log.i('user not logged in.');
          return;
        }
        apiClient = ApiClient(account, PDio());
        log.i('user logged in.');
      }
    } catch (e) {
      log.e('init error: $e');
    }
  }

  void logout() {
    apiClient.account = Account.empty();
    apiClient = ApiClient.empty();
    removeUserData();
    accountController.init();
  }

  static void updateFollow(String uid, bool isFollowed,
      Map<String, UpdateFollowCallback> followCallbacks) {
    followCallbacks.forEach((key, value) {
      if (key.startsWith("$uid#")) {
        value(isFollowed);
      }
    });
  }
}