import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zerotonpj_2/services/challenge_service.dart';
import 'package:zerotonpj_2/screens/upload_proof_screen.dart'; // ✅ 인증 업로드 화면 import

class ChallengeDetailScreen extends StatelessWidget {
  final String challengeId;
  final String title;
  final String description;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final success = await joinChallenge(challengeId, userId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ 챌린지 참여 완료!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ 참여 실패')),
                  );
                }
              },
              child: const Text('챌린지 참여하기'),
            ),
            const SizedBox(height: 20), // 버튼 간격
            ElevatedButton(
              onPressed: () {
                // 인증 업로드 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadProofScreen(challengeId: challengeId),
                  ),
                );
              },
              child: const Text('인증 업로드하기'),
            ),
          ],
        ),
      ),
    );
  }
}
