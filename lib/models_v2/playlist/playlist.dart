import 'package:wakmusic/utils/json.dart';

class PlaylistImage {
  final String name;
  final int version;

  const PlaylistImage({
    required this.name,
    this.version = 1,
  });

  factory PlaylistImage.fromJson(JSON json) {
    return PlaylistImage(
      name: json['name'],
      version: json['version'],
    );
  }
}

abstract class Playlist {
  String get key;
  String get title;
  DateTime get createAt;
  PlaylistImage get image;

  const Playlist();
}
