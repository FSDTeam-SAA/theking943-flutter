import 'package:docmobi/app.dart';
import 'package:docmobi/providers/user_provider.dart';
import 'package:docmobi/providers/dependent_provider.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/providers/appointment_provider.dart';
import 'package:provider/provider.dart';
import 'package:docmobi/providers/doctor_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('');
  print('╔═══════════════════════════════════════════════════════╗');
  print('║           🚀 APP INITIALIZATION STARTED               ║');
  print('╚═══════════════════════════════════════════════════════╝');
  print('');
  
  // ✅ Step 1: Initialize API Service
  print('📡 STEP 1: Initializing API Service...');
  try {
    await ApiService.init();
    final isLoggedIn = ApiService.isLoggedIn;
    final hasToken = ApiService.token != null;
    
    print('   ✅ API Service initialized');
    print('   • Logged In: ${isLoggedIn ? "YES ✅" : "NO ❌"}');
    print('   • Token Status: ${hasToken ? "EXISTS ✅" : "MISSING ❌"}');
    if (hasToken) {
      final tokenPreview = ApiService.token!.length > 30 
          ? ApiService.token!.substring(0, 30) 
          : ApiService.token!;
      print('   • Token Preview: $tokenPreview...');
    }
    print('');
    
    // ✅ Step 2: Initialize Socket (if logged in)
    if (isLoggedIn) {
      print('🔌 STEP 2: Initializing Socket Service...');
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        final userRole = prefs.getString('user_role');
        
        print('   • User ID from prefs: ${userId ?? "NOT FOUND ❌"}');
        print('   • User Role: ${userRole ?? "NOT FOUND ❌"}');
        
        if (userId != null && userId.isNotEmpty) {
          print('   • Attempting socket connection...');
          
          // ✅ CRITICAL: Connect socket BEFORE running app
          final connected = await SocketService.instance.connect(userId);
          
          if (connected) {
            print('');
            print('   🔌 SOCKET CONNECTION STATUS:');
            print('   ╔═════════════════════════════════════════╗');
            print('   ║ Socket Exists: YES ✅                   ║');
            print('   ║ Connected: YES ✅                       ║');
            print('   ║ Socket ID: ${SocketService.instance.socket?.id ?? "N/A"}');
            print('   ║ User Room: chat_$userId');
            print('   ╚═════════════════════════════════════════╝');
            print('');
            print('   ✅ Socket connected successfully!');
            print('   ✅ Ready to send/receive calls');
          } else {
            print('   ❌ Socket connection failed');
            print('   ⚠️ Calls may not work properly');
          }
        } else {
          print('   ❌ User ID not found in SharedPreferences');
          print('   ❌ Cannot initialize socket');
        }
      } catch (e, stackTrace) {
        print('   ❌ Socket initialization error: $e');
        print('   Stack trace: $stackTrace');
        print('   ⚠️ App will continue without real-time features');
      }
    } else {
      print('⏭️ STEP 2: Skipped (User not logged in)');
    }
    
    print('');
    print('╔═══════════════════════════════════════════════════════╗');
    print('║           ✅ INITIALIZATION COMPLETE                  ║');
    print('╚═══════════════════════════════════════════════════════╝');
    print('');
    
  } catch (e, stackTrace) {
    print('❌ CRITICAL ERROR during initialization: $e');
    print('Stack trace: $stackTrace');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => DependentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}