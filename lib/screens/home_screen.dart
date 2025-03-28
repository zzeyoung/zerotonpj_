import 'dart:convert';
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

  // 🔸 날씨 main 값을 weatherTag로 변환하는 매핑 함수
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

  Future<void> fetchWeatherAndChallenges() async {
    try {
      // 🔹 1. 날씨 API 호출
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/weather'), // 로컬 API 주소
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final description = data['weather'][0]['main']; // ex: Clear, Rain
        final temp = data['main']['temp'];

        final weatherTag = mapWeatherToTag(description);

        setState(() {
          weatherDescription = description;
          temperature = temp;
        });

        // 🔹 2. 날씨 태그에 맞는 챌린지 가져오기
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
      appBar: AppBar(title: Text('환영해요 ${widget.nickname}!')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weatherDescription != null && temperature != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '오늘의 날씨는 $weatherDescription, ${temperature?.toStringAsFixed(1)}°C 입니다.',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          if (filteredChallenges.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('해당 날씨에 맞는 챌린지가 아직 없어요 🥲'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredChallenges.length,
                itemBuilder: (context, index) {
                  final doc = filteredChallenges[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person),
        onPressed: () {
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
