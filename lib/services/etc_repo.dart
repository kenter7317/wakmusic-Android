import 'package:shared_preferences/shared_preferences.dart';

class EtcRepository {
  final String authKey = "auth_AmadeusChoi";

  Future<bool> appAuthorityCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(authKey);

    if (value == null || value.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> appAuthoritySave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(authKey, authKey);
  }
}
