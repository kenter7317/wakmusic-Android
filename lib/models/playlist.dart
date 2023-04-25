import 'package:wakmusic/utils/json.dart';

class Playlist {
  final String? id;
  final String? key;
  final String title;
  final String? creator;
  final String? image;
  final List<String>? songlist;
  final int imageVersion;

  const Playlist({
    this.id,
    this.key,
    required this.title,
    this.creator,
    this.image,
    this.songlist,
    this.imageVersion = 1,
  });

  factory Playlist.fromJson(JSON json) {
    return Playlist(
      id: '${json['id']}',
      key: json['key'],
      title: json['title'],
      creator: json['creator_id'],
      image: json['image'],
      songlist: (json['songlist'] as List).map((song) => "$song").toList(),
      imageVersion: json['image_version'],
    );
  }
}

class Reclist extends Playlist {
  final bool public;

  const Reclist({
    required super.id,
    required super.title,
    required this.public,
    super.imageVersion = 1,
  });

  factory Reclist.fromJson(JSON json) {
    return Reclist(
      id: json['id'],
      title: json['title'],
      public: json['public'],
      imageVersion: json['image_round_version'],
    );
  }
}
