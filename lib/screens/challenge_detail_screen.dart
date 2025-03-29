import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotonpj_2/services/challenge_service.dart';
import 'package:zerotonpj_2/screens/upload_proof_screen.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final String challengeId;
  final String title;
  final String description;

  ChallengeDetailScreen({
    super.key,
    required this.challengeId,
    required this.title,
    required this.description,
  });

  final List<String> adImages = [
    'assets/images/ad1.png',
    'assets/images/ad2.png',
    'assets/images/ad3.png',
  ];

  Future<int> fetchChallengePoint() async {
    final doc = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .get();
    if (doc.exists && doc.data()!.containsKey('point')) {
      return doc.data()!['point'];
    } else {
      return 0;
    }
  }

  Widget getImageForMission(String title) {
    String imagePath;

    if (title.contains('플로깅')) {
      imagePath = 'assets/images/plogging.png';
    } else if (title.contains('햇볕') || title.contains('빨래')) {
      imagePath = 'assets/images/sun_dry.png';
    } else if (title.contains('걷') || title.contains('자전거')) {
      imagePath = 'assets/images/walk_bike.png';
    } else if (title.contains('책')) {
      imagePath = 'assets/images/read_book.png';
    } else if (title.contains('빗물')) {
      imagePath = 'assets/images/rain_water.png';
    } else if (title.contains('요리')) {
      imagePath = 'assets/images/cook_food.png';
    } else if (title.contains('다회용') || title.contains('용기')) {
      imagePath = 'assets/images/reusable_container.png';
    } else if (title.contains('플러그') || title.contains('전기')) {
      imagePath = 'assets/images/unplug.png';
    } else if (title.contains('유튜브') ||
        title.contains('영상') ||
        title.contains('시청')) {
      imagePath = 'assets/images/youtube_video.png';
    } else if (title.contains('기부') || title.contains('겨울 옷')) {
      imagePath = 'assets/images/donate_clothes.png';
    } else if (title.contains('방 온도') ||
        (title.contains('옷') && title.contains('따뜻'))) {
      imagePath = 'assets/images/warm_clothes.png';
    } else if (title.contains('손난로') || title.contains('장갑')) {
      imagePath = 'assets/images/gloves.png';
    } else {
      imagePath = 'assets/images/default.png';
    }

    return Image.asset(
      imagePath,
      height: 180,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final String selectedAd = adImages[Random().nextInt(adImages.length)];

    return Scaffold(
      backgroundColor: const Color(0xFF1ABC9C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(child: getImageForMission(title)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '오늘의 미션',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<int>(
                    future: fetchChallengePoint(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final point = snapshot.data ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.wb_sunny_outlined,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.monetization_on,
                                    color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('$point 에코'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final success =
                              await joinChallenge(challengeId, userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(success ? '✅ 챌린지 참여 완료!' : '❌ 참여 실패'),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ABC9C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.track_changes,
                                  size: 30, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                '챌린지 참여하기',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UploadProofScreen(challengeId: challengeId),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ABC9C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/upload_proof_button.png',
                                height: 30,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '인증 업로드하기',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ✅ 광고 배너 (고정 높이, 여백 없음, 가로 꽉 차게)
          Container(
            height: 80,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Color(0xFF2980B9),
            ),
            child: Image.asset(
              selectedAd,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
