import 'package:koscom_salad/constants/salad_state.dart';

class SaladModel {
  final int id;
  final int userId;
  final int appointmentId;
  final SaladState state;
  final DateTime date;

  SaladModel({
    required this.id,
    required this.userId,
    required this.appointmentId,
    required this.state,
    required this.date,
  });

  factory SaladModel.fromJson(Map<String, dynamic> json) {
    return SaladModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      appointmentId: json['appointment_id'] as int,
      state: SaladState.values.byName(json['state'] as String),
      date: DateTime.parse(json['appointment']['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'appointment_id': appointmentId,
        'state': state.name,
        'date': date.toIso8601String(),
      };
}
