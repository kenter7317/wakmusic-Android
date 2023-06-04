import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class SongsAPI extends API {
  @override
  String get url => dotenv.get('API_SONGS');

  const SongsAPI();

  Future<List<Song>> newest({
    GroupType? group,
  }) async {
    final url = dotenv.get('API_NEW');
    final response = await request(
      '$url/${group?.name ?? 'monthly'}',
      method: HttpMethod.get,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
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
    final response = await request(
      '$url/search'
      '?type=${type.name}'
      '&sort=${sort.name}'
      '&keyword=$keyword',
      method: HttpMethod.get,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }
}
