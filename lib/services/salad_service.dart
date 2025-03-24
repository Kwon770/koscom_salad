import 'package:koscomsalad/main.dart';
import 'package:koscomsalad/services/models/salad_model.dart';
import 'package:koscomsalad/utils/auth_utils.dart';
import 'package:koscomsalad/utils/service_utils.dart';

// saladState enum = state column table
// booked
// pickedUp
// takeHome
// spoiled

class SaladService {
  SaladService._();

  static Future<void> createSalad(int userId, int appointmentId) async {
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
    final userId = await AuthUtils.getUserId();
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

  static Future<void> applySalad(int saladId) async {
    try {
      await supabase.from('salad').update({'state': 'applied'}).eq('id', saladId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'salad_id': saladId});
    }
  }

  static Future<void> pickUpSalad(int saladId) async {
    try {
      await supabase.from('salad').update({'state': 'pickedUp'}).eq('id', saladId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'salad_id': saladId});
    }
  }

  static Future<void> takeHomeSalad(int saladId) async {
    try {
      await supabase.from('salad').update({'state': 'takeHome'}).eq('id', saladId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'salad_id': saladId});
    }
  }

  static Future<void> spoilSalad(int saladId) async {
    try {
      await supabase.from('salad').update({'state': 'spoiled'}).eq('id', saladId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'salad_id': saladId});
    }
  }

  static Future<void> deleteSalad(int saladId) async {
    try {
      await supabase.from('salad').delete().eq('id', saladId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'salad_id': saladId});
    }
  }

  static Future<void> deleteSaladByAppointmentId(int appointmentId) async {
    try {
      await supabase.from('salad').delete().eq('appointment_id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'appointment_id': appointmentId});
    }
  }
}
