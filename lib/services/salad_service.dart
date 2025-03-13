import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/services/models/salad_model.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/service_utils.dart';

// saladState enum = state column table
// booked
// pickedUp
// takeHome
// spoiled

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

  static Future<List<SaladModel>> getSalads(int year, int month) async {
    final String userId = await AuthUtils.getUserId();
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    try {
      final salads = await supabase
          .from('salad')
          .select('*, appointment!inner(date)')
          .eq('appointment.user_id', userId)
          .gte('appointment.date', startDate.toIso8601String())
          .lte('appointment.date', endDate.toIso8601String());

      return salads.map((salad) => SaladModel.fromJson(salad)).toList();
    } catch (e) {
      await ServiceUtils.handleException(e, {'user_id': userId, 'year': year, 'month': month});
      return [];
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

  static Future<void> deleteSaladByAppointmentId(String appointmentId) async {
    try {
      await supabase.from('salad').delete().eq('appointment_id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'appointment_id': appointmentId});
    }
  }
}
