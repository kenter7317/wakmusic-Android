import 'package:flutter/foundation.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/utils/json.dart';

class Creator {
  final String displayName;
  final Profile profile;

  const Creator({
    required this.displayName,
    required this.profile,
  });

  factory Creator.fromJson(JSON json) {
    return Creator(
      displayName: json['displayName'],
      profile: Profile.fromJson(json['profile']),
    );
  }
}

class UserPlaylist extends Playlist {
  @override
  final String key;
  @override
  final String title;
  @override
  final DateTime createAt;
  final Creator creator;
  @override
  final PlaylistImage image;
  final List<Song> songs;

  const UserPlaylist({
    required this.key,
    required this.title,
    required this.createAt,
    required this.creator,
    required this.image,
    required this.songs,
  });

  factory UserPlaylist.fromJson(JSON json) {
    return UserPlaylist(
      key: json['key'],
      title: json['title'],
      createAt: msEpoch(json['createAt']),
      creator: json['user'],
      image: json['image'],
      songs: (json['songs'] as List).map((e) => Song.fromJson(e)).toList(),
    );
  }

  UserPlaylist copyWith({
    String? key,
    String? title,
    PlaylistImage? image,
    List<Song>? songs,
  }) {
    return UserPlaylist(
      key: key ?? this.key,
      title: title ?? this.title,
      createAt: createAt,
      creator: creator,
      image: image ?? this.image,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(covariant UserPlaylist other) {
    return key == other.key &&
        title == other.title &&
        createAt == other.createAt &&
        creator == other.creator &&
        image == other.image &&
        listEquals(songs, other.songs);
  }

  @override
  int get hashCode => Object.hash(key, title, createAt, creator, image, songs);
}
