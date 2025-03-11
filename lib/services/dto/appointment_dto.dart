class AppointmentDto {
  final String title;
  final DateTime date;
  final bool notifyOnPickup;
  final bool notifyOnHome;
  // final String userId = supabase.auth.currentUser!.id;
  final String userId = 'd3b6f1a4-9c2e-4e3d-bc77-5a9f6e2d8b10';

  AppointmentDto({
    required this.title,
    required this.date,
    required this.notifyOnPickup,
    required this.notifyOnHome,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'notify_on_pickup': notifyOnPickup,
        'notify_on_home': notifyOnHome,
        'user_id': userId,
      };
}
