import 'dart:convert';
import 'dart:ui';

import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/controller/defaults.dart';

import '../utils/text_composition/text_composition.dart';

class UserSetting {
  late SharedPreferences prefs;

  List<String> settings = [
    '0', //0,darkMode 0:system 1:light 2:dark
    '0', //1,isAMOLED 0:false 1:true
    '0', //2,useDynamicColor 0:false 1:true
    'system', //3,language
    '4', //4,maxParallelDownload
    '', //5,downloadPath
    r'/${id}-p${index}.${ext}', //6,downloadSubPath
    '0', //7,showOriginal 0:false 1:true
    '0', //8,showOriginalOnWifi 0:false 1:true
    '1', //9,checkUpdate 0:false 1:true
    '', //10,proxy
    '', //11,blockedTags
    '', //12,blockedUsers
    '', //13,blockedCommentUsers
    '', //14,blockedNovelUsers
    '0', //15,hideR18 0:false 1:true
    '0', //16,hideAI 0:false 1:true
    '1', //17,feedAIBadge 0:false 1:true
    '1', //18,longPressSaveConfirm 0:false 1:true
    '1', //19,firstLongPressSave 0:false 1:true
    '', //20,blockedIllusts
    '0', //21,saveChoice 0:all 1:ToDir 2:ToGallery
    '', //22,bookmarkedTags
    '', //23,bookmarkedNovelTags
    '', //24,blockedComments
    '', //25,blockedNovels
    '', //26,blockedNovelTags
    'illust', //27,awPrefer
    '', //28,historyIllustTag
    '', //29,historyNovelTag
    '', //30,historyUserTag
    'zinc', //31,themeColor
    '0', //32,novelDirectEntry 0:false 1:true
    '1' //33,isHighRefreshRate 0:false 1:true
  ];

  Future<void> updateSettings() async {
    await prefs.setStringList('settings', settings);
  }

  Future<void> readSettings() async {
    List<String> g = prefs.getStringList("settings") ?? [];
    log.t("read settings: $g");
    if (g.isNotEmpty) {
      for (int i = 0; i < g.length && i < settings.length; i++) {
        settings[i] = g[i];
      }
    }
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('settings')) {
      log.w("by right first time run or cache cleared");
      await updateSettings();
      return;
    }
    await readSettings();
  }

  void setDefaults() {
    settings = [
      '0', //0,darkMode 0:system 1:light 2:dark
      '0', //1,isAMOLED 0:false 1:true
      '0', //2,useDynamicColor 0:false 1:true
      'system', //3,language
      '4', //4,maxParallelDownload
      '', //5,downloadPath
      r'/${id}-p${index}.${ext}', //6,downloadSubPath
      '0', //7,showOriginal 0:false 1:true
      '0', //8,showOriginalOnWifi 0:false 1:true
      '1', //9,checkUpdate 0:false 1:true
      '', //10,proxy
      '', //11,blockedTags
      '', //12,blockedUsers
      '', //13,blockedCommentUsers
      '', //14,blockedNovelUsers
      '0', //15,hideR18 0:false 1:true
      '0', //16,hideAI 0:false 1:true
      '1', //17,feedAIBadge 0:false 1:true
      '1', //18,longPressSaveConfirm 0:false 1:true
      '1', //19,firstLongPressSave 0:false 1:true
      '', //20,blockedIllusts
      '0', //21,saveChoice 0:all 1:ToDir 2:ToGallery
      '', //22,bookmarkedTags
      '', //23,bookmarkedNovelTags
      '', //24,blockedComments
      '', //25,blockedNovels
      '', //26,blockedNovelTags
      'illust', //27,awPrefer
      '', //28,historyIllustTag
      '', //29,historyNovelTag
      '', //30,historyUserTag
      '0xFF536DFE', //31,seedColor
      '0', //32,novelDirectEntry 0:false 1:true
      '1' //33,isHighRefreshRate 0:false 1:true
    ];
    updateSettings();
  }

  void clearSettings() {
    prefs.clear();
    setDefaults();
  }

  String get locale => getLocale();

  Locale localeObj() {
    List<String> loc = getLocale().split('_');
    if (loc.length != 2) {
      return Locale('en', 'US');
    }
    return Locale(loc[0], loc[1]);
  }

  void setHighRefreshRate(bool enabled) {
    settings[33] = enabled ? '1' : '0';
    updateSettings();
    if (DynamicData.isAndroid) {
      if (enabled) {
        FlutterDisplayMode.setHighRefreshRate();
      } else {
        FlutterDisplayMode.setLowRefreshRate();
      }
    }
  }

  String getLocale() {
    if (settings[3] == 'system') {
      var locale = PlatformDispatcher.instance.locale;
      if (locale.languageCode == 'und' || locale.languageCode.isEmpty) {
        return 'en_US';
      }
      if (locale.countryCode == null || locale.countryCode!.isEmpty) {
        if (locale.languageCode == 'zh') {
          return 'zh_CN';
        }
        return 'en_US';
      }
      return "${locale.languageCode}_${locale.countryCode}";
    }
    return settings[3];
  }

  void setLocale(Locale? loc) {
    if (loc == null) {
      settings[3] = 'system';
      return;
    }
    if (loc.languageCode == 'und' || loc.languageCode.isEmpty) {
      settings[3] = 'en_US';
    }
    if (loc.countryCode == null || loc.countryCode!.isEmpty) {
      if (loc.languageCode == 'zh') {
        settings[3] = 'zh_CN';
      }
      settings[3] = 'en_US';
    }
    settings[3] = "${loc.languageCode}_${loc.countryCode}";
  }

  String get awPrefer => settings[27];
  bool get isHighRefreshRate => settings[33] == '1';
  bool get showOriginal => settings[7] == '1';
  bool get showOriginalOnWifi => settings[8] == '1';
  bool get checkUpdate => settings[9] == '1';
  bool get novelDirectEntry => settings[32] == '1';
  bool get isDarkMode =>
      settings[0] == '2' ||
      settings[0] == '0' &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
  bool get isAMOLED => settings[1] == '1';
  bool get useDynamicColor => settings[2] == '1';
  bool get longPressSaveConfirm => settings[18] == '1';
  bool get firstLongPressSave => settings[19] == '1';
  bool get hideR18 => settings[15] == '1';
  bool get hideAI => settings[16] == '1';
  bool get feedAIBadge => settings[17] == '1';
  String get downloadPath => settings[5];
  String get downloadSubPath => settings[6];
  String get proxy => settings[10];
  String get saveChoice => settings[21];
  String get themeName => settings[31];
  String get darkMode => settings[0];

  void addBlockedTags(List<String> tags) {
    for (var tag in tags) {
      if (!localManager.blockedTags.contains(tag)) {
        localManager.blockedTags.add(tag);
        localManager.blockedTags.refresh();
      }
    }
    settings[11] = localManager.blockedTags.join(';');
    updateSettings();
  }

  void addBookmarkedTags(List<String> tags) {
    for (var tag in tags) {
      if (!localManager.bookmarkedTags.contains(tag)) {
        localManager.bookmarkedTags.add(tag);
        localManager.bookmarkedTags.refresh();
      }
    }
    settings[22] = localManager.bookmarkedTags.join(';');
    updateSettings();
  }

  void addBlockedUsers(List<String> users) {
    for (var user in users) {
      if (!localManager.blockedUsers.contains(user)) {
        localManager.blockedUsers.add(user);
        localManager.blockedUsers.refresh();
      }
    }
    settings[12] = localManager.blockedUsers.join(';');
    updateSettings();
  }

  void addBlockedCommentUsers(List<String> users) {
    for (var user in users) {
      if (!localManager.blockedCommentUsers.contains(user)) {
        localManager.blockedCommentUsers.add(user);
        localManager.blockedCommentUsers.refresh();
      }
    }
    settings[13] = localManager.blockedCommentUsers.join(';');
    updateSettings();
  }

  void addBlockedNovelUsers(List<String> users) {
    for (var user in users) {
      if (!localManager.blockedNovelUsers.contains(user)) {
        localManager.blockedNovelUsers.add(user);
        localManager.blockedNovelUsers.refresh();
      }
    }
    settings[14] = localManager.blockedNovelUsers.join(';');
    updateSettings();
  }

  void addBlockedComments(List<String> comments) {
    for (var comment in comments) {
      if (!localManager.blockedComments.contains(comment)) {
        localManager.blockedComments.add(comment);
        localManager.blockedComments.refresh();
      }
    }
    settings[24] = localManager.blockedComments.join(';');
    updateSettings();
  }

  void addBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      if (!localManager.blockedIllusts.contains(illust)) {
        localManager.blockedIllusts.add(illust);
        localManager.blockedIllusts.refresh();
      }
    }
    settings[20] = localManager.blockedIllusts.join(';');
    updateSettings();
  }

  void addBlockedNovels(List<String> novels) {
    for (var novel in novels) {
      if (!localManager.blockedNovels.contains(novel)) {
        localManager.blockedNovels.add(novel);
        localManager.blockedNovels.refresh();
      }
    }
    settings[25] = localManager.blockedNovels.join(';');
    updateSettings();
  }

  void addBlockedNovelTags(List<String> tags) {
    for (var tag in tags) {
      if (!localManager.blockedNovelTags.contains(tag)) {
        localManager.blockedNovelTags.add(tag);
        localManager.blockedNovelTags.refresh();
      }
    }
    settings[26] = localManager.blockedNovelTags.join(';');
    updateSettings();
  }

  void addBookmarkedNovelTags(List<String> tags) {
    for (var tag in tags) {
      if (!localManager.bookmarkedNovelTags.contains(tag)) {
        localManager.bookmarkedNovelTags.add(tag);
        localManager.bookmarkedNovelTags.refresh();
      }
    }
    settings[23] = localManager.bookmarkedNovelTags.join(';');
    updateSettings();
  }

  void clearBlockedTags() {
    localManager.blockedTags.clear();
    localManager.blockedTags.refresh();
    settings[11] = '';
    updateSettings();
  }

  void clearBlockedUsers() {
    localManager.blockedUsers.clear();
    localManager.blockedUsers.refresh();
    settings[12] = '';
    updateSettings();
  }

  void clearBlockedCommentUsers() {
    localManager.blockedCommentUsers.clear();
    settings[13] = '';
    updateSettings();
  }

  void clearBlockedNovelUsers() {
    localManager.blockedNovelUsers.clear();
    localManager.blockedNovelUsers.refresh();
    settings[14] = '';
    updateSettings();
  }

  void clearBlockedIllusts() {
    localManager.blockedIllusts.clear();
    localManager.blockedIllusts.refresh();
    settings[20] = '';
    updateSettings();
  }

  void clearBlockedComments() {
    localManager.blockedComments.clear();
    localManager.blockedComments.refresh();
    settings[24] = '';
    updateSettings();
  }

  void clearBookmarkedTags() {
    localManager.bookmarkedTags.clear();
    localManager.bookmarkedTags.refresh();
    settings[22] = '';
    updateSettings();
  }

  void clearBlockedNovels() {
    localManager.blockedNovels.clear();
    localManager.blockedNovels.refresh();
    settings[25] = '';
    updateSettings();
  }

  void clearBlockedNovelTags() {
    localManager.blockedNovelTags.clear();
    localManager.blockedNovelTags.refresh();
    settings[26] = '';
    updateSettings();
  }

  void clearBookmarkedNovelTags() {
    localManager.bookmarkedNovelTags.clear();
    localManager.bookmarkedNovelTags.refresh();
    settings[23] = '';
    updateSettings();
  }

  void removeBlockedTags(List<String> tags) {
    for (var tag in tags) {
      localManager.blockedTags.remove(tag);
      localManager.blockedTags.refresh();
    }
    settings[11] = localManager.blockedTags.join(';');
    updateSettings();
  }

  void removeBookmarkedTags(List<String> tags) {
    for (var tag in tags) {
      localManager.bookmarkedTags.remove(tag);
      localManager.bookmarkedTags.refresh();
    }
    settings[22] = localManager.bookmarkedTags.join(';');
    updateSettings();
  }

  void removeBlockedUsers(List<String> users) {
    for (var user in users) {
      localManager.blockedUsers.remove(user);
      localManager.blockedUsers.refresh();
    }
    settings[12] = localManager.blockedUsers.join(';');
    updateSettings();
  }

  void removeBlockedCommentUsers(List<String> users) {
    for (var user in users) {
      localManager.blockedCommentUsers.remove(user);
      localManager.blockedCommentUsers.refresh();
    }
    settings[13] = localManager.blockedCommentUsers.join(';');
    updateSettings();
  }

  void removeBlockedNovelUsers(List<String> users) {
    for (var user in users) {
      localManager.blockedNovelUsers.remove(user);
      localManager.blockedNovelUsers.refresh();
    }
    settings[14] = localManager.blockedNovelUsers.join(';');
    updateSettings();
  }

  void removeBlockedComments(List<String> comments) {
    for (var comment in comments) {
      localManager.blockedComments.remove(comment);
      localManager.blockedComments.refresh();
    }
    settings[24] = localManager.blockedComments.join(';');
    updateSettings();
  }

  void removeBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      localManager.blockedIllusts.remove(illust);
      localManager.blockedIllusts.refresh();
    }
    settings[20] = localManager.blockedIllusts.join(';');
    updateSettings();
  }

  void removeBlockedNovels(List<String> novels) {
    for (var novel in novels) {
      localManager.blockedNovels.remove(novel);
      localManager.blockedNovels.refresh();
    }
    settings[25] = localManager.blockedNovels.join(';');
    updateSettings();
  }

  void removeBlockedNovelTags(List<String> tags) {
    for (var tag in tags) {
      localManager.blockedNovelTags.remove(tag);
      localManager.blockedNovelTags.refresh();
    }
    settings[26] = localManager.blockedNovelTags.join(';');
    updateSettings();
  }

  void removeBookmarkedNovelTags(List<String> tags) {
    for (var tag in tags) {
      localManager.bookmarkedNovelTags.remove(tag);
      localManager.bookmarkedNovelTags.refresh();
    }
    settings[23] = localManager.bookmarkedNovelTags.join(';');
    updateSettings();
  }

  void addHistoryTag(String id, ArtworkType type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        if (localManager.historyIllustTag.contains(id)) {
          localManager.historyIllustTag.remove(id);
        }
        if (localManager.historyIllustTag.length > 40) {
          localManager.historyIllustTag.removeAt(0);
        }
        localManager.historyIllustTag.add(id);
        settings[28] = localManager.historyIllustTag.join(';');
        localManager.historyIllustTag.refresh();
        updateSettings();
        break;
      case ArtworkType.NOVEL:
        if (localManager.historyNovelTag.contains(id)) {
          localManager.historyNovelTag.remove(id);
        }
        if (localManager.historyNovelTag.length > 40) {
          localManager.historyNovelTag.removeAt(0);
        }
        localManager.historyNovelTag.add(id);
        settings[29] = localManager.historyNovelTag.join(';');
        localManager.historyNovelTag.refresh();
        updateSettings();
        break;
      case ArtworkType.ALL:
        if (localManager.historyIllustTag.contains(id)) {
          localManager.historyIllustTag.remove(id);
        }
        if (localManager.historyIllustTag.length > 40) {
          localManager.historyIllustTag.removeAt(0);
        }
        localManager.historyIllustTag.add(id);
        settings[28] = localManager.historyIllustTag.join(';');
        localManager.historyIllustTag.refresh();
        updateSettings();
        if (localManager.historyNovelTag.contains(id)) {
          localManager.historyNovelTag.remove(id);
        }
        if (localManager.historyNovelTag.length > 40) {
          localManager.historyNovelTag.removeAt(0);
        }
        localManager.historyNovelTag.add(id);
        settings[29] = localManager.historyNovelTag.join(';');
        localManager.historyNovelTag.refresh();
        updateSettings();
      case ArtworkType.USER:
        if (localManager.historyUserTag.contains(id)) {
          localManager.historyUserTag.remove(id);
        }
        if (localManager.historyUserTag.length > 40) {
          localManager.historyUserTag.removeAt(0);
        }
        localManager.historyUserTag.add(id);
        settings[30] = localManager.historyUserTag.join(';');
        localManager.historyUserTag.refresh();
        updateSettings();
        break;
    }
  }

  void deleteHistoryTag(ArtworkType type, String tag) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        localManager.historyIllustTag.remove(tag);
        localManager.historyIllustTag.refresh();
        settings[28] = localManager.historyIllustTag.join(';');
        updateSettings();
        break;
      case ArtworkType.NOVEL:
        localManager.historyNovelTag.remove(tag);
        localManager.historyNovelTag.refresh();
        settings[29] = localManager.historyNovelTag.join(';');
        updateSettings();
        break;
      case ArtworkType.ALL:
        localManager.historyIllustTag.remove(tag);
        localManager.historyIllustTag.refresh();
        settings[28] = localManager.historyIllustTag.join(';');
        updateSettings();
        localManager.historyNovelTag.remove(tag);
        localManager.historyNovelTag.refresh();
        settings[29] = localManager.historyNovelTag.join(';');
        updateSettings();
      case ArtworkType.USER:
        localManager.historyUserTag.remove(tag);
        localManager.historyUserTag.refresh();
        settings[30] = localManager.historyUserTag.join(';');
        updateSettings();
        break;
    }
  }

  void clearHistoryTag(ArtworkType type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        localManager.historyIllustTag.clear();
        localManager.historyIllustTag.refresh();
        settings[28] = localManager.historyIllustTag.join(';');
        updateSettings();
        break;
      case ArtworkType.NOVEL:
        localManager.historyNovelTag.clear();
        localManager.historyNovelTag.refresh();
        settings[29] = localManager.historyNovelTag.join(';');
        updateSettings();
        break;
      case ArtworkType.ALL:
        localManager.historyIllustTag.clear();
        localManager.historyIllustTag.refresh();
        settings[28] = localManager.historyIllustTag.join(';');
        updateSettings();
        localManager.historyNovelTag.clear();
        localManager.historyNovelTag.refresh();
        settings[29] = localManager.historyNovelTag.join(';');
        updateSettings();
      case ArtworkType.USER:
        localManager.historyUserTag.clear();
        localManager.historyUserTag.refresh();
        settings[30] = localManager.historyUserTag.join(';');
        updateSettings();
        break;
    }
  }

  List<String> getHistoryTag(ArtworkType type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        return localManager.historyIllustTag;
      case ArtworkType.NOVEL:
        return localManager.historyNovelTag;
      case ArtworkType.ALL:
        return localManager.historyIllustTag +
            localManager.historyNovelTag +
            localManager.historyUserTag;
      case ArtworkType.USER:
        return localManager.historyUserTag;
    }
  }

  void setFromMap(Map<String, dynamic> map) {
    for (var i = 0; i < settings.length; i++) {
      if (map.containsKey(i.toString())) {
        settings[i] = map[i.toString()];
      }
    }
    updateSettings();
  }

  String toJson() {
    return jsonEncode(settings);
  }

  void set(String key, dynamic value) {
    // settings[int.parse(key)] = value;
    // updateSettings();
  }
}

var settings = UserSetting();

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
}
