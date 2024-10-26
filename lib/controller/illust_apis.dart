part of 'api_client.dart';

extension IllustExt on ApiClient {
  Future<Res<List<Illust>>> getRecommendedIllusts() async {
    var res = await apiGet(recommendationUrl);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getBookmarkedIllusts(String restrict,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ??
        "$bookmarkIllustUrl?user_id=${account.user.id}&restrict=$restrict");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getUserBookmarks(String uid,
      [String? nextUrl]) async {
    var res = await apiGet(
        nextUrl ?? "$bookmarkIllustUrl?user_id=$uid&restrict=public");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> addBookmark(String id, String method,
      [String type = "public"]) async {
    var res = method == "add"
        ? await apiPost("/v2/illust/bookmark/$method",
            data: {"illust_id": id, "restrict": type})
        : await apiPost("/v1/illust/bookmark/$method", data: {
            "illust_id": id,
          });
    if (!res.error) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<List<TrendingTag>>> getHotTags() async {
    var res = await apiGet(
        "/v1/trending-tags/illust?filter=for_android&include_translated_tag_results=true");
    if (res.error) {
      return Res.fromErrorRes(res);
    } else {
      return Res(List.from(res.data["trend_tags"].map((e) => TrendingTag(
          Tag(e["tag"], e["translated_name"]), Illust.fromJson(e["illust"])))));
    }
  }

  Future<Res<List<Illust>>> search(
      String keyword, SearchOptions options) async {
    String path = "";
    final encodedKeyword = Uri.encodeComponent(keyword +
        options.favoriteNumber.toParam() +
        options.ageLimit.toParam());
    if (options.sort == SearchSort.popular && !options.sort.isPremium) {
      path =
          "/v1/search/popular-preview/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&search_target=${options.matchType.toParam()}";
    } else {
      path =
          "/v1/search/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&sort=${options.sort.toParam()}&search_target=${options.matchType.toParam()}";
    }

    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getIllustsWithNextUrl(String nextUrl) async {
    var res = await apiGet(nextUrl);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getUserIllusts(String uid, String? type) async {
    var res = await apiGet(
        "/v1/user/illusts?filter=for_android&user_id=$uid${type != null ? "&type=$type" : ""}");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getFollowingArtworks(String restrict,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v2/illust/follow?restrict=$restrict");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  String toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  /// mode: day, week, month, day_male, day_female, week_original, week_rookie, day_manga, week_manga, month_manga, day_r18_manga, day_r18, week_r18, week_r18g, week_rookie_manga
  Future<Res<List<Illust>>> getRanking(String mode,
      [String? date, String? nextUrl]) async {
    var link = "/v1/illust/ranking?filter=for_android&mode=$mode";
    if (date != null) {
      link += "&date=$date";
    }
    var res = await apiGet(nextUrl ?? link);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Comment>>> getComments(String id, [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v3/illust/comments?illust_id=$id");
    if (res.success) {
      return Res(
          (res.data["comments"] as List)
              .map((e) => Comment.fromJson(e))
              .toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> comment(String id, String content,
      {String? parentId}) async {
    Map<String, String> data;
    if (parentId != null && parentId.isNotEmpty) {
      data = {
        "illust_id": id,
        "comment": content,
        "parent_comment_id": parentId
      };
    } else {
      data = {"illust_id": id, "comment": content};
    }
    var res = await apiPost("/v1/illust/comment/add", data: data);
    if (res.success) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<Illust>> getIllustByID(String id) async {
    var res = await apiGet("/v1/illust/detail?illust_id=$id");
    if (res.success) {
      return Res(Illust.fromJson(res.data["illust"]));
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getRecommendedMangas() async {
    var res = await apiGet(
        "/v1/manga/recommended?filter=for_android&include_ranking_illusts=true&include_privacy_policy=true");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> relatedIllusts(String id) async {
    var res =
        await apiGet("/v2/illust/related?filter=for_android&illust_id=$id");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<String>> getNovelImage(String novelId, String imageId) async {
    var res = await apiGetPlain(
        "/web/v1/novel/image?novel_id=$novelId&uploaded_image_id=$imageId");
    if (res.success) {
      var html = res.data;
      int start = html.indexOf('<img src="') + 10;
      int end = html.indexOf('"', start);
      return Res(html.substring(start, end));
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<SpotlightResponse> getSpotlightArticles(String category) async {
    var res = await apiGet(
        "/v1/spotlight/articles?filter=for_android?category=$category");
    if (res.success) {
      return SpotlightResponse.fromJson(res.data);
    } else {
      return SpotlightResponse(spotlightArticles: [], nextUrl: "error");
    }
  }

  Future<SpotlightResponse> getNextSpotlightArticles(String nextUrl) async {
    var res = await apiGet(nextUrl);
    if (res.success) {
      return SpotlightResponse.fromJson(res.data);
    } else {
      return SpotlightResponse(spotlightArticles: [], nextUrl: "error");
    }
  }
}
