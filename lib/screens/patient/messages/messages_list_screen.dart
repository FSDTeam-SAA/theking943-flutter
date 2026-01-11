import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/messages/chat_screen.dart';
import 'package:docmobi/screens/patient/navigation/patient_main_navigation.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'dart:async';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;
  String? _currentUserId;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadChats();
    _startAutoRefresh(); // ✅ Auto-refresh every 3 seconds
    _setupSocketListener(); // ✅ Listen to socket events
  }

  // ✅ Setup socket listener for real-time updates
  void _setupSocketListener() {
    final socket = SocketService.instance.socket;
    if (socket != null) {
      socket.on('message:new', (data) {
        print('📨 New message received in list');
        _loadChats(); // Reload chats when new message arrives
      });
    }
  }

  // ✅ Start auto-refresh timer
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadChatsQuietly(); // Silent reload without loading indicator
      }
    });
  }

  // ✅ Silent reload (no loading indicator)
  Future<void> _loadChatsQuietly() async {
    try {
      final result = await ApiService.getMyChats();
      
      if (result['success'] == true && mounted) {
        final chats = result['data'] ?? [];
        
        Map<String, dynamic> uniqueChatsMap = {};
        for (var chat in chats) {
          final chatId = chat['_id']?.toString();
          if (chatId != null) {
            final participants = chat['participants'] as List?;
            if (participants != null && 
                participants.any((p) => p['role'] == 'doctor')) {
              if (!uniqueChatsMap.containsKey(chatId) ||
                  _isNewerChat(chat, uniqueChatsMap[chatId])) {
                uniqueChatsMap[chatId] = chat;
              }
            }
          }
        }
        
        final uniqueChats = uniqueChatsMap.values.toList();
        
        uniqueChats.sort((a, b) {
          final aTime = a['updatedAt']?.toString() ?? '';
          final bTime = b['updatedAt']?.toString() ?? '';
          return bTime.compareTo(aTime);
        });
        
        if (mounted) {
          setState(() {
            _chats = uniqueChats;
          });
        }
      }
    } catch (e) {
      print('❌ Error in quiet reload: $e');
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final profileResult = await ApiService.getUserProfile();
      if (profileResult['success'] == true) {
        setState(() {
          _currentUserId = profileResult['data']['_id']?.toString();
        });
      }
    } catch (e) {
      print('❌ Error loading current user ID: $e');
    }
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Loading patient chats...');
      final result = await ApiService.getMyChats();
      
      if (result['success'] == true) {
        final chats = result['data'] ?? [];
        
        Map<String, dynamic> uniqueChatsMap = {};
        for (var chat in chats) {
          final chatId = chat['_id']?.toString();
          if (chatId != null) {
            final participants = chat['participants'] as List?;
            if (participants != null && 
                participants.any((p) => p['role'] == 'doctor')) {
              if (!uniqueChatsMap.containsKey(chatId) ||
                  _isNewerChat(chat, uniqueChatsMap[chatId])) {
                uniqueChatsMap[chatId] = chat;
              }
            }
          }
        }
        
        final uniqueChats = uniqueChatsMap.values.toList();
        
        uniqueChats.sort((a, b) {
          final aTime = a['updatedAt']?.toString() ?? '';
          final bTime = b['updatedAt']?.toString() ?? '';
          return bTime.compareTo(aTime);
        });
        
        setState(() {
          _chats = uniqueChats;
          _isLoading = false;
        });
        print('✅ Loaded ${_chats.length} unique doctor chats');
      } else {
        setState(() {
          _chats = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
      setState(() {
        _chats = [];
        _isLoading = false;
      });
    }
  }

  bool _isNewerChat(Map<String, dynamic> chat1, Map<String, dynamic> chat2) {
    final time1 = chat1['updatedAt']?.toString() ?? '';
    final time2 = chat2['updatedAt']?.toString() ?? '';
    return time1.compareTo(time2) > 0;
  }

  void _goBackToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientMainNavigation(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _goBackToHome,
          ),
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadChats,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, 
                              size: 64, 
                              color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadChats,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        return _buildChatItem(_chats[index]);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final participants = chat['participants'] as List? ?? [];
    
    final doctor = participants.firstWhere(
      (p) => p['role'] == 'doctor',
      orElse: () => null,
    );
    
    if (doctor == null) {
      return const SizedBox.shrink();
    }
    
    final String doctorName = doctor['fullName']?.toString() ?? 'Doctor';
    final String? doctorAvatar = doctor['avatar']?['url']?.toString();
    final String doctorId = doctor['_id']?.toString() ?? '';
    
    final lastMessage = chat['lastMessage'];
    final String messageText = lastMessage != null 
        ? (lastMessage['content']?.toString() ?? 'Start conversation')
        : 'Start conversation';
    
    // ✅ Get unread count
    final int unreadCount = chat['unreadCount'] ?? 0;
    
    final DateTime? updatedAt = chat['updatedAt'] != null 
        ? DateTime.tryParse(chat['updatedAt'].toString())
        : null;
    final String timeText = updatedAt != null ? _formatTime(updatedAt) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                chatId: chat['_id'].toString(),
                doctorName: doctorName,
                doctorAvatar: doctorAvatar,
                doctorId: doctorId,
              ),
            ),
          ).then((_) {
            _loadChats();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: doctorAvatar != null && 
                       doctorAvatar.isNotEmpty &&
                       doctorAvatar != 'file:///' &&
                       (doctorAvatar.startsWith('http://') || 
                        doctorAvatar.startsWith('https://'))
                    ? Image.network(
                        doctorAvatar,
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                           Image.asset(
                             "assets/images/doctor1.png",
                             height: 56,
                             width: 56,
                             fit: BoxFit.cover,
                           ),
                      )
                    : Image.asset(
                        "assets/images/doctor1.png",
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2C49),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Dr.',
                            style: TextStyle(
                              color: Color(0xFF1E61D4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // ✅ Added unread count display
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            messageText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unreadCount > 0 
                                  ? const Color(0xFF1B2C49)
                                  : Colors.grey,
                              fontSize: 14,
                              fontWeight: unreadCount > 0 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        // ✅ Unread badge
                        if (unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel(); // ✅ Cancel timer
    SocketService.instance.off('message:new'); // ✅ Remove listener
    super.dispose();
  }
}