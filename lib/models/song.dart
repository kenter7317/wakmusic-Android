import 'package:wakmusic/utils/json.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String? remix;
  final String? reaction;
  final DateTime date;
  final int views;
  final int last;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.remix,
    required this.reaction,
    required this.date,
    required this.views,
    required this.last,
  });

  factory Song.fromJson(JSON json) => Song(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    remix: json['remix'],
    reaction: json['reaction'],
    date: () {
      try {
        return DateTime(
          json['date'] ~/ 10000 + 2000,
          json['date'] ~/ 100 % 100,
          json['date'] % 100,
        );
      } catch (_) {
        return DateTime(1999);
      }
    }(),
    views: json['views'] ?? 0,
    last: json['last'] ?? 0,
  );
}
