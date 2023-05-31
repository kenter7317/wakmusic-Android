import 'package:wakmusic/services/apis/api.dart';

class Profile {
  final String type;
  final int imageVersion;

  const Profile({
    required this.type,
    required this.imageVersion,
  });

  factory Profile.fromJson(JSON json) {
    return Profile(
      type: json['type'],
      imageVersion: json['version'],
    );
  }
}
