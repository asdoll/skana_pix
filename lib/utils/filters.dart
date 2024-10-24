import 'package:skana_pix/pixiv_dart_api.dart';

List<Illust> checkIllusts(List<Illust> illusts) {
  illusts.removeWhere((illust) {
    if (settings.blockedIllusts.contains(illust.id.toString())) {
      return true;
    }
    if (illust.isMuted) {
      return true;
    }
    if (settings.blockedTags.isEmpty) {
      return false;
    }
    if (settings.blockedUsers.contains(illust.author.id.toString())) {
      return true;
    }
    for (var tag in illust.tags) {
      if ((settings.blockedTags as List).contains(tag.name)) {
        return true;
      }
    }
    return false;
  });
  return illusts;
}
List<Novel> checkNovels(List<Novel> novels) {
  novels.removeWhere((novel) {
    if (settings.blockedNovels.contains(novel.id.toString())) {
      return true;
    }
    if (novel.isMuted) {
      return true;
    }
    if (settings.blockedNovelTags.isEmpty) {
      return false;
    }
    if (settings.blockedNovelUsers.contains(novel.author.id.toString())) {
      return true;
    }
    for (var tag in novel.tags) {
      if ((settings.blockedNovelTags as List).contains(tag.name)) {
        return true;
      }
    }
    return false;
  });
  return novels;
}
