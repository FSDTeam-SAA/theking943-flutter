import 'package:docmobi/app.dart';
import 'package:docmobi/providers/user_provider.dart';
import 'package:docmobi/providers/dependent_provider.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/services/agora_chat_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:docmobi/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/providers/appointment_provider.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:docmobi/providers/doctor_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docmobi/providers/locale_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 Background Message: ${message.notification?.title}');
}

// ✅ Guard flags for service initialization (module level)
bool _chatSocketInitializing = false;
bool _chatSocketInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========================================
  // CRITICAL: Initialize only essential services synchronously
  // ========================================

  // 1. Initialize Firebase (required for background message handler)
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ Firebase core initialized');
  } catch (e) {
    debugPrint('❌ Firebase Init Error: $e');
  }

  debugPrint('Starting app initialization...');

  // 2. Load saved locale for immediate application startup
  final savedLocaleCode = await getSavedLocaleCode();
  final initialLocale = Locale(savedLocaleCode ?? 'en');

  // 3. Load token (fast - no network calls)
  await ApiService.init();
  final isLoggedIn = ApiService.isLoggedIn;
  debugPrint('🔍 Token status: ${isLoggedIn ? "Logged In" : "Not Logged In"}');

  debugPrint('✅ Critical initialization complete - Starting app');

  // ========================================
  // START THE APP IMMEDIATELY
  // ========================================
  runApp(
    ProviderScope(
      overrides: [
        // We initialize the localeProvider with the saved locale to avoid flicker
        localeProvider.overrideWith(
          () => LocaleNotifier()..setInitialLocale(initialLocale),
        ),
      ],
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => UserProvider()),
          legacy_provider.ChangeNotifierProvider(
            create: (_) => AppointmentProvider(),
          ),
          legacy_provider.ChangeNotifierProvider(
            create: (_) => DoctorProvider(),
          ),
          legacy_provider.ChangeNotifierProvider(
            create: (_) => DependentProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );

  // ========================================
  // DEFERRED: Initialize non-critical services in background
  // ========================================
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    debugPrint('🔄 Starting deferred service initialization...');

    // Initialize services in parallel for faster loading
    await Future.wait([
      // Notification Service
      _initNotificationService(),

      // User session sync (network call - deferred)
      _syncUserSession(),

      // Chat and Socket services (only if logged in)
      if (isLoggedIn) _initChatAndSocketServices(),
    ]);

    debugPrint('✅ All deferred services initialized');
  });
}

/// Initialize Notification Service in background
Future<void> _initNotificationService() async {
  try {
    await NotificationService.init();
    debugPrint('✅ Notification Service ready');
  } catch (e) {
    debugPrint('❌ Notification Service Error: $e');
  }
}

/// Sync user session in background (network call)
Future<void> _syncUserSession() async {
  try {
    await ApiService.syncUserSession();
  } catch (e) {
    debugPrint('⚠️ User session sync failed: $e');
  }
}

/// Initialize Chat and Socket services for logged-in users
Future<void> _initChatAndSocketServices() async {
  // ✅ Guard against redundant initialization during hot restart
  if (_chatSocketInitialized) {
    debugPrint('⏭️ Chat/Socket services already initialized, skipping');
    return;
  }

  if (_chatSocketInitializing) {
    debugPrint('⏳ Chat/Socket services initialization in progress, skipping');
    return;
  }

  _chatSocketInitializing = true;

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      // Initialize Agora Chat
      try {
        await AgoraChatService.instance.init();
        await AgoraChatService.instance.login(userId);
        debugPrint('✅ Agora Chat initialized for user: $userId');
      } catch (e) {
        debugPrint('⚠️ Agora Chat initialization failed: $e');
      }

      // Initialize Socket Service
      try {
        await SocketService.instance.connect(userId);
        debugPrint('✅ Socket initialized for user: $userId');
      } catch (e) {
        debugPrint('⚠️ Socket initialization failed: $e');
      }

      _chatSocketInitialized = true;
    } else {
      debugPrint('⚠️ User ID not found - Socket & Agora Chat not connected');
    }
  } catch (e) {
    debugPrint('❌ Chat/Socket initialization error: $e');
  } finally {
    _chatSocketInitializing = false;
  }
}
