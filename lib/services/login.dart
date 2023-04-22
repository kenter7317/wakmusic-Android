import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Login {
  naver('네이버', true, NaverLoginService()),
  google('구글', true, GoogleLoginService()),
  apple('애플', false, AppleLoginService());

  const Login(this.locale, this.enabled, this.service);
  final String locale;
  final bool enabled;
  final LoginService service;

  static get on => Login.values.where((e) => e.enabled).toList();

  factory Login.byName(String name) =>
      Login.values.singleWhere((e) => e.name == name);
}

const _storage = FlutterSecureStorage();

class NaverLoginService implements LoginService {
  const NaverLoginService();

  static const Login _platform = Login.naver;

  @override
  Login get platform => _platform;

  Future<bool> isFirst() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isFirst') ?? true) {
      await prefs.setBool('isFirst', false);
      return true;
    }
    return false;
  }

  @override
  Future<String?> login() async {
    try {
      if (!await isFirst() && await FlutterNaverLogin.isLoggedIn) {
        final res = await FlutterNaverLogin.currentAccount();
        return res.id;
      }

      final NaverLoginResult res = await FlutterNaverLogin.logIn();

      if (res.status != NaverLoginStatus.loggedIn) {
        return null;
      }
      return res.account.id;
    } catch (e) {
      await FlutterNaverLogin.logOutAndDeleteToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await FlutterNaverLogin.logOut();
    _storage.delete(key: 'token');
  }
}

class GoogleLoginService implements LoginService {
  const GoogleLoginService();

  static const Login _platform = Login.google;

  @override
  Login get platform => _platform;

  @override
  Future<String?> login() async {
    final sign = GoogleSignIn();
    if (await sign.isSignedIn()) {
      await sign.signInSilently();
      return sign.currentUser?.id;
    }

    final res = await sign.signIn();
    return res?.id;
  }

  @override
  Future<void> logout() async {
    final sign = GoogleSignIn();

    await sign.signOut();
    _storage.delete(key: 'token');
  }
}

class AppleLoginService implements LoginService {
  const AppleLoginService();

  static const Login _platform = Login.apple;

  @override
  Login get platform => _platform;

  @override
  Future<String> login() async {
    return '';
  }

  @override
  Future<void> logout() async {
    _storage.delete(key: 'token');
  }
}

abstract class LoginService {
  Login get platform;

  Future<String?> login();
  Future<void> logout();
}