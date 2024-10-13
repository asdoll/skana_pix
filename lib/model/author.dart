import 'illust.dart' show Illust;

class Author {
  final int id;
  final String name;
  final String account;
  final String avatar;
  bool isFollowed;

  Author(this.id, this.name, this.account, this.avatar, this.isFollowed);

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
  final List<Illust> artworks;

  UserPreview(this.id, this.name, this.account, this.avatar, this.isFollowed,
      this.isBlocking, this.artworks);

  UserPreview.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'],
        name = json['user']['name'],
        account = json['user']['account'],
        avatar = json['user']['profile_image_urls']['medium'],
        isFollowed = json['user']['is_followed'],
        isBlocking = json['user']['is_access_blocking_user'] ?? false,
        artworks =
            (json['illusts'] as List).map((e) => Illust.fromJson(e)).toList();

  @override
  String toString() {
    return 'UserPreview{id: $id, name: $name, account: $account, avatar: $avatar, isFollowed: $isFollowed, isBlocking: $isBlocking, artworks: $artworks}';
  }
}