import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000';

  /// Register function
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String userType,
    String? medicalLicenseNumber,
    String? specialty,
    String? experienceYears,
  }) async {
    try {
      print('🔄 Registering user: $email as $userType');

      final Map<String, dynamic> requestBody = {
        'fullName': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': userType.toLowerCase().trim(),
      };

      if (userType.toLowerCase() == 'doctor') {
        requestBody['medicalLicenseNumber'] = medicalLicenseNumber;
        requestBody['specialty'] = specialty;
        requestBody['experienceYears'] = experienceYears;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Token save koro
        if (data['data'] != null && data['data']['accessToken'] != null) {
          await ApiService.saveToken(data['data']['accessToken']);
          
          // ✅ User info + ROLE save koro
          if (data['data']['user'] != null) {
            await _saveUserInfo(data['data']['user']);
          }
        }

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
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  /// Login function
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Logging in user: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Response Status: ${response.statusCode}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Save token
        if (data['data'] != null) {
          if (data['data']['accessToken'] != null) {
            await ApiService.saveToken(data['data']['accessToken']);
          }
          
          // ✅ Save user info + ROLE
          if (data['data']['user'] != null) {
            await _saveUserInfo(data['data']['user']);
            
            // Debug: Check saved role
            final prefs = await SharedPreferences.getInstance();
            final savedRole = prefs.getString('user_role');
            print('✅ Saved Role: $savedRole');
          }
        }

        return {
          'success': true,
          'message': 'Login successful',
          'data': data['data'],
          'role': data['data']?['user']?['role'], // ✅ Return role
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid email or password'
        };
      }
    } catch (e) {
      print('❌ Login Error: $e');
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  /// Logout function
  Future<void> logout() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ Logged out successfully');
  }

  /// ✅ Get saved user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_role');
    } catch (e) {
      print('❌ Error getting role: $e');
      return null;
    }
  }

  /// ✅ Get saved user info
  static Future<Map<String, String?>> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'id': prefs.getString('user_id'),
        'name': prefs.getString('user_name'),
        'email': prefs.getString('user_email'),
        'role': prefs.getString('user_role'),
      };
    } catch (e) {
      print('❌ Error getting user info: $e');
      return {};
    }
  }

  // ✅ Helper: Save user info with role
  Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_id', user['_id'] ?? '');
      await prefs.setString('user_name', user['fullName'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      
      // ✅ CRITICAL: Save role properly
      final role = user['role']?.toString().toLowerCase() ?? '';
      await prefs.setString('user_role', role);
      
      print('✅ User info saved:');
      print('   - ID: ${user['_id']}');
      print('   - Name: ${user['fullName']}');
      print('   - Role: $role');
    } catch (e) {
      print('❌ Error saving user info: $e');
    }
  }

  Future<String?> getToken() async {
    return ApiService.token;
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection') ||
        error.toString().contains('timeout')) {
      return 'Cannot connect to server. Ensure Node.js server is running at $baseUrl';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }
}