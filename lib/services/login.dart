import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum Login {
  naver('네이버', NaverLoginService()),
  google('구글', GoogleLoginService()),
  apple('애플', AppleLoginService());

  const Login(this.locale, this.service);
  final String locale;
  final LoginService service;

  factory Login.byName(String name) =>
      Login.values.singleWhere((e) => e.name == name);
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
  Future<void> logout() async {
    await FlutterNaverLogin.logOut();
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
  Future<void> logout();
}
