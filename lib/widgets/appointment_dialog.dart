import 'package:flutter/material.dart';
import 'package:koscom_salad/services/appointment_service.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';

class AppointmentDialog extends StatefulWidget {
  final DateTime date;
  final bool isCreate;
  final String? appointmentId;
  final VoidCallback? onComplete;

  const AppointmentDialog({
    super.key,
    required this.date,
    required this.isCreate,
    this.appointmentId,
    this.onComplete,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  String appointmentName = '점심 약속';
  bool notifyOnApply = true;
  bool notifyOnPickup = true;
  bool notifyOnHome = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isCreate && widget.appointmentId != null) {
      loadAppointment();
    }
  }

  Future<void> loadAppointment() async {
    final appointment = await AppointmentService.getAppointment(widget.appointmentId!);
    if (mounted && appointment != null) {
      setState(() {
        appointmentName = appointment.title;
        notifyOnApply = appointment.notifyOnApply;
        notifyOnPickup = appointment.notifyOnPickup;
        notifyOnHome = appointment.notifyOnHome;
      });
    }
  }

  Future<void> onSaveButtonPressed(BuildContext context) async {
    final dto = AppointmentDto(
      title: appointmentName,
      date: widget.date,
      notifyOnApply: notifyOnApply,
      notifyOnPickup: notifyOnPickup,
      notifyOnHome: notifyOnHome,
      userId: await AuthUtils.getUserId(),
    );

    if (widget.isCreate) {
      await AppointmentService.createAppointment(dto);
    } else {
      await AppointmentService.updateAppointment(widget.appointmentId!, dto);
    }

    if (!mounted) return;
    widget.onComplete?.call();
    Navigator.pop(context);
  }

  Future<void> onDeleteButtonPressed(BuildContext context) async {
    final confirmed = await DialogUtils.showYesOrNoDialog(
      null,
      title: '약속 삭제',
      message: '정말 삭제하시겠습니까?',
      yesText: '삭제',
      noText: '취소',
    );

    if (!confirmed || !mounted) return;

    await AppointmentService.deleteAppointment(widget.appointmentId!);
    if (!mounted) return;
    widget.onComplete?.call();
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
            Text(
              widget.isCreate ? '약속 생성' : '약속 수정',
              style: const TextStyle(
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
                      title: const Text('샐러드 신청 알림 \n(전일 16:49)'),
                      trailing: Switch.adaptive(
                        value: notifyOnApply,
                        onChanged: (value) {
                          setState(() => notifyOnApply = value);
                        },
                        activeColor: const Color(0xFF17522F),
                        inactiveTrackColor: Colors.white,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('샐러드 픽업 알림 \n(당일 12:19)'),
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
                      title: const Text('샐러드 챙기기 알림 \n(당일 17:39)'),
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
                if (!widget.isCreate) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () => onDeleteButtonPressed(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.red),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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
                    child: Text(
                      widget.isCreate ? '저장' : '수정',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
