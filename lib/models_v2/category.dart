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
}
