import 'package:shared_preferences/shared_preferences.dart';

class EtcRepository {

  final String AuthKey = "auth";

  Future<bool> appAuthorityCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(AuthKey);

    if(value == null || value.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> appAuthoritySave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthKey, AuthKey);
  }
}
