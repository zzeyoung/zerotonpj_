import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zerotonpj_2/screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotonpj_2/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    try {
      final auth = FirebaseAuth.instance;
      final credential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final nickname = userDoc.data()?['nickname'] ?? '사용자';

      print('✅ 로그인 성공!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(nickname: nickname),
        ),
      );
    } catch (e) {
      print('❌ 로그인 실패: $e');
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ECO STEP',
                    style: TextStyle(
                      fontSize: 64,
                      color: Color(0xFF30B190),
                      fontFamily: 'NanumPenScript', // ✅ 폰트 적용
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/earth.png',
                    height: 200,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '날마다 조금씩, 지구와 나를 위한 가치 있는 선택',
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black87,
                      fontFamily: 'NanumPenScript', // ✅ 폰트 적용
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
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
                        borderSide: const BorderSide(
                            color: Color(0xFF30B190), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 비밀번호 입력
                  TextField(
                    controller: passwordController,
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
                        borderSide: const BorderSide(
                            color: Color(0xFF30B190), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30B190),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: login,
                      child: const Text(
                        '로그인',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '회원가입',
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
      ),
    );
  }
}
