import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';

class NoticeAPI extends API {
  @override
  String get url => dotenv.get('API_NOTICE');

  const NoticeAPI();

  Future<List<Category>> get categories async {
    final response = await request('$url/categories', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Category.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<List<Notice>> get display async {
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Notice.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<List<Notice>> get all async {
    final response = await request('$url/all', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Notice.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }
}
