import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/callbacks.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_service_method_channel.dart';

abstract class AudioServicePlatform extends PlatformInterface {
  /// Constructs a AudioServicePlatform.
  AudioServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioServicePlatform _instance = MethodChannelAudioService();

  /// The default instance of [AudioServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioService].
  static AudioServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioServicePlatform] when
  /// they register themselves.
  static set instance(AudioServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> configure() {
    throw UnimplementedError('configure() has not been implemented.');
  }

  Future<void> setState(AudioState request) {
    throw UnimplementedError('setState() has not been implemented.');
  }

  Future<void> setMetadata(AudioMetadata request) {
    throw UnimplementedError('setMetadata() has not been implemented.');
  }

  Future<void> stopService() {
    throw UnimplementedError('stopService() has not been implemented.');
  }

  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    throw UnimplementedError('setHandlerCallbacks() has not been implemented.');
  }
}
