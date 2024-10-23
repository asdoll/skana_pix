class SpotlightResponse {
  List<SpotlightArticle> spotlightArticles;
  String? nextUrl;

  SpotlightResponse({
    required this.spotlightArticles,
    this.nextUrl,
  });
  factory SpotlightResponse.fromJson(Map<String, dynamic> json) =>
      SpotlightResponse(
        spotlightArticles: (json['spotlight_articles'] as List<dynamic>)
            .map((e) => SpotlightArticle.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextUrl: json['next_url'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'spotlight_articles': spotlightArticles,
        'next_url': nextUrl,
      };
}

class SpotlightArticle {
  int id;
  String title;
  String pureTitle;
  String thumbnail;
  String articleUrl;
  DateTime publishDate;
  // Category? category;
  // @JsonKey(name: 'subcategory_label')
  // SubcategoryLabel? subcategoryLabel;

  SpotlightArticle({
    required this.id,
    required this.title,
    required this.pureTitle,
    required this.thumbnail,
    required this.articleUrl,
    required this.publishDate,
    // this.category,
    // required this.subcategoryLabel,
  });

  factory SpotlightArticle.fromJson(Map<String, dynamic> json) =>
      SpotlightArticle(
        id: (json['id'] as num).toInt(),
        title: json["title"] as String,
        pureTitle: json["pure_title"] as String,
        thumbnail: json["thumbnail"] as String,
        articleUrl: json["article_url"] as String,
        publishDate: DateTime.parse(json["publish_date"]),
        // category: json["category"] == null ? null : Category.fromJson(json["category"]),
        // subcategoryLabel: SubcategoryLabel.fromJson(json["subcategory_label"]),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'pure_title': pureTitle,
        'thumbnail': thumbnail,
        'article_url': articleUrl,
        'publish_date': publishDate.toIso8601String(),
      };
}

class AmWork {
  String? title;
  String? user;
  String? arworkLink;
  String? userLink;
  String? userImage;
  String? showImage;
}
