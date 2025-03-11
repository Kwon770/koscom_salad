import 'package:flutter/material.dart';
import 'package:koscom_salad/services/appointment_service.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';

class AppointmentDialog extends StatelessWidget {
  final DateTime date;
  String appointmentName = '점심 약속';
  bool notifyOnPickup = true;
  bool notifyOnHome = true;

  AppointmentDialog({super.key, required this.date});

  onSaveButtonPressed(BuildContext context) {
    print(AppointmentService.createAppointment(AppointmentDto(
      title: appointmentName,
      date: date,
      notifyOnPickup: notifyOnPickup,
      notifyOnHome: notifyOnHome,
    )));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '약속 생성',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: appointmentName),
              onChanged: (value) => appointmentName = value,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF17522F),
                    width: 2.0,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF17522F),
                    width: 2.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF17522F),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('샐러드 픽업 알림 (전일 16:49)'),
                      trailing: Switch.adaptive(
                        value: notifyOnPickup,
                        onChanged: (value) {
                          setState(() => notifyOnPickup = value);
                        },
                        activeColor: const Color(0xFF17522F),
                        inactiveTrackColor: Colors.white,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('샐러드 챙기기 알림 (당일 17:39)'),
                      trailing: Switch.adaptive(
                        value: notifyOnHome,
                        onChanged: (value) {
                          setState(() => notifyOnHome = value);
                        },
                        activeColor: const Color(0xFF17522F),
                        inactiveTrackColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF17522F)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('취소', style: TextStyle(color: Color(0xFF17522F))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onSaveButtonPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17522F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
