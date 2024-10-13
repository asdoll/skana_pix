import 'author.dart' show Author;
import 'tag.dart';

class MuteList {
  List<Tag> tags;

  List<Author> authors;

  int limit;

  MuteList(this.tags, this.authors, this.limit);

  static MuteList? fromJson(Map<String, dynamic> data) {
    return MuteList(
        (data['muted_tags'] as List)
            .map((e) => Tag(e['tag'], e['tag_translation']))
            .toList(),
        (data['muted_users'] as List)
            .map((e) => Author(e['user_id'], e['user_name'], e['user_account'],
                e['user_profile_image_urls']['medium'], false))
            .toList(),
        data['mute_limit_count']);
  }
}