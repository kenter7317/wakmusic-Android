import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/models_v2/song.dart';

class ArtistAPI extends API {
  @override
  String get url => dotenv.get('API_ARTIST');

  const ArtistAPI();

  Future<List<Artist>> get list async {
    final response = await request('$url/list', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Artist.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<List<Song>> albums({
    required String id,
    required AlbumType sort,
    int start = 0,
  }) async {
    final response = await request(
      '$url/albums'
      '?id=$id'
      '&sort=${sort.eng}'
      '&start=$start',
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
