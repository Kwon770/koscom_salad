import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'package:koscom_salad/services/appointment_service.dart';
import 'package:koscom_salad/services/dto/appointment_dto.dart';
import 'package:koscom_salad/services/salad_service.dart';
import 'package:koscom_salad/utils/korean_date_utils.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';

class AppointmentDialog extends StatefulWidget {
  final DateTime date;
  final bool isCreate;
  final int? appointmentId;
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

  Future<void> _onSaveButtonPressed(BuildContext context) async {
    final dto = AppointmentDto(
      title: appointmentName,
      date: widget.date,
      notifyOnApply: notifyOnApply,
      notifyOnPickup: notifyOnPickup,
      notifyOnHome: notifyOnHome,
      userId: await AuthUtils.getUserId(),
    );

    await saveAppointment(dto);
    await saveAlarm(dto);

    if (mounted) {
      widget.onComplete?.call();
      Navigator.pop(context);
    }
  }

  Future<void> saveAlarm(AppointmentDto dto) async {
    final previousWorkday = await KoreanDateUtils.getPreviousWorkday(dto.date);
    final applyAlarmSettings = AlarmSettings(
      id: int.parse(
          '${previousWorkday.year}${previousWorkday.month.toString().padLeft(2, '0')}${previousWorkday.day.toString().padLeft(2, '0')}1'),
      dateTime: DateTime(previousWorkday.year, previousWorkday.month, previousWorkday.day, 16, 49),
      notificationSettings: NotificationSettings(
        title: '⏰ 샐러드 신청 알림',
        body: '1분 뒤 샐러드 신청이 시작됩니다!',
        stopButton: '알림 종료',
      ),
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      assetAudioPath: 'assets/audios/mute.mp3',
      volumeSettings: VolumeSettings.fixed(volume: 0),
    );

    final pickupAlarmSettings = AlarmSettings(
      id: int.parse(
          '${dto.date.year}${dto.date.month.toString().padLeft(2, '0')}${dto.date.day.toString().padLeft(2, '0')}2'),
      dateTime: DateTime(dto.date.year, dto.date.month, dto.date.day, 12, 20),
      notificationSettings: NotificationSettings(
        title: '🏃 샐러드 픽업 알림 제목',
        body: '식당에서 샐러드 픽업해가세요!',
        stopButton: '알림 종료',
      ),
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      assetAudioPath: 'assets/audios/mute.mp3',
      volumeSettings: VolumeSettings.fixed(volume: 0),
    );

    final homeAlarmSettings = AlarmSettings(
      id: int.parse(
          '${dto.date.year}${dto.date.month.toString().padLeft(2, '0')}${dto.date.day.toString().padLeft(2, '0')}3'),
      dateTime: DateTime(dto.date.year, dto.date.month, dto.date.day, 17, 39),
      notificationSettings: NotificationSettings(
        title: '🏠 샐러드 챙기기 알림 제목',
        body: '샐러드 챙기기 알림 내용',
      ),
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      assetAudioPath: 'assets/audios/mute.mp3',
      volumeSettings: VolumeSettings.fixed(volume: 0),
    );

    await Alarm.set(alarmSettings: applyAlarmSettings);
    await Alarm.set(alarmSettings: pickupAlarmSettings);
    await Alarm.set(alarmSettings: homeAlarmSettings);
  }

  Future<void> saveAppointment(AppointmentDto dto) async {
    if (widget.isCreate) {
      final appointmentId = await AppointmentService.createAppointment(dto);
      await SaladService.createSalad(dto.userId, appointmentId);
    } else {
      await AppointmentService.updateAppointment(widget.appointmentId!, dto);
    }
  }

  Future<void> _onDeleteButtonPressed(BuildContext context) async {
    final confirmed = await DialogUtils.showYesOrNoDialog(
      null,
      title: '약속 삭제',
      message: '정말 삭제하시겠습니까?',
      yesText: '삭제',
      noText: '취소',
    );

    if (!confirmed || !mounted) return;

    await deleteAppointment();
    await deleteAlarm();

    if (mounted) {
      widget.onComplete?.call();
      Navigator.pop(context);
    }
  }

  Future<void> deleteAlarm() async {
    DateTime date = widget.date;
    final previousWorkday = await KoreanDateUtils.getPreviousWorkday(date);

    await Alarm.stop(
      int.parse(
          '${previousWorkday.year}${previousWorkday.month.toString().padLeft(2, '0')}${previousWorkday.day.toString().padLeft(2, '0')}1'),
    );
    await Alarm.stop(
      int.parse('${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}2'),
    );
    await Alarm.stop(
      int.parse('${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}3'),
    );
  }

  Future<void> deleteAppointment() async {
    await SaladService.deleteSaladByAppointmentId(widget.appointmentId!);
    await AppointmentService.deleteAppointment(widget.appointmentId!);
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
                      title: const Text('샐러드 픽업 알림 \n(당일 12:20)'),
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
                      onPressed: () => _onDeleteButtonPressed(context),
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
                    onPressed: () => _onSaveButtonPressed(context),
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
