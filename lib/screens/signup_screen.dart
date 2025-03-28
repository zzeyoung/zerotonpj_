import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotonpj_2/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();

  final AuthService _authService = AuthService(); // ✅ auth 서비스 객체 생성
  String? errorMessage;

  Future<void> signup() async {
    try {
      final user = await _authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: pwController.text.trim(),
        nickname: nicknameController.text.trim(),
      );

      if (user != null) {
        print('✅ 회원가입 완료! UID: ${user.uid}');
        Navigator.pop(context); // 또는 홈화면 이동
      }
    } catch (e) {
      print('❌ 회원가입 실패: $e');
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signup,
              child: const Text('회원가입'),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}
