import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';
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
}
