import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      totalPoints = data['totalPoints'] ?? 0;
    });

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 초록색 배경
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF30B190),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // 👈 뒤로가기 기능 추가
                          },
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Text(
                          '마이페이지',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const Icon(Icons.settings, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 프로필 카드
                  Container(
                    margin: const EdgeInsets.only(top: 30, left: 16, right: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$nickname 님',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('Lv 2: 새싹 🌱'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('총 포인트 $totalPoints',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black87)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF30B190),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                '내 에코 현황 >',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 참여 챌린지 목록
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '참여한 챌린지 목록',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (joinedChallengeList.isEmpty)
                          const Text('참여한 챌린지가 없어요 🥲')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: joinedChallengeList.length,
                            itemBuilder: (context, index) {
                              final challenge = joinedChallengeList[index];
                              return Card(
                                color: Colors.white,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF30B190)),
                                  title: Text(
                                    challenge['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(challenge['description']),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
