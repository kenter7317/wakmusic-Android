import 'package:audio_service/models/enums.dart';

abstract class AudioHandlerCallbacks {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> toPrevious();
  Future<void> toNext();
  Future<void> seek(double position);
  Future<void> onButtonClicked(MediaButton button);
  Future<void> onNotiClicked();
  Future<void> onNotiDeleted();
  Future<void> onTaskRemoved();
}
