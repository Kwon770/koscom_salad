class AppointmentDto {
  final String title;
  final DateTime date;
  final bool notifyOnPickup;
  final bool notifyOnHome;
  final String userId;

  AppointmentDto({
    required this.title,
    required this.date,
    required this.notifyOnPickup,
    required this.notifyOnHome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'notify_on_pickup': notifyOnPickup,
        'notify_on_home': notifyOnHome,
        'user_id': userId,
      };
}
