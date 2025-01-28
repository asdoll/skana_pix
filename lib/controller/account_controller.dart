import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/utils/leaders.dart';

class AccountController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool waitingForAuth = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString userid = "".obs;
  RxBool isPremium = false.obs;
  AccountController() {
    isLoggedIn.value = !ConnectManager().notLoggedIn;
    userid.value = ConnectManager().apiClient.userid;
    isPremium.value = ConnectManager().apiClient.isPremium;
  }

  Future<String> generateWebviewUrl() {
    return ConnectManager().apiClient.generateWebviewUrl();
  }

  void onFinished(String code) async {
    isLoading.value = true;
    waitingForAuth.value = false;
    var res = await ConnectManager().apiClient.loginWithCode(code);
    if (res.error) {
      Leader.showTextToast(res.errorMessage!);
      isLoading.value = false;
    } else {
      isLoggedIn.value = true;
      isPremium.value = ConnectManager().apiClient.isPremium;
      userid.value = ConnectManager().apiClient.userid;
    }
  }

  void logout() {
    ConnectManager().logout();
    init();
  }

  void init() {
    isLoading.value = false;
    waitingForAuth.value = false;
    isLoggedIn.value = !ConnectManager().notLoggedIn;
    userid.value = ConnectManager().apiClient.userid;
    isPremium.value = ConnectManager().apiClient.isPremium;
  }
}

late AccountController accountController;
