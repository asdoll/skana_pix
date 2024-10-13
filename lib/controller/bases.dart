import 'package:intl/intl.dart';

abstract class BaseClient {
  const BaseClient();

  static String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  String get clientID => 'MOBrBDS8blbauoSck0ZfDbtuzpyT';
  String get clientSecret => 'lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj';
  String get baseUrl => 'https://app-api.pixiv.net';
  String get oauthUrl => 'https://oauth.secure.pixiv.net';
  String get oauthUrlToken => "$oauthUrl/auth/token";
  String get clientTime =>
      DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());

  String get recommendationUrl =>
      "/v1/illust/recommended?include_privacy_policy=true&filter=for_android&include_ranking_illusts=true";

  String get authCallbackUrl =>
      "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback";
  String codeChallengeUrl(String codeChallenge) =>
      "https://app-api.pixiv.net/web/v1/login?code_challenge=$codeChallenge&code_challenge_method=S256&client=pixiv-android";

  String get userDetailUrl => "/v1/user/detail";
  String get bookmarkIllustUrl => "/v1/user/bookmarks/illust";
}

class BasePath {
  static String dataPath = "data/";
  static String cachePath = "cache/";
  static String get accountJsonPath => "${dataPath}account.json";
  static String get appSettingJsonPath => "${dataPath}setting.json";
  static String get downloadPath => '${dataPath}downloads/';
  static String downloadSubPath = r"illust/${id}-p${index}.${ext}";
  static String get downloadNovelPath => "${downloadPath}novel/";
  static String get downloadDbPath => "${dataPath}download.db";
}
