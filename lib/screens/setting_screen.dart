import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void handleNicknameChange() {
    // TODO: 닉네임 변경 다이얼로그 표시
  }

  void handleBugReport() {
    // TODO: 버그 제보 페이지로 이동
  }

  void handleUpdate() {
    // TODO: 앱 버전 업데이트 페이지로 이동
  }

  void handleLogout() {
    // TODO: 로그아웃 처리
  }

  void handleWithdraw() {
    // TODO: 탈퇴 확인 다이얼로그 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('사용자 1'),
            subtitle: Text('내 정보 수정하기', style: TextStyle(color: Colors.black.withOpacity(0.5))),
            trailing: const Icon(Icons.chevron_right),
            onTap: handleNicknameChange,
          ),
          const Divider(),
          ListTile(
            title: const Text('버그 제보하기'),
            onTap: handleBugReport,
          ),
          ListTile(
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
            onTap: handleUpdate,
          ),
          const Divider(),
          ListTile(
            title: const Text('로그아웃'),
            onTap: handleLogout,
          ),
          ListTile(
            title: const Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.red),
            ),
            onTap: handleWithdraw,
          ),
        ],
      ),
    );
  }
}
