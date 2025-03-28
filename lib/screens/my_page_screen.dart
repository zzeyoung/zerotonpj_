// lib/screens/my_page_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String nickname = '';
  int totalPoints = 0;
  List<Map<String, dynamic>> joinedChallengeList = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data();

    if (data == null) return;

    setState(() {
      nickname = data['nickname'] ?? '사용자';
      totalPoints = data['totalPoint'] ?? 0;
    });

    // 참여한 챌린지 ID 배열
    List<dynamic> joinedIds = data['joinedChallenges'] ?? [];

    List<Map<String, dynamic>> challenges = [];

    for (String challengeId in joinedIds) {
      final doc = await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .get();
      if (doc.exists) {
        challenges.add({
          'title': doc['title'],
          'description': doc['description'],
        });
      }
    }

    setState(() {
      joinedChallengeList = challenges;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 닉네임: $nickname', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('⭐️ 총 포인트: $totalPoints',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('📌 참여한 챌린지 목록',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: joinedChallengeList.isEmpty
                  ? const Text('참여한 챌린지가 없어요.')
                  : ListView.builder(
                      itemCount: joinedChallengeList.length,
                      itemBuilder: (context, index) {
                        final challenge = joinedChallengeList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(challenge['title']),
                            subtitle: Text(challenge['description']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
