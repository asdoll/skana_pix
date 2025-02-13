import 'package:get/get.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class PrefsController extends GetxController {
  RxString language = settings.locale.obs;
  RxBool langMenu = false.obs;
  RxString awPrefer = settings.awPrefer.obs;
  RxBool awMenu = false.obs;
  RxBool showOriginal = (settings.settings[7] == "1").obs;
  RxBool hideR18 = (settings.settings[15] == "1").obs;
  RxBool hideAI = (settings.settings[16] == "1").obs;
  RxBool feedAIBadge = (settings.settings[17] == "1").obs;
  RxBool longPressSaveConfirm = (settings.settings[18] == "1").obs;
  RxBool novelDirectEntry = (settings.settings[32] == "1").obs;
  RxBool checkUpdate = (settings.settings[9] == "1").obs;
  RxBool isHighRefreshRate = (settings.settings[33] == "1").obs;
  RxString orientation = settings.settings[1].obs;
  RxBool orientationMenu = false.obs;

  void changeLanguage(String? value) {
    if (value != null) {
      language.value = value;
      settings.setLocale(value);
    }
  }

  void changeAwPrefer(String? value) {
    if (value != null) {
      awPrefer.value = value;
      settings.settings[27] = value;
      settings.updateSettings();
    }
  }

  void setShowOriginal(bool v) {
    showOriginal.value = v;
    settings.settings[7] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setHideR18(bool v) {
    hideR18.value = v;
    settings.settings[15] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setHideAI(bool v) {
    hideAI.value = v;
    settings.settings[16] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setAIBadge(bool v) {
    feedAIBadge.value = v;
    settings.settings[17] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setLongPressConfirm(bool v) {
    longPressSaveConfirm.value = v;
    settings.settings[18] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setNovelDirectEntry(bool v) {
    novelDirectEntry.value = v;
    settings.settings[32] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setCheckUpdate(bool v) {
    checkUpdate.value = v;
    settings.settings[9] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setHighRefreshRate(bool v) {
    isHighRefreshRate.value = v;
    settings.settings[33] = v ? "1" : "0";
    settings.updateSettings();
  }

  void setOrientation(String? value) {
    if (value != null) {
      orientation.value = value;
      settings.settings[1] = value;
      settings.updateSettings();
      resetOrientation();
    }
  }
}

class HostController extends GetxController {
  RxInt hostIndex = settings.imageHost.obs;
  RxString customProxyHost = settings.customProxyHost.obs;
  RxBool showMenu = false.obs;

  String getPixreHost() {
    return imageHost[1];
  }

  void setHostIndex(int index) {
    hostIndex.value = index;
    settings.imageHost = index;
  }

  void setCustomProxyHost(String host) {
    customProxyHost.value = host;
    settings.customProxyHost = host;
  }

  void reset() {
    setHostIndex(0);
    setCustomProxyHost(imageHost[0]);
  }
}
