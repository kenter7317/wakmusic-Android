import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/apis/api.dart';

class StaticAPI extends API {
  @override
  String get url => dotenv.get('BASE_URL_STATIC');

  const StaticAPI();

  Future<SubtitleController> lyrics({
    required String id,
  }) async {
    var controller = SubtitleController(
        provider: SubtitleProvider.fromNetwork(
            Uri.parse('$url/lyrics/$id.vtt')));
    await controller.initial();
    return controller;
  }
}
