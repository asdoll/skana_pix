import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import '../controller/exceptions.dart';
import '../controller/logging.dart';
import '../model/user.dart';

import '../model/author.dart';
import '../model/comment.dart';
import '../model/illust.dart';
import '../model/mutelist.dart';
import '../model/novel.dart';
import '../model/searches.dart';
import '../model/tag.dart';
import '../model/spotlight.dart';
import 'PDio.dart';
import 'bases.dart';
import 'res.dart';
import 'saves.dart';
import 'settings.dart';

part 'novel_apis.dart';
part 'illust_apis.dart';

class ApiClient extends BaseClient {
  Account account;
  PDio pDio;

  ApiClient(this.account, this.pDio);

  ApiClient.empty()
      : account = Account.empty(),
        pDio = PDio();

  String? codeVerifier;

  String get userid => account.user.id;

  String get accessToken => account.accessToken;

  bool get isPremium => account.user.isPremium;

  int errorCount = 0;

  Map<String, String> get headers {
    final time =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
    final hash =
        md5.convert(utf8.encode(time + BaseClient.hashSalt)).toString();
    if (settings.getLocale().contains("zh")) {
      if (settings.getLocale().contains("TW")) {
        return {
          "X-Client-Time": time,
          "X-Client-Hash": hash,
          "User-Agent": "PixivAndroidApp/5.0.234 (Android 14.0; Pixes)",
          "accept-language": "zh-TW",
          "Accept-Encoding": "gzip",
          if (account.accessToken.isNotEmpty)
            "Authorization": "Bearer $accessToken"
        };
      }
      return {
        "X-Client-Time": time,
        "X-Client-Hash": hash,
        "User-Agent": "PixivAndroidApp/5.0.234 (Android 14.0; Pixes)",
        "accept-language": "zh-TW",
        "Accept-Encoding": "gzip",
        if (account.accessToken.isNotEmpty)
          "Authorization": "Bearer $accessToken"
      };
    }
    return {
      "X-Client-Time": time,
      "X-Client-Hash": hash,
      "User-Agent": "PixivAndroidApp/5.0.234 (Android 14.0; Pixes)",
      "accept-language": "en-US",
      "Accept-Encoding": "gzip",
      if (account.accessToken.isNotEmpty) "Authorization": "Bearer $accessToken"
    };
  }

  Future<String> generateWebviewUrl() async {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    codeVerifier =
        List.generate(128, (i) => chars[Random.secure().nextInt(chars.length)])
            .join();
    final codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier!)).bytes)
        .replaceAll('=', '');
    return codeChallengeUrl(codeChallenge);
  }

  Future<Res<bool>> loginWithCode(String code) async {
    try {
      if (codeVerifier == null) {
        throw "Code verifier is null! You must generate a webview url first";
      }
      var res = await pDio.post<String>(oauthUrlToken,
          data: {
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "code_verifier": codeVerifier,
            "grant_type": "authorization_code",
            "include_policy": "true",
            "redirect_uri": authCallbackUrl,
          },
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: headers));
      if (res.statusCode != 200) {
        errorCount++;
        throw "Invalid Status code ${res.statusCode}";
      }
      final data = json.decode(res.data!);
      account = Account.fromJson(data);
      Savers.writeAccountJson(account);
      errorCount = 0;
      return const Res(true);
    } catch (e, s) {
      log.e("$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<bool>> refreshToken() async {
    try {
      var res = await pDio.post<String>(oauthUrlToken,
          data: {
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": account.refreshToken,
            "include_policy": "true",
          },
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              validateStatus: (i) => true,
              headers: headers));
      if (res.statusCode != 200) {
        var data = res.data ?? "";
        if (data.contains("Invalid refresh token")) {
          errorCount++;
          throw "Failed to refresh token.";
        }
      }
      var newAccount = Account.fromJson(json.decode(res.data!));
      account = newAccount;
      Savers.writeAccountJson(account);
      errorCount = 0;
      return const Res(true);
    } catch (e, s) {
      log.e("$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<Map<String, dynamic>>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    try {
      if (!path.startsWith("http")) {
        path = "$baseUrl$path";
      }
      final res = await pDio.get<Map<String, dynamic>>(path,
          queryParameters: query,
          options: Options(headers: headers, validateStatus: (status) => true));
      if (res.statusCode == 200) {
        errorCount = 0;
        return Res(res.data!);
      } else if (res.statusCode == 400) {
        if (res.data.toString().contains("Access Token")) {
          var refresh = await refreshToken();
          if (refresh.success) {
            return apiGet(path, query: query);
          } else {
            return Res.error(refresh.errorMessage);
          }
        } else {
          return Res.error("Invalid Status Code: ${res.statusCode}");
        }
      } else if ((res.statusCode ?? 500) < 500) {
        return Res.error(res.data?["error"]?["message"] ??
            "Invalid Status code ${res.statusCode}");
      } else {
        return Res.error("Invalid Status Code: ${res.statusCode}");
      }
    } catch (e, s) {
      errorCount++;
      log.e("$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<String>> apiGetPlain(String path,
      {Map<String, dynamic>? query}) async {
    try {
      if (!path.startsWith("http")) {
        path = "$baseUrl$path";
      }
      final res = await pDio.get<String>(path,
          queryParameters: query,
          options: Options(headers: headers, validateStatus: (status) => true));
      if (res.statusCode == 200) {
        errorCount = 0;
        return Res(res.data!);
      } else if (res.statusCode == 400) {
        if (res.data.toString().contains("Access Token")) {
          var refresh = await refreshToken();
          if (refresh.success) {
            return apiGetPlain(path, query: query);
          } else {
            return Res.error(refresh.errorMessage);
          }
        } else {
          return Res.error("Invalid Status Code: ${res.statusCode}");
        }
      } else {
        return Res.error("Invalid Status Code: ${res.statusCode}");
      }
    } catch (e, s) {
      errorCount++;
      log.e("$e\n$s");
      return Res.error(e);
    }
  }

  String? encodeFromData(Map<String, dynamic>? data) {
    if (data == null) return null;
    StringBuffer buffer = StringBuffer();
    data.forEach((key, value) {
      if (value is List) {
        for (var element in value) {
          buffer.write("$key[]=$element&");
        }
      } else {
        buffer.write("$key=$value&");
      }
    });
    return buffer.toString();
  }

  Future<Res<Map<String, dynamic>>> apiPost(String path,
      {Map<String, dynamic>? query, Map<String, dynamic>? data}) async {
    try {
      if (!path.startsWith("http")) {
        path = "$baseUrl$path";
      }
      final res = await pDio.post<Map<String, dynamic>>(path,
          queryParameters: query,
          data: encodeFromData(data),
          options: Options(
              headers: headers,
              validateStatus: (status) => true,
              contentType: Headers.formUrlEncodedContentType));
      if (res.statusCode == 200) {
        errorCount = 0;
        return Res(res.data!);
      } else if (res.statusCode == 400) {
        if (res.data.toString().contains("Access Token")) {
          var refresh = await refreshToken();
          if (refresh.success) {
            return apiGet(path, query: query);
          } else {
            return Res.error(refresh.errorMessage);
          }
        } else {
          return Res.error("Invalid Status Code: ${res.statusCode}");
        }
      } else if ((res.statusCode ?? 500) < 500) {
        return Res.error(res.data?["error"]?["message"] ??
            "Invalid Status code ${res.statusCode}");
      } else {
        return Res.error("Invalid Status Code: ${res.statusCode}");
      }
    } catch (e, s) {
      errorCount++;
      log.e("$e\n$s");
      return Res.error(e);
    }
  }

  /// get user details
  Future<Res<UserDetails>> getUserDetails(Object userId) async {
    var res = await apiGet(userDetailUrl,
        query: {"user_id": userId, "filter": "for_android"});
    if (res.success) {
      return Res(UserDetails.fromJson(res.data));
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> follow(String uid, String method,
      [String type = "public"]) async {
    var res = method == "add"
        ? await apiPost("/v1/user/follow/add",
            data: {"user_id": uid, "restrict": type})
        : await apiPost("/v1/user/follow/delete", data: {
            "user_id": uid,
          });
    if (!res.error) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<List<UserPreview>>> searchUsers(String keyword,
      [String? nextUrl]) async {
    var path = nextUrl ??
        "/v1/search/user?filter=for_android&word=${Uri.encodeComponent(keyword)}";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List)
              .map((e) => UserPreview.fromJson(e))
              .toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> getFollowing(String uid, String type,
      [String? nextUrl]) async {
    if (type == "mypixiv") return getMypixiv(uid, nextUrl);
    var path = nextUrl ??
        "/v1/user/following?filter=for_android&user_id=$uid&restrict=$type";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List)
              .map((e) => UserPreview.fromJson(e))
              .toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> getMypixiv(String uid,
      [String? nextUrl]) async {
    var path = nextUrl ?? "/v1/user/mypixiv?filter=for_android&user_id=$uid";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List)
              .map((e) => UserPreview.fromJson(e))
              .toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> getRecommendationUsers(
      [String? nextUrl]) async {
    var path = nextUrl ?? "/v1/user/recommended?filter=for_android";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List)
              .map((e) => UserPreview.fromJson(e))
              .toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getHistory(int page) async {
    String param = "";
    if (page > 1) {
      param = "?offset=${30 * (page - 1)}";
    }
    var res = await apiGet("/v1/user/browsing-history/illusts$param");
    if (res.success) {
      return Res((res.data["illusts"] as List)
          .map((e) => Illust.fromJson(e))
          .toList());
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<MuteList>> getMuteList() async {
    var res = await apiGet("/v1/mute/list");
    if (res.success) {
      return Res(MuteList.fromJson(res.data));
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> editMute(List<String> addTags, List<String> addUsers,
      List<String> deleteTags, List<String> deleteUsers) async {
    var res = await apiPost("/v1/mute/edit",
        data: {
          "add_tags": addTags,
          "add_user_ids": addUsers,
          "delete_tags": deleteTags,
          "delete_user_ids": deleteUsers
        }..removeWhere((key, value) => value.isEmpty));
    if (res.success) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<List<UserPreview>>> relatedUsers(String id) async {
    var res =
        await apiGet("/v1/user/related?filter=for_android&seed_user_id=$id");
    if (res.success) {
      return Res((res.data["user_previews"] as List)
          .map((e) => UserPreview.fromJson(e))
          .toList());
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> sendHistory(List<int> ids) async {
    var res = await apiPost("/v2/user/browsing-history/illust/add",
        data: {"illust_ids": ids});
    if (res.success) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<List<Illust>> batchIllustRequest(
      Future<Res<List<Illust>>> request, int maxCount) async {
    List<Illust> all = [];
    String? nextUrl;
    int retryCount = 0;
    while (nextUrl != "end" && all.length < maxCount) {
      if (nextUrl != null) {
        request = getIllustsWithNextUrl(nextUrl);
      }
      var res = await request;
      if (res.error) {
        retryCount++;
        if (retryCount > 3) {
          throw BadRequestException(res.errMsg);
        }
        await Future.delayed(Duration(seconds: 1 << retryCount));
        continue;
      }
      all.addAll(res.data);
      nextUrl = res.subData ?? "end";
    }
    return all;
  }

  Future<Res<List<Illust>>> getRecommendedIllusts([String? nextUrl]) async {
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
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
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
    var res = await apiGet(
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
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
    var res = await apiGet("$bookmarkIllustUrl?user_id=$uid&restrict=public");
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
    String fn =
        options.favoriteNumber == 0 ? "" : " ${options.favoriteNumber}users入り";
    final encodedKeyword = Uri.encodeComponent(keyword + fn);
    if (options.selectSort == search_sort[2] && !isPremium) {
      path =
          "/v1/search/popular-preview/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&search_target=${options.searchTarget}&search_ai_type=${options.searchAI ? "1" : "0"}";
    } else {
      path =
          "/v1/search/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&sort=${options.selectSort}&search_target=${options.searchTarget}&search_ai_type=${options.searchAI ? "1" : "0"}";
    }
    if (options.startTime != null) {
      path += "&start_date=${toRequestDate(options.startTime!)}";
    }
    if (options.endTime != null) {
      path += "&end_date=${toRequestDate(options.endTime!)}";
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

  String? getFormatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
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

  Future<Res<List<Illust>>> getUserIllusts(String uid, String? type,
      [String? nextUrl]) async {
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
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
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
    var res = await apiGet("/v2/illust/follow?restrict=$restrict");
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
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
    var link = "/v1/illust/ranking?filter=for_android&mode=$mode";
    if (date != null) {
      link += "&date=$date";
    }
    var res = await apiGet(link);
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

  Future<Res<List<Illust>>> getIllustByID(String id) async {
    var res = await apiGet("/v1/illust/detail?illust_id=$id");
    if (res.success) {
      return Res([Illust.fromJson(res.data["illust"])]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getRecommendedMangas([String? nextUrl]) async {
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
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

  Future<Res<List<Illust>>> relatedIllusts(String id, [String? nextUrl]) async {
    if (nextUrl != null) {
      return getIllustsWithNextUrl(nextUrl);
    }
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

  Future<Res<List<Tag>>> getSearchAutoCompleteKeywords(String word) async {
    var res = await apiGet(
      "/v2/search/autocomplete?merge_plain_keyword_results=true",
      query: {"word": word},
    );
    if (res.success) {
      return Res((res.data["tags"] as List)
          .map((e) => Tag(e["name"], e["translated_name"]))
          .toList());
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Novel>>> getRecommendNovels([String? nextUrl]) {
    return getNovelsWithNextUrl(nextUrl ?? "/v1/novel/recommended");
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
    String fn =
        options.favoriteNumber == 0 ? "" : " ${options.favoriteNumber}users入り";
    final encodedKeyword = Uri.encodeComponent(keyword + fn);
    var url = "/v1/search/novel?"
        "include_translated_tag_results=true&"
        "merge_plain_keyword_results=true&"
        "word=$encodedKeyword&"
        "sort=${options.selectSort}&"
        "search_target=${options.searchTarget}&"
        "search_ai_type=${options.searchAI ? "1" : "0"}";

    if (options.startTime != null) {
      url += "&start_date=${toRequestDate(options.startTime!)}";
    }
    if (options.endTime != null) {
      url += "&end_date=${toRequestDate(options.endTime!)}";
    }
    return getNovelsWithNextUrl(url);
  }

  /// mode: day, day_male, day_female, week_rookie, week, week_ai
  Future<Res<List<Novel>>> getNovelRanking(String mode,
      [String? date, String? nextUrl]) {
    var url = "/v1/novel/ranking?mode=$mode";
    if (date != null) {
      url += "&date=$date";
    }
    return getNovelsWithNextUrl(nextUrl ?? url);
  }

  Future<Res<List<Novel>>> getBookmarkedNovels(String restrict,
      [String? nextUrl]) {
    return getNovelsWithNextUrl(nextUrl ??
        "/v1/user/bookmarks/novel?user_id=${account.user.id}&restrict=$restrict");
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
      log.e("Data Convert: Failed to analyze html novel content: \n$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<List<Novel>>> relatedNovels(String id, [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v1/novel/related?novel_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(
        (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList(),
        subData: res.data["next_url"]);
  }

  Future<Res<List<Novel>>> getUserNovels(String uid, [String? nextUrl]) {
    return getNovelsWithNextUrl(nextUrl ?? "/v1/user/novels?user_id=$uid");
  }

  Future<Res<List<Novel>>> getUserBookmarksNovel(String uid,
      [String? nextUrl]) async {
    var res = await apiGet(
        nextUrl ?? "$bookmarkNovelUrl?user_id=$uid&restrict=public");
    if (res.success) {
      return Res(
          (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<NovelSeriesResponse>> getNovelSeries(String id,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v2/novel/series?series_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(NovelSeriesResponse.fromJson(res.data),
        subData: res.data["next_url"]);
  }

  Future<Res<List<Novel>>> getNovelFollowing(String restrict,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v1/novel/follow?restrict=$restrict");
    if (res.success) {
      return Res(
          (res.data["novels"] as List).map((e) => Novel.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<TrendingTag>>> getHotNovelTags() async {
    var res = await apiGet(
        "/v1/trending-tags/novel?filter=for_android&include_translated_tag_results=true");
    if (res.error) {
      return Res.fromErrorRes(res);
    } else {
      return Res(List.from(res.data["trend_tags"].map((e) => TrendingTag(
          Tag(e["tag"], e["translated_name"]), Illust.fromJson(e["illust"])))));
    }
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

  Future<Res<List<Novel>>> getNovelById(String id) async {
    var res = await apiGet("/v2/novel/detail?novel_id=$id");
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res([Novel.fromJson(res.data["novel"])]);
  }
}
