// lib/services/challenge_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> joinChallenge(String challengeId, String userId) async {
  final url = Uri.parse('http://10.0.2.2:3000/challenge/$challengeId/join');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'userId': userId}),
  );

  return response.statusCode == 200;
}
