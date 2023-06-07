import 'package:wakmusic/utils/json.dart';

class Category {
  final String type;
  final String name;

  const Category({
    required this.type,
    required this.name,
  });

  factory Category.fromJson(JSON json) {
    return Category(
      type: json['type'],
      name: json['category'],
    );
  }

  static const qnaAll = Category(type: 'qna', name: '전체');
  static const noticeAll = Category(type: 'notice', name: '전체');

  @override
  bool operator ==(covariant Category other) {
    return type == other.type && name == other.name;
  }

  @override
  int get hashCode => Object.hash(type, name);
}
