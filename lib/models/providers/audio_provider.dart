import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service/models/enums.dart';
import 'package:audio_service/player/youtube_audio_player.dart';
import 'package:audio_service/models/audio_value.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/song.dart';

class AudioProvider extends ChangeNotifier implements AudioHandler<Song> {
  late final YoutubeAudioPlayer _player;

  Future<void> init() async {
    _player = await AudioService.init(() => this);
    _player.metadataStream.listen((data) {
      _metadata = data;
    });
    _player.playbackStateStream.listen((state) {
      _playbackState = state;
      if (nextPlayable && state == PlaybackState.ended) {
        toNext(auto: true);
      } else {
        notifyListeners();
      }
    });
    AudioService.position.listen((pos) {
      log('$pos');
    });
  }

  static final List<Song> _queue = [];
  @override
  List<Song> get queue => _queue;

  bool get isEmpty => _queue.isEmpty;
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == _queue.length - 1;
  @override
  bool get prevPlayable => !isFirst || loopMode == LoopMode.all;
  @override
  bool get nextPlayable => !isLast || loopMode != LoopMode.none;

  final Set<Song> _shuffledQueue = {};
  Set<Song> get shuffledQueue => _shuffledQueue;

  int _index = 0;
  int? get currentIndex {
    if (isEmpty) {
      _index = 0;
      return null;
    }
    return _index;
  }

  Song? get currentSong {
    if (isEmpty) {
      return null;
    }
    return _queue[_index];
  }

  @override
  LoopMode loopMode = LoopMode.none;

  @override
  void nextLoopMode({LoopMode? v}) {
    loopMode = v ?? LoopMode.values[(loopMode.index + 1) % 3];
    if (loopMode == LoopMode.single) toggleShuffle(v: false);
    notifyListeners();
  }

  @override
  bool shuffle = false;

  @override
  void toggleShuffle({bool? v}) {
    _shuffledQueue.clear();
    shuffle = v ?? !shuffle;
    notifyListeners();
  }

  AudioMetadata _metadata = AudioMetadata.nothing();
  PlaybackState _playbackState = PlaybackState.unknown;

  @override
  AudioMetadata get metadata => _metadata;

  @override
  Duration get duration => _metadata.duration;

  @override
  PlaybackState get playbackState => _playbackState;

  Stream<PlaybackState> get playbackStream => _player.playbackStateStream;

  @override
  Stream<Duration> get position => AudioService.position;

  @override
  Future<void> play() async {
    if (isEmpty) return;
    if (currentSong != null && playbackState.isNotPlaying ||
        playbackState == PlaybackState.ended) {
      await load(currentSong!);
    } else {
      await _player.playVideo();
      notifyListeners();
    }
  }

  @override
  Future<void> pause() async {
    if (isEmpty) return;
    await _player.pauseVideo();
    notifyListeners();
  }

  @override
  Future<void> playPause() async {
    switch (playbackState) {
      case PlaybackState.playing:
        return pause();
      case PlaybackState.ended:
        return load(currentSong!);
      default:
        return play();
    }
  }

  @override
  Future<void> stop() async {
    (await _player.webViewController).android.resume();
    // (await _player.webViewController).android.pause();
    await _player.stopVideo();
    clear();
  }

  @override
  Future<void> load(Song song) async {
    if (!_player.headlessInAppWebView.isRunning()) {
      await _player.headlessInAppWebView.run();
    }
    (await _player.webViewController).android.resume();
    (await _player.webViewController).android.pause();
    if (shuffle) _shuffledQueue.add(song);
    await _player.loadVideoById(
      id: song.id,
      title: song.title,
      artist: song.artist,
      start: song.start,
      end: song.end,
    );
    notifyListeners();
  }

  Future<void> loadRandom() async {
    if (_queue.length == _shuffledQueue.length) {
      _shuffledQueue.clear();
      return loadRandom();
    }
    final list = [..._queue]..shuffle();
    final song = list.firstWhere((e) => !_shuffledQueue.contains(e));
    _index = _queue.indexOf(song);
    await load(currentSong!);
  }

  @override
  Future<void> seek(double position) async {
    switch (_playbackState) {
      case PlaybackState.paused:
        await play();
        break;
      case PlaybackState.ended:
        await load(currentSong!);
        break;
      default:
    }
    await _player.seekTo(seconds: position, allowSeekAhead: true);
    notifyListeners();
  }

  @override
  Future<void> toPrevious() async {
    if (isEmpty) return;
    toggleShuffle(v: false);
    switch (loopMode) {
      case LoopMode.none:
        if (isFirst) return seek(0);
        return load(_queue[--_index]);
      case LoopMode.all:
        if (isFirst) {
          _index = _queue.length - 1;
        } else {
          _index--;
        }
        return load(_queue[_index]);
      case LoopMode.single:
        return seek(0);
    }
  }

  @override
  Future<void> toNext({bool auto = false}) async {
    if (isEmpty) return;
    switch (loopMode) {
      case LoopMode.none:
        if (shuffle) return loadRandom();
        if (isLast) return;
        return load(_queue[++_index]);
      case LoopMode.all:
        if (shuffle) return loadRandom();
        if (isLast) {
          _index = 0;
        } else {
          _index++;
        }
        return load(_queue[_index]);
      case LoopMode.single:
        if (auto) return load(currentSong!);
    }
  }

  @override
  Future<void> toQueueItem(int i) async {
    if (isEmpty || i < 0 || i >= _queue.length) return;
    if (currentIndex == i) return seek(0);
    toggleShuffle(v: false);
    _index = i;
    return load(_queue[_index]);
  }

  @override
  Future<void> addQueueItem(
    Song song, {
    bool autoplay = false,
  }) async {
    if (!_queue.contains(song)) {
      _queue.add(song);
    }
    if (autoplay) {
      _index = _queue.indexOf(song);
      load(song);
    }
    notifyListeners();
  }

  @override
  Future<void> addQueueItems(
    List<Song> songs, {
    bool override = false,
    bool randomize = false,
    bool autoplay = false,
  }) async {
    if (override) clear();
    final list = songs.where((s) => !_queue.contains(s)).toList();
    if (randomize) list.shuffle();
    _queue.addAll(list);
    if (autoplay && !isEmpty && list.isNotEmpty) {
      _index = _queue.indexOf(list.first);
      load(list.first);
    }
    notifyListeners();
  }

  @override
  Future<void> insertQueueItem(int i, Song song) async {
    if (i < 0 || _queue.contains(song)) return;
    _queue.insert(i, song);
    notifyListeners();
  }

  @override
  Future<void> removeQueueItem(Song song) async {
    _queue.remove(song);
    notifyListeners();
  }

  @override
  Future<void> removeQueueItemAt(int i) async {
    if (i < 0 || i >= _queue.length) return;
    _queue.removeAt(i);
    notifyListeners();
  }

  @override
  Future<void> removeQueueItems(List<Song> songs) async {
    if(songs.isEmpty) return;

    var curSong = currentSong;

    _queue.removeWhere((s) => songs.contains(s));

    if(_queue.isEmpty) {
      stop();
    } else if(curSong != null) {
      if (songs.contains(curSong)) {
        _index = 0;
        load(_queue[_index]);
      } else {
        _index = _queue.indexOf(curSong);
      }
    }
    notifyListeners();
  }

  Future<void> clear() async {
    _queue.clear();
    _index = 0;
    _shuffledQueue.clear();
    notifyListeners();
  }

  Future<void> swapQueueItem(int oldIdx, int newIdx) async {
    var song = _queue.removeAt(oldIdx);
    _queue.insert(newIdx, song);
    if (oldIdx == _index) _index = newIdx;
    notifyListeners();
  }
}
