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

  String get coverImageUrl {
    if (image.medium.isNotEmpty) {
      return image.medium;
    } else if (image.squareMedium.isNotEmpty) {
      return image.squareMedium;
    } else if (image.large.isNotEmpty) {
      return image.large;
    } else {
      return "";
    }
  }

  @override
  String toString() {
    return 'Novel{id: $id, title: $title, caption: $caption, isOriginal: $isOriginal, image: $image, createDate: $createDate, tags: $tags, pages: $pages, length: $length, author: $author, seriesId: $seriesId, seriesTitle: $seriesTitle, isBookmarked: $isBookmarked, totalBookmarks: $totalBookmarks, totalViews: $totalViews, commentsCount: $commentsCount, isAi: $isAi, isMuted: $isMuted, mypixivOnly: $mypixivOnly}';
  }
}

class NovelWebResponse {
  String id;
  String title;
  dynamic seriesId;
  dynamic seriesTitle;
  dynamic seriesIsWatched;
  String userId;
  String coverUrl;
  List<String> tags;
  String caption;
  String cdate;
  String text;
  dynamic marker;
  SeriesNavigation? seriesNavigation;
  List<dynamic>? glossaryItems;
  List<dynamic>? replaceableItemIds;
  Map<String, NovelImage>? images;
  Map<String, NovelIllusts?>? illusts;
  int? aiType;
  bool? isOriginal;
  NovelWebResponse({
    required this.id,
    required this.title,
    required this.seriesId,
    required this.seriesTitle,
    required this.seriesIsWatched,
    required this.userId,
    required this.coverUrl,
    required this.tags,
    required this.caption,
    required this.cdate,
    required this.text,
    required this.marker,
    required this.illusts,
    required this.images,
    required this.seriesNavigation,
    required this.glossaryItems,
    required this.replaceableItemIds,
    required this.aiType,
    required this.isOriginal,
  });

  factory NovelWebResponse.fromJson(Map<String, dynamic> json) =>
      NovelWebResponse(
        id: json['id'] as String,
        title: json['title'] as String,
        seriesId: json['seriesId'],
        seriesTitle: json['seriesTitle'],
        seriesIsWatched: json['seriesIsWatched'],
        userId: json['userId'] as String,
        coverUrl: json['coverUrl'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        caption: json['caption'] as String,
        cdate: json['cdate'] as String,
        text: json['text'] as String,
        marker: json['marker'],
        illusts: (json['illusts'] is Map<String, dynamic>)
            ? (json['illusts'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e == null || (e as Map?)?['illust'] == null)
                        ? null
                        : NovelIllusts.fromJson(e as Map<String, dynamic>)),
              )
            : null,
        images: (json['images'] is Map<String, dynamic>)
            ? (json['images'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, NovelImage.fromJson(e as Map<String, dynamic>)),
              )
            : null,
        seriesNavigation: json['seriesNavigation'] == null
            ? null
            : SeriesNavigation.fromJson(
                json['seriesNavigation'] as Map<String, dynamic>),
        glossaryItems: json['glossaryItems'] as List<dynamic>?,
        replaceableItemIds: json['replaceableItemIds'] as List<dynamic>?,
        aiType: json['aiType'] as int?,
        isOriginal: json['isOriginal'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'seriesId': seriesId,
        'seriesTitle': seriesTitle,
        'seriesIsWatched': seriesIsWatched,
        'userId': userId,
        'coverUrl': coverUrl,
        'tags': tags,
        'caption': caption,
        'cdate': cdate,
        'text': text,
        'marker': marker,
        'seriesNavigation': seriesNavigation,
        'glossaryItems': glossaryItems,
        'replaceableItemIds': replaceableItemIds,
        'images': images,
        'illusts': illusts,
        'aiType': aiType,
        'isOriginal': isOriginal,
      };
}

class NovelIllusts {
  String? small;
  String? medium;
  String? original;

  NovelIllusts({
    required this.small,
    required this.medium,
    required this.original,
  });

  Map<String, dynamic> toJson() => {
        'small': small,
        'medium': medium,
        'original': original,
      };

  factory NovelIllusts.fromJson(Map<String, dynamic> json) => NovelIllusts(
        small: json['small'] as String?,
        medium: json['medium'] as String?,
        original: json['original'] as String?,
      );
}

class NovelImage {
  String? novelImageId;
  String sl;
  NovelUrls urls;

  NovelImage({
    required this.novelImageId,
    required this.sl,
    required this.urls,
  });

  factory NovelImage.fromJson(Map<String, dynamic> json) => NovelImage(
        novelImageId: json['novelImageId'] as String?,
        sl: json['sl'] as String,
        urls: NovelUrls.fromJson(json['urls'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'novelImageId': novelImageId,
        'sl': sl,
        'urls': urls,
      };
}

class NovelUrls {
  String? the240Mw;
  String? the480Mw;
  String? the1200X1200;
  String? the128X128;
  String? original;

  NovelUrls({
    required this.the240Mw,
    required this.the480Mw,
    required this.the1200X1200,
    required this.the128X128,
    required this.original,
  });

  factory NovelUrls.fromJson(Map<String, dynamic> json) => NovelUrls(
        the240Mw: json['the240Mw'] as String?,
        the480Mw: json['the480Mw'] as String?,
        the1200X1200: json['the1200X1200'] as String?,
        the128X128: json['the128X128'] as String?,
        original: json['original'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'the240Mw': the240Mw,
        'the480Mw': the480Mw,
        'the1200X1200': the1200X1200,
        'the128X128': the128X128,
        'original': original,
      };
}

class SeriesNavigation {
  SimpleNovel? nextNovel;
  SimpleNovel? prevNovel;

  SeriesNavigation({
    required this.nextNovel,
    required this.prevNovel,
  });

  factory SeriesNavigation.fromJson(Map<String, dynamic> json) =>
      SeriesNavigation(
        nextNovel: json['nextNovel'] == null
            ? null
            : SimpleNovel.fromJson(json['nextNovel'] as Map<String, dynamic>),
        prevNovel: json['prevNovel'] == null
            ? null
            : SimpleNovel.fromJson(json['prevNovel'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'nextNovel': nextNovel,
        'prevNovel': prevNovel,
      };
}

class SimpleNovel {
  int id;
  bool viewable;
  String contentOrder;
  String title;
  String coverUrl;

  SimpleNovel({
    required this.id,
    required this.viewable,
    required this.contentOrder,
    required this.title,
    required this.coverUrl,
  });

  factory SimpleNovel.fromJson(Map<String, dynamic> json) => SimpleNovel(
        id: (json['id'] as num).toInt(),
        viewable: json['viewable'] as bool,
        contentOrder: json['contentOrder'] as String,
        title: json['title'] as String,
        coverUrl: json['coverUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'viewable': viewable,
        'contentOrder': contentOrder,
        'title': title,
        'coverUrl': coverUrl,
      };
}
