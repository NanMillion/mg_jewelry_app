import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      // 🔔 1. Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint("🔔 Permission: ${settings.authorizationStatus}");

      // 🔑 2. Get FCM Token
      final token = await _fcm.getToken();
      debugPrint("🔥 FCM TOKEN: $token");

      // 🧠 3. SUBSCRIBE TO TOPIC (IMPORTANT 🔥)
      await _fcm.subscribeToTopic("test");
      debugPrint("✅ Subscribed to topic: test");

      // 🔁 4. Token refresh listener
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint("🔄 New Token: $newToken");
      });

      // 📩 5. FOREGROUND MESSAGE
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("📩 Foreground Notification:");
        debugPrint("Title: ${message.notification?.title}");
        debugPrint("Body: ${message.notification?.body}");
      });

      // 📲 6. WHEN APP OPENED FROM NOTIFICATION
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("📲 Opened from notification");
      });

      // 🚀 7. HANDLE TERMINATED STATE (IMPORTANT)
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint("🚀 App opened from terminated state");
      }
    } catch (e) {
      debugPrint("❌ Push Init Error: $e");
    }
  }
}