import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();

  String? errorMessage;

  Future<void> signup() async {
    try {
      final auth = FirebaseAuth.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: pwController.text.trim(),
      );

      final uid = credential.user!.uid;

      // Firestore에 유저 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'totalPoints': 0,
        'joinedChallenges': [],
      });

      print('✅ 회원가입 성공! UID: $uid');

      // 성공 시 로그인 페이지로 이동하거나 홈으로 이동
      Navigator.pop(context); // or push to main screen
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
