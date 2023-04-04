import 'package:wakmusic/services/login.dart';
import 'package:wakmusic/utils/json.dart';

class User {
  final String id;
  final Login platform;
  String profile;
  String displayName;
  final DateTime firstLoginTime;
  final bool first;

  User({
    required this.id,
    required this.platform,
    required this.profile,
    required this.displayName,
    required this.firstLoginTime,
    required this.first,
  });

  factory User.fromJson(JSON json) => User(
    id: json['id'],
    platform: Login.byName(json['platform']),
    profile: json['profile'],
    displayName: json['displayName'] ?? "이파리",
    firstLoginTime: DateTime.fromMillisecondsSinceEpoch(json['first_login_time'] * 1000),
    first: json['first'],
  );
}