import 'package:wakmusic/models_v2/enums/types.dart';
import 'package:wakmusic/utils/json.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String? remix;
  final String? reaction;
  final DateTime date;
  final Duration start;
  final Duration? end;
  final SongMetadata metadata;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.remix,
    required this.reaction,
    required this.date,
    this.start = const Duration(),
    this.end,
    required this.metadata,
  });

  factory Song.fromJson(
    JSON json, {
    ChartType? type,
  }) {
    return Song(
      id: json['songId'],
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
      start: Duration(seconds: json['start'] ?? 0),
      end: (json['end'] ?? 0) == 0 ? null : Duration(seconds: json['end']),
      metadata: SongMetadata.fromJson(
        json[type?.name ?? 'total'],
        type: type,
      ),
    );
  }

  @override
  bool operator ==(covariant Song other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SongMetadata {
  final ChartType? type;
  final int views;
  final int? increase;
  final int? last;

  bool get rankable => (type != null) && (increase != null) && (last != null);

  const SongMetadata({
    this.type,
    required this.views,
    this.increase,
    this.last,
  })  : assert(type == null || type == ChartType.total || increase != null),
        assert(type == null || last != null);

  factory SongMetadata.fromJson(
    JSON json, {
    ChartType? type,
  }) {
    return SongMetadata(
      type: type,
      views: json['views'],
      increase: json['increase'],
      last: json['last'],
    );
  }
}
