import 'dart:convert';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';

import '../utils/text_composition/text_composition.dart';

class UserSetting {
  late SharedPreferences prefs;

  String darkMode = 'system';
  bool isAMOLED = false;
  bool useDynamicColor = false;
  String language = 'system';
  int maxParallelDownload = 4;
  String downloadPath = '';
  String downloadSubPath = r'/${id}-p${index}.${ext}';
  bool showOriginal = false;
  bool showOriginalOnWifi = false;
  bool checkUpdate = true;
  String proxy = '';
  List<String> blockedTags = [];
  List<String> blockedUsers = [];
  List<String> blockedCommentUsers = [];
  List<String> blockedNovelUsers = [];
  bool hideR18 = false;
  bool hideAI = false;
  bool feedAIBadge = true;
  bool longPressSaveConfirm = true;
  bool firstLongPressSave = true;
  List<String> blockedIllusts = [];
  int saveChoice = 0; //0:all 1:ToDir 2:ToGallery
  List<String> bookmarkedTags = [];
  List<String> bookmarkedNovelTags = [];
  List<String> blockedComments = [];
  List<String> blockedNovels = [];
  List<String> blockedNovelTags = [];
  String awPrefer = 'illust';
  List<String> historyIllustTag = [];
  List<String> historyNovelTag = [];
  List<String> historyUserTag = [];
  int seedColor = 0xFF536DFE;
  bool novelDirectEntry = false;
  bool isHighRefreshRate = true;

  Future<void> saveDefaults() async {
    await prefs.setString('darkMode', darkMode);
    await prefs.setBool('isAMOLED', isAMOLED);
    await prefs.setBool('useDynamicColor', useDynamicColor);
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
    await prefs.setStringList('blockedCommentUsers', blockedCommentUsers);
    await prefs.setStringList('blockedNovelUsers', blockedNovelUsers);
    await prefs.setBool('hideR18', hideR18);
    await prefs.setBool('hideAI', hideAI);
    await prefs.setBool('feedAIBadge', feedAIBadge);
    await prefs.setBool('longPressSaveConfirm', longPressSaveConfirm);
    await prefs.setBool('firstLongPressSave', firstLongPressSave);
    await prefs.setStringList('blockedIllusts', blockedIllusts);
    await prefs.setInt('saveChoice', saveChoice);
    await prefs.setStringList('bookmarkedTags', bookmarkedTags);
    await prefs.setStringList('blockedComments', blockedComments);
    await prefs.setStringList('blockedNovels', blockedNovels);
    await prefs.setStringList('blockedNovelTags', blockedNovelTags);
    await prefs.setString('awPrefer', awPrefer);
    await prefs.setStringList('historyIllustTag', historyIllustTag);
    await prefs.setStringList('historyNovelTag', historyNovelTag);
    await prefs.setStringList('historyUserTag', historyUserTag);
    await prefs.setStringList('bookmarkedNovelTags', bookmarkedNovelTags);
    await prefs.setInt('seedColor', seedColor);
    await prefs.setBool('novelDirectEntry', novelDirectEntry);
    await prefs.setBool('isHighRefreshRate', isHighRefreshRate);
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('darkMode')) {
      logger("by right first time run or cache cleared");
      await saveDefaults();
      return;
    }
    darkMode = prefs.getString('darkMode') ?? 'system';
    isAMOLED = prefs.getBool('isAMOLED') ?? false;
    useDynamicColor = prefs.getBool('useDynamicColor') ?? false;
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
    blockedCommentUsers = prefs.getStringList('blockedCommentUsers') ?? [];
    blockedNovelUsers = prefs.getStringList('blockedNovelUsers') ?? [];
    hideR18 = prefs.getBool('hideR18') ?? false;
    hideAI = prefs.getBool('hideAI') ?? false;
    feedAIBadge = prefs.getBool('feedAIBadge') ?? true;
    longPressSaveConfirm = prefs.getBool('longPressSaveConfirm') ?? true;
    firstLongPressSave = prefs.getBool('firstLongPressSave') ?? true;
    blockedIllusts = prefs.getStringList('blockedIllusts') ?? [];
    saveChoice = prefs.getInt('saveChoice') ?? 0;
    bookmarkedTags = prefs.getStringList('bookmarkedTags') ?? [];
    blockedComments = prefs.getStringList('blockedComments') ?? [];
    blockedNovels = prefs.getStringList('blockedNovels') ?? [];
    blockedNovelTags = prefs.getStringList('blockedNovelTags') ?? [];
    awPrefer = prefs.getString('awPrefer') ?? 'illust';
    historyIllustTag = prefs.getStringList('historyIllustTag') ?? [];
    historyNovelTag = prefs.getStringList('historyNovelTag') ?? [];
    historyUserTag = prefs.getStringList('historyUserTag') ?? [];
    bookmarkedNovelTags = prefs.getStringList('bookmarkedNovelTags') ?? [];
    seedColor = prefs.getInt('seedColor') ?? 0xFF536DFE;
    novelDirectEntry = prefs.getBool('novelDirectEntry') ?? false;
    isHighRefreshRate = prefs.getBool('isHighRefreshRate') ?? true;
  }

  void setDefaults() {
    darkMode = 'system';
    isAMOLED = false;
    useDynamicColor = false;
    language = 'system';
    maxParallelDownload = 4;
    downloadPath = '';
    downloadSubPath = r'/${id}-p${index}.${ext}';
    showOriginal = false;
    showOriginalOnWifi = false;
    checkUpdate = true;
    proxy = '';
    blockedTags = [];
    blockedUsers = [];
    blockedCommentUsers = [];
    blockedNovelUsers = [];
    hideR18 = false;
    hideAI = false;
    feedAIBadge = true;
    longPressSaveConfirm = true;
    firstLongPressSave = true;
    blockedIllusts = [];
    saveChoice = 0;
    bookmarkedTags = [];
    blockedComments = [];
    blockedNovels = [];
    blockedNovelTags = [];
    awPrefer = 'illust';
    historyIllustTag = [];
    historyNovelTag = [];
    historyUserTag = [];
    bookmarkedNovelTags = [];
    seedColor = 0xFF536DFE;
    novelDirectEntry = false;
    isHighRefreshRate = true;
    saveDefaults();
  }

  void set(String key, dynamic value) {
    switch (key) {
      case 'darkMode':
        darkMode = value;
        prefs.setString('darkMode', darkMode);
        ThemeStuff.instance.updateValue(DynamicData.themeWarp);
        break;
      case 'isAMOLED':
        isAMOLED = value;
        prefs.setBool('isAMOLED', isAMOLED);
        ThemeStuff.instance.updateValue(DynamicData.themeWarp);
        break;
      case 'useDynamicColor':
        useDynamicColor = value;
        prefs.setBool('useDynamicColor', useDynamicColor);
        ThemeStuff.instance.updateValue(DynamicData.themeWarp);
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
      case 'blockedCommentUsers':
        blockedCommentUsers = value;
        prefs.setStringList('blockedCommentUsers', blockedCommentUsers);
        break;
      case 'blockedNovelUsers':
        blockedNovelUsers = value;
        prefs.setStringList('blockedNovelUsers', blockedNovelUsers);
        break;
      case 'hideR18':
        hideR18 = value;
        prefs.setBool('hideR18', hideR18);
        break;
      case 'hideAI':
        hideAI = value;
        prefs.setBool('hideAI', hideAI);
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
      case 'blockedComments':
        blockedComments = value;
        prefs.setStringList('blockedComments', blockedComments);
        break;
      case 'blockedNovels':
        blockedNovels = value;
        prefs.setStringList('blockedNovels', blockedNovels);
        break;
      case 'blockedNovelTags':
        blockedNovelTags = value;
        prefs.setStringList('blockedNovelTags', blockedNovelTags);
        break;
      case 'awPrefer':
        awPrefer = value;
        prefs.setString('awPrefer', awPrefer);
        break;
      case 'historyIllustTag':
        historyIllustTag = value;
        prefs.setStringList('historyIllustTag', historyIllustTag);
        break;
      case 'historyNovelTag':
        historyNovelTag = value;
        prefs.setStringList('historyNovelTag', historyNovelTag);
        break;
      case 'historyUserTag':
        historyUserTag = value;
        prefs.setStringList('historyUserTag', historyUserTag);
        break;
      case 'bookmarkedNovelTags':
        bookmarkedNovelTags = value;
        prefs.setStringList('bookmarkedNovelTags', bookmarkedNovelTags);
        break;
      case 'seedColor':
        seedColor = value;
        prefs.setInt('seedColor', seedColor);
        ThemeStuff.instance.updateValue(DynamicData.themeWarp);
        break;
      case 'novelDirectEntry':
        novelDirectEntry = value;
        prefs.setBool('novelDirectEntry', novelDirectEntry);
        break;
      case 'isHighRefreshRate':
        isHighRefreshRate = value;
        prefs.setBool('isHighRefreshRate', isHighRefreshRate);
    }
  }

  String toJson() {
    return jsonEncode(getMap());
  }

  Map<String, dynamic> getMap() {
    return {
      'darkMode': darkMode,
      'isAMOLED': isAMOLED,
      'useDynamicColor': useDynamicColor,
      'language': language,
      'maxParallelDownload': maxParallelDownload,
      'downloadPath': downloadPath,
      'downloadSubPath': downloadSubPath,
      'showOriginal': showOriginal,
      'showOriginalOnWifi': showOriginalOnWifi,
      'checkUpdate': checkUpdate,
      'proxy': proxy,
      'blockedTags': blockedTags,
      'blockedUsers': blockedUsers,
      'blockedCommentUsers': blockedCommentUsers,
      'blockedNovelUsers': blockedNovelUsers,
      'hideR18': hideR18,
      'hideAI': hideAI,
      'feedAIBadge': feedAIBadge,
      'longPressSaveConfirm': longPressSaveConfirm,
      'firstLongPressSave': firstLongPressSave,
      'blockedIllusts': blockedIllusts,
      'saveChoice': saveChoice,
      'bookmarkedTags': bookmarkedTags,
      'blockedComments': blockedComments,
      'blockedNovels': blockedNovels,
      'blockedNovelTags': blockedNovelTags,
      'awPrefer': awPrefer,
      'historyIllustTag': historyIllustTag,
      'historyNovelTag': historyNovelTag,
      'historyUserTag': historyUserTag,
      'bookmarkedNovelTags': bookmarkedNovelTags,
      'seedColor': seedColor,
      'novelDirectEntry': novelDirectEntry,
      'isHighRefreshRate': isHighRefreshRate,
    };
  }

  void setFromMap(Map<String, dynamic> map) {
    darkMode = map['darkMode'] ?? 'system';
    isAMOLED = map['isAMOLED'] ?? false;
    useDynamicColor = map['useDynamicColor'] ?? false;
    language = map['language'] ?? 'system';
    maxParallelDownload = map['maxParallelDownload'] ?? 4;
    downloadPath = map['downloadPath'] ?? '';
    downloadSubPath = map['downloadSubPath'] ?? r'/${id}-p${index}.${ext}';
    showOriginal = map['showOriginal'] ?? false;
    showOriginalOnWifi = map['showOriginalOnWifi'] ?? false;
    checkUpdate = map['checkUpdate'] ?? true;
    proxy = map['proxy'] ?? '';
    blockedTags = List<String>.from(map['blockedTags']);
    blockedUsers = List<String>.from(map['blockedUsers']);
    blockedCommentUsers = List<String>.from(map['blockedCommentUsers']);
    blockedNovelUsers = List<String>.from(map['blockedNovelUsers']);
    hideR18 = map['hideR18'] ?? false;
    hideAI = map['hideAI'] ?? false;
    feedAIBadge = map['feedAIBadge'] ?? true;
    longPressSaveConfirm = map['longPressSaveConfirm'] ?? true;
    firstLongPressSave = map['firstLongPressSave'] ?? true;
    blockedIllusts = List<String>.from(map['blockedIllusts']);
    saveChoice = map['saveChoice'] ?? 0;
    bookmarkedTags = List<String>.from(map['bookmarkedTags']);
    blockedComments = List<String>.from(map['blockedComments']);
    blockedNovels = List<String>.from(map['blockedNovels']);
    blockedNovelTags = List<String>.from(map['blockedNovelTags']);
    awPrefer = map['awPrefer'] ?? 'illust';
    historyIllustTag = List<String>.from(map['historyIllustTag']);
    historyNovelTag = List<String>.from(map['historyNovelTag']);
    historyUserTag = List<String>.from(map['historyUserTag']);
    bookmarkedNovelTags = List<String>.from(map['bookmarkedNovelTags']);
    seedColor = map['seedColor'] ?? 0xFF536DFE;
    novelDirectEntry = map['novelDirectEntry'] ?? false;
    isHighRefreshRate = map['isHighRefreshRate'] ?? true;
    saveDefaults();
    BotToast.showText(text: "Imported".i18n);
  }

  void clearSettings() {
    prefs.clear();
    setDefaults();
  }

  ThemeMode get themeMode {
    switch (darkMode) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(int i) {
    switch (i) {
      case 0:
        set('darkMode', 'system');
        break;
      case 1:
        set('darkMode', 'light');
        break;
      case 2:
        set('darkMode', 'dark');
        break;
    }
  }

  String get locale => getLocale();

  Locale LocaleObj() {
    List<String> loc = getLocale().split('_');
    if (loc.length != 2) {
      return Locale('en', 'US');
    }
    return Locale(loc[0], loc[1]);
  }

  void setHighRefreshRate(bool enabled) {
    set('isHighRefreshRate', enabled);
    if(DynamicData.isAndroid) {
      if(enabled){
        FlutterDisplayMode.setHighRefreshRate();
      } else {
        FlutterDisplayMode.setLowRefreshRate();
      }
    }
  }

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

  void addBlockedCommentUsers(List<String> users) {
    for (var user in users) {
      if (!blockedCommentUsers.contains(user)) {
        blockedCommentUsers.add(user);
      }
    }
    set('blockedCommentUsers', blockedCommentUsers);
  }

  void addBlockedNovelUsers(List<String> users) {
    for (var user in users) {
      if (!blockedNovelUsers.contains(user)) {
        blockedNovelUsers.add(user);
      }
    }
    set('blockedNovelUsers', blockedNovelUsers);
  }

  void addBlockedComments(List<String> comments) {
    for (var comment in comments) {
      if (!blockedComments.contains(comment)) {
        blockedComments.add(comment);
      }
    }
    set('blockedComments', blockedComments);
  }

  void addBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      if (!blockedIllusts.contains(illust)) {
        blockedIllusts.add(illust);
      }
    }
    set('blockedIllusts', blockedIllusts);
  }

  void addBlockedNovels(List<String> novels) {
    for (var novel in novels) {
      if (!blockedNovels.contains(novel)) {
        blockedNovels.add(novel);
      }
    }
    set('blockedNovels', blockedNovels);
  }

  void addBlockedNovelTags(List<String> tags) {
    for (var tag in tags) {
      if (!blockedNovelTags.contains(tag)) {
        blockedNovelTags.add(tag);
      }
    }
    set('blockedNovelTags', blockedNovelTags);
  }

  void addBookmarkedNovelTags(List<String> tags) {
    for (var tag in tags) {
      if (!bookmarkedNovelTags.contains(tag)) {
        bookmarkedNovelTags.add(tag);
      }
    }
    set('bookmarkedNovelTags', bookmarkedNovelTags);
  }

  void clearBlockedTags() {
    blockedTags.clear();
    set('blockedTags', blockedTags);
  }

  void clearBlockedUsers() {
    blockedUsers.clear();
    set('blockedUsers', blockedUsers);
  }

  void clearBlockedCommentUsers() {
    blockedCommentUsers.clear();
    set('blockedCommentUsers', blockedCommentUsers);
  }

  void clearBlockedNovelUsers() {
    blockedNovelUsers.clear();
    set('blockedNovelUsers', blockedNovelUsers);
  }

  void clearBlockedIllusts() {
    blockedIllusts.clear();
    set('blockedIllusts', blockedIllusts);
  }

  void clearBlockedComments() {
    blockedComments.clear();
    set('blockedComments', blockedComments);
  }

  void clearBookmarkedTags() {
    bookmarkedTags.clear();
    set('bookmarkedTags', bookmarkedTags);
  }

  void clearBlockedNovels() {
    blockedNovels.clear();
    set('blockedNovels', blockedNovels);
  }

  void clearBlockedNovelTags() {
    blockedNovelTags.clear();
    set('blockedNovelTags', blockedNovelTags);
  }

  void clearBookmarkedNovelTags() {
    bookmarkedNovelTags.clear();
    set('bookmarkedNovelTags', bookmarkedNovelTags);
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

  void removeBlockedCommentUsers(List<String> users) {
    for (var user in users) {
      blockedCommentUsers.remove(user);
    }
    set('blockedCommentUsers', blockedCommentUsers);
  }

  void removeBlockedNovelUsers(List<String> users) {
    for (var user in users) {
      blockedNovelUsers.remove(user);
    }
    set('blockedNovelUsers', blockedNovelUsers);
  }

  void removeBlockedComments(List<String> comments) {
    for (var comment in comments) {
      blockedComments.remove(comment);
    }
    set('blockedComments', blockedComments);
  }

  void removeBlockedIllusts(List<String> illusts) {
    for (var illust in illusts) {
      blockedIllusts.remove(illust);
    }
    set('blockedIllusts', blockedIllusts);
  }

  void removeBlockedNovels(List<String> novels) {
    for (var novel in novels) {
      blockedNovels.remove(novel);
    }
    set('blockedNovels', blockedNovels);
  }

  void removeBlockedNovelTags(List<String> tags) {
    for (var tag in tags) {
      blockedNovelTags.remove(tag);
    }
    set('blockedNovelTags', blockedNovelTags);
  }

  void removeBookmarkedNovelTags(List<String> tags) {
    for (var tag in tags) {
      bookmarkedNovelTags.remove(tag);
    }
    set('bookmarkedNovelTags', bookmarkedNovelTags);
  }

  void addHistoryTag(String id, ArtworkType? type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        if (historyIllustTag.contains(id)) {
          historyIllustTag.remove(id);
        }
        if (historyIllustTag.length > 40) {
          historyIllustTag.removeAt(0);
        }
        historyIllustTag.add(id);
        set('historyIllustTag', historyIllustTag);
        break;
      case ArtworkType.NOVEL:
        if (historyNovelTag.contains(id)) {
          historyNovelTag.remove(id);
        }
        if (historyNovelTag.length > 40) {
          historyNovelTag.removeAt(0);
        }
        historyNovelTag.add(id);
        set('historyNovelTag', historyNovelTag);
        break;
      case ArtworkType.ALL:
        if (historyIllustTag.contains(id)) {
          historyIllustTag.remove(id);
        }
        if (historyIllustTag.length > 40) {
          historyIllustTag.removeAt(0);
        }
        historyIllustTag.add(id);
        set('historyIllustTag', historyIllustTag);
        if (historyNovelTag.contains(id)) {
          historyNovelTag.remove(id);
        }
        if (historyNovelTag.length > 40) {
          historyNovelTag.removeAt(0);
        }
        historyNovelTag.add(id);
        set('historyNovelTag', historyNovelTag);
      case null:
        if (historyUserTag.contains(id)) {
          historyUserTag.remove(id);
        }
        if (historyUserTag.length > 40) {
          historyUserTag.removeAt(0);
        }
        historyUserTag.add(id);
        set('historyUserTag', historyUserTag);
        break;
    }
  }

  void deleteHistoryTag(ArtworkType? type, String tag) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        historyIllustTag.remove(tag);
        set('historyIllustTag', historyIllustTag);
        break;
      case ArtworkType.NOVEL:
        historyNovelTag.remove(tag);
        set('historyNovelTag', historyNovelTag);
        break;
      case ArtworkType.ALL:
        historyIllustTag.remove(tag);
        set('historyIllustTag', historyIllustTag);
        historyNovelTag.remove(tag);
        set('historyNovelTag', historyNovelTag);
        break;
      case null:
        historyUserTag.remove(tag);
        set('historyUserTag', historyUserTag);
        break;
    }
  }

  void clearHistoryTag(ArtworkType? type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        historyIllustTag.clear();
        set('historyIllustTag', historyIllustTag);
        break;
      case ArtworkType.NOVEL:
        historyNovelTag.clear();
        set('historyNovelTag', historyNovelTag);
        break;
      case ArtworkType.ALL:
        historyIllustTag.clear();
        set('historyIllustTag', historyIllustTag);
        historyNovelTag.clear();
        set('historyNovelTag', historyNovelTag);
        break;
      case null:
        historyUserTag.clear();
        set('historyUserTag', historyUserTag);
        break;
    }
  }

  List<String> getHistoryTag(ArtworkType? type) {
    switch (type) {
      case ArtworkType.ILLUST:
      case ArtworkType.MANGA:
        return historyIllustTag;
      case ArtworkType.NOVEL:
        return historyNovelTag;
      case ArtworkType.ALL:
        return historyIllustTag + historyNovelTag;
      case null:
        return historyUserTag;
    }
  }
}

var settings = UserSetting();

class TextConfigManager {
  static final _box = Hive.box("textConfigData");
  static TextCompositionConfig get config => TextCompositionConfig.fromJSON(_box.toMap().cast<String, dynamic>());
  static set config(TextCompositionConfig config) => _box.putAll(config.toJSON());
  static Future<void> init() async{
    await Hive.initFlutter("textConfigData");
    await Hive.openBox("textConfigData");
  }
}
