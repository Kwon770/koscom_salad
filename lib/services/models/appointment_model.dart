class AppointmentModel {
  final int id;
  final int userId;
  final DateTime date;
  final String title;
  final bool notifyOnApply;
  final bool notifyOnPickup;
  final bool notifyOnHome;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.notifyOnApply,
    required this.notifyOnPickup,
    required this.notifyOnHome,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      notifyOnApply: json['notify_on_apply'] as bool,
      notifyOnPickup: json['notify_on_pickup'] as bool,
      notifyOnHome: json['notify_on_home'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'title': title,
        'notify_on_apply': notifyOnApply,
        'notify_on_pickup': notifyOnPickup,
        'notify_on_home': notifyOnHome,
      };
}
