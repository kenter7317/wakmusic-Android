import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/enums/http_method.dart';
import 'package:wakmusic/models_v2/enums/http_status.dart';
import 'package:wakmusic/models_v2/member.dart';
import 'package:wakmusic/services/apis/api.dart';

class CommonAPI extends API {
  const CommonAPI();

  Future<List<Member>> teams() async {
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

  Future<void> check() async {}
}
