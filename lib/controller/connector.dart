import 'dart:io';

import 'package:skana_pix/pixiv_dart_api.dart';

import 'package:path_provider/path_provider.dart';

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

  static void updateFollow(String uid, bool isFollowed,
      Map<String, UpdateFollowCallback> followCallbacks) {
    followCallbacks.forEach((key, value) {
      if (key.startsWith("$uid#")) {
        value(isFollowed);
      }
    });
  }
}

User get user => ConnectManager().apiClient.account.user;

Function get sendHistory => ConnectManager().apiClient.sendHistory;
Function get getIllustsWithNextUrl => ConnectManager().apiClient.getIllustsWithNextUrl;
Function get getIllustByID => ConnectManager().apiClient.getIllustByID;
Function get getRecommendedIllusts => ConnectManager().apiClient.getRecommendedIllusts;
Function get getBookmarkedIllusts => ConnectManager().apiClient.getBookmarkedIllusts;
Function get getRecommendedMangas => ConnectManager().apiClient.getRecommendedMangas;
Function get getBookmarkedNovels => ConnectManager().apiClient.getBookmarkedNovels;
Function get getRecommendedNovels => ConnectManager().apiClient.getRecommendNovels;
Function get generateWebviewUrl => ConnectManager().apiClient.generateWebviewUrl;
Function get loginWithCode => ConnectManager().apiClient.loginWithCode;
Function get refreshToken => ConnectManager().apiClient.refreshToken;
Function get getUserDetails => ConnectManager().apiClient.getUserDetails;
Function get followUser => ConnectManager().apiClient.follow;
Function get searchUsers => ConnectManager().apiClient.searchUsers;
Function get getFollowing => ConnectManager().apiClient.getFollowing;
Function get getMypixiv => ConnectManager().apiClient.getMypixiv;
Function get getRecommendationUsers => ConnectManager().apiClient.getRecommendationUsers;
Function get getHistory => ConnectManager().apiClient.getHistory;
Function get getMuteList => ConnectManager().apiClient.getMuteList;
Function get editMute => ConnectManager().apiClient.editMute;
Function get relatedUsers => ConnectManager().apiClient.relatedUsers;
Function get batchIllustRequest => ConnectManager().apiClient.batchIllustRequest;
Function get getUserBookmarks => ConnectManager().apiClient.getUserBookmarks;
Function get addBookmark => ConnectManager().apiClient.addBookmark;
Function get getHotTags => ConnectManager().apiClient.getHotTags;
Function get searchIt => ConnectManager().apiClient.search;
Function get getUserIllusts => ConnectManager().apiClient.getUserIllusts;
Function get getFollowingArtworks => ConnectManager().apiClient.getFollowingArtworks;
Function get getRanking => ConnectManager().apiClient.getRanking;
Function get getComments => ConnectManager().apiClient.getComments;
Function get commentIt => ConnectManager().apiClient.comment;
Function get relatedIllusts => ConnectManager().apiClient.relatedIllusts;
Function get getNovelImage => ConnectManager().apiClient.getNovelImage;
Function get getNovelsWithNextUrl => ConnectManager().apiClient.getNovelsWithNextUrl;
Function get searchNovels => ConnectManager().apiClient.searchNovels;
Function get getNovelRanking => ConnectManager().apiClient.getNovelRanking;
Function get favoriteNovel => ConnectManager().apiClient.favoriteNovel;
Function get deleteFavoriteNovel => ConnectManager().apiClient.deleteFavoriteNovel;
Function get getNovelComments => ConnectManager().apiClient.getNovelComments;
Function get getNovelContent => ConnectManager().apiClient.getNovelContent;
Function get relatedNovels => ConnectManager().apiClient.relatedNovels;
Function get getNovelSeries => ConnectManager().apiClient.getNovelSeries;
Function get getUserNovels => ConnectManager().apiClient.getUserNovels;
Function get commentNovel => ConnectManager().apiClient.commentNovel;
Function get getNovelById => ConnectManager().apiClient.getNovelById;
Function get getSpotlightArticles => ConnectManager().apiClient.getSpotlightArticles;
Function get getNextSpotlightArticles => ConnectManager().apiClient.getNextSpotlightArticles;