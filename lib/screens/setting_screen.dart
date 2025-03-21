import 'package:flutter/material.dart';
import 'package:koscom_salad/services/user_service.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:koscom_salad/utils/webhook_agent.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';
import 'package:koscom_salad/main.dart';
import 'package:koscom_salad/screens/onboarding_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? '알 수 없음';
        _isLoading = false;
      });
    }
  }

  void handleNameChange() async {
    final newName = await DialogUtils.showSimpleInput(
      title: '이름 변경',
      hintText: '변경할 이름을 입력해주세요.',
      submitText: '변경',
      maxLines: 1,
    );

    if (newName == null || !mounted) return;

    await UserService.changeUserName(newName);
    await _loadUserName();
    DialogUtils.showAlertDialog(
      null,
      title: '변경 완료',
      message: '이름이 변경되었습니다.',
    );
  }

  void handleBugReport() async {
    final feedback = await DialogUtils.showSimpleInput(
      title: '버그 제보',
      hintText: '버그 내용을 자세히 적어주세요.',
      submitText: '전송',
      maxLines: 5,
    );

    if (feedback == null || !mounted) return;

    await WebhookAgent.sendFeedbackToDiscord(feedback);
    DialogUtils.showAlertDialog(
      null,
      title: '전송 완료',
      message: '소중한 의견 감사합니다.',
    );
  }

  void handleWithdraw() async {
    final confirmed = await DialogUtils.showYesOrNoDialog(
      null,
      title: '회원 탈퇴',
      message: '정말 탈퇴하시겠습니까?\n탈퇴 후에는 복구가 불가능합니다.',
      yesText: '탈퇴',
      noText: '취소',
    );

    if (!confirmed) return;
    await UserService.deleteUserSoftly();
    await AuthUtils.removeUserId();

    if (mounted) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF17522F)))
          : ListView(
              children: [
                ListTile(
                  title: Text(_userName),
                  subtitle: Text(
                    '내 정보 수정하기',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: handleNameChange,
                ),
                const Divider(),
                ListTile(
                  title: const Text('버그 제보하기'),
                  onTap: handleBugReport,
                ),
                ListTile(
                  title: const Text('탈퇴하기'),
                  onTap: handleWithdraw,
                ),
              ],
            ),
    );
  }
}
