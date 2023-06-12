import 'package:audio_service/models/audio_value.dart';
import 'package:audio_service/models/callbacks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service/audio_service_platform_interface.dart';
import 'package:audio_service/audio_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioServicePlatform
    with MockPlatformInterfaceMixin
    implements AudioServicePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> configure() async {}

  @override
  Future<void> setState(AudioState request) async {}

  @override
  Future<void> setMetadata(AudioMetadata request) async {}

  @override
  Future<void> stopService() async {}

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) async {}
}

void main() {
  final AudioServicePlatform initialPlatform = AudioServicePlatform.instance;

  test('$MethodChannelAudioService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioService>());
  });

  test('getPlatformVersion', () async {
    // AudioService audioServicePlugin = AudioService();
    MockAudioServicePlatform fakePlatform = MockAudioServicePlatform();
    AudioServicePlatform.instance = fakePlatform;

    expect(await AudioService.getPlatformVersion(), '42');
  });
}
