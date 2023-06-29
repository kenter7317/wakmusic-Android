import 'package:firebase_analytics/firebase_analytics.dart';
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

class NaverLoginService extends LoginService {
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
        final res = await FlutterNaverLogin.currentAccessToken;
        return res.accessToken;
      }

      final NaverLoginResult res = await FlutterNaverLogin.logIn();

      if (res.status != NaverLoginStatus.loggedIn) {
        return null;
      }

      final token = await FlutterNaverLogin.currentAccessToken;
      return token.accessToken;
    } catch (e) {
      await FlutterNaverLogin.logOutAndDeleteToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await FlutterNaverLogin.logOut();
    super.logout();
  }

  @override
  Future<void> remove() async {
    await FlutterNaverLogin.logOutAndDeleteToken();
    super.remove();
  }
}

class GoogleLoginService extends LoginService {
  const GoogleLoginService();

  static const Login _platform = Login.google;

  @override
  Login get platform => _platform;

  @override
  Future<String?> login() async {
    final sign = GoogleSignIn();
    final user = (await sign.isSignedIn())
        ? await sign.signInSilently()
        : await sign.signIn();

    final auth = await user?.authentication;
    return auth?.accessToken;
  }

  @override
  Future<void> logout() async {
    final sign = GoogleSignIn();

    await sign.signOut();
    super.logout();
  }

  @override
  Future<void> remove() async {
    final sign = GoogleSignIn();

    await sign.disconnect();
    super.remove();
  }
}

class AppleLoginService extends LoginService {
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
    super.logout();
  }

  @override
  Future<void> remove() async {
    super.remove();
  }
}

abstract class LoginService {
  const LoginService();

  Login get platform;

  Future<String?> login();

  Future<void> logout() async {
    _storage.delete(key: 'token');
    FirebaseAnalytics.instance.setUserId(id: null);
  }

  Future<void> remove() async {
    _storage.delete(key: 'token');
    FirebaseAnalytics.instance.setUserId(id: null);
  }
}
