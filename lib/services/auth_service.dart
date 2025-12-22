import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
  static const String baseUrl = 'http://localhost:5000'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.5:5000'; // Physical Device
  
  /// Register করার function
  /// এখানে license, specialty, experience প্যারামিটারগুলো যোগ করা হয়েছে
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? license,    // New
    String? specialty,  // New
    String? experience, // New
  }) async {
    try {
      print('🔄 Registering user: $email as $userType');
      
      // বডি ডাটা ম্যাপ তৈরি
      final Map<String, dynamic> requestBody = {
        'fullName': name,
        'email': email,
        'password': password,
        'confirmPassword': password,
        'role': userType.toLowerCase(), 
      };

      // যদি ইউজার টাইপ Doctor হয়, তবেই এই ফিল্ডগুলো ম্যাপে যোগ হবে
      if (userType.toLowerCase() == 'doctor') {
        requestBody['medicalLicense'] = license;
        requestBody['specialty'] = specialty;
        requestBody['experience'] = experience;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody), // ডাইনামিক বডি পাঠানো হচ্ছে
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - Check if server is running');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'data': data
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      print('❌ Registration Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e)
      };
    }
  }

  /// Login করার function (আগের মতোই আছে)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Logging in user: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - Check if server is running');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['data']?['accessToken'] != null) {
          await _saveToken(data['data']['accessToken']);
        }
        if (data['data']?['user'] != null) {
          await _saveUserInfo(data['data']['user']);
        }

        return {
          'success': true,
          'message': 'Login successful',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid email or password'
        };
      }
    } catch (e) {
      print('❌ Login Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e)
      };
    }
  }

  /// Token save করার function
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('✅ Token saved successfully');
  }

  /// User info save করার function
  Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user['_id'] ?? '');
    await prefs.setString('user_name', user['fullName'] ?? '');
    await prefs.setString('user_email', user['email'] ?? '');
    await prefs.setString('user_role', user['role'] ?? '');
    print('✅ User info saved successfully');
  }

  /// Token পাওয়ার function
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// User info পাওয়ার function
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('user_id'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'role': prefs.getString('user_role'),
    };
  }

  /// Check user login state
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    print('✅ Logged out successfully');
  }

  /// Error message helper
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') || 
        error.toString().contains('Connection') ||
        error.toString().contains('timeout')) {
      return 'Cannot connect to server. Please check:\n'
             '1. Server is running (node server.js)\n'
             '2. Correct IP address in baseUrl\n'
             '3. Network connection';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid response from server';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }
}