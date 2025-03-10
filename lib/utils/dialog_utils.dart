import 'package:flutter/material.dart';
import 'package:koscom_salad/widgets/appointment_dialog.dart';
import 'package:koscom_salad/widgets/yes_or_no_dialog.dart';
import 'package:koscom_salad/widgets/alert_dialog.dart';

class DialogUtils {
  DialogUtils._();

  static void showAppointmentEditDialog(
      BuildContext context, DateTime date, Function(Map<String, dynamic>) onAppointmentCreate) {
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

  static Future<bool> showYesOrNoDialog(
    BuildContext context,
    String? iconPath, {
    required String title,
    required String message,
    String yesText = '예',
    String noText = '아니오',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (context) => YesOrNoDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        yesText: yesText,
        noText: noText,
      ),
    );

    return result ?? false;
  }

  static Future<void> showAlertDialog(
    BuildContext context,
    String? iconPath, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }
}
