import 'package:get/get.dart';
import 'package:skana_pix/controller/api_client.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/leaders.dart';

class LikeController extends GetxController {
  RxMap<String, int> illusts = RxMap<String, int>();
  RxMap<String, int> novels = RxMap<String, int>();
  RxMap<String, int> users = RxMap<String, int>();

  Future<void> toggleIllust(String id, int state,
      {bool private = false}) async {
    if (illusts[id] == 1) return;
    state = illusts[id] ?? state;
    illusts[id] = 1;
    var res = await ConnectManager().apiClient.addBookmark(
        id, state == 0 ? "add" : "delete", private ? "private" : "public");
    if (res.success) {
      illusts[id] = state == 0 ? 2 : 0;
    } else {
      Leader.showTextToast("Network Error".tr);
      illusts[id] = state;
    }
  }

  Future<void> toggleNovel(String id, int state, {bool private = false}) async {
    if (novels[id] == 1) return;
    state = novels[id] ?? state;
    novels[id] = 1;
    var res = state == 0
        ? await ConnectManager()
            .apiClient
            .favoriteNovel(id, private ? "private" : "public")
        : await ConnectManager().apiClient.deleteFavoriteNovel(id);
    if (res.success) {
      novels[id] = state == 0 ? 2 : 0;
    } else {
      Leader.showTextToast("Network Error".tr);
      novels[id] = state;
    }
  }

  Future<void> toggleUser(String id, int state, {bool private = false}) async {
    if (users[id] == 1) return;
    state = users[id] ?? state;
    users[id] = 1;
    var res = await ConnectManager().apiClient.follow(
        id, state == 0 ? "add" : "delete", private ? "private" : "public");
    if (res.success) {
      users[id] = state == 0 ? 2 : 0;
    } else {
      Leader.showTextToast("Network Error".tr);
      users[id] = state;
    }
  }

  Future<void> toggle(String id, ArtworkType type, int state,
      {bool private = false}) async {
    if (type == ArtworkType.ILLUST || type == ArtworkType.MANGA) {
      await toggleIllust(id, state, private: private);
    } else if (type == ArtworkType.NOVEL) {
      await toggleNovel(id, state, private: private);
    } else if (type == ArtworkType.USER) {
      await toggleUser(id, state, private: private);
    } else {
      log.e("why is this happening");
    }
  }

  void clear() {
    illusts.clear();
    novels.clear();
  }
}

late LikeController likeController;

late LocalManager localManager;

class LocalManager extends GetxController {
  RxList<String> blockedIllusts = RxList<String>();
  RxList<String> blockedNovels = RxList<String>();
  RxList<String> blockedUsers = RxList<String>();
  RxList<String> blockedTags = RxList<String>();
  RxList<String> blockedCommentUsers = RxList<String>();
  RxList<String> blockedNovelUsers = RxList<String>();
  RxList<String> bookmarkedTags = RxList<String>();
  RxList<String> bookmarkedNovelTags = RxList<String>();
  RxList<String> blockedComments = RxList<String>();
  RxList<String> blockedNovelTags = RxList<String>();
  RxList<String> historyIllustTag = RxList<String>();
  RxList<String> historyNovelTag = RxList<String>();
  RxList<String> historyUserTag = RxList<String>();

  void init() {
    blockedUsers = settings.settings[12].split(';').obs;
    blockedTags = settings.settings[11].split(';').obs;
    blockedCommentUsers = settings.settings[13].split(';').obs;
    blockedNovelUsers = settings.settings[14].split(';').obs;
    bookmarkedTags = settings.settings[22].split(';').obs;
    bookmarkedNovelTags = settings.settings[23].split(';').obs;
    blockedComments = settings.settings[24].split(';').obs;
    blockedNovels = settings.settings[25].split(';').obs;
    blockedNovelTags = settings.settings[26].split(';').obs;
    blockedIllusts = settings.settings[20].split(';').obs;
    historyIllustTag = settings.settings[28].split(';').obs;
    historyNovelTag = settings.settings[29].split(';').obs;
    historyUserTag = settings.settings[30].split(';').obs;
  }

  void add(String param, List<String> value) {
    switch (param) {
      case "blockedUsers":
        settings.addBlockedUsers(value);
        break;
      case "blockedTags":
        settings.addBlockedTags(value);
        break;
      case "blockedCommentUsers":
        settings.addBlockedCommentUsers(value);
        break;
      case "blockedNovelUsers":
        settings.addBlockedNovelUsers(value);
        break;
      case "bookmarkedTags":
        settings.addBookmarkedTags(value);
        break;
      case "blockedComments":
        settings.addBlockedComments(value);
        break;
      case "blockedNovels":
        settings.addBlockedNovels(value);
        break;
      case "blockedNovelTags":
        settings.addBlockedNovelTags(value);
        break;
      case "blockedIllusts":
        settings.addBlockedIllusts(value);
        break;
      case "historyIllustTag":
        settings.addHistoryTag(value.first, ArtworkType.ILLUST);
        break;
      case "historyNovelTag":
        settings.addHistoryTag(value.first, ArtworkType.NOVEL);
        break;
      case "historyUserTag":
        settings.addHistoryTag(value.first, ArtworkType.USER);
        break;
    }
  }

  void delete(String param, List<String> value) {
    switch (param) {
      case "blockedUsers":
        settings.removeBlockedUsers(value);
        break;
      case "blockedTags":
        settings.removeBlockedTags(value);
        break;
      case "blockedCommentUsers":
        settings.removeBlockedCommentUsers(value);
        break;
      case "blockedNovelUsers":
        settings.removeBlockedNovelUsers(value);
        break;
      case "bookmarkedTags":
        settings.removeBookmarkedTags(value);
        break;
      case "blockedComments":
        settings.removeBlockedComments(value);
        break;
      case "blockedNovels":
        settings.removeBlockedNovels(value);
        break;
      case "blockedNovelTags":
        settings.removeBlockedNovelTags(value);
        break;
      case "blockedIllusts":
        settings.removeBlockedIllusts(value);
        break;
      case "historyIllustTag":
        settings.deleteHistoryTag(ArtworkType.ILLUST, value.first);
        break;
      case "historyNovelTag":
        settings.deleteHistoryTag(ArtworkType.NOVEL, value.first);
        break;
      case "historyUserTag":
        settings.deleteHistoryTag(ArtworkType.USER, value.first);
        break;
    }
  }
}

