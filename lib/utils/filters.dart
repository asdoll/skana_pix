import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';

List<Illust> checkIllusts(List<Illust> illusts) {
  illusts.removeWhere((illust) {
    if (illust.isBlocked) {
      return true;
    }
    if (DynamicData.blockedTags.isEmpty) {
      return false;
    }
    if (DynamicData.blockedTags.contains("user:${illust.author.id}")) {
      return true;
    }
    for (var tag in illust.tags) {
      if ((DynamicData.blockedTags as List).contains(tag.name)) {
        return true;
      }
    }
    return false;
  });
  return illusts;
}