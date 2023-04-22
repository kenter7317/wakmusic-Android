enum PlaybackState {
  unknown(-2),
  unStarted(-1),
  ended(0),
  playing(1),
  paused(2),
  buffering(3),
  cued(5);

  const PlaybackState(this.code);

  final int code;

  bool get isPlaying => [ended, playing, paused, buffering].contains(this);
  bool get isNotPlaying => [unknown, unStarted, cued].contains(this);

  factory PlaybackState.byCode(int i) {
    return PlaybackState.values.firstWhere(
      (e) => e.code == i,
      orElse: () => PlaybackState.unknown,
    );
  }
}

enum LoopMode {
  none,
  all,
  single,
}

enum MediaButton {
  media,
  prev,
  next,
}

enum YoutubeError {
  none(0),
  invalidParam(2),
  html5Error(5),
  videoNotFound(100),
  notEmbeddable(101),
  sameAsNotEmbeddable(150),
  unknown(-1);

  const YoutubeError(this.code);

  final int code;

  factory YoutubeError.byCode(int i) {
    return YoutubeError.values.firstWhere(
      (e) => e.code == i,
      orElse: () => YoutubeError.unknown,
    );
  }
}

class ThumbnailQuality {
  /// 120*90
  static const String defaultQuality = 'default';

  /// 320*180
  static const String medium = 'mqdefault';

  /// 480*360
  static const String high = 'hqdefault';

  /// 640*480
  static const String standard = 'sddefault';

  /// Unscaled thumbnail
  static const String max = 'maxresdefault';
}
