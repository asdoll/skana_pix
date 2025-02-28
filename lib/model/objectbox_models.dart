
import 'package:objectbox/objectbox.dart';
import 'package:skana_pix/model/novel.dart' show Novel;

@Entity()
class IllustHistory {
  @Id()
  int id = 0;
  @Index()
  int illustId;
  int userId;
  String pictureUrl;
  String? userName;
  String? title;
  int time;

  IllustHistory(
      {
      required this.illustId,
      required this.userId,
      required this.pictureUrl,
      required this.time,
      required this.title,
      required this.userName});

}

@Entity()
class NovelHistory {
  @Id()
  int id = 0;
  @Index()
  int novelId;
  int userId;
  String pictureUrl;
  int time;
  String title;
  String userName;
  double lastRead;

  NovelHistory(
      {
      required this.novelId,
      required this.userId,
      required this.pictureUrl,
      required this.time,
      required this.title,
      required this.userName,
      this.lastRead = 0
      });
  
  factory NovelHistory.convert(Novel novel) {
    return NovelHistory(
        novelId: novel.id,
        userId: novel.author.id,
        pictureUrl: novel.image.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: novel.title,
        userName: novel.author.name,
        lastRead: 0);
  }

}