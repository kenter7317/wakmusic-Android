import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/enums/types.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class SongsAPI extends API {
  @override
  String get url => dotenv.get('API_SONGS');

  const SongsAPI();

  Future<List<Song>> newest({
    GroupType? group, // null일 때 monthly
  }) async {
    final url = dotenv.get('API_NEW');
    throw '';
  }

  // 보류
  Future<List<Song>> list() async {
    throw '';
  }

  Future<List<Song>> search({
    required SearchType type,
    required AlbumType sort,
    required String keyword,
  }) async {
    final url = dotenv.get('API_SEARCH');
    throw '';
  }
}
