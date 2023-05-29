import 'package:wakmusic/utils/json.dart';

class Member {
  final String team;
  final String name;
  final String role;

  const Member({
    required this.team,
    required this.name,
    required this.role,
  });

  factory Member.fromJson(JSON json) {
    return Member(
      team: json['team'],
      name: json['name'],
      role: json['role'],
    );
  }
}
