import 'dart:async';

import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/enums.dart';

abstract class AudioHandler<T> {
  List<T> get queue;

  AudioMetadata get metadata;
  Duration get duration;

  // Stream<PlaybackState> get playbackState;
  PlaybackState get playbackState;
  Stream<Duration> get position;

  bool get prevPlayable;
  bool get nextPlayable;

  LoopMode get loopMode;
  set loopMode(LoopMode value);
  void nextLoopMode();

  bool get shuffle;
  set shuffle(bool value);
  void toggleShuffle();

  Future<void> play();

  Future<void> pause();

  Future<void> playPause();

  Future<void> stop();

  Future<void> load(T song);

  Future<void> seek(double position);

  Future<void> toPrevious();

  Future<void> toNext();

  Future<void> toQueueItem(int i);

  Future<void> addQueueItem(T song);

  Future<void> addQueueItems(List<T> songs, {bool randomize = false});

  Future<void> insertQueueItem(int i, T song);

  Future<void> removeQueueItem(T song);

  Future<void> removeQueueItemAt(int i);

  Future<void> removeQueueItems(List<T> songs);
}
