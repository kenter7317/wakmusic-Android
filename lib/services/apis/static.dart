import 'package:wakmusic/services/apis/api.dart';

class StaticAPI extends API {
  @override
  String get url => dotenv.get('BASE_URL_STATIC');

  const StaticAPI();
}
