class BoardInfo {
  BoardInfo({
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
  });

  String title;
  String content;
  String startDate;
  String? endDate;

  factory BoardInfo.fromJson(Map<String, dynamic> json) =>BoardInfo(
      title: json['title'] as String,
      content: json['content'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );
  Map<String, dynamic> toJson() => <String, dynamic>{
      'title': title,
      'content': content,
      'startDate': startDate,
      'endDate': endDate,
    };
}
