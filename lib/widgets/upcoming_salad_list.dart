import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koscom_salad/widgets/appointment_dialog.dart';

class UpcomingSaladList extends StatefulWidget {
  const UpcomingSaladList({super.key, required this.appointments});

  final List<Map<String, dynamic>> appointments;

  @override
  State<UpcomingSaladList> createState() => _UpcomingSaladListState();
}

class _UpcomingSaladListState extends State<UpcomingSaladList> {
  late final List<Map<String, dynamic>> _upcomingSalads;

  @override
  void initState() {
    super.initState();
    _upcomingSalads = widget.appointments;
  }

  void showAppointmentDialog(DateTime date) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) {
        return AppointmentDialog(
          date: date,
          onAppointmentCreate: onAppointmentCreate,
        );
      },
    );
  }

  void onAppointmentCreate(Map<String, dynamic> appointment) {
    // MOCK
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '예정된 샐러드',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _upcomingSalads.length,
          itemBuilder: (context, index) {
            final salad = _upcomingSalads[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: GestureDetector(
                onTap: () => showAppointmentDialog(salad['date']),
                child: ListTile(
                  title: Text(
                    salad['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '예약일: ${DateFormat('yyyy-MM-dd').format(salad['date'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
