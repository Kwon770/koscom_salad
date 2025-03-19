import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/screens/setting_screen.dart';
import 'package:koscom_salad/services/models/appointment_model.dart';
import 'package:koscom_salad/services/models/salad_model.dart';
import 'package:koscom_salad/services/salad_service.dart';
import 'package:koscom_salad/services/user_service.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';
import 'package:koscom_salad/widgets/calendar.dart';
import 'package:koscom_salad/widgets/upcoming_salad_list.dart';
import 'package:koscom_salad/services/appointment_service.dart';

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

    updateFCMToken();
    refreshAppointments();
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
  }

  void refreshAppointments() {
    setState(() {
      _appointmentsFuture = AppointmentService.getAppointments();
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
            color: Colors.black,
          ),
        ],
        backgroundColor: Colors.white,
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
