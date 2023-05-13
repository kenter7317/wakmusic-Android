class Notice {
  final int id;
  final String category;
  final String title;
  final String mainText;
  final List<String> images;
  final DateTime createAt;
  final DateTime startAt;
  final DateTime endAt;

  Notice({
    required this.id,
    required this.category,
    required this.title,
    required this.mainText,
    required this.images,
    required this.createAt,
    required this.startAt,
    required this.endAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json['id'],
        category: json['category'],
        title: json['title'],
        mainText: json['main_text'] ??
            '공지사항 내용이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.\n\n자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.', // for test
        images:
            (json['images'] as List).map((image) => image as String).toList(),
        createAt: DateTime.fromMillisecondsSinceEpoch(json['create_at']),
        startAt: DateTime.fromMillisecondsSinceEpoch(json['start_at']),
        endAt: DateTime.fromMillisecondsSinceEpoch(json['end_at']),
      );
}
