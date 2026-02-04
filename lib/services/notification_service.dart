import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

// ✅ Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to access other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  /* await Firebase.initializeApp(); */
  debugPrint('🌙 Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase and Local Notifications
  static Future<void> init() async {
    // 0. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 1. Request Permissions (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    }

    // 2. Local Notifications Setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click
        debugPrint('🔔 Notification clicked: ${details.payload}');
      },
    );

    // 3. Foreground Listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 4. Background/Terminated Click Listeners
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '🔔 App opened from notification: ${message.notification?.title}',
      );
    });

    // 5. Get Initial Token
    await _saveToken();

    // 6. Token Refresh Listener
    _fcm.onTokenRefresh.listen((token) => _saveToken(token));
  }

  /// Get and save FCM Token to Backend
  static Future<void> _saveToken([String? token]) async {
    try {
      final fcmToken = token ?? await _fcm.getToken();
      if (fcmToken != null) {
        debugPrint('🔑 FCM Token: $fcmToken');

        if (ApiService.isLoggedIn) {
          final platform = Platform.isAndroid ? 'android' : 'ios';
          await ApiService.registerFCMToken(
            token: fcmToken,
            platform: platform,
          );
          debugPrint('✅ FCM Token registered with backend');
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Show Local Notification when in foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'docmobi_notifications',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  // ========================================
  // Existing REST API methods
  // ========================================

  /// Fetch all notifications from the backend
  static Future<List<NotificationModel>> getNotifications() async {
    final response = await ApiService.get(ApiConfig.notifications);

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> data = [];
      if (response['data'] is Map && response['data']['items'] is List) {
        data = response['data']['items'];
      } else if (response['data'] is List) {
        data = response['data'];
      }

      return data.map((json) => NotificationModel.fromJson(json)).toList();
    }
    return [];
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    final response = await ApiService.get(ApiConfig.unreadCount);
    if (response['success'] == true && response['data'] != null) {
      return (response['data']['count'] ?? 0) as int;
    }
    return 0;
  }

  /// Mark a single notification as read
  static Future<bool> markAsRead(String id) async {
    final response = await ApiService.patch(ApiConfig.getMarkAsReadUrl(id), {});
    return response['success'] == true;
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    final response = await ApiService.patch(ApiConfig.markAllAsRead, {});
    return response['success'] == true;
  }

  /// Delete a notification
  static Future<bool> deleteNotification(String id) async {
    final response = await ApiService.delete(
      '${ApiConfig.deleteNotification}/$id',
    );
    return response['success'] == true;
  }
}
