import 'package:flutter/material.dart';
import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/widgets/appointment_dialog.dart';
import 'package:koscom_salad/widgets/yes_or_no_dialog.dart';
import 'package:koscom_salad/widgets/alert_dialog.dart';
import 'package:koscom_salad/widgets/simple_input_dialog.dart';

class DialogUtils {
  DialogUtils._();

  static BuildContext get _context => navigatorKey.currentContext!;

  static void showAppointmentCreateDialog(DateTime date, {VoidCallback? onComplete}) {
    showDialog(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => AppointmentDialog(
        date: date,
        isCreate: true,
        onComplete: onComplete,
      ),
    );
  }

  static void showAppointmentEditDialog(DateTime date, int appointmentId, {VoidCallback? onComplete}) {
    showDialog(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => AppointmentDialog(
        date: date,
        isCreate: false,
        appointmentId: appointmentId,
        onComplete: onComplete,
      ),
    );
  }

  static Future<bool?> showYesOrNoDialog(
    String? iconPath, {
    required String title,
    required String message,
    String yesText = '예',
    String noText = '아니오',
  }) async {
    final result = await showDialog<bool?>(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => YesOrNoDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        yesText: yesText,
        noText: noText,
      ),
    );

    return result;
  }

  static Future<void> showAlertDialog(
    String? iconPath, {
    required String title,
    required String message,
    String buttonText = '확인',
    VoidCallback? onButtonPressed,
  }) async {
    await showDialog(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => CustomAlertDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  static Future<void> showErrorDialog(String? message) async {
    final errorMessage = message ?? '서버 에러가 발생했습니다. 잠시 후 다시 시도해주세요';

    await showDialog(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  static Future<String?> showSimpleInput({
    required String title,
    required String hintText,
    required String submitText,
    String closeText = '닫기',
    int maxLines = 1,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String?>(
      context: _context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => SimpleInputDialog(
        title: title,
        hintText: hintText,
        submitText: submitText,
        closeText: closeText,
        maxLines: maxLines,
        controller: controller,
      ),
    );

    controller.clear();
    return result;
  }
}
