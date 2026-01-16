import 'package:flutter/material.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/screens/common/calls/video_call_screen.dart';
import 'package:docmobi/screens/common/calls/audio_call_screen.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String? doctorAvatar;
  final String? doctorId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    this.doctorAvatar,
    this.doctorId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  List<File> _selectedFiles = [];
  String? _currentUserId;
  String? _currentUserAvatar;
  String? _currentUserName;
  String? _otherUserId;
  String? _actualDoctorAvatar; // ✅ Real avatar from API
  String? _actualDoctorName;

  Timer? _refreshTimer;
  Set<String> _messageIds = {};
  bool _isAutoScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _actualDoctorAvatar = widget.doctorAvatar;
    _actualDoctorName = widget.doctorName;
    _loadCurrentUserProfile();
    _loadMessages();
    _startAutoRefresh();
    _setupSocketListeners();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        _isAutoScrollEnabled = (maxScroll - currentScroll) < 100;
      }
    });
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final profileResult = await ApiService.getUserProfile();
      if (profileResult['success'] == true) {
        setState(() {
          _currentUserId = profileResult['data']['_id']?.toString();
          _currentUserAvatar = profileResult['data']['avatar']?['url']
              ?.toString();
          _currentUserName = profileResult['data']['fullName']?.toString();
        });
        print('✅ Current user profile loaded');
        print('   ID: $_currentUserId');
        print('   Name: $_currentUserName');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  void _setupSocketListeners() {
    final socket = SocketService.instance.socket;
    if (socket != null) {
      socket.on('message:new', (data) {
        print('📨 New message received: $data');
        if (data['chatId'] == widget.chatId) {
          _loadMessagesQuietly();
        }
      });
      print('✅ Socket listeners setup');
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) _loadMessagesQuietly();
    });
  }

  Future<void> _loadMessagesQuietly() async {
    try {
      final result = await ApiService.getChatMessages(
        chatId: widget.chatId,
        page: 1,
        limit: 50,
      );

      if (result['success'] == true && mounted) {
        final newMessages = result['data']?['items'] ?? [];

        Set<String> newMessageIds = {};
        for (var msg in newMessages) {
          final msgId = msg['_id']?.toString();
          if (msgId != null) newMessageIds.add(msgId);
        }

        if (newMessageIds.length != _messageIds.length ||
            !newMessageIds.containsAll(_messageIds)) {
          setState(() {
            _messages = newMessages;
            _messageIds = newMessageIds;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      print('❌ Quiet refresh error: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getChatMessages(
        chatId: widget.chatId,
        page: 1,
        limit: 50,
      );

      if (result['success'] == true) {
        final messages = result['data']?['items'] ?? [];

        Set<String> ids = {};
        for (var msg in messages) {
          final msgId = msg['_id']?.toString();
          if (msgId != null) ids.add(msgId);
        }

        setState(() {
          _messages = messages;
          _messageIds = ids;
          _isLoading = false;
        });

        if (_messages.isNotEmpty && _currentUserId != null) {
          for (var msg in _messages) {
            final senderId = msg['sender']?['_id']?.toString();
            if (senderId != null && senderId != _currentUserId) {
              setState(() {
                _otherUserId = senderId;
                // Get real avatar from message sender
                _actualDoctorAvatar = msg['sender']?['avatar']?['url']
                    ?.toString();
              });
              break;
            }
          }
        }

        if (_otherUserId == null && widget.doctorId != null) {
          setState(() => _otherUserId = widget.doctorId);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();

    if (content.isEmpty && _selectedFiles.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendMessage(
        chatId: widget.chatId,
        content: content,
        files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
        contentType: _selectedFiles.isNotEmpty ? 'file' : 'text',
      );

      if (result['success'] == true) {
        _controller.clear();
        setState(() {
          _selectedFiles = [];
          _isAutoScrollEnabled = true;
        });

        await _loadMessages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedFiles.add(File(image.path)));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  // ✅ Unified method to initiate Call (Audio or Video)
  void _initiateCall({required bool isVideo}) async {
    if (_otherUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot initiate call: User info missing'),
          ),
        );
      }
      return;
    }

    final socket = SocketService.instance.socket;
    if (socket == null || !socket.connected) {
      if (_currentUserId != null) {
        try {
          await SocketService.instance.connect(_currentUserId!);
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          print('❌ Socket reconnection failed: $e');
        }
      }

      if (SocketService.instance.socket == null ||
          !SocketService.instance.socket!.connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot connect to call server'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // ✅ Use API Service to initiate call (matches Doctor implementation)
    // This ensures backend sets up the call properly and sends caller info
    try {
      final result = await ApiService.initiateCall(
        chatId: widget.chatId,
        receiverId: _otherUserId!,
        isVideo: isVideo,
      );

      if (result['success'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Call failed: ${result['message']}')),
          );
        }
        return;
      }
    } catch (e) {
      print('❌ Call initiation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to connect call')));
      }
      return;
    }

    // Call triggered successfully via API, navigation handles locally
    print('📞 Call initiated via API successfully');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => isVideo
              ? VideoCallScreen(
                  chatId: widget.chatId,
                  userName: widget.doctorName,
                  userAvatar: _actualDoctorAvatar ?? widget.doctorAvatar,
                  otherUserId: _otherUserId!,
                  isInitiator: true,
                )
              : AudioCallScreen(
                  chatId: widget.chatId,
                  userName: widget.doctorName,
                  userAvatar: _actualDoctorAvatar ?? widget.doctorAvatar,
                  otherUserId: _otherUserId!,
                  isInitiator: true,
                ),
        ),
      );
    }
  }

  Widget _getAvatarWidget(String? avatarUrl, {bool isDoctor = false}) {
    // ✅ Use actual avatar from API first, then fallback to widget avatar
    final displayAvatar = isDoctor
        ? (_actualDoctorAvatar ?? widget.doctorAvatar)
        : avatarUrl;

    if (displayAvatar != null &&
        displayAvatar.isNotEmpty &&
        displayAvatar != 'file:///' &&
        (displayAvatar.startsWith('http://') ||
            displayAvatar.startsWith('https://'))) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(displayAvatar),
        onBackgroundImageError: (exception, stackTrace) {},
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage(
        isDoctor ? 'assets/images/doctor1.png' : 'assets/images/profile.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _getAvatarImage(_actualDoctorAvatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _actualDoctorName ?? widget.doctorName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Doctor',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Audio Call icon
          IconButton(
            icon: const Icon(
              Icons.phone_outlined,
              color: Colors.black,
              size: 26,
            ),
            onPressed: () => _initiateCall(isVideo: false),
          ),
          // Video icon
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => _initiateCall(isVideo: true),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Today",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with ${widget.doctorName}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildBubble(_messages[index]);
                    },
                  ),
          ),

          if (_selectedFiles.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedFiles[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Type your message.......",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Color(0xFF6C5CE7)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> message) {
    final String text = message['content']?.toString() ?? '';
    final String senderId = message['sender']?['_id']?.toString() ?? '';
    final String? senderAvatar = message['sender']?['avatar']?['url']
        ?.toString();

    final bool isMe = message['sender']?['role'] == 'patient';

    final List<dynamic> attachments = message['fileUrl'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _getAvatarWidget(senderAvatar, isDoctor: true),
              if (!isMe) const SizedBox(width: 8),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF6C5CE7) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe
                        ? const Radius.circular(20)
                        : const Radius.circular(5),
                    bottomRight: isMe
                        ? const Radius.circular(5)
                        : const Radius.circular(20),
                  ),
                  boxShadow: [
                    if (!isMe)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (attachments.isNotEmpty)
                      ...attachments.map((att) {
                        final String? url = att['url']?.toString();
                        if (url != null &&
                            url.isNotEmpty &&
                            url != 'file:///' &&
                            (url.startsWith('http://') ||
                                url.startsWith('https://'))) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
              if (isMe) const SizedBox(width: 8),
              if (isMe) _getAvatarWidget(null, isDoctor: false),
            ],
          ),

          if (message['createdAt'] != null)
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 45,
                right: isMe ? 45 : 0,
                top: 5,
              ),
              child: Text(
                _formatTime(message['createdAt']),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider _getAvatarImage(String? avatarUrl) {
    if (avatarUrl == null ||
        avatarUrl.isEmpty ||
        avatarUrl == 'file:///' ||
        (!avatarUrl.startsWith('http://') &&
            !avatarUrl.startsWith('https://'))) {
      return const AssetImage('assets/images/doctor1.png');
    }
    return NetworkImage(avatarUrl);
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    SocketService.instance.off('message:new');
    super.dispose();
  }
}
