import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? iconPath;
  final String title;
  final String message;
  final String buttonText;

  const CustomAlertDialog({
    super.key,
    this.iconPath,
    required this.title,
    required this.message,
    this.buttonText = '확인',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 80),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null) ...[
              Image.asset(
                iconPath!,
                width: 88,
                height: 88,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF17522F)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Color(0xFF17522F)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
