import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audio_service/audio_handler.dart';
import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/enums.dart';
import 'package:audio_service/player/webview_event_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef JSON = Map<String, dynamic>;

class YoutubeAudioPlayer {
  YoutubeAudioPlayer(this.handler, String html) {
    _eventHandler = WebViewEventHandler(this, html);
    headlessInAppWebView = _eventHandler.headlessInAppWebView;
    headlessInAppWebView.run();
  }

  Completer<InAppWebViewController> _webViewCompleter = Completer();
  late final WebViewEventHandler _eventHandler;
  late final HeadlessInAppWebView headlessInAppWebView;
  late final AudioHandler handler;
  Future<InAppWebViewController> get webViewController =>
      _webViewCompleter.future;

  final StreamController<AudioMetadata> _metadataController =
      StreamController.broadcast(sync: true);
  final StreamController<PlaybackState> _playbackStateController =
      StreamController.broadcast(sync: true);

  Stream<AudioMetadata> get metadataStream => _metadataController.stream;
  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  String _id = '';
  String _title = '';
  String _artist = '';
  Duration _start = const Duration();
  Duration? _end;

  Future<void> loadVideoById({
    required String id,
    String title = '',
    String artist = '',
    Duration? start,
    Duration? end,
  }) async {
    _id = id;
    _title = title;
    _artist = artist;
    _start = start ?? const Duration();
    _end = end;
    return _evalMap(
      'loadVideoById',
      args: {
        'videoId': id,
        if (start != null) 'startSeconds': start.inSeconds,
        if (end != null) 'endSeconds': end.inSeconds,
      },
    );
  }

  Future<void> _evalMap(String func, {JSON? args}) async {
    await _eventHandler.isReady;
    final controller = await _webViewCompleter.future;
    return controller.evaluateJavascript(
      source: 'player.$func(${jsonEncode(args)});',
    );
  }

  Future<void> _eval(String func, {String args = ''}) async {
    await _eventHandler.isReady;
    final controller = await _webViewCompleter.future;
    return controller.evaluateJavascript(source: 'player.$func($args);');
  }

  Future<dynamic> _run(String func, {String args = ''}) async {
    await _eventHandler.isReady;

    final controller = await _webViewCompleter.future;
    return controller.evaluateJavascript(source: 'player.$func($args);');
  }

  Future<PlaybackState> get playbackState async {
    final stateCode = await _run('getPlayerState');

    return PlaybackState.byCode(stateCode);
  }

  Future<double> get duration async {
    final duration = await _run('getDuration');
    final result = double.tryParse('$duration') ?? _start.inSeconds.toDouble();
    return result - _start.inSeconds;
  }

  Future<double> get currentTime async {
    final time = await _run('getCurrentTime');
    final result = double.tryParse('$time') ?? _start.inSeconds.toDouble();
    return result - _start.inSeconds;
  }

  Future<void> pauseVideo() {
    return _eval('pauseVideo');
  }

  Future<void> playVideo() {
    return _eval('playVideo');
  }

  Future<void> seekTo({required double seconds, bool allowSeekAhead = false}) {
    // log('seconds: $seconds');
    return _eval('seekTo', args: '$seconds, $allowSeekAhead');
  }

  Future<void> stopVideo() {
    _metadataController.add(AudioMetadata.nothing());
    return _eval('stopVideo');
  }

  Future<void> init(InAppWebViewController controller) async {
    _webViewCompleter = Completer();
    _webViewCompleter.complete(controller);
    headlessInAppWebView.run();

    _eventHandler.reset();
    await onInit();
  }

  void update({
    Duration? duration,
    PlaybackState? playbackState,
    YoutubeError? error,
  }) {
    if (error != null) log('Youtube Player ERROR :: ${error.code}');
    if (duration != null) {
      final metadata = AudioMetadata(
        id: _id,
        title: _title,
        artist: _artist,
        duration:
            (_end != null && _end! <= duration) ? _end! - _start : duration,
      );
      _metadataController.add(metadata);
    }
    if (playbackState != null) {
      _playbackStateController.add(playbackState);
    }
  }

  FutureOr<void> Function() onInit = () {};

  void close() {
    // AudioService.stop();
    headlessInAppWebView.dispose();
  }
}
