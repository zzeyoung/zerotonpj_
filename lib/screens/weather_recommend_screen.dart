import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherRecommendScreen extends StatefulWidget {
  const WeatherRecommendScreen({super.key});

  @override
  State<WeatherRecommendScreen> createState() => _WeatherRecommendScreenState();
}

class _WeatherRecommendScreenState extends State<WeatherRecommendScreen> {
  List<Map<String, dynamic>> challenges = [];
  bool isLoading = true;
  String? todayWeather;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
          'http://10.0.2.2:3000/challenges/recommend-by-location?lat=$lat&lon=$lon');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> result = data['challenges'];

        setState(() {
          todayWeather = data['weather'];
          challenges = result.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('추천 실패: ${response.body}');
      }
    } catch (e) {
      print('❌ 추천 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'snow':
        return '❄️';
      default:
        return '🌈';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 날씨 챌린지')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todayWeather != null)
                    Text(
                      '오늘의 날씨: $todayWeather ${getWeatherEmoji(todayWeather!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: challenges.isEmpty
                        ? const Center(child: Text('추천 챌린지가 없어요 😢'))
                        : ListView.builder(
                            itemCount: challenges.length,
                            itemBuilder: (context, index) {
                              final c = challenges[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(c['title'] ?? ''),
                                  subtitle: Text(c['description'] ?? ''),
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
