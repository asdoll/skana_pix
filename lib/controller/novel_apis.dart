part of "api_client.dart";

extension NovelExt on ApiClient {
  Future<Res<List<Novel>>> getRecommendNovels() {
    return getNovelsWithNextUrl("/v1/novel/recommended");
  }

  Future<Res<List<Novel>>> getNovelsWithNextUrl(String nextUrl) async {
    var res = await apiGet(nextUrl);
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(
        (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList(),
        subData: res.data["next_url"]);
  }

  Future<Res<List<Novel>>> searchNovels(String keyword, SearchOptions options) {
    var url = "/v1/search/novel?"
        "include_translated_tag_results=true&"
        "merge_plain_keyword_results=true&"
        "word=${Uri.encodeComponent(keyword)}&"
        "sort=${options.sort.toParam()}&"
        "search_target=${options.matchType.toParam()}&"
        "search_ai_type=0";
    return getNovelsWithNextUrl(url);
  }

  /// mode: day, day_male, day_female, week_rookie, week, week_ai
  Future<Res<List<Novel>>> getNovelRanking(String mode, [DateTime? date]) {
    var url = "/v1/novel/ranking?mode=$mode";
    if (date != null) {
      url += "&date=${date.year}-${date.month}-${date.day}";
    }
    return getNovelsWithNextUrl(url);
  }

  Future<Res<List<Novel>>> getBookmarkedNovels(String uid) {
    return getNovelsWithNextUrl(
        "/v1/user/bookmarks/novel?user_id=$uid&restrict=public");
  }

  Future<Res<bool>> favoriteNovel(String id,
      [String restrict = "public"]) async {
    var res = await apiPost("/v2/novel/bookmark/add", data: {
      "novel_id": id,
      "restrict": restrict,
    });
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return const Res(true);
  }

  Future<Res<bool>> deleteFavoriteNovel(String id) async {
    var res = await apiPost("/v1/novel/bookmark/delete", data: {
      "novel_id": id,
    });
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return const Res(true);
  }

  String? _parseHtml(String html) {
    var document = parse(html);
    final scriptElement = document.querySelector('script')!;
    String scriptContent = scriptElement.innerHtml;
    final novelRegex = RegExp(r'novel: ({.*?}),\n\s*isOwnWork');
    final match = novelRegex.firstMatch(scriptContent);
    if (match != null) {
      final novelJsonString = match.group(1);
      return novelJsonString;
    }
    return null;
  }

  Future<Res<NovelWebResponse>> getNovelContent(String id) async {
    var res = await apiGetPlain("/webview/v2/novel?id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    try {
      String json = _parseHtml(res.data)!;
      NovelWebResponse novelTextResponse =
          NovelWebResponse.fromJson(jsonDecode(json));
      return Res(novelTextResponse);
    } catch (e, s) {
      Log.error(
          "Data Convert", "Failed to analyze html novel content: \n$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<List<Novel>>> relatedNovels(String id) async {
    var res = await apiPost("/v1/novel/related", data: {
      "novel_id": id,
    });
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(
        (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList());
  }

  Future<Res<List<Novel>>> getUserNovels(String uid) {
    return getNovelsWithNextUrl("/v1/user/novels?user_id=$uid");
  }

  Future<Res<List<Novel>>> getNovelSeries(String id, [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v2/novel/series?series_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(
        (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList(),
        subData: res.data["next_url"]);
  }

  Future<Res<List<Comment>>> getNovelComments(String id,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v3/novel/comments?novel_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(
        (res.data["comments"] as List).map((e) => Comment.fromJson(e)).toList(),
        subData: res.data["next_url"]);
  }

  Future<Res<bool>> commentNovel(String id, String comment,
      {String? parentId}) async {
    Map<String, String> data;
    if (parentId != null && parentId.isNotEmpty) {
      data = {
        "novel_id": id,
        "comment": comment,
        "parent_comment_id": parentId
      };
    } else {
      data = {"novel_id": id, "comment": comment};
    }
    var res = await apiPost("/v1/novel/comment/add", data: data);
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return const Res(true);
  }

  Future<Res<Novel>> getNovelById(String id) async {
    var res = await apiGet("/v2/novel/detail?novel_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    // Savers.writeText('${BasePath.downloadNovelPath}test.log',
    //     Novel.fromJson(res.data["novel"]).toString());
    return Res(Novel.fromJson(res.data["novel"]));
  }
}
