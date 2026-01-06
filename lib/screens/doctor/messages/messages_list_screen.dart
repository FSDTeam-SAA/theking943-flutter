import 'package:docmobi/screens/doctor/navigation/doctor_main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/screens/doctor/messages/chat_screen.dart';
import 'package:docmobi/screens/doctor/home/doctor_home_screen.dart';
import 'package:docmobi/services/api_service.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  String selectedTab = "All";
  List<dynamic> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getMyChats();
      
      if (result['success'] == true) {
        setState(() {
          _chats = result['data'] ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_chats.length} chats');
      } else {
        print('⚠️ Failed to load chats: ${result['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredChats {
    if (selectedTab == "All") {
      return _chats;
    } else if (selectedTab == "Doctors") {
      return _chats.where((chat) {
        final participants = chat['participants'] as List?;
        if (participants == null) return false;
        
        // Check if there's any doctor in participants (excluding self)
        return participants.any((p) => p['role'] == 'doctor');
      }).toList();
    } else {
      // Patient tab
      return _chats.where((chat) {
        final participants = chat['participants'] as List?;
        if (participants == null) return false;
        
        // Check if there's any patient in participants
        return participants.any((p) => p['role'] == 'patient');
      }).toList();
    }
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DoctorMainNavigation()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayChats = _filteredChats;

    // WillPopScope এর বদলে নতুন PopScope ব্যবহার করা হয়েছে (Flutter 3.12+)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            // Tab Selection Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabButton("All"),
                    _buildTabButton("Doctors"),
                    _buildTabButton("Patient"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Chat List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadChats,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayChats.isEmpty
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
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: displayChats.length,
                            itemBuilder: (context, index) {
                              return _buildChatItem(displayChats[index]);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E61D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1B2C49),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final participants = chat['participants'] as List? ?? [];
    
    // Find the other user (not me)
    final otherUser = participants.firstWhere(
      (p) => p['_id'] != null, // You should check against current user ID
      orElse: () => {'fullName': 'Unknown', 'avatar': null, 'role': 'unknown'},
    );
    
    final String name = otherUser['fullName']?.toString() ?? 'Unknown User';
    final String? avatar = otherUser['avatar']?.toString();
    final String role = otherUser['role']?.toString() ?? '';
    
    final lastMessage = chat['lastMessage'];
    final String messageText = lastMessage?['content']?.toString() ?? 'No messages yet';
    
    final DateTime? updatedAt = chat['updatedAt'] != null 
        ? DateTime.tryParse(chat['updatedAt'].toString())
        : null;
    final String timeText = updatedAt != null ? _formatTime(updatedAt) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorChatDetailScreen(
                chatId: chat['_id'].toString(),
                userName: name,
                userAvatar: avatar,
                userRole: role,
              ),
            ),
          ).then((_) => _loadChats()); // Refresh when coming back
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
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: avatar != null
                    ? NetworkImage(avatar)
                    : const AssetImage('assets/images/doctor.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
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
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2C49),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (role == 'doctor')
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
                    const SizedBox(height: 4),
                    Text(
                      messageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
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
}