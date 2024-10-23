class Comment {
  final int id;
  final String comment;
  final DateTime date;
  final String uid;
  final String name;
  final String avatar;
  final bool hasReplies;
  final String? stampUrl;
  final Comment? parentComment;

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        comment = json['comment'],
        date = DateTime.parse(json['date']),
        uid = json['user']['id'].toString(),
        name = json['user']['name'],
        avatar = json['user']['profile_image_urls']['medium'],
        hasReplies = json['has_replies'] ?? false,
        stampUrl = json['stamp']?['stamp_url'],
        parentComment = json['parent_comment'] == null
            ? null
            : Comment.fromJson(json['parent_comment']);
  
  @override
  String toString() {
    return 'Comment{id: $id, comment: $comment, date: $date, uid: $uid, name: $name, avatar: $avatar, hasReplies: $hasReplies, stampUrl: $stampUrl, parentComment: $parentComment}';
  }
}