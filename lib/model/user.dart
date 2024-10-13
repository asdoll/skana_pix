import 'dart:convert';
import 'dart:io';

import 'package:pixiv_dart_api/controller/bases.dart';
import 'package:pixiv_dart_api/controller/exceptions.dart';

class User {
  String profileImg;
  final String id;
  String name;
  String account;
  String email;
  bool isPremium;

  User(this.profileImg, this.id, this.name, this.account, this.email,
      this.isPremium);

  User.fromJson(Map<String, dynamic> json)
      : profileImg = json['profile_image_urls']['px_170x170'],
        id = json['id'],
        name = json['name'],
        account = json['account'],
        email = json['mail_address'],
        isPremium = json['is_premium'];

  Map<String, dynamic> toJson() => {
        'profile_image_urls': {'px_170x170': profileImg},
        'id': id,
        'name': name,
        'account': account,
        'mail_address': email,
        'is_premium': isPremium
      };

  User.empty()
      : profileImg = "",
        id = "",
        name = "",
        account = "",
        email = "",
        isPremium = false;
}

class Account {
  String accessToken;
  String refreshToken;
  final User user;
  int expiresIn;
  String tokenType;
  DateTime acquisitionTime;

  Account(this.accessToken, this.refreshToken, this.expiresIn, this.tokenType, this.acquisitionTime, this.user);

  Account.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        refreshToken = json['refresh_token'],
        user = User.fromJson(json['user']),
        expiresIn = json['expires_in'],
        tokenType = json['token_type'],
        acquisitionTime = DateTime.now();

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user.toJson(),
        'expires_in': expiresIn,
        'token_type': tokenType,
        'acquisition_time': acquisitionTime.toIso8601String(),
      };

  static Future<Account?> fromPath() async{
    final file = File("${BasePath.dataPath}/account.json");
    try {
      var json = jsonDecode(await file.readAsString());
      if (json != null) {
        return Account.fromJson(json);
      }
    } catch (e) {
      throw BadRequestException(e.toString());
    }
    return null;
  }

  Account.empty()
      : accessToken = "",
        refreshToken = "",
        user = User.empty(),
        expiresIn = 0,
        tokenType = "",
        acquisitionTime = DateTime.now();

  bool isValid() {
    return accessToken.isNotEmpty && refreshToken.isNotEmpty;
  }

  bool isExpired() {
    final expiryDate = acquisitionTime.add(Duration(seconds: expiresIn));
    return expiryDate.isAfter(DateTime.now());
  }

}

class UserDetails {
  final int id;
  final String name;
  final String account;
  final String avatar;
  final String comment;
  bool isFollowed;
  final bool isBlocking;
  final String? webpage;
  final String gender;
  final String birth;
  final String region;
  final String job;
  final int totalFollowUsers;
  final int myPixivUsers;
  final int totalIllusts;
  final int totalMangas;
  final int totalNovels;
  final int totalIllustBookmarks;
  final String? backgroundImage;
  final String? twitterUrl;
  final bool isPremium;
  final String? pawooUrl;

  UserDetails(
      this.id,
      this.name,
      this.account,
      this.avatar,
      this.comment,
      this.isFollowed,
      this.isBlocking,
      this.webpage,
      this.gender,
      this.birth,
      this.region,
      this.job,
      this.totalFollowUsers,
      this.myPixivUsers,
      this.totalIllusts,
      this.totalMangas,
      this.totalNovels,
      this.totalIllustBookmarks,
      this.backgroundImage,
      this.twitterUrl,
      this.isPremium,
      this.pawooUrl);

  UserDetails.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'],
        name = json['user']['name'],
        account = json['user']['account'],
        avatar = json['user']['profile_image_urls']['medium'],
        comment = json['user']['comment'],
        isFollowed = json['user']['is_followed'],
        isBlocking = json['user']['is_access_blocking_user'],
        webpage = json['profile']['webpage'],
        gender = json['profile']['gender'],
        birth = json['profile']['birth'],
        region = json['profile']['region'],
        job = json['profile']['job'],
        totalFollowUsers = json['profile']['total_follow_users'],
        myPixivUsers = json['profile']['total_mypixiv_users'],
        totalIllusts = json['profile']['total_illusts'],
        totalMangas = json['profile']['total_manga'],
        totalNovels = json['profile']['total_novels'],
        totalIllustBookmarks = json['profile']['total_illust_bookmarks_public'],
        backgroundImage = json['profile']['background_image_url'],
        twitterUrl = json['profile']['twitter_url'],
        isPremium = json['profile']['is_premium'],
        pawooUrl = json['profile']['pawoo_url'];
}