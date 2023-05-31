import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/user.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/services/login.dart';

class AuthAPI extends API {
  @override
  String get url => dotenv.get('API_AUTH');

  const AuthAPI();

  Future<String> login({
    required String id,
    required Login provider,
  }) async {
    final url = dotenv.get('API_LOGIN');
    throw '';
  }

  Future<User> get({
    required String token,
  }) async {
    throw '';
  }

  Future<void> remove({
    required String token,
  }) async {
    throw '';
  }
}
