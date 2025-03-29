import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:zerotonpj_2/screens/challenge_detail_screen.dart';
import 'package:zerotonpj_2/screens/my_page_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nickname;

  const HomeScreen({super.key, required this.nickname});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? weatherDescription;
  double? temperature;
  List<DocumentSnapshot> filteredChallenges = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherAndChallenges();
  }

  String mapWeatherToTag(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'rain':
        return 'rainy';
      case 'clouds':
        return 'cloudy';
      case 'snow':
        return 'snowy';
      case 'thunderstorm':
        return 'stormy';
      default:
        return 'unknown';
    }
  }

  String getBackgroundImage() {
    switch (mapWeatherToTag(weatherDescription ?? '')) {
      case 'sunny':
        return 'assets/sunny_bg.jpg';
      case 'rainy':
        return 'assets/rainy_bg.jpg';
      case 'cloudy':
        return 'assets/cloudy_bg.jpg';
      case 'snowy':
        return 'assets/snowy_bg.jpg';
      default:
        return 'assets/default_bg.jpg';
    }
  }

  Future<void> fetchWeatherAndChallenges() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/weather'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final description = data['weather'][0]['main'];
        final temp = data['main']['temp'];

        final weatherTag = mapWeatherToTag(description);

        setState(() {
          weatherDescription = description;
          temperature = temp;
        });

        final querySnapshot = await FirebaseFirestore.instance
            .collection('challenges')
            .where('weatherTag', isEqualTo: weatherTag)
            .get();

        setState(() {
          filteredChallenges = querySnapshot.docs;
        });
      } else {
        print("날씨 API 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("날씨 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              getBackgroundImage(),
              fit: BoxFit.cover,
            ),
          ),

          // 흐림 필터 + 내용
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.white.withOpacity(0.2), // 약간 밝은 반투명 레이어
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '환영해요 ${widget.nickname}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (weatherDescription != null && temperature != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            '오늘의 날씨는 $weatherDescription, ${temperature?.toStringAsFixed(1)}°C 입니다.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '오늘의 챌린지',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filteredChallenges.isEmpty
                            ? const Center(
                                child: Text(
                                  '해당 날씨에 맞는 챌린지가 아직 없어요 🥲',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredChallenges.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredChallenges[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: ListTile(
                                      leading: Text(
                                        data['imageUrl'] ?? '🌿',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      title: Text(
                                        data['title'] ?? '제목 없음',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(data['description'] ?? ''),
                                      trailing:
                                          const Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChallengeDetailScreen(
                                              challengeId: doc.id,
                                              title: data['title'] ?? '',
                                              description:
                                                  data['description'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 마이페이지 버튼
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.person),
          color: const Color(0xFF30B190),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyPageScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
