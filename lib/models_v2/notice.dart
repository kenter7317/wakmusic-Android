import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/services/apis/api.dart';

class Notice {
  final int id;
  final String title;
  final String mainText;
  final String thumbnail;
  final List<String> images;
  final DateTime createAt;
  final DateTime startAt;
  final DateTime endAt;
  final Category category;

  Notice({
    required this.id,
    required this.title,
    required this.mainText,
    required this.thumbnail,
    required this.images,
    required this.createAt,
    required this.startAt,
    required this.endAt,
    required this.category,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      mainText: json['mainText'],
      thumbnail: json['thumbnail'],
      // '공지사항 내용이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.\n\n자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.', // for test
      images: (json['images'] as List).map((image) => "$image").toList(),
      createAt: msEpoch(json['createAt']),
      startAt: msEpoch(json['startAt']),
      endAt: msEpoch(json['endAt']),
      category: Category.fromJson(json['category']),
    );
  }
}
