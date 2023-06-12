import 'package:wakmusic/models_v2/image_version.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/utils/json.dart';

export './reclist.dart';
export './user_playlist.dart';

class PlaylistImage extends ImageQuery {
  @override
  final String name;

  @override
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

@Deprecated('')
abstract class Playlist {
  String get key;
  String get title;
  DateTime get createAt;
  ImageQuery get image;
  List<Song>? get songs;

  const Playlist();

  Playlist copyWith({
    String? title,
    ImageQuery? image,
    List<Song>? songs,
  });
}
