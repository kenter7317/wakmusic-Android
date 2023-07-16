import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/callbacks.dart';
import 'package:audio_service/models/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

import 'audio_service_platform_interface.dart';

/// An implementation of [AudioServicePlatform] that uses method channels.
class MethodChannelAudioService extends AudioServicePlatform {
  final MethodChannel _clientChannel =
      const MethodChannel('waktaverse.music.audio_service.client.methods');
  @visibleForTesting
  final MethodChannel handlerChannel =
      const MethodChannel('waktaverse.music.audio_service.handler.methods');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await _clientChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> configure() async {
    await _clientChannel.invokeMethod<void>('configure');
  }

  @override
  Future<void> setState(AudioState request) async {
    await handlerChannel.invokeMethod<void>('setState', request.toMap());
  }

  @override
  Future<void> setMetadata(AudioMetadata request) async {
    await handlerChannel.invokeMethod<void>('setMetadata', request.toMap());
  }

  @override
  Future<void> stopService() async {
    await handlerChannel.invokeMethod<void>('stopService');
  }

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    handlerChannel.setMethodCallHandler((call) async {
      return handlerCallbacksCallHandler(callbacks, call);
    });
  }

  @visibleForTesting
  Future<dynamic> handlerCallbacksCallHandler(
    AudioHandlerCallbacks callbacks,
    MethodCall call,
  ) async {
    // log("tqlllj ${call.method}");
    switch (call.method) {
      case 'play':
        await callbacks.play();
        return null;
      case 'pause':
        await callbacks.pause();
        return null;
      case 'stop':
        await callbacks.stop();
        return null;
      case 'toPrevious':
        await callbacks.toPrevious();
        return null;
      case 'toNext':
        await callbacks.toNext();
        return null;
      case 'seek':
        await callbacks.seek((call.arguments['position'] as int) / 1000);
        return null;
      case 'onButtonClicked':
        await callbacks.onButtonClicked(
          MediaButton.values[call.arguments['button'] as int],
        );
        return null;
      case 'onNotiClicked':
        await callbacks.onNotiClicked();
        return null;
      case 'onNotiDeleted':
        await callbacks.onNotiDeleted();
        return null;
      case 'onTaskRemoved':
        await callbacks.onTaskRemoved();
        return null;
      default:
        throw PlatformException(
          code: 'unimplemented',
          message: 'Method not implemented: ${call.method}',
        );
    }
  }
}
