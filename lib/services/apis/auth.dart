import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:wakmusic/models_v2/user.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/services/login.dart';

class AuthAPI extends API {
  @override
  String get url => dotenv.get('API_AUTH');

  const AuthAPI();

  Future<String> login({
    required Login provider,
  }) async {
    final token = await provider.service.login();
    if (token == null) {
      throw WakError.loginCancelled;
    }

    final url = dotenv.get('API_LOGIN');
    final response = await request(
      url,
      method: HttpMethod.post,
      body: {
        'token': token,
        'provider': provider.name,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['token'];
    }

    assert(status.isError);
    throw status;
  }

  Future<User> get({
    required String token,
  }) async {
    final response = await request(url, method: HttpMethod.get, token: token);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      final user = User.fromJson(jsonDecode(response.body));
      final analytics = FirebaseAnalytics.instance;
      if (user.first) {
        analytics.logSignUp(signUpMethod: user.platform.name);
      } else {
        analytics.logLogin(loginMethod: user.platform.name);
      }

      analytics.setUserId(id: '${user.displayName}#${user.id.substring(0, 5)}');
      return user;
    }

    assert(status.isError);
    throw status;
  }

  Future<void> remove({
    required String token,
  }) async {
    final response = await request(
      '$url/remove',
      method: HttpMethod.delete,
      token: token,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.delete)) {
      return;
    }

    assert(status.isError);
    throw status;
  }
}
