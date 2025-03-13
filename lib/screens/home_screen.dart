import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/screens/setting_screen.dart';
import 'package:koscom_salad/services/models/appointment_model.dart';
import 'package:koscom_salad/services/models/salad_model.dart';
import 'package:koscom_salad/services/salad_service.dart';
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
    _appointmentsFuture = AppointmentService.getAppointments();
    _saladsFuture = SaladService.getSalads(_currentDate.year, _currentDate.month);
  }

  void refreshAppointments() {
    setState(() {
      _appointmentsFuture = AppointmentService.getAppointments();
      _saladsFuture = SaladService.getSalads(_currentDate.year, _currentDate.month);
    });
  }

  void onDateChanged(DateTime date) {
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
              onDateChanged: onDateChanged,
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
