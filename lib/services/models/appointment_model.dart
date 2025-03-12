class AppointmentModel {
  final String id;
  final String title;
  final DateTime date;
  final bool notifyOnPickup;
  final bool notifyOnHome;

  AppointmentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        date = DateTime.parse(json['date']),
        notifyOnPickup = json['notify_on_pickup'],
        notifyOnHome = json['notify_on_home'];
}
