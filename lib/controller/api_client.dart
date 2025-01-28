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
}
