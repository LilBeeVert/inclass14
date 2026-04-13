import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM TOKEN: $token');
    return token;
  }

  Stream<RemoteMessage> foregroundMessages() {
    return FirebaseMessaging.onMessage;
  }

  Stream<RemoteMessage> openedAppMessages() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }
}
