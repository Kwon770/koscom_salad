import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/screens/setting_screen.dart';
import 'package:koscom_salad/widgets/calendar.dart';
import 'package:koscom_salad/widgets/upcoming_salad_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentDate = DateTime.now();
  final List<Map<String, dynamic>> _appointments = [
    {
      'date': DateTime(2024, 1, 15),
      'name': '점심 약속',
      'notifyOnPickup': true,
      'notifyOnHome': true,
    },
    {
      'date': DateTime(2024, 1, 16),
      'name': '점심 약속',
      'notifyOnPickup': true,
      'notifyOnHome': true,
    },
    {
      'date': DateTime(2024, 1, 17),
      'name': '점심 약속',
      'notifyOnPickup': true,
      'notifyOnHome': true,
    },
  ];

  onDateChanged(DateTime date) {
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
              onDateChanged: onDateChanged,
            ),
            const UpcomingSaladList(),
          ],
        ),
      ),
    );
  }
}
