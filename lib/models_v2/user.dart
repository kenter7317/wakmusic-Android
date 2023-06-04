import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/services/login.dart';
import 'package:wakmusic/utils/json.dart';

class User {
  final String id;
  final Login platform;
  String displayName;
  final DateTime firstLoginTime;
  final DateTime createAt;
  Profile profile;
  final bool first;

  User({
    required this.id,
    required this.platform,
    required this.displayName,
    required this.firstLoginTime,
    required this.createAt,
    required this.profile,
    required this.first,
  });

  factory User.fromJson(JSON json) {
    return User(
      id: json['userId'],
      platform: Login.byName(json['platform']),
      displayName: "${json['displayName']}",
      firstLoginTime: msEpoch(json['firstLoginTime']),
      createAt: msEpoch(json['createAt']),
      profile: Profile(
        type: json['profile']['type'],
        imageVersion: json['profile']['version'],
      ),
      first: json['first'],
    );
  }
}
