import 'package:koscomsalad/utils/dialog_utils.dart';
import 'package:koscomsalad/utils/webhook_agent.dart';

class ServiceUtils {
  static Future<void> handleException(var error, Map<String, dynamic> data, [String? message]) async {
    await WebhookAgent.sendErrorToDiscord(error, data);
    await DialogUtils.showErrorDialog(message);
  }
}
