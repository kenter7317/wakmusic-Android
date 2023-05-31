import 'package:wakmusic/models_v2/event.dart';
import 'package:wakmusic/models_v2/member.dart';
import 'package:wakmusic/services/apis/api.dart';

class CommonAPI extends API {
  const CommonAPI();

  Future<List<Member>> get teams async {
    final url = dotenv.get('API_TEAMS');
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Member.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<Event> check({
    required AppVersion version,
  }) async {
    final url = dotenv.get('API_CHECK');
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return Event.fromJson(jsonDecode(response.body));
    }

    assert(status.isError);
    throw status;
  }
}
