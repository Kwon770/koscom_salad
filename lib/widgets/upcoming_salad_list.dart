import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koscom_salad/services/appointment_service.dart';
import 'package:koscom_salad/services/models/appointment_model.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';

class UpcomingSaladList extends StatelessWidget {
  const UpcomingSaladList({super.key});

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
        FutureBuilder<List<AppointmentModel>>(
          future: AppointmentService.getAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appointments = snapshot.data ?? [];
            print('appointments : $appointments');

            if (snapshot.hasError || appointments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '예정된 샐러드가 없어요.... 🍽️',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              );
            }

            return makeList(appointments);
          },
        ),
      ],
    );
  }

  ListView makeList(List<AppointmentModel> appointments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          child: GestureDetector(
            onTap: () => DialogUtils.showAppointmentCreateDialog(appointment.date),
            child: ListTile(
              title: Text(
                appointment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '예약일: ${DateFormat('yyyy-MM-dd').format(appointment.date)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
