import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/main.dart';
import 'package:kumoh_calendar/user_page/signin_page.dart'; // 로그인 성공 후 이동할 페이지

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _signup() async {
    final String userEmail = _userEmailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    try {
      // Firebase Auth를 통해 회원가입 시도
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      // Firestore에 데이터 저장
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.doc(userCredential.user!.uid).set({
        'email': userEmail,
      });

      // 회원가입 후 로그인 페이지로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
        (Route<dynamic> route) => false,
      );

    } on FirebaseAuthException catch (e) {
      // 회원가입 실패 시 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${e.message}')),
      );
    } catch (e) {
      // Firestore 저장 실패 시 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보 저장 실패: ${e.toString()}')),
      );

      // 사용자 삭제
      await FirebaseAuth.instance.currentUser?.delete();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '회원가입',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userEmailController,
              decoration: const InputDecoration(
                labelText: '사용자 이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('회원가입'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // 버튼 크기
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 이전 페이지로 돌아가기
              },
              child: const Text('로그인 페이지로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
