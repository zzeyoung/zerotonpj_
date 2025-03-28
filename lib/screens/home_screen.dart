import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotonpj_2/screens/challenge_detail_screen.dart';
import 'package:zerotonpj_2/screens/my_page_screen.dart'; // ✅ 마이페이지 스크린 추가

class HomeScreen extends StatelessWidget {
  final String nickname;

  const HomeScreen({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('환영해요 $nickname!')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 챌린지가 없어요.'));
          }

          final challenges = snapshot.data!.docs;

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final doc = challenges[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['title'] ?? '제목 없음'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengeDetailScreen(
                          challengeId: doc.id,
                          title: data['title'] ?? '',
                          description: data['description'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person),
        onPressed: () {
          // 마이페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyPageScreen(),
            ),
          );
        },
      ),
    );
  }
}
