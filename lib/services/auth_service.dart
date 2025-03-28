import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원가입 + Firestore에 유저 정보 저장
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      // 1. Firebase Auth 회원가입
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      // 2. Firestore에 유저 정보 저장
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'nickname': nickname,
          'totalPoint': 0,
          'joinedChallenges': [],
        });
        return user;
      }

      return null;
    } catch (e) {
      print('❌ 회원가입 오류: $e');
      rethrow;
    }
  }
}
