import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class UserSetting {
  String darkMode = 'system';
  String language = 'system';
  int maxParallelDownload = 4;
  String downloadPath = '';
  String downloadSubPath = r'/${id}-p${index}.${ext}';
  bool showOriginal = false;
  bool showOriginalOnWifi = false;
  bool checkUpdate = true;
  String proxy = '';
  late SharedPreferences prefs;
  List<String> blockedTags = [];
  List<String> blockedUsers = [];
  bool hideR18 = false;
  bool feedAIBadge = true;
  bool longPressSaveConfirm = true;
  bool firstLongPressSave = true;
  List<String> blockedIllusts = [];
  int saveChoice = 0;//0:all 1:ToDir 2:ToGallery
  List<String> bookmarkedTags = [];

  Future<void> saveDefaults() async {
    await prefs.setString('darkMode', darkMode);
    await prefs.setString('language', language);
    await prefs.setInt('maxParallelDownload', maxParallelDownload);
    await prefs.setString('downloadPath', downloadPath);
    await prefs.setString('downloadSubPath', downloadSubPath);
    await prefs.setBool('showOriginal', showOriginal);
    await prefs.setBool('showOriginalOnWifi', showOriginalOnWifi);
    await prefs.setBool('checkUpdate', checkUpdate);
    await prefs.setString('proxy', proxy);
    await prefs.setStringList('blockedTags', blockedTags);
    await prefs.setStringList('blockedUsers', blockedUsers);
    await prefs.setBool('hideR18', hideR18);
    await prefs.setBool('feedAIBadge', feedAIBadge);
    await prefs.setBool('longPressSaveConfirm', longPressSaveConfirm);
    await prefs.setBool('firstLongPressSave', firstLongPressSave);
    await prefs.setStringList('blockedIllusts', blockedIllusts);
    await prefs.setInt('saveChoice', saveChoice);
    await prefs.setStringList('bookmarkedTags', bookmarkedTags);
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('darkMode')) {
      logger("by right first time run or cache cleared");
      await saveDefaults();
      return;
    }
    darkMode = prefs.getString('darkMode') ?? 'system';
    language = prefs.getString('language') ?? 'system';
    maxParallelDownload = prefs.getInt('maxParallelDownload') ?? 4;
    downloadPath = prefs.getString('downloadPath') ?? '';
    downloadSubPath =
        prefs.getString('downloadSubPath') ?? r'/${id}-p${index}.${ext}';
    showOriginal = prefs.getBool('showOriginal') ?? false;
    showOriginalOnWifi = prefs.getBool('showOriginalOnWifi') ?? false;
    checkUpdate = prefs.getBool('checkUpdate') ?? true;
    proxy = prefs.getString('proxy') ?? '';
    blockedTags = prefs.getStringList('blockedTags') ?? [];
    blockedUsers = prefs.getStringList('blockedUsers') ?? [];
    hideR18 = prefs.getBool('hideR18') ?? false;
    feedAIBadge = prefs.getBool('feedAIBadge') ?? true;
    longPressSaveConfirm = prefs.getBool('longPressSaveConfirm') ?? true;
    firstLongPressSave = prefs.getBool('firstLongPressSave') ?? true;
    blockedIllusts = prefs.getStringList('blockedIllusts') ?? [];
    saveChoice = prefs.getInt('saveChoice') ?? 0;
    bookmarkedTags = prefs.getStringList('bookmarkedTags') ?? [];
  }

  void set(String key, dynamic value) {
    switch (key) {
      case 'darkMode':
        darkMode = value;
        prefs.setString('darkMode', darkMode);
        break;
      case 'language':
        language = value;
        prefs.setString('language', language);
        break;
      case 'maxParallelDownload':
        maxParallelDownload = value;
        prefs.setInt('maxParallelDownload', maxParallelDownload);
        break;
      case 'downloadPath':
        downloadPath = value;
        prefs.setString('downloadPath', downloadPath);
        break;
      case 'downloadSubPath':
        downloadSubPath = value;
        prefs.setString('downloadSubPath', downloadSubPath);
        break;
      case 'showOriginal':
        showOriginal = value;
        prefs.setBool('showOriginal', showOriginal);
        break;
      case 'showOriginalOnWifi':
        showOriginalOnWifi = value;
        prefs.setBool('showOriginalOnWifi', showOriginalOnWifi);
        break;
      case 'checkUpdate':
        checkUpdate = value;
        prefs.setBool('checkUpdate', checkUpdate);
        break;
      case 'proxy':
        proxy = value;
        prefs.setString('proxy', proxy);
        break;
      case 'blockedTags':
        blockedTags = value;
        prefs.setStringList('blockedTags', blockedTags);
        break;
      case 'blockedUsers':
        blockedUsers = value;
        prefs.setStringList('blockedUsers', blockedUsers);
        break;
      case 'hideR18':
        hideR18 = value;
        prefs.setBool('hideR18', hideR18);
        break;
      case 'feedAIBadge':
        feedAIBadge = value;
        prefs.setBool('feedAIBadge', feedAIBadge);
        break;
      case 'longPressSaveConfirm':
        longPressSaveConfirm = value;
        prefs.setBool('longPressSaveConfirm', longPressSaveConfirm);
        break;
      case 'firstLongPressSave':
        firstLongPressSave = value;
        prefs.setBool('firstLongPressSave', firstLongPressSave);
        break;
      case 'blockedIllusts':
        blockedIllusts = value;
        prefs.setStringList('blockedIllusts', blockedIllusts);
        break;
      case 'saveChoice':
        saveChoice = value;
        prefs.setInt('saveChoice', saveChoice);
        break;
      case 'bookmarkedTags':
        bookmarkedTags = value;
        prefs.setStringList('bookmarkedTags', bookmarkedTags);
        break;
    }
  }

  String get locale => getLocale();

  String getLocale() {
    if (language == 'system') {
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
    return language;
  }

  void setLocale(Locale? loc) {
    if (loc == null) {
      set('language', 'system');
      return;
    }
    if (loc.languageCode == 'und' || loc.languageCode.isEmpty) {
      set('language', 'en_US');
    }
    if (loc.countryCode == null || loc.countryCode!.isEmpty) {
      if (loc.languageCode == 'zh') {
        set('language', 'zh_CN');
      }
      set('language', 'en_US');
    }
    set('language', "${loc.languageCode}_${loc.countryCode}");
  }

  void addBlockedTags(List<String> tags) {
    for (var tag in tags) {
      if (!blockedTags.contains(tag)) {
        blockedTags.add(tag);
      }
    }
    set('blockedTags', blockedTags);
  }

  void addBookmarkedTags(List<String> tags) {
    for (var tag in tags) {
      if (!bookmarkedTags.contains(tag)) {
        bookmarkedTags.add(tag);
      }
    }
    set('bookmarkedTags', bookmarkedTags);
  }
  void addBlockedUsers(List<String> users) {
    for (var user in users) {
      if (!blockedUsers.contains(user)) {
        blockedUsers.add(user);
      }
    }
    set('blockedUsers', blockedUsers);
  }

  void addBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      if (!blockedIllusts.contains(illust)) {
        blockedIllusts.add(illust);
      }
    }
    set('blockedIllusts', blockedIllusts);
  }

  void clearBlockedTags() {
    blockedTags.clear();
    set('blockedTags', blockedTags);
  }

  void clearBlockedUsers() {
    blockedUsers.clear();
    set('blockedUsers', blockedUsers);
  }

  void clearBlockedIllusts() {
    blockedIllusts.clear();
    set('blockedIllusts', blockedIllusts);
  }

  void clearBookmarkedTags() {
    bookmarkedTags.clear();
    set('bookmarkedTags', bookmarkedTags);
  }

  void removeBlockedTags(List<String> tags) {
    for (var tag in tags) {
      blockedTags.remove(tag);
    }
    set('blockedTags', blockedTags);
  }

  void removeBookmarkedTags(List<String> tags) {
    for (var tag in tags) {
      bookmarkedTags.remove(tag);
    }
    set('bookmarkedTags', bookmarkedTags);
  }

  void removeBlockedUsers(List<String> users) {
    for (var user in users) {
      blockedUsers.remove(user);
    }
    set('blockedUsers', blockedUsers);
  }

  void removeBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      blockedIllusts.remove(illust);
    }
    set('blockedIllusts', blockedIllusts);
  }
}

var settings = UserSetting();
