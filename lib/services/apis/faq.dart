import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/services/apis/api.dart';

class FAQAPI extends API {
  @override
  String get url => dotenv.get('API_FAQ');

  const FAQAPI();

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

  Future<List<FAQ>> get list async {
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => FAQ.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }
}
