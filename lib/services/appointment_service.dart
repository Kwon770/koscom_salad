import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';
import 'package:koscom_salad/utils/webhook_agent.dart';

class AppointmentService {
  AppointmentService._();

  static Future<void> createAppointment(AppointmentDto appointmentDto) async {
    try {
      await supabase.from('appointment').insert(appointmentDto.toJson());
    } catch (e) {
      await _handleException(e as Exception, appointmentDto.toJson());
      rethrow;
    }
  }

  static Future<void> _handleException(Exception error, Map<String, dynamic> data) async {
    await WebhookAgent.sendErrorToDiscord(error, data);
    await DialogUtils.showErrorDialog();
  }
}
