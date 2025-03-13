import 'package:koscom_salad/constants/salad_state.dart';

class SaladModel {
  final String id;
  final String userId;
  final String appointmentId;
  final SaladState state;
  final DateTime date;

  SaladModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        appointmentId = json['appointment_id'],
        state = SaladState.values.byName(json['state']),
        date = DateTime.parse(json['appointment']['date']);
}
