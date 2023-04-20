import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakmusic/models/user.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/services/login.dart';

class UserRepository {
  final FlutterSecureStorage _storage;
  final API _api;

  UserRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(
        // aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
  })  : _storage = storage,
        _api = API();

  Future<String?> get _token => _storage.read(key: 'token');
  Future<bool> get isLoggedIn async => await _token != null;

  Future<User> getUser({Login? platform}) async {
    final cached = await _token;
    assert(platform != null || cached != null);
    try {
      if (cached != null) {
        return await _api.getUser(token: cached);
      }

      final newToken = await _api.getToken(platform!);
      _storage.write(key: 'token', value: newToken);

      return await _api.getUser(token: newToken);
    } catch (e) {
      _storage.delete(key: 'token');
      rethrow;
    }
  }

  Future<bool> setUserProfile(String profile) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.setUserProfile(profile, token: token);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> setUserName(String name) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.setUserName(name, token: token);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
