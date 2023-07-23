import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_handler.dart';
import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/callbacks.dart';
import 'package:audio_service/models/enums.dart';
import 'package:audio_service/player/youtube_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio_service_platform_interface.dart';

class AudioService {
  static late final AudioHandler _handler;
  static late final YoutubeAudioPlayer player;

  static Future<String?> getPlatformVersion() {
    return AudioServicePlatform.instance.getPlatformVersion();
  }

  static Future<YoutubeAudioPlayer> init<R extends AudioHandler>(
    R Function() builder,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    final callbacks = _HandlerCallbacks();
    AudioServicePlatform.instance.setHandlerCallbacks(callbacks);
    await AudioServicePlatform.instance.configure();
    final handler = builder();
    _handler = handler;
    callbacks.setHandler(handler);
    player = YoutubeAudioPlayer(
      _handler,
      await rootBundle.loadString('packages/audio_service/assets/player.html'),
    );
    _observe();
    return player;
  }

  static Future<void> _observe() async {
    var previousState = _handler.playbackState;
    player.metadataStream.listen((metadata) {
      if (metadata.isEmpty) return;
      AudioServicePlatform.instance.setMetadata(metadata);
    });
    player.playbackStateStream
        .asyncMap((state) async => {state: await player.currentTime})
        .listen((map) {
      final state = map.keys.first;
      final position = (map.values.first * 1000).truncate();
      final updatedValue = AudioState(
        playbackState: state,
        position: Duration(milliseconds: position),
        prevPlayable: _handler.prevPlayable,
        nextPlayable: _handler.nextPlayable,
      );
      AudioServicePlatform.instance.setState(updatedValue);
      if (updatedValue.playbackState.isNotPlaying && previousState.isPlaying) {
        // AudioService.stop();
        // log('not playing now');
      } else if (updatedValue.playbackState.isPlaying &&
          previousState.isNotPlaying) {
        // log('playing now');
      }
      previousState = state;
    });
  }

  static final Stream<Duration> position = createPositionStream(
    minPeriod: const Duration(milliseconds: 250),
    maxPeriod: const Duration(milliseconds: 250),
  );

  static Stream<Duration> createPositionStream({
    int steps = 400,
    Duration minPeriod = const Duration(milliseconds: 100),
    Duration maxPeriod = const Duration(milliseconds: 500),
  }) {
    assert(minPeriod <= maxPeriod);
    assert(minPeriod > Duration.zero);
    Duration? last;

    late StreamController<Duration> controller;
    late StreamSubscription<Duration> durationSubscription;
    late StreamSubscription<PlaybackState> playbackStateSubscription;
    Timer? currentTimer;
    Duration duration() => _handler.duration;
    Duration step() {
      var s = duration() ~/ steps;
      if (s < minPeriod) s = minPeriod;
      if (s > maxPeriod) s = maxPeriod;
      return s;
    }

    void yieldPosition(Timer? timer) async {
      final currentTime = player.headlessInAppWebView.isRunning()
          ? await player.currentTime
          : 0;
      Duration time = Duration(
        milliseconds: (currentTime * 1000).truncate(),
      );
      if (last != time) {
        controller.add(last = time);
      }
    }

    controller = StreamController.broadcast(
      sync: true,
      onListen: () {
        durationSubscription = player.metadataStream
            .map((data) => data.duration)
            .listen((Duration duration) {
          currentTimer?.cancel();
          currentTimer = Timer.periodic(step(), yieldPosition);
        });
        playbackStateSubscription =
            player.playbackStateStream.listen((PlaybackState state) {
          yieldPosition(currentTimer);
        });
      },
      onCancel: () {
        durationSubscription.cancel();
        playbackStateSubscription.cancel();
      },
    );

    return controller.stream;
  }

  static Future<void> stop() async {
    // log("WakMusicFlutter: AudioService.stop() called");
    await AudioServicePlatform.instance.stopService();
  }
}

class _HandlerCallbacks extends AudioHandlerCallbacks {
  final _handlerCompleter = Completer<AudioHandler>();

  Future<AudioHandler> get handlerFuture => _handlerCompleter.future;

  void setHandler(AudioHandler handler) => _handlerCompleter.complete(handler);

  @override
  Future<void> play() async => (await handlerFuture).play();

  @override
  Future<void> pause() async => (await handlerFuture).pause();

  @override
  Future<void> stop() async => (await handlerFuture).stop();

  @override
  Future<void> toPrevious() async => (await handlerFuture).toPrevious();

  @override
  Future<void> toNext() async => (await handlerFuture).toNext();

  @override
  Future<void> seek(double position) async =>
      (await handlerFuture).seek(position);

  @override
  Future<void> onButtonClicked(MediaButton button) async =>
      (await handlerFuture).playPause();

  @override
  Future<void> onNotiClicked() async {}

  @override
  Future<void> onNotiDeleted() async {
    // log("WakMusicFlutter: onNotiDeleted() called");
    (await handlerFuture).stop();
    AudioService.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    // log("WakMusicFlutter: onTaskRemoved() called");
    (await handlerFuture).stop();
    AudioService.stop();
  }
}



  // static final _valueController = StreamController<AudioValue>.broadcast();
  // static final _durationController = StreamController<Duration>.broadcast();
  // static final _playbackStateController =
  //     StreamController<PlaybackState>.broadcast();
  // static AudioValue _value = const AudioValue();

  // static Stream<AudioValue> get stream => _valueController.stream;
  // static AudioValue get value => _value;

  // static StreamSubscription<AudioValue> listen(
  //   void Function(AudioValue event)? onData, {
  //   Function? onError,
  //   void Function()? onDone,
  //   bool? cancelOnError,
  // }) {
  //   return _valueController.stream.listen(
  //     (value) {
  //       _value = value;
  //       print('!::! ${value.toMap()}');
  //       onData?.call(value);
  //     },
  //     onError: onError,
  //     onDone: onDone,
  //     cancelOnError: cancelOnError,
  //   );
  // }
  // static Future<void> update({
  //   AudioMetadata? metadata,
  //   Duration? duration,
  //   PlaybackState? playbackState,
  // }) async {
  //   final updatedValue = AudioValue(
  //     metadata: metadata ?? value.metadata,
  //     duration: duration ?? value.duration,
  //     playbackState: playbackState ?? value.playbackState,
  //   );

  //   _valueController.add(updatedValue);
  //   _durationController.add(updatedValue.duration);
  //   _playbackStateController.add(updatedValue.playbackState);
  // }
