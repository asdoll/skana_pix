import '../utils/parser.dart';

import 'author.dart' show Author;
import 'illust.dart';
import 'tag.dart';

class Novel {
  final int id;
  final String title;
  final String caption;
  final bool isOriginal;
  final IllustImage image;
  final DateTime createDate;
  final List<Tag> tags;
  final int pages;
  final int length;
  final Author author;
  final int? seriesId;
  final String? seriesTitle;
  bool isBookmarked;
  final int totalBookmarks;
  final int totalViews;
  final int commentsCount;
  final bool isAi;
  final bool isMuted;
  final bool mypixivOnly;

  Novel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        caption = json["caption"],
        isOriginal = json["is_original"],
        image = IllustImage.fromJson(json["image_urls"]),
        createDate = DateTime.parse(json["create_date"]),
        tags = (json['tags'] as List)
            .map((e) => Tag(e['name'], e['translated_name']))
            .toList(),
        pages = json["page_count"],
        length = json["text_length"],
        author = Author(
            json['user']['id'],
            json['user']['name'],
            json['user']['account'],
            json['user']['profile_image_urls']['medium'],
            json['user']['is_followed'] ?? false),
        seriesId = json["series"]?["id"],
        seriesTitle = json["series"]?["title"],
        isBookmarked = json["is_bookmarked"],
        totalBookmarks = json["total_bookmarks"],
        totalViews = json["total_view"],
        commentsCount = json["total_comments"],
        isAi = json["novel_ai_type"] == 2,
        isMuted = json["is_muted"],
        mypixivOnly = json["is_mypixiv_only"];
  
  String get coverImageUrl{
    if(image.medium.isNotEmpty){
      return image.medium;
    }else if(image.squareMedium.isNotEmpty){
      return image.squareMedium;
    }else if(image.large.isNotEmpty){
      return image.large;
    }else {
      return "";
    }
  }

  @override
  String toString() {
    return 'Novel{id: $id, title: $title, caption: $caption, isOriginal: $isOriginal, image: $image, createDate: $createDate, tags: $tags, pages: $pages, length: $length, author: $author, seriesId: $seriesId, seriesTitle: $seriesTitle, isBookmarked: $isBookmarked, totalBookmarks: $totalBookmarks, totalViews: $totalViews, commentsCount: $commentsCount, isAi: $isAi, isMuted: $isMuted, mypixivOnly: $mypixivOnly}';
  }
}

class NovelContent {
  final Novel novel;
  final String text;
  final List<String> images;

  NovelContent.fromJson(this.text, Novel info)
      : novel = info,
        images = Parser.parseImgsInNovel(text);
}
