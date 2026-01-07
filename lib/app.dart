import 'package:docmobi/screens/patient/profile/add_dependents_screen.dart';
import 'package:docmobi/screens/patient/profile/edit_dependent_screen.dart'; // ✅ ADD THIS
import 'package:docmobi/screens/patient/profile/dependents_list_screen.dart'; // ✅ ADD THIS
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docmobi/screens/patient/navigation/patient_main_navigation.dart';
import 'package:docmobi/screens/doctor/navigation/doctor_main_navigation.dart';
import 'package:docmobi/screens/splash/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role = prefs.getString('user_role');

      print('🔍 Checking login status...');
      print('   - Token: ${token != null ? "Found" : "Not found"}');
      print('   - Role: $role');

      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _userRole = role?.toLowerCase();
        _isLoading = false;
      });

      if (_isLoggedIn) {
        print('✅ User is logged in as: $_userRole');
      } else {
        print('⚠️ User not logged in');
      }
    } catch (e) {
      print('❌ Error checking login: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docambi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: _buildHomeScreen(),
      
      // ✅ UPDATED ROUTES - Added all dependent management routes
      routes: {
        '/dependents-list': (context) => const DependentsListScreen(),  // ✅ List screen
        '/add-dependent': (context) => const AddDependentScreen(),      // ✅ Add screen
        '/edit-dependent': (context) => const EditDependentScreen(),    // ✅ Edit screen
        // Add more routes as needed
      },
    );
  }

  Widget _buildHomeScreen() {
    // Loading state
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not logged in
    if (!_isLoggedIn) {
      return const SplashScreen();
    }

    // Logged in - Route based on role
    print('🚀 Routing to: $_userRole screen');

    switch (_userRole) {
      case 'doctor':
        return const DoctorMainNavigation();
      
      case 'patient':
        return const PatientMainNavigation();
      
      case 'admin':
        // If you have admin screen
        // return const AdminMainNavigation();
        return const PatientMainNavigation(); // Fallback
      
      default:
        // Unknown role - logout and go to splash
        print('⚠️ Unknown role: $_userRole - Logging out');
        _logout();
        return const SplashScreen();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}