import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotonpj_2/services/auth_service.dart';
import 'package:zerotonpj_2/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final AuthService _authService = AuthService();

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
        Navigator.pop(context);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '지구를 위한 여정에 함께해요 🙌🏻',
                  style: TextStyle(fontSize: 20, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 24),
                // 이메일 입력
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Color(0xFF30B190), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 비밀번호 입력
                TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Color(0xFF30B190), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 닉네임 입력
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Color(0xFF30B190), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 계정 만들기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30B190),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: signup,
                    child: const Text(
                      '계정 만들기',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '이미 계정이 있으십니까?',
                    style: TextStyle(color: Color(0xFF30B190)),
                  ),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
