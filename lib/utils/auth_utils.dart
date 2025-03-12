import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  AuthUtils._();

  static Future<String> getUserId() async {
    return await SharedPreferences.getInstance().then((prefs) {
      final id = prefs.getString('userId');
      if (id == null) throw Exception('로그인이 필요합니다.');
      return id;
    });
  }

  static Future<void> setUserId(String userId) async {
    await SharedPreferences.getInstance().then((prefs) => prefs.setString('userId', userId));
  }

  static Future<void> removeUserId() async {
    await SharedPreferences.getInstance().then((prefs) => prefs.remove('userId'));
  }
}
