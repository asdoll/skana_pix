import 'package:skana_pix/pixiv_dart_api.dart';

List<Illust> checkIllusts(List<Illust> illusts) {
  illusts.removeWhere((illust) {
    if (settings.blockedIllusts.contains(illust.title)) {
      return true;
    }
    if (illust.isMuted) {
      return true;
    }
    if (settings.blockedTags.isEmpty) {
      return false;
    }
    if (settings.blockedUsers.contains(illust.author.name)) {
      return true;
    }
    for (var tag in illust.tags) {
      if ((settings.blockedTags as List).contains(tag.name)) {
        return true;
      }
    }
    if (illust.isAi && settings.hideAI) {
      return true;
    }
    return false;
  });
  return illusts;
}

List<Novel> checkNovels(List<Novel> novels) {
  novels.removeWhere((novel) {
    if (settings.blockedNovels.contains(novel.title)) {
      return true;
    }
    if (novel.isMuted) {
      return true;
    }
    if (settings.blockedNovelTags.isEmpty) {
      return false;
    }
    if (settings.blockedNovelUsers.contains(novel.author.name)) {
      return true;
    }
    for (var tag in novel.tags) {
      if ((settings.blockedNovelTags as List).contains(tag.name)) {
        return true;
      }
    }
    if (novel.isAi && settings.hideAI) {
      return true;
    }
    return false;
  });
  return novels;
}
