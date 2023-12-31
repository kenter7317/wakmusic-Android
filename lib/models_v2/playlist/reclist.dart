import 'package:wakmusic/models_v2/image_version.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/utils/json.dart';

/* 
  user =>
  key, title, createAt, user, image, songs,
 
  detail =>
  key, title, createAt, user, image, songs,

  rec list =>
  key, title, public, createAt, image

  rec detail =>
  key, title, public, createAt, songs, image
*/

class Reclist extends Playlist {
  @override
  final String key;
  @override
  final String title;
  final bool public;
  @override
  final DateTime createAt;
  @override
  final ImageVersion image;

  @override
  List<Song>? songs;

  Reclist({
    required this.key,
    required this.title,
    required this.public,
    required this.createAt,
    required this.image,
    this.songs,
  });

  bool get fetchRequired => songs == null;

  factory Reclist.fromJson(JSON json) {
    return Reclist(
      key: json['key'],
      title: json['title'],
      public: json['public'],
      createAt: msEpoch(json['createAt']),
      image: ImageVersion.fromJson(json['image']),
      songs: (json['songs'] as List?)?.map((e) => Song.fromJson(e)).toList(),
    );
  }

  @override
  Playlist copyWith({
    String? title,
    covariant PlaylistImage? image,
    List<Song>? songs,
  }) {
    return this;
  }
}
