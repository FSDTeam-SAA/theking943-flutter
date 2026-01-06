import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _token;
  // ✅ Your Mac IP Address from same WiFi network
  // Use this for Physical Android/iOS devices on same WiFi
  static const String _baseUrl = 'http://192.168.10.210:5000';
  
  // For Android Emulator, use: 'http://10.0.2.2:5000'
  // For iOS Simulator, use: 'http://localhost:5000'

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
      final url = '$_baseUrl$endpoint';
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
      final url = '$_baseUrl$endpoint';
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
      final url = '$_baseUrl$endpoint';
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
      final url = '$_baseUrl$endpoint';
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
      final url = '$_baseUrl$endpoint';
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

  /// Response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

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

  // ==================== REELS API METHODS ====================

  /// Create Reel with video upload
  static Future<Map<String, dynamic>> createReel({
    required File videoFile,
    File? thumbnailFile,
    String? caption,
    String visibility = 'public',
  }) async {
    try {
      final url = '$_baseUrl/api/v1/reels';
      print('📤 POST (Multipart): $url');
      print('🎥 Video: ${videoFile.path}');
      print('🖼️ Thumbnail: ${thumbnailFile?.path ?? "None"}');
      print('📝 Caption: $caption');
      print('🔐 Visibility: $visibility');

      if (_token == null || _token!.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requiresLogin': true,
        };
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $_token';

      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
        ),
      );

      // Add thumbnail if exists
      if (thumbnailFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'thumbnail',
            thumbnailFile.path,
          ),
        );
      }

      // Add other fields
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }
      request.fields['visibility'] = visibility;

      print('📤 Sending multipart request...');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Longer timeout for video upload
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Create Reel Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get All Reels (Public feed)
  static Future<Map<String, dynamic>> getAllReels({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final endpoint = '/api/v1/reels/all-reels?page=$page&limit=$limit';
      print('📤 GET All Reels: $_baseUrl$endpoint');

      final response = await get(endpoint, requiresAuth: false);
      
      print('📥 All Reels Response: $response');
      return response;
    } catch (e) {
      print('❌ Get All Reels Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get My Reels (Authenticated user's reels)
  static Future<Map<String, dynamic>> getMyReels({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final endpoint = '/api/v1/reels?page=$page&limit=$limit';
      print('📤 GET My Reels: $_baseUrl$endpoint');

      final response = await get(endpoint, requiresAuth: true);
      
      print('📥 My Reels Response: $response');
      return response;
    } catch (e) {
      print('❌ Get My Reels Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get Single Reel by ID
  static Future<Map<String, dynamic>> getReelById(String reelId) async {
    try {
      final endpoint = '/api/v1/reels/$reelId';
      print('📤 GET Reel by ID: $_baseUrl$endpoint');

      final response = await get(endpoint, requiresAuth: true);
      
      print('📥 Reel Response: $response');
      return response;
    } catch (e) {
      print('❌ Get Reel by ID Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Update Reel
  static Future<Map<String, dynamic>> updateReel({
    required String reelId,
    File? videoFile,
    File? thumbnailFile,
    String? caption,
    String? visibility,
  }) async {
    try {
      final url = '$_baseUrl/api/v1/reels/$reelId';
      print('📤 PUT (Multipart): $url');

      if (_token == null || _token!.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requiresLogin': true,
        };
      }

      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $_token';

      // Add video file if provided
      if (videoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            videoFile.path,
          ),
        );
      }

      // Add thumbnail if provided
      if (thumbnailFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'thumbnail',
            thumbnailFile.path,
          ),
        );
      }

      // Add other fields
      if (caption != null) {
        request.fields['caption'] = caption;
      }
      if (visibility != null) {
        request.fields['visibility'] = visibility;
      }

      print('📤 Sending update request...');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Update Reel Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Delete Reel
  static Future<Map<String, dynamic>> deleteReel(String reelId) async {
    try {
      final endpoint = '/api/v1/reels/$reelId';
      print('📤 DELETE Reel: $_baseUrl$endpoint');

      final response = await delete(endpoint, requiresAuth: true);
      
      print('📥 Delete Response: $response');
      return response;
    } catch (e) {
      print('❌ Delete Reel Error: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }
// ==================== POST API METHODS ====================
// Add these methods to your existing ApiService class

/// Create Post with multiple media files
static Future<Map<String, dynamic>> createPost({
  required String content,
  List<File>? mediaFiles,
  String visibility = 'public',
}) async {
  try {
    final url = '$_baseUrl/api/v1/posts';
    print('📤 POST (Multipart): $url');
    print('📝 Content: $content');
    print('📷 Media files: ${mediaFiles?.length ?? 0}');

    if (_token == null || _token!.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication required',
        'requiresLogin': true,
      };
    }

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $_token';

    // Add content
    if (content.isNotEmpty) {
      request.fields['content'] = content;
    }

    // Add visibility
    request.fields['visibility'] = visibility;

    // Add media files
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      for (var file in mediaFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            file.path,
          ),
        );
      }
    }

    print('📤 Sending multipart request...');

    // Send request
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(streamedResponse);

    print('📥 Status: ${response.statusCode}');
    print('📥 Response: ${response.body}');

    return _handleResponse(response);
  } catch (e) {
    print('❌ Create Post Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get All Posts (Public feed)
static Future<Map<String, dynamic>> getAllPosts({
  int page = 1,
  int limit = 10,
}) async {
  try {
    final endpoint = '/api/v1/posts/all-posts?page=$page&limit=$limit';
    print('📤 GET All Posts: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: false);
    
    print('📥 All Posts Response: $response');
    return response;
  } catch (e) {
    print('❌ Get All Posts Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get My Posts (Authenticated user's posts - Doctor only)
static Future<Map<String, dynamic>> getMyPosts({
  int page = 1,
  int limit = 10,
}) async {
  try {
    final endpoint = '/api/v1/posts?page=$page&limit=$limit';
    print('📤 GET My Posts: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    print('📥 My Posts Response: $response');
    return response;
  } catch (e) {
    print('❌ Get My Posts Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get Single Post by ID
static Future<Map<String, dynamic>> getPostById(String postId) async {
  try {
    final endpoint = '/api/v1/posts/$postId';
    print('📤 GET Post by ID: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    print('📥 Post Response: $response');
    return response;
  } catch (e) {
    print('❌ Get Post by ID Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Update Post
static Future<Map<String, dynamic>> updatePost({
  required String postId,
  String? content,
  List<File>? mediaFiles,
  String? visibility,
}) async {
  try {
    final url = '$_baseUrl/api/v1/posts/$postId';
    print('📤 PUT (Multipart): $url');

    if (_token == null || _token!.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication required',
        'requiresLogin': true,
      };
    }

    var request = http.MultipartRequest('PUT', Uri.parse(url));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $_token';

    // Add fields
    if (content != null && content.isNotEmpty) {
      request.fields['content'] = content;
    }
    if (visibility != null) {
      request.fields['visibility'] = visibility;
    }

    // Add media files if provided
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      for (var file in mediaFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            file.path,
          ),
        );
      }
    }

    print('📤 Sending update request...');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  } catch (e) {
    print('❌ Update Post Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Delete Post
static Future<Map<String, dynamic>> deletePost(String postId) async {
  try {
    final endpoint = '/api/v1/posts/$postId';
    print('📤 DELETE Post: $_baseUrl$endpoint');

    final response = await delete(endpoint, requiresAuth: true);
    
    print('📥 Delete Response: $response');
    return response;
  } catch (e) {
    print('❌ Delete Post Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Toggle Like on Post
static Future<Map<String, dynamic>> toggleLikePost(String postId) async {
  try {
    final endpoint = '/api/v1/posts/$postId/like';
    print('📤 POST Toggle Like: $_baseUrl$endpoint');

    final response = await post(endpoint, {}, requiresAuth: true);
    
    print('📥 Like Response: $response');
    return response;
  } catch (e) {
    print('❌ Toggle Like Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get Post Likes
static Future<Map<String, dynamic>> getPostLikes({
  required String postId,
  int page = 1,
  int limit = 20,
}) async {
  try {
    final endpoint = '/api/v1/posts/$postId/likes?page=$page&limit=$limit';
    print('📤 GET Post Likes: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    return response;
  } catch (e) {
    print('❌ Get Post Likes Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Add Comment to Post
static Future<Map<String, dynamic>> addPostComment({
  required String postId,
  required String content,
}) async {
  try {
    final endpoint = '/api/v1/posts/$postId/comments';
    print('📤 POST Add Comment: $_baseUrl$endpoint');

    final response = await post(
      endpoint,
      {'content': content},
      requiresAuth: true,
    );
    
    print('📥 Comment Response: $response');
    return response;
  } catch (e) {
    print('❌ Add Comment Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get Post Comments
static Future<Map<String, dynamic>> getPostComments({
  required String postId,
  int page = 1,
  int limit = 10,
}) async {
  try {
    final endpoint = '/api/v1/posts/$postId/comments?page=$page&limit=$limit';
    print('📤 GET Post Comments: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    return response;
  } catch (e) {
    print('❌ Get Post Comments Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Delete Post Comment
static Future<Map<String, dynamic>> deletePostComment({
  required String postId,
  required String commentId,
}) async {
  try {
    final endpoint = '/api/v1/posts/$postId/comments/$commentId';
    print('📤 DELETE Comment: $_baseUrl$endpoint');

    final response = await delete(endpoint, requiresAuth: true);
    
    print('📥 Delete Comment Response: $response');
    return response;
  } catch (e) {
    print('❌ Delete Comment Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}


// ==================== CHAT API METHODS ====================

/// Create or Get Chat (1-on-1)
static Future<Map<String, dynamic>> createOrGetChat({
  required String userId,
}) async {
  try {
    final endpoint = '/api/v1/chat';
    print('📤 POST Create/Get Chat: $_baseUrl$endpoint');

    final response = await post(
      endpoint,
      {'userId': userId},
      requiresAuth: true,
    );
    
    print('📥 Chat Response: $response');
    return response;
  } catch (e) {
    print('❌ Create Chat Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get My Chats
static Future<Map<String, dynamic>> getMyChats() async {
  try {
    final endpoint = '/api/v1/chat';
    print('📤 GET My Chats: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    print('📥 Chats Response: $response');
    return response;
  } catch (e) {
    print('❌ Get Chats Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Get Chat Messages
static Future<Map<String, dynamic>> getChatMessages({
  required String chatId,
  int page = 1,
  int limit = 20,
}) async {
  try {
    final endpoint = '/api/v1/chat/$chatId/messages?page=$page&limit=$limit';
    print('📤 GET Chat Messages: $_baseUrl$endpoint');

    final response = await get(endpoint, requiresAuth: true);
    
    return response;
  } catch (e) {
    print('❌ Get Messages Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}

/// Send Message
static Future<Map<String, dynamic>> sendMessage({
  required String chatId,
  String? content,
  List<File>? files,
  String contentType = 'text',
}) async {
  try {
    final url = '$_baseUrl/api/v1/chat/$chatId/message';
    print('📤 POST Send Message: $url');

    if (_token == null || _token!.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication required',
        'requiresLogin': true,
      };
    }

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $_token';

    // Add content
    if (content != null && content.isNotEmpty) {
      request.fields['content'] = content;
    }
    
    request.fields['contentType'] = contentType;

    // Add files if provided
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
          ),
        );
      }
    }

    print('📤 Sending message...');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  } catch (e) {
    print('❌ Send Message Error: $e');
    return {
      'success': false,
      'message': _getErrorMessage(e),
    };
  }
}


}