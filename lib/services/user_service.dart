import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/service_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<int> registerUser(String name) async {
    try {
      final response = await supabase
          .from('user')
          .insert({
            'name': name,
          })
          .select()
          .single();

      return response['id'] as int;
    } catch (e) {
      await ServiceUtils.handleException(e, {'name': name}, '유저 등록 실패');
      rethrow;
    }
  }

  static Future<String?> getUserName() async {
    final userId = await AuthUtils.getUserId();

    try {
      final response = await supabase.from('user').select('name').eq('id', userId).single();

      return response['name'] as String;
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': userId});
      return null;
    }
  }

  static Future<void> changeUserName(String newName) async {
    final userId = await AuthUtils.getUserId();

    try {
      await supabase.from('user').update({'name': newName}).eq('id', userId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': userId, 'name': newName});
      rethrow;
    }
  }

  static Future<void> updateFCMToken(String fcmToken) async {
    final userId = await AuthUtils.getUserId();

    try {
      await supabase.from('user').update({'fcm_token': fcmToken}).eq('id', userId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': userId, 'fcmToken': fcmToken});
      rethrow;
    }
  }

  static Future<void> deleteUserSoftly() async {
    final userId = await AuthUtils.getUserId();

    try {
      await supabase.from('user').update({'is_deleted': true}).eq('id', userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': userId}, '회원 탈퇴 실패');
      rethrow;
    }
  }
}
