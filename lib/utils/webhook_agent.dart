import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class WebhookAgent {
  static Future<String> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String info = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info = '''
platform: Android
model: ${androidInfo.model}
manufacturer: ${androidInfo.manufacturer}
Android version: ${androidInfo.version.release}
SDK: ${androidInfo.version.sdkInt}
''';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info = '''
platform: iOS 
model: ${iosInfo.model}
iOS version: ${iosInfo.systemVersion}
''';
      }

      final ipResponse = await http.get(Uri.parse('https://api.ipify.org'));
      if (ipResponse.statusCode == 200) {
        info += 'ip: ${ipResponse.body}';
      }

      return info;
    } catch (e) {
      return '디바이스 정보 조회 실패: $e';
    }
  }

  static Future<void> sendErrorToDiscord(Exception error, Map<String, dynamic> data) async {
    final deviceInfo = await getDeviceInfo();
    final now = DateTime.now().toIso8601String();
    final webhookUrl = dotenv.env['DISCORD_WEBHOOK_SUPABASE_URL']!;

    final client = http.Client();
    try {
      await client.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': '''
[SUPABASE ERROR : $now]
$error

DTO ----------------------
${jsonEncode(data)}

User ID ----------------------
${data['user_id']}

Device Info ----------------------
$deviceInfo

          '''
        }),
      );
    } finally {
      client.close();
    }
  }
}
