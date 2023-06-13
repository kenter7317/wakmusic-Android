import 'package:wakmusic/services/apis/api.dart';

class LikeAPI extends API {
  @override
  String get url => dotenv.get('API_LIKE');

  const LikeAPI();

  Future<int> get({
    required String songId,
  }) async {
    final response = await request('$url/$songId', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return jsonDecode(response.body)['likes'];
    }

    assert(status.isError);
    throw status;
  }

  Future<int> add({
    required String songId,
    required String token,
  }) async {
    final response = await request(
      '$url/$songId/addLike',
      method: HttpMethod.post,
      token: token
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['likes'];
    }

    assert(status.isError);
    throw status;
  }

  Future<int> remove({
    required String songId,
    required String token,
  }) async {
    final response = await request(
      '$url/$songId/removeLike',
      method: HttpMethod.post,
      token: token
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['likes'];
    }

    assert(status.isError);
    throw status;
  }
}
