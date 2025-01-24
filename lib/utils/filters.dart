import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

List<Illust> checkIllusts(List<Illust> illusts) {
  illusts.removeWhere((illust) {
    if (localManager.blockedIllusts.contains(illust.title)) {
      return true;
    }
    if (illust.isMuted) {
      return true;
    }
    if (localManager.blockedTags.isEmpty) {
      return false;
    }
    if (localManager.blockedUsers.contains(illust.author.name)) {
      return true;
    }
    for (var tag in illust.tags) {
      if (localManager.blockedTags.contains(tag.name)) {
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
    if (localManager.blockedNovels.contains(novel.title)) {
      return true;
    }
    if (novel.isMuted) {
      return true;
    }
    if (localManager.blockedNovelTags.isEmpty) {
      return false;
    }
    if (localManager.blockedNovelUsers.contains(novel.author.name)) {
      return true;
    }
    for (var tag in novel.tags) {
      if (localManager.blockedNovelTags.contains(tag.name)) {
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
