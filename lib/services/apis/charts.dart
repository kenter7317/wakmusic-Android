import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class ChartsAPI extends API {
  @override
  String get url => dotenv.get('API_CHARTS');

  const ChartsAPI();

  Future<List<Song>> top({
    required ChartType type,
    int limit = 100,
  }) async {
    final response = await request(
      '$url'
      '?type=${type.name}'
      '&limit=$limit',
      method: HttpMethod.get,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e, type: type))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<DateTime> get updatedTime async {
    final url = dotenv.get('API_UPDATED');

    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return msEpoch(int.parse(response.body) * 1000);
    }

    assert(status.isError);
    throw status;
  }
}
