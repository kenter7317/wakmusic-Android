import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/utils/json.dart';

class PlaylistDetail {
  final String? key;
  final String title;
  final String? creator;
  final String? image;
  final List<Song> songs;
  final int imageVersion;

  const PlaylistDetail({
    this.key,
    required this.title,
    this.creator,
    this.image,
    required this.songs,
    this.imageVersion = 1,
  });

  factory PlaylistDetail.fromJson(JSON json) {
    return PlaylistDetail(
      key: json['key'],
      title: json['title'],
      creator: json['creator_id'],
      image: json['image'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
      imageVersion: json['image_version'],
    );
  }

  Playlist get simplify {
    return Playlist(
      key: key,
      title: title,
      creator: creator,
      image: image,
      songlist: songs.map((song) => song.id).toList(),
      imageVersion: imageVersion,
    );
  }
}

class ReclistDetail extends PlaylistDetail {
  final String id;
  final bool public;

  const ReclistDetail({
    required this.id,
    required super.title,
    required super.songs,
    required this.public,
    super.imageVersion = 1,
  });

  factory ReclistDetail.fromJson(JSON json) {
    return ReclistDetail(
      id: json['id'],
      title: json['title'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
      public: json['public'],
      imageVersion: json['image_square_version'],
    );
  }

  @override
  Reclist get simplify {
    return Reclist(
      id: id,
      title: title,
      public: public,
      imageVersion: imageVersion,
    );
  }
}
