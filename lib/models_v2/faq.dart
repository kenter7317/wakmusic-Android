import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/utils/json.dart';

class FAQ {
  final String question;
  final String description;
  final DateTime createAt;
  final Category category;
  bool isExpanded = false;

  FAQ({
    required this.question,
    required this.description,
    required this.createAt,
    required this.category,
  });

  factory FAQ.fromJson(JSON json) {
    return FAQ(
      question: json['question'],
      description: json['description'],
      createAt: msEpoch(json['createAt'] * 1000),
      category: Category.fromJson(json['category']),
    );
  }

  factory FAQ.clone(FAQ faq) {
    return FAQ(
      category: faq.category,
      question: faq.question,
      description: faq.description,
      createAt: faq.createAt,
    );
  }
}
