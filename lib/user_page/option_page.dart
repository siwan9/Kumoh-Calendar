import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/user_page/signin_page.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // 사용자 정보 가져오기

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('사용자 정보'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
          children: [
            const Text(
              '사용자 이메일',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 설명 텍스트 스타일
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '사용자 없음',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Center( // 버튼을 중앙에 배치
              child: ElevatedButton(
                onPressed: () => _logout(context), // context를 매개변수로 전달
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninPage()),
      (Route<dynamic> route) => false,
    );
  }
}
