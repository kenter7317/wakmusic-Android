import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/services/apis/api.dart';

class UserAPI extends API {
  @override
  String get url => dotenv.get('API_USER');

  const UserAPI();
}
