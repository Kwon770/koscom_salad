import 'package:flutter/material.dart';
import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/widgets/appointment_dialog.dart';
import 'package:koscom_salad/widgets/yes_or_no_dialog.dart';
import 'package:koscom_salad/widgets/alert_dialog.dart';

class DialogUtils {
  DialogUtils._();

  static BuildContext get _context => navigatorKey.currentContext!;

  static void showAppointmentEditDialog(DateTime date) {
    showDialog(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => AppointmentDialog(date: date),
    );
  }

  static Future<bool> showYesOrNoDialog(
    String? iconPath, {
    required String title,
    required String message,
    String yesText = '예',
    String noText = '아니오',
  }) async {
    final result = await showDialog<bool>(
      context: _context,
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
    String? iconPath, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: _context,
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

  static Future<void> showErrorDialog() async {
    await showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        content: const Text('서버 에러가 발생했습니다. 잠시 후 다시 시도해주세요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
