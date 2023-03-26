import 'package:wakmusic/utils/json.dart';

class FAQ {
  final String category;
  final String question;
  final String description;
  final DateTime createAt;
  bool isExpanded = false;

  FAQ({
    required this.category,
    required this.question,
    required this.description,
    required this.createAt,
  });

  factory FAQ.fromJson(JSON json) => FAQ(
    category: json['category'],
    question: json['question'],
    description: json['description'],
    createAt: DateTime.fromMillisecondsSinceEpoch(
      int.parse(json['create_at']) * 1000),
  );

  factory FAQ.clone(FAQ faq) => FAQ(
    category: faq.category,
    question: faq.question,
    description: faq.description,
    createAt: faq.createAt,
  );
}