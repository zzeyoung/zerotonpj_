// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchWeatherBasedChallenges(
    double lat, double lon) async {
  final url = Uri.parse(
      'http://10.0.2.2:3000/challenges/recommend-by-location?lat=$lat&lon=$lon');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> challenges = data['challenges'];
    return challenges.map((e) => e as Map<String, dynamic>).toList();
  } else {
    throw Exception('날씨 기반 추천 실패: ${response.body}');
  }
}
