import 'package:koscomsalad/main.dart';
import 'package:koscomsalad/services/dto/appointment_dto.dart';
import 'package:koscomsalad/services/models/appointment_model.dart';
import 'package:koscomsalad/utils/auth_utils.dart';
import 'package:koscomsalad/utils/service_utils.dart';

class AppointmentService {
  AppointmentService._();

  static Future<int> createAppointment(AppointmentDto appointmentDto) async {
    try {
      final int createdAppointmentId = await supabase
          .from('appointment')
          .insert(appointmentDto.toJson())
          .select()
          .single()
          .then((value) => value['id']);

      return createdAppointmentId;
    } catch (e) {
      await ServiceUtils.handleException(e, appointmentDto.toJson());
      rethrow;
    }
  }

  static Future<AppointmentModel?> getAppointment(int appointmentId) async {
    try {
      final response = await supabase.from('appointment').select('*').eq('id', appointmentId).single();

      return AppointmentModel.fromJson(response);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': appointmentId});
      return null;
    }
  }

  static Future<void> updateAppointment(int appointmentId, AppointmentDto appointmentDto) async {
    try {
      await supabase.from('appointment').update(appointmentDto.toJson()).eq('id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, appointmentDto.toJson(), '{id: $appointmentId}');
    }
  }

  static Future<void> deleteAppointment(int appointmentId) async {
    try {
      await supabase.from('appointment').delete().eq('id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': appointmentId});
    }
  }

  static Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      final userId = await AuthUtils.getUserId();
      final response = await supabase
          .from('appointment')
          .select('*')
          .eq('user_id', userId)
          .gte('date',
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String()) // 0시 0분 기준
          .order('date', ascending: true);

      return response.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      await ServiceUtils.handleException(e, {});
      return [];
    }
  }
}
