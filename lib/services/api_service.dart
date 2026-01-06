import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';

class ApiService {
  static String? _token;
  static const String _baseUrl = 'http://localhost:5000'; // Change this to your backend URL

  /// Initialize - Token load kora
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      print('✅ ApiService initialized. Token: ${_token != null ? "Found" : "Not found"}');
      
      if (_token != null) {
        print('🔍 Token status: ${isLoggedIn ? "Logged In" : "Not Logged In"}');
      }
    } catch (e) {
      print('❌ Error initializing ApiService: $e');
    }
  }

  /// Token save kora
  static Future<void> saveToken(String token) async {
    try {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('✅ Token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  /// Token clear kora
  static Future<void> clearToken() async {
    try {
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('✅ Token cleared');
    } catch (e) {
      print('❌ Error clearing token: $e');
    }
  }

  /// Check if logged in
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Get current token
  static String? get token => _token;

  /// Headers generate - WITH TOKEN
  static Map<String, String> _getHeaders({bool requiresAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      print('🔐 Token added to headers: Bearer ${_token!.substring(0, 20)}...');
    } else if (requiresAuth && (_token == null || _token!.isEmpty)) {
      print('⚠️ Auth required but no token available');
    }

    return headers;
  }

  /// GET Request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      print('📤 GET: $url');
      print('🔐 Auth Required: $requiresAuth');

      final headers = _getHeaders(requiresAuth: requiresAuth);
      print('📋 Headers: ${headers.keys.toList()}');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      print('📤 POST: $url');
      print('📦 Body: $body');
      print('🔐 Auth Required: $requiresAuth');

      final headers = _getHeaders(requiresAuth: requiresAuth);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      print('📤 PUT: $url');
      print('📦 Body: $body');
      print('🔐 Auth Required: $requiresAuth');

      final headers = _getHeaders(requiresAuth: requiresAuth);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// PATCH Request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      print('📤 PATCH: $url');
      print('📦 Body: $body');
      print('🔐 Auth Required: $requiresAuth');

      final headers = _getHeaders(requiresAuth: requiresAuth);

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ PATCH Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// DELETE Request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      print('📤 DELETE: $url');
      print('🔐 Auth Required: $requiresAuth');

      final headers = _getHeaders(requiresAuth: requiresAuth);

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // ========================================
  // 📱 CHAT & MESSAGING APIs
  // ========================================

  /// Get Chat Messages
  static Future<Map<String, dynamic>> getChatMessages({
    required String chatId,
    required int page,
    required int limit,
  }) async {
    return await get(
      '/messages?chatId=$chatId&page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  /// Get My Chats
  static Future<Map<String, dynamic>> getMyChats() async {
    return await get(
      '/chats',
      requiresAuth: true,
    );
  }

  /// Create or Get Chat
  static Future<Map<String, dynamic>> createOrGetChat({
    required String userId,
  }) async {
    return await post(
      '/chats',
      {'userId': userId},
      requiresAuth: true,
    );
  }

  /// Send Message
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    String? content,
    List<File>? files,
    String? contentType,
  }) async {
    Map<String, dynamic> body = {
      'chatId': chatId,
    };

    if (content != null && content.isNotEmpty) {
      body['content'] = content;
    }

    if (contentType != null) {
      body['contentType'] = contentType;
    }

    // If files are provided, upload them first
    if (files != null && files.isNotEmpty) {
      // Handle file upload logic here
      // For now, just send the message
      body['hasFiles'] = true;
    }

    return await post(
      '/messages',
      body,
      requiresAuth: true,
    );
  }

  // ========================================
  // 📝 POST APIs (for social features)
  // ========================================

  /// Create Post
  static Future<Map<String, dynamic>> createPost({
    required String content,
    List<File>? mediaFiles,
    String visibility = 'public',
  }) async {
    Map<String, dynamic> body = {
      'content': content,
      'visibility': visibility,
    };

    // If media files provided, handle upload
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      // Convert files to paths or base64 as needed by your API
      body['mediaFiles'] = mediaFiles.map((file) => file.path).toList();
    }

    return await post(
      '/posts',
      body,
      requiresAuth: true,
    );
  }

  /// Get All Posts
  static Future<Map<String, dynamic>> getAllPosts({
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/posts?page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  /// Get User Posts
  static Future<Map<String, dynamic>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/posts/user/$userId?page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  /// Like Post
  static Future<Map<String, dynamic>> likePost({
    required String postId,
  }) async {
    return await post(
      '/posts/$postId/like',
      {},
      requiresAuth: true,
    );
  }

  /// Comment on Post
  static Future<Map<String, dynamic>> commentOnPost({
    required String postId,
    required String comment,
  }) async {
    return await post(
      '/posts/$postId/comment',
      {'comment': comment},
      requiresAuth: true,
    );
  }

  /// Delete Post
  static Future<Map<String, dynamic>> deletePost({
    required String postId,
  }) async {
    return await delete(
      '/posts/$postId',
      requiresAuth: true,
    );
  }

  // ========================================
  // 👤 USER APIs
  // ========================================

  /// Get User Profile
  static Future<Map<String, dynamic>> getUserProfile({
    String? userId,
  }) async {
    final endpoint = userId != null ? '/users/$userId' : '/users/me';
    return await get(endpoint, requiresAuth: true);
  }

  /// Update User Profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    return await put(
      '/users/me',
      data,
      requiresAuth: true,
    );
  }

  /// Search Users
  static Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/users/search?q=$query&page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  // ========================================
  // 📅 APPOINTMENT APIs
  // ========================================

  /// Get Appointments
  static Future<Map<String, dynamic>> getAppointments() async {
    return await get(
      '/appointments',
      requiresAuth: true,
    );
  }

  /// Create Appointment
  static Future<Map<String, dynamic>> createAppointment({
    required Map<String, dynamic> appointmentData,
  }) async {
    return await post(
      '/appointments',
      appointmentData,
      requiresAuth: true,
    );
  }

  /// Update Appointment Status
  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    return await patch(
      '/appointments/$appointmentId',
      {'status': status},
      requiresAuth: true,
    );
  }

  /// Cancel Appointment
  static Future<Map<String, dynamic>> cancelAppointment({
    required String appointmentId,
  }) async {
    return await patch(
      '/appointments/$appointmentId/cancel',
      {},
      requiresAuth: true,
    );
  }

  // ========================================
  // 🏥 DOCTOR APIs
  // ========================================

  /// Get All Doctors
  static Future<Map<String, dynamic>> getAllDoctors({
    int page = 1,
    int limit = 20,
    String? specialty,
  }) async {
    String endpoint = '/doctors?page=$page&limit=$limit';
    if (specialty != null && specialty.isNotEmpty) {
      endpoint += '&specialty=$specialty';
    }
    return await get(endpoint, requiresAuth: false);
  }

  /// Get Doctor Details
  static Future<Map<String, dynamic>> getDoctorDetails({
    required String doctorId,
  }) async {
    return await get(
      '/doctors/$doctorId',
      requiresAuth: false,
    );
  }

  /// Search Doctors
  static Future<Map<String, dynamic>> searchDoctors({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/doctors/search?q=$query&page=$page&limit=$limit',
      requiresAuth: false,
    );
  }

  // ========================================
  // 💰 PAYMENT/EARNINGS APIs
  // ========================================

  /// Get Earnings
  static Future<Map<String, dynamic>> getEarnings() async {
    return await get(
      '/earnings',
      requiresAuth: true,
    );
  }

  /// Get Transactions
  static Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/transactions?page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  // ========================================
  // 🎬 REELS/POSTS APIs (Social Media)
  // ========================================

  /// Create Reel
  static Future<Map<String, dynamic>> createReel({
    File? videoFile,
    String? caption,
    String visibility = 'public',
  }) async {
    Map<String, dynamic> body = {
      'visibility': visibility,
    };

    if (caption != null && caption.isNotEmpty) {
      body['caption'] = caption;
    }

    if (videoFile != null) {
      body['videoFile'] = videoFile.path;
    }

    return await post(
      '/reels',
      body,
      requiresAuth: true,
    );
  }

  /// Get All Reels
  static Future<Map<String, dynamic>> getAllReels({
    int page = 1,
    int limit = 20,
  }) async {
    return await get(
      '/reels?page=$page&limit=$limit',
      requiresAuth: true,
    );
  }

  /// Upload Reel (with file upload)
  static Future<Map<String, dynamic>> uploadReel({
    required List<dynamic> mediaFiles,
    required String caption,
    String visibility = 'public',
  }) async {
    return await post(
      '/reels/upload',
      {
        'mediaFiles': mediaFiles,
        'caption': caption,
        'visibility': visibility,
      },
      requiresAuth: true,
    );
  }

  // ========================================
  // 📤 FILE UPLOAD APIs
  // ========================================

  /// Upload Single File
  static Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fieldName,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/upload';
      print('📤 Uploading file: $filePath');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_getHeaders(requiresAuth: true));
      
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ File upload error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Upload Multiple Files
  static Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<String> filePaths,
    required String fieldName,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/upload/multiple';
      print('📤 Uploading ${filePaths.length} files');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_getHeaders(requiresAuth: true));
      
      for (var filePath in filePaths) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, filePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Multiple file upload error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 Status: ${response.statusCode}');
    
    // Safe substring for logging
    final bodyPreview = response.body.length > 500 
        ? response.body.substring(0, 500) 
        : response.body;
    print('📥 Response Body: $bodyPreview...');

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;

      // Success response (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          ...data,
        };
      }
      // Unauthorized (401) - Token invalid/expired
      else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Clearing token');
        clearToken();
        return {
          'success': false,
          'message': data['message'] ?? 'Session expired. Please login again.',
          'requiresLogin': true,
          'statusCode': response.statusCode,
        };
      }
      // Forbidden (403)
      else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'Access denied',
          'statusCode': response.statusCode,
        };
      }
      // Not Found (404)
      else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': data['message'] ?? 'Resource not found',
          'statusCode': response.statusCode,
        };
      }
      // Bad Request (400)
      else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': data['message'] ?? 'Bad request',
          'statusCode': response.statusCode,
          'errors': data['errorSources'] ?? [],
        };
      }
      // Server Error (500+)
      else if (response.statusCode >= 500) {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
          'statusCode': response.statusCode,
        };
      }
      // Other errors
      else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Response parsing error: $e');
      return {
        'success': false,
        'message': 'Invalid response format',
        'statusCode': response.statusCode,
        'rawBody': response.body,
      };
    }
  }

  /// Error message generator
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') || 
        errorString.contains('failed host lookup')) {
      return 'Cannot connect to server. Please check your internet connection.';
    } else if (errorString.contains('connection refused')) {
      return 'Server is not responding. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please check your connection and try again.';
    } else if (errorString.contains('format')) {
      return 'Invalid data format received from server.';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }

  /// Update base URL if needed (for different environments)
  static void setBaseUrl(String url) {
    // Remove this method if you're using ApiConfig
    print('⚠️ Base URL updated to: $url');
  }
}