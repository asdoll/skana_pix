import 'package:skana_pix/utils/filters.dart';

import 'author.dart' show Author;
import 'tag.dart' show Tag;

class IllustImage {
  final String squareMedium;
  final String medium;
  final String large;
  final String original;

  const IllustImage(this.squareMedium, this.medium, this.large, this.original);
  IllustImage.fromJson(Map<String, dynamic> json)
      : squareMedium = json['square_medium'] ?? "",
        medium = json['medium'] ?? "",
        large = json['large'] ?? "",
        original = json['original'] ?? "";
}

class Illust {
  final int id;
  final String title;
  final String type;
  final List<IllustImage> images;
  final String caption;
  final int restrict;
  final Author author;
  final List<Tag> tags;
  final DateTime createDate;
  final int pageCount;
  final int width;
  final int height;
  final int totalView;
  final int totalBookmarks;
  bool isBookmarked;
  final bool isAi;
  final bool isUgoira;
  final bool isMuted;

  bool get isR18 => tags.contains(const Tag("R-18", null));

  bool get isR18G => tags.contains(const Tag("R-18G", null));

  bool get isBlocked => isMuted || (checkIllusts([this]).isEmpty);

  Illust.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        type = json['type'],
        images = (() {
          List<IllustImage> images = [];
          for (var i in json['meta_pages']) {
            images.add(IllustImage(
                i['image_urls']['square_medium'],
                i['image_urls']['medium'],
                i['image_urls']['large'],
                i['image_urls']['original']));
          }
          if (images.isEmpty) {
            images.add(IllustImage(
                json['image_urls']['square_medium'],
                json['image_urls']['medium'],
                json['image_urls']['large'],
                json['meta_single_page']['original_image_url']));
          }
          return images;
        }()),
        caption = json['caption'],
        restrict = json['restrict'],
        author = Author(
            json['user']['id'],
            json['user']['name'],
            json['user']['account'],
            json['user']['profile_image_urls']['medium'],
            json['user']['is_followed'] ?? false),
        tags = (json['tags'] as List)
            .map((e) => Tag(e['name'], e['translated_name']))
            .toList(),
        createDate = DateTime.parse(json['create_date']),
        pageCount = json['page_count'],
        width = json['width'],
        height = json['height'],
        totalView = json['total_view'],
        totalBookmarks = json['total_bookmarks'],
        isBookmarked = json['is_bookmarked'],
        isAi = json['illust_ai_type'] == 2,
        isUgoira = json['type'] == "ugoira",
        isMuted = json['is_muted'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'images': images.map((e) => {
            'square_medium': e.squareMedium,
            'medium': e.medium,
            'large': e.large,
            'original': e.original
          }),
      'caption': caption,
      'restrict': restrict,
      'author': author.toJson(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'create_date': createDate.toIso8601String(),
      'page_count': pageCount,
      'width': width,
      'height': height,
      'total_view': totalView,
      'total_bookmarks': totalBookmarks,
      'is_bookmarked': isBookmarked,
      'is_ai': isAi,
      'is_ugoira': isUgoira,
      'is_muted': isMuted
    };
  }

  @override
  String toString() {
    return 'Illust{id: $id, title: $title, type: $type, images: $images, caption: $caption, restrict: $restrict, author: $author, tags: $tags, createDate: $createDate, pageCount: $pageCount, width: $width, height: $height, totalView: $totalView, totalBookmarks: $totalBookmarks, isBookmarked: $isBookmarked, isAi: $isAi, isUgoira: $isUgoira, isMuted: $isMuted}';
  }
}