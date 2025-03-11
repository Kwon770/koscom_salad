import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/utils/service_utils.dart';

class UserService {
  static Future<String> registerUser(String name) async {
    try {
      final response = await supabase
          .from('user')
          .insert({
            'name': name,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      await ServiceUtils.handleException(e, {'name': name}, '유저 등록 실패');
      rethrow;
    }
  }
}
