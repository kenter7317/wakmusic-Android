import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum Login {
  naver('네이버', NaverLoginService()),
  google('구글', GoogleLoginService()),
  apple('애플', AppleLoginService());

  const Login(this.locale, this.service);
  final String locale;
  final LoginService service;
}

const _storage = FlutterSecureStorage();

class NaverLoginService implements LoginService {
  const NaverLoginService();

  static const Login _platform = Login.naver;

  @override
  Login get platform => _platform;

  @override
  Future<String?> login() async {
    if (await FlutterNaverLogin.isLoggedIn) {
      final res = await FlutterNaverLogin.currentAccount();
      return res.id;
    }

    final NaverLoginResult res = await FlutterNaverLogin.logIn();

    if (res.status == NaverLoginStatus.cancelledByUser) {
      return null;
    }
    return res.account.id;
  }

  @override
  Future<String> logout() async {
    final NaverLoginResult res = await FlutterNaverLogin.logOut();
    return res.account.id;
  }
}

class GoogleLoginService implements LoginService {
  const GoogleLoginService();

  static const Login _platform = Login.google;

  @override
  Login get platform => _platform;

  @override
  Future<String> login() async {
    return '';
  }

  @override
  Future<String> logout() async {
    return '';
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
  Future<String> logout() async {
    return '';
  }
}

abstract class LoginService {
  Login get platform;

  Future<String?> login();
  Future<String?> logout();
}
