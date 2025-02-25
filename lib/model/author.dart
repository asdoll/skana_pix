import 'illust.dart' show Illust;
import 'novel.dart';

class Author {
  final int id;
  final String name;
  final String account;
  final String avatar;
  bool isFollowed;

  Author(this.id, this.name, this.account, this.avatar, this.isFollowed);

  Author.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        account = json['account'],
        avatar = json['profile_image_urls']['medium'],
        isFollowed = json['is_followed'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account': account,
        'avatar': avatar,
        'isFollowed': isFollowed
      };

  @override
  String toString() {
    return 'Author{id: $id, name: $name, account: $account, avatar: $avatar, isFollowed: $isFollowed}';
  }
}

class UserPreview {
  final int id;
  final String name;
  final String account;
  final String avatar;
  bool isFollowed;
  final bool isBlocking;
  final List<Illust> illusts;
  final List<Novel> novels;

  UserPreview(this.id, this.name, this.account, this.avatar, this.isFollowed,
      this.isBlocking, this.illusts, this.novels);

  UserPreview.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'],
        name = json['user']['name'],
        account = json['user']['account'],
        avatar = json['user']['profile_image_urls']['medium'],
        isFollowed = json['user']['is_followed'],
        isBlocking = json['user']['is_access_blocking_user'] ?? false,
        illusts =
            (json['illusts'] as List).map((e) => Illust.fromJson(e)).toList(),
        novels =
            (json['novels'] as List).map((e) => Novel.fromJson(e)).toList();

  @override
  String toString() {
    return 'UserPreview{id: $id, name: $name, account: $account, avatar: $avatar, isFollowed: $isFollowed, isBlocking: $isBlocking, illusts: $illusts}';
  }
}
