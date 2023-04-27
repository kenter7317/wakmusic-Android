import 'package:flutter/foundation.dart';
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

  Playlist copyWith({
    String? id,
    String? key,
    String? title,
    String? creator,
    String? image,
    List<String>? songlist,
    int? imageVersion,
  }) {
    return Playlist(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      image: image ?? this.image,
      songlist: songlist ?? this.songlist,
      imageVersion: imageVersion ?? this.imageVersion,
    );
  }

  @override
  bool operator ==(covariant Playlist other) {
    return id == other.id &&
        key == other.key &&
        title == other.title &&
        creator == other.creator &&
        image == other.image &&
        listEquals(songlist, other.songlist) &&
        imageVersion == other.imageVersion;
  }

  // @override
  // int get hashCode =>
  //     Object.hash(id, key, title, creator, image, songlist, imageVersion);
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
