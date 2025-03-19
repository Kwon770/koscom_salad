import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  AuthUtils._();

  static Future<int> getUserId() async {
    return await SharedPreferences.getInstance().then((prefs) {
      final id = prefs.getInt('userId');
      if (id == null) throw Exception('로그인이 필요합니다.');
      return id;
    });
  }

  static Future<void> setUserId(int userId) async {
    await SharedPreferences.getInstance().then((prefs) => prefs.setInt('userId', userId));
  }

  static Future<void> removeUserId() async {
    await SharedPreferences.getInstance().then((prefs) => prefs.remove('userId'));
  }
}
