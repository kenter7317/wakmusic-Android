import 'package:audio_service/models/enums.dart';

class AudioMetadata {
  final String id;
  final String title;
  final String artist;
  final Duration duration;

  const AudioMetadata({
    required this.id,
    required this.title,
    required this.artist,
    this.duration = const Duration(),
  });

  bool get isEmpty =>
      id.isEmpty ||
      title.isEmpty ||
      artist.isEmpty ||
      duration == Duration.zero;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'duration': duration.inMilliseconds,
      };

  factory AudioMetadata.nothing() => const AudioMetadata(
        id: '',
        title: '',
        artist: '',
      );
}

class AudioState {
  final PlaybackState playbackState;
  final Duration position;
  final bool prevPlayable;
  final bool nextPlayable;

  const AudioState({
    this.playbackState = PlaybackState.unknown,
    this.position = const Duration(),
    this.prevPlayable = false,
    this.nextPlayable = false,
  });

  Map<String, dynamic> toMap() => {
        'playbackState': playbackState.code,
        'position': position.inMilliseconds,
        'prevPlayable': prevPlayable,
        'nextPlayable': nextPlayable,
      };
}
