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
    if (settings.blockedTags.contains("user:${illust.author.id}")) {
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
