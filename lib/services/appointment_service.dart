import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';
import 'package:koscom_salad/services/models/appointment_model.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/service_utils.dart';

class AppointmentService {
  AppointmentService._();

  static Future<void> createAppointment(AppointmentDto appointmentDto) async {
    try {
      await supabase.from('appointment').insert(appointmentDto.toJson());
    } catch (e) {
      await ServiceUtils.handleException(e, appointmentDto.toJson());
    }
  }

  static Future<AppointmentModel?> getAppointment(String appointmentId) async {
    try {
      final response = await supabase.from('appointment').select('*').eq('id', appointmentId).single();

      return AppointmentModel.fromJson(response);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': appointmentId});
      return null;
    }
  }

  static Future<void> updateAppointment(String appointmentId, AppointmentDto appointmentDto) async {
    try {
      await supabase.from('appointment').update(appointmentDto.toJson()).eq('id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, appointmentDto.toJson(), '{id: $appointmentId}');
    }
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await supabase.from('appointment').delete().eq('id', appointmentId);
    } catch (e) {
      await ServiceUtils.handleException(e, {'id': appointmentId});
    }
  }

  static Future<List<AppointmentModel>> getAppointments() async {
    try {
      final userId = await AuthUtils.getUserId();
      final response =
          await supabase.from('appointment').select('*').eq('user_id', userId).order('date', ascending: false);

      return response.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      await ServiceUtils.handleException(e, {});
      return [];
    }
  }
}
