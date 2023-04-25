import 'package:wakmusic/models/song.dart';

abstract class IPlaylist {
  final String id;
  String get title;
  int get imageVersion;

  const IPlaylist({required this.id});
}

abstract class IPlaylistDetail {
  final String? id;
  String get title;
  List<Song> get songs;
  int get imageVersion;

  const IPlaylistDetail({this.id});
}
