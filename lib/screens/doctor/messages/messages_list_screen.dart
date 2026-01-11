import 'package:docmobi/screens/doctor/messages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DoctorMessagesScreen extends StatefulWidget {
  final String? initialDoctorId;

  const DoctorMessagesScreen({super.key, this.initialDoctorId});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allChats = [];
  bool isLoading = true;
  String? currentUserId;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUserId();
    _loadChats();
    _startAutoRefresh(); // ✅ Auto-refresh every 3 seconds
    _setupSocketListener(); // ✅ Listen to socket events

    if (widget.initialDoctorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createChatWithDoctor(widget.initialDoctorId!);
      });
    }
  }

  // ✅ Setup socket listener for real-time updates
  void _setupSocketListener() {
    final socket = SocketService.instance.socket;
    if (socket != null) {
      socket.on('message:new', (data) {
        print('📨 New message received in doctor list');
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
      final response = await ApiService.getMyChats();
      if (response['success'] == true && mounted) {
        final chats = List<Map<String, dynamic>>.from(response['data'] ?? []);
        
        Map<String, Map<String, dynamic>> uniqueChatsMap = {};
        for (var chat in chats) {
          final chatId = chat['_id']?.toString();
          if (chatId != null) {
            if (!uniqueChatsMap.containsKey(chatId) ||
                _isNewerChat(chat, uniqueChatsMap[chatId]!)) {
              uniqueChatsMap[chatId] = chat;
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
            allChats = uniqueChats;
          });
        }
      }
    } catch (e) {
      print('Error in quiet reload: $e');
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final result = await ApiService.getUserProfile();
      if (result['success'] == true) {
        setState(() {
          currentUserId = result['data']['_id']?.toString();
        });
      }
    } catch (e) {
      print('Error loading user ID: $e');
    }
  }

  Future<void> _loadChats() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getMyChats();
      if (response['success'] == true) {
        final chats = List<Map<String, dynamic>>.from(response['data'] ?? []);
        
        Map<String, Map<String, dynamic>> uniqueChatsMap = {};
        for (var chat in chats) {
          final chatId = chat['_id']?.toString();
          if (chatId != null) {
            if (!uniqueChatsMap.containsKey(chatId) ||
                _isNewerChat(chat, uniqueChatsMap[chatId]!)) {
              uniqueChatsMap[chatId] = chat;
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
          allChats = uniqueChats;
          isLoading = false;
        });
        
        print('✅ Loaded ${allChats.length} unique chats');
      }
    } catch (e) {
      print('Error loading chats: $e');
      setState(() => isLoading = false);
    }
  }

  bool _isNewerChat(Map<String, dynamic> chat1, Map<String, dynamic> chat2) {
    final time1 = chat1['updatedAt']?.toString() ?? '';
    final time2 = chat2['updatedAt']?.toString() ?? '';
    return time1.compareTo(time2) > 0;
  }

  Future<void> _createChatWithDoctor(String doctorId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await ApiService.createOrGetChat(userId: doctorId);
      Navigator.pop(context);

      if (result['success'] == true) {
        final chatData = result['data'];
        final chatId = chatData['_id']?.toString();
        
        if (chatId != null) {
          final participants = chatData['participants'] as List;
          final otherUser = participants.firstWhere(
            (p) => p['_id'] != currentUserId,
            orElse: () => participants[0],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorChatDetailScreen(
                chatId: chatId,
                userName: otherUser['fullName'] ?? 'Doctor',
                userAvatar: otherUser['avatar']?['url'],
                userRole: otherUser['role'] ?? 'doctor',
                otherUserId: otherUser['_id'],
              ),
            ),
          ).then((_) => _loadChats());

          _tabController.animateTo(0);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get uniqueChats {
    return allChats;
  }

  List<Map<String, dynamic>> get doctorChats {
    return uniqueChats.where((chat) {
      final participants = chat['participants'] as List? ?? [];
      return participants.any((p) => 
        p['_id'] != currentUserId && p['role'] == 'doctor'
      );
    }).toList();
  }

  List<Map<String, dynamic>> get patientChats {
    return uniqueChats.where((chat) {
      final participants = chat['participants'] as List? ?? [];
      return participants.any((p) => 
        p['_id'] != currentUserId && p['role'] == 'patient'
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFF1B2C49),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1664CD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1664CD),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Doctors'),
            Tab(text: 'Patients'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(uniqueChats),
                _buildChatList(doctorChats),
                _buildChatList(patientChats),
              ],
            ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> chats) {
    if (chats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No messages yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return _buildChatCard(chats[index]);
        },
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final participants = chat['participants'] as List? ?? [];
    final otherUser = participants.firstWhere(
      (p) => p['_id'] != currentUserId,
      orElse: () => participants.isNotEmpty ? participants[0] : {},
    );

    final String userName = otherUser['fullName'] ?? 'Unknown';
    final String? userAvatar = otherUser['avatar']?['url'];
    final String userRole = otherUser['role'] ?? 'user';
    final String lastMessageText = chat['lastMessage']?['content'] ?? 'No messages yet';
    final int unreadCount = chat['unreadCount'] ?? 0;
    
    final String? lastMessageTime = chat['lastMessage']?['createdAt'];
    final String timeText = lastMessageTime != null 
        ? _formatTime(DateTime.parse(lastMessageTime))
        : '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorChatDetailScreen(
              chatId: chat['_id'],
              userName: userName,
              userAvatar: userAvatar,
              userRole: userRole,
              otherUserId: otherUser['_id'],
            ),
          ),
        ).then((_) => _loadChats());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: userAvatar != null &&
                      userAvatar.isNotEmpty &&
                      userAvatar != 'file:///' &&
                      (userAvatar.startsWith('http://') ||
                          userAvatar.startsWith('https://'))
                  ? NetworkImage(userAvatar)
                  : const AssetImage('assets/images/doctor.png') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2C49),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageText,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0 
                                ? const Color(0xFF1B2C49)
                                : Colors.grey[600],
                            fontWeight: unreadCount > 0 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1664CD),
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
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autoRefreshTimer?.cancel(); // ✅ Cancel timer
    SocketService.instance.off('message:new'); // ✅ Remove listener
    super.dispose();
  }
}