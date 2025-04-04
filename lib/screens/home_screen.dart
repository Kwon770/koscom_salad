import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:koscomsalad/constants/image_paths.dart';
import 'package:koscomsalad/screens/setting_screen.dart';
import 'package:koscomsalad/services/models/appointment_model.dart';
import 'package:koscomsalad/services/models/salad_model.dart';
import 'package:koscomsalad/services/salad_service.dart';
import 'package:koscomsalad/services/user_service.dart';
import 'package:koscomsalad/utils/dialog_utils.dart';
import 'package:koscomsalad/widgets/calendar.dart';
import 'package:koscomsalad/widgets/upcoming_salad_list.dart';
import 'package:koscomsalad/services/appointment_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentDate = DateTime.now();
  late Future<List<AppointmentModel>> _appointmentsFuture;
  late Future<List<SaladModel>> _saladsFuture;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      updateFCMToken();
    });

    Alarm.ringing.listen((AlarmSet alarmSet) {
      for (var alarm in alarmSet.alarms) {
        DialogUtils.showAlertDialog(
          ImagePaths.salad,
          title: alarm.notificationSettings.title,
          message: alarm.notificationSettings.body,
          buttonText: '알림 종료',
          onButtonPressed: () {
            Alarm.stop(alarm.id);
            Navigator.pop(context);
          },
        );
      }
    });

    updateFCMToken();
    refreshAppointments();
  }

  void refreshAppointments() {
    setState(() {
      _appointmentsFuture = AppointmentService.getUpcomingAppointments();
      _saladsFuture = SaladService.getSalads(_currentDate.year, _currentDate.month);
    });
  }

  void updateFCMToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.getAPNSToken();
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      return;
    }

    await UserService.updateFCMToken(fcmToken);
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _currentDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(ImagePaths.salad),
        ),
        title: Center(
          child: Text(
            '${_currentDate.year}년 ${_currentDate.month}월',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Calendar(
              saladsFuture: _saladsFuture,
              onDateChanged: _onDateChanged,
              onAppointmentCreated: refreshAppointments,
            ),
            UpcomingSaladList(
              appointmentsFuture: _appointmentsFuture,
              onAppointmentModified: refreshAppointments,
            ),
          ],
        ),
      ),
    );
  }
}
