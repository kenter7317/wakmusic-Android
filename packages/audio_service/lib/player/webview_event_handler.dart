import 'dart:async';

import 'package:audio_service/audio_handler.dart';
import 'package:audio_service/models/enums.dart';
import 'package:audio_service/player/youtube_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewEventHandler {
  WebViewEventHandler(this.controller) {
    final events = <String, void Function(Object)>{
      'Ready': onReady,
      'StateChange': onStateChange,
      'PlayerError': onError,
      'PlaybackQualityChange': onPlaybackQualityChange,
    };

    headlessInAppWebView = HeadlessInAppWebView(
      initialSize: const Size(480, 270),
      initialFile: 'packages/audio_service/assets/player.html',
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false,
        ),
        android: AndroidInAppWebViewOptions(),
      ),
      onWebViewCreated: (controller) {
        events.forEach((k, v) {
          controller.addJavaScriptHandler(handlerName: k, callback: v);
        });
        this.controller.init(controller);
      },
    );
  }

  final YoutubeAudioPlayer controller;

  late final HeadlessInAppWebView headlessInAppWebView;

  Completer<void> _readyCompleter = Completer();

  void onReady(Object data) {
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  Future<void> onPlaybackQualityChange(Object data) async {}

  Future<void> onStateChange(Object data) async {
    final stateCode = (data as List)[0];

    final playbackState = PlaybackState.byCode(stateCode);

    if (playbackState == PlaybackState.playing) {
      final duration = await controller.duration;
      controller.update(
        duration: Duration(milliseconds: (duration * 1000).truncate()),
        playbackState: playbackState,
      );
    } else {
      controller.update(playbackState: playbackState);
    }
  }

  void onApiChange(Object? data) {}

  void onError(Object data) {
    final error = YoutubeError.byCode((data as List)[0]);

    controller.update(error: error);
  }

  Future<void> get isReady => _readyCompleter.future;

  void reset() => _readyCompleter = Completer();
}
