import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import 'package:flutter/material.dart';
import '../screens/doctor/messages/doctor_chat_screen.dart';
import '../screens/patient/messages/patient_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 [BACKGROUND HANDLER] Message received: ${message.messageId}');
  debugPrint('   - Title: ${message.notification?.title}');
  debugPrint('   - Body: ${message.notification?.body}');
  debugPrint('   - Data: ${message.data}');

  // 1. Initialize Local Notifications (Required for background display)
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await localNotifications.initialize(initializationSettings);
  debugPrint('✅ [BACKGROUND] Local notifications initialized');

  // 2. Extract Data
  final data = message.data;
  final String? title = message.notification?.title;
  final String? body = message.notification?.body;
  
  // CRITICAL: Always show notification in background/terminated state
  // This ensures messages appear even when app is fully closed
  debugPrint('🌙 [BACKGROUND] Creating local notification...');
  debugPrint('   - Type: ${data['type']}');
  debugPrint('   - ChatId: ${data['chatId']}');
  
  final String notificationTitle = title ?? data['userName'] ?? 'New Message';
  final String notificationBody = body ?? 
      (data['type'] == 'image' ? '[Image]' : 
       data['content'] ?? data['body'] ?? 'You have a new message');
  
  const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'docmobi_chat_notifications_v3', 
      'Chat Notifications',
      channelDescription: 'Real-time message notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  try {
    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notificationTitle,
      notificationBody,
      details,
      payload: jsonEncode(data),
    );
    debugPrint('✅ [BACKGROUND] Local notification displayed successfully');
  } catch (e) {
    debugPrint('❌ [BACKGROUND] Failed to show notification: $e');
  }
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? navigatorKey; // ✅ Added for navigation

  /// Initialize Firebase and Local Notifications
  static Future<void> init() async {
    debugPrint('🔔 [NOTIFICATION SERVICE] Starting initialization...');
    
    // 0. Register Background Handler FIRST (before any Firebase operations)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ Background message handler registered');

    // 1. Request Permissions (iOS/Android 13+)
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint('❌ User denied notification permission');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }

    // 2. Local Notifications Setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

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
        if (details.payload != null) {
          handleNotificationClick(details.payload!);
        }
      },
    );
    debugPrint('✅ Local notifications initialized');

    // 3. Create Android notification channel explicitly
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'docmobi_chat_notifications_v3',
        'Chat Notifications',
        description: 'Real-time message notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      debugPrint('✅ Android notification channel created: ${channel.id}');
    } catch (e) {
      debugPrint('❌ Error creating Android notification channel: $e');
    }

    // 4. iOS Foreground Notification Presentation
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('✅ iOS foreground notification options set');
    } catch (e) {
      debugPrint('❌ Error setting iOS foreground options: $e');
    }

    // 5. Foreground Listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 [FOREGROUND] FCM Message received');
      debugPrint('   - Title: ${message.notification?.title}');
      debugPrint('   - Body: ${message.notification?.body}');
      debugPrint('   - Data: ${message.data}');
      _showLocalNotification(message);
    });

    // 6. Background/Terminated Click Listeners
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 [BACKGROUND CLICK] App opened from notification');
      debugPrint('   - Title: ${message.notification?.title}');
      debugPrint('   - Data: ${message.data}');
      handleNotificationClick(message.data); // ✅ Pass the Map directly
    });

    // 7. Get Initial Token
    await _saveToken();

    // 8. Token Refresh Listener
    _fcm.onTokenRefresh.listen((token) => _saveToken(token));
    
    debugPrint('✅ [NOTIFICATION SERVICE] Initialization complete');
  }

  static Future<void> checkInitialMessage() async {
    try {
      debugPrint('🔍 Checking initial message (Terminated State Check)...');

      // 1. Check for Local Notification Launch (Primary for background/terminated)
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final payload = notificationAppLaunchDetails!.notificationResponse?.payload;
        if (payload != null) {
          debugPrint('🏁 [TERMINATED CLICK] App launched from LOCAL Notification');
          debugPrint('   - Payload: $payload');
          
          // Execute immediately - pending mechanism handles navigator readiness
          handleNotificationClick(payload);
          return; // Stop here if local notification handled it
        }
      }

      // 2. Fallback: Check for FCM Initial Message
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🏁 [TERMINATED CLICK] App launched from FCM Notification');
        debugPrint('   - Title: ${initialMessage.notification?.title}');
        debugPrint('   - Data: ${initialMessage.data}');
        
        // Execute immediately
        handleNotificationClick(initialMessage.data);
      } else {
        debugPrint('ℹ️ No initial message found (Normal Launch)');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking initial message: $e');
    }
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

  static String? currentChatId; // ✅ Track active chat to suppress notifications

  /// Show Local Notification when in foreground or from Agora
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    _showLocalNotificationInternal(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }

  /// Internal helper to show local notification
  static Future<void> _showLocalNotificationInternal({
    String? title,
    String? body,
    required Map<String, dynamic> data,
  }) async {
    // ✅ Check if user is currently in this chat
    final msgChatId = data['chatId']?.toString();
    debugPrint('🔔 [INTERNAL] Processing notification data: $data');
    debugPrint('📱 _showLocalNotificationInternal: chatId=$msgChatId, currentChatId=$currentChatId');

    /* ⚠️ DEBUGGING: Commented out suppression to verify reception
    if (msgChatId != null && msgChatId == currentChatId) {
      debugPrint('🔕 Suppressing notification for active chat: $msgChatId');
      return;
    }
    */
    debugPrint('🔔 [INTERNAL] Forcing notification display for debugging...');

    debugPrint('📱 Building and showing local notification: $title');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'docmobi_chat_notifications_v3', // New channel to force fresh settings
          'Chat Notifications',
          channelDescription: 'Real-time message notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'New Message',
          showWhen: true,
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      debugPrint('📱 Calling _localNotifications.show... [Channel: docmobi_chat_messages_v2]');
      await _localNotifications.show(
        msgChatId?.hashCode ?? DateTime.now().millisecondsSinceEpoch.hashCode,
        title,
        body,
        details,
        payload: jsonEncode(data), // ✅ Use JSON for reliable parsing
      );
      debugPrint('✅ Local notification shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Show notification for message received via Agora
  static Future<void> showLocalNotificationForChat({
    required String senderName,
    required String content,
    required String chatId,
    required String otherUserId,
    String? avatar,
  }) async {
    await _showLocalNotificationInternal(
      title: 'New message from $senderName',
      body: content,
      data: {
        'type': 'chat',
        'chatId': chatId,
        'otherUserId': otherUserId,
        'userName': senderName,
        'userAvatar': avatar,
      },
    );
  }

  /// Handle navigation when notification is clicked
  static String? pendingPayload; // ✅ Store payload if navigator not ready

  /// Handle navigation when notification is clicked
  static void handleNotificationClick(dynamic payload) async {
    debugPrint('🚀 Handling notification click. Payload type: ${payload.runtimeType}');

    if (navigatorKey?.currentState == null) {
      debugPrint('⚠️ Navigator not ready. Storing payload as pending.');
      if (payload is String) {
        pendingPayload = payload;
      } else if (payload is Map) {
        pendingPayload = jsonEncode(payload);
      }
      return;
    }

    try {
      Map<String, dynamic> data = {};
      
      if (payload is Map<String, dynamic>) {
        data = payload;
      } else if (payload is String) {
        try {
          data = jsonDecode(payload);
        } catch (e) {
          data = _parsePayload(payload);
        }
      }

      debugPrint('📍 Parsing navigation data: $data');

      if (data['type'] == 'chat' || data['chatId'] != null) {
        final String? chatId = data['chatId']?.toString();
        final String? userName = data['userName']?.toString() ?? 'User';
        final String? otherUserId = data['otherUserId']?.toString();
        final String? userAvatar = data['userAvatar']?.toString();

        if (chatId != null) {
          final prefs = await SharedPreferences.getInstance();
          final userRole = prefs.getString('user_role')?.toLowerCase();

          debugPrint('📍 Navigating to chat: $chatId for role: $userRole');

          if (userRole == 'doctor') {
            navigatorKey!.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DoctorChatDetailScreen(
                  chatId: chatId,
                  userName: userName ?? 'User',
                  userAvatar: userAvatar,
                  userRole: 'patient',
                  otherUserId: otherUserId,
                ),
              ),
            );
          } else {
            navigatorKey!.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatId: chatId,
                  doctorName: userName ?? 'Doctor',
                  doctorAvatar: userAvatar,
                  doctorId: otherUserId,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling notification click: $e');
    }
  }

  /// ✅ Consume any pending payload once navigator is ready
  static void consumePendingPayload() {
    if (pendingPayload != null) {
      debugPrint('🚀 Consuming pending notification payload...');
      handleNotificationClick(pendingPayload);
      pendingPayload = null;
    }
  }

  /// Simple parser for toString() data format
  static Map<String, dynamic> _parsePayload(String payload) {
    // This is a naive parser for {key: value, key2: value2} format
    // In production, always use jsonEncode/jsonDecode for payloads
    final Map<String, dynamic> data = {};
    try {
      final clean = payload.replaceAll('{', '').replaceAll('}', '');
      final pairs = clean.split(', ');
      for (var pair in pairs) {
        final kv = pair.split(': ');
        if (kv.length == 2) {
          data[kv[0].trim()] = kv[1].trim();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Payload parse error: $e');
    }
    return data;
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

  /// Clear app badge count (iOS)
  static Future<void> clearBadge() async {
    try {
      // Cancel all pending notifications to clear badge
      await _localNotifications.cancelAll();
      debugPrint('🔔 Badge cleared and all local notifications cancelled');
    } catch (e) {
      debugPrint('⚠️ Error clearing badge: $e');
    }
  }

  /// Cancel all local notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
