import 'package:wakmusic/services/login.dart';
import 'package:wakmusic/utils/json.dart';

class User {
  final String id;
  final Login platform;
  String profile;
  String displayName;
  final DateTime firstLoginTime;
  final bool first;
  int profileVersion;

  User({
    required this.id,
    required this.platform,
    required this.profile,
    required this.displayName,
    required this.firstLoginTime,
    required this.first,
    required this.profileVersion,
  });

  factory User.fromJson(JSON json) => User(
    id: json['id'],
    platform: Login.byName(json['platform']),
    profile: json['profile'],
    displayName: "${json['displayName']}",
    firstLoginTime: DateTime.fromMillisecondsSinceEpoch(json['first_login_time']),
    first: json['first'],
    profileVersion: json['profile_version'],
  );
}