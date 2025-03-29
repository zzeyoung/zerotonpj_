import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static Future<void> setupFCM(String userId) async {
    print('📲 setupFCM() 호출됨');

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(); // 권한 요청

    final token = await messaging.getToken();

    if (token == null) {
      print('❌ FCM 토큰을 받아오지 못했어요.');
    } else {
      print('🔥 FCM Token: $token'); // ✅ 이 로그가 꼭 있어야 함

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/notification/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'token': token,
        }),
      );
      print('📡 서버 응답: ${response.body}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 포그라운드 알림 도착!');
      print('🔔 ${message.notification?.title}');
      print('📝 ${message.notification?.body}');
    });
  }
}
