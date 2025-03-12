import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/utils/service_utils.dart';

// state
// BOOKED
// PICKED_UP
// TAKE_HOME
// SPOILED

class SaladService {
  SaladService._();

  static Future<void> createSalad(String userId, String appointmentId) async {
    try {
      await supabase.from('salad').insert({
        'user_id': userId,
        'appointment_id': appointmentId,
      });
    } catch (e) {
      await ServiceUtils.handleException(e, {'user_id': userId, 'appointment_id': appointmentId});
    }
  }

  static Future<void> pickUpSalad(String userId) async {
    try {
      await supabase.from('salad').update({'state': 'PICKED_UP'}).eq('user_id', userId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'user_id': userId});
    }
  }

  static Future<void> takeHomeSalad(String userId) async {
    try {
      await supabase.from('salad').update({'state': 'TAKE_HOME'}).eq('user_id', userId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'user_id': userId});
    }
  }

  static Future<void> deleteSalad(String appointmentId) async {
    try {
      await supabase.from('salad').delete().eq('appointment_id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'appointment_id': appointmentId});
    }
  }
}
