import 'package:flutter/material.dart';
import 'package:docmobi/l10n/app_localizations.dart';
import 'package:docmobi/services/agora_chat_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:docmobi/screens/common/calls/video_call_screen.dart';
import 'package:docmobi/screens/common/calls/audio_call_screen.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

// Modular Widgets
import 'package:docmobi/widgets/chat/chat_bubble.dart';
import 'package:docmobi/widgets/chat/call_log_bubble.dart';
import 'package:docmobi/widgets/chat/chat_date_separator.dart';
import 'package:docmobi/widgets/chat/chat_app_bar.dart';
import 'package:docmobi/widgets/chat/chat_input.dart';

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
  bool _isOtherUserTyping = false;
  Timer? _myTypingTimer;
  Timer? _otherUserTypingTimer; // To auto-hide if they don't stop properly

  bool _isAutoScrollEnabled = true;
  final Set<String> _selectedMessageIds = {}; // ✅ For multi-select delete
  bool _isSelectionMode = false; // ✅ Selection mode toggle

  @override
  void initState() {
    super.initState();
    _actualDoctorAvatar = widget.doctorAvatar;
    _actualDoctorName = widget.doctorName;
    _loadCurrentUserProfile().then((_) {
      _loadMessages();
      _setupAgoraListeners();
      _ensureAgoraConnection();
      _setupSocketListeners(); // ✅ Setup socket for real-time typing
      AgoraChatService.instance.markAllMessagesAsRead(
        widget.doctorId!,
      ); // ✅ Mark as read on entry using peer ID (doctorId)
    });

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        _isAutoScrollEnabled = (maxScroll - currentScroll) < 100;
      }
    });
  }

  // ✅ Real-time Socket Listeners
  void _setupSocketListeners() {
    if (_currentUserId != null) {
      SocketService.instance.ensureConnected();

      // Listen for typing
      SocketService.instance.on('chat:typing', (data) {
        if (data['chatId'] == widget.chatId && mounted) {
          setState(() => _isOtherUserTyping = true);

          // Auto-hide after 5 seconds if no stop signal
          _otherUserTypingTimer?.cancel();
          _otherUserTypingTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) setState(() => _isOtherUserTyping = false);
          });
        }
      });

      // Listen for stop typing
      SocketService.instance.on('chat:stopTyping', (data) {
        if (data['chatId'] == widget.chatId && mounted) {
          setState(() => _isOtherUserTyping = false);
          _otherUserTypingTimer?.cancel();
        }
      });
    }
  }

  void _onTextChanged(String value) {
    if (widget.doctorId == null) return;

    // Only emit if not already "typing" in the last 2 seconds
    if (_myTypingTimer == null || !_myTypingTimer!.isActive) {
      SocketService.instance.emit('chat:typing', {
        'toUserId': widget.doctorId,
        'chatId': widget.chatId,
      });
    }

    _myTypingTimer?.cancel();
    _myTypingTimer = Timer(const Duration(seconds: 3), () {
      SocketService.instance.emit('chat:stopTyping', {
        'toUserId': widget.doctorId,
        'chatId': widget.chatId,
      });
    });
  }

  Future<void> _ensureAgoraConnection() async {
    // 1. Initialize if needed
    if (!AgoraChatService.instance.isConnected) {
      await AgoraChatService.instance.init();
    }

    // 2. Check if logged in
    final isLoggedIn = await ChatClient.getInstance.isLoginBefore();
    debugPrint(
      '🔍 Agora Login Status: $isLoggedIn | CurrentUser: $_currentUserId',
    );

    if (!isLoggedIn && _currentUserId != null) {
      debugPrint('🔄 Not logged in. Attempting login for $_currentUserId...');
      await AgoraChatService.instance.login(_currentUserId!);
    } else if (isLoggedIn) {
      final currentAgoraUser = await ChatClient.getInstance.getCurrentUserId();
      if (currentAgoraUser != _currentUserId && _currentUserId != null) {
        debugPrint(
          '⚠️ Agora ID mismatch ($currentAgoraUser vs $_currentUserId). Relogging...',
        );
        await AgoraChatService.instance.logout();
        await AgoraChatService.instance.login(_currentUserId!);
      }
    }
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
        debugPrint('✅ Current user profile loaded');
        debugPrint('   ID: $_currentUserId');
        debugPrint('   Name: $_currentUserName');
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = _messages.isEmpty);

    if (widget.doctorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // ✅ Use local database for initial load (Much faster!)
      final messages = await AgoraChatService.instance.loadMessagesFromLocal(
        conversationId: widget.doctorId!,
      );

      if (mounted) {
        final List<dynamic> formattedMessages = messages
            .map((m) => _convertAgoraMessage(m))
            .toList();

        setState(() {
          _messages = formattedMessages;
          _isLoading = false;
        });

        // Try to identify other user ID if not set
        if (_otherUserId == null && messages.isNotEmpty) {
          for (var m in messages) {
            if (m.from != _currentUserId) {
              setState(() => _otherUserId = m.from);
              break;
            }
          }
        }

        if (_otherUserId == null && widget.doctorId != null) {
          setState(() => _otherUserId = widget.doctorId);
        }

        _scrollToBottom();
      }

      // 🔄 Sync from server in background silently
      AgoraChatService.instance
          .fetchHistoryMessages(conversationId: widget.doctorId!)
          .then((remoteMessages) {
            if (mounted && remoteMessages.isNotEmpty) {
              final List<dynamic> updatedMessages = remoteMessages
                  .map((m) => _convertAgoraMessage(m))
                  .toList();
              setState(() {
                _messages = updatedMessages;
              });
            }
          });
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Multi-select Delete Helper
  void _toggleSelection(String msgId) {
    setState(() {
      if (_selectedMessageIds.contains(msgId)) {
        _selectedMessageIds.remove(msgId);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(msgId);
        _isSelectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteMessages),
        content: Text(
          AppLocalizations.of(
            context,
          )!.deleteMessagesConfirm(_selectedMessageIds.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.deleteLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final idsToDelete = _selectedMessageIds.toList();
        await AgoraChatService.instance.deleteMessages(
          conversationId: widget.chatId,
          messageIds: idsToDelete,
        );

        if (mounted) {
          setState(() {
            _messages.removeWhere((m) => idsToDelete.contains(m['_id']));
            _cancelSelection();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.messagesDeleted),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to delete messages: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.failedToDelete(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _isAutoScrollEnabled) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setupAgoraListeners() {
    AgoraChatService.instance.addMessageListener(
      'patient_chat_${widget.chatId}',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          List<dynamic> incomingFormatted = [];

          for (var msg in messages) {
            debugPrint(
              '📩 [PatientChat] Received message SDK: ID=${msg.msgId}, From=${msg.from}, Conv=${msg.conversationId}',
            );

            if (msg.conversationId == widget.doctorId ||
                msg.from == widget.doctorId) {
              debugPrint('   ✅ Match found for this chat');

              // Prevent duplicates
              final bool alreadyExists = _messages.any(
                (m) => m['_id'] == msg.msgId,
              );
              if (!alreadyExists) {
                incomingFormatted.add(_convertAgoraMessage(msg));
              }
            }
          }

          if (incomingFormatted.isNotEmpty && mounted) {
            setState(() {
              _messages.addAll(incomingFormatted);
              // Sort by date just in case they arrived out of order
              _messages.sort(
                (a, b) => (DateTime.parse(
                  a['createdAt'],
                )).compareTo(DateTime.parse(b['createdAt'])),
              );
            });

            _scrollToBottom();

            AgoraChatService.instance.markAllMessagesAsRead(
              widget.doctorId!,
            ); // ✅ Clear unread badge live
          }
        },
      ),
    );
    debugPrint(
      '✅ Agora Chat listeners setup for ID: patient_chat_${widget.chatId}',
    );
  }

  Map<String, dynamic> _convertAgoraMessage(ChatMessage message) {
    String content = '';
    List<Map<String, dynamic>> attachmentUrls = [];

    if (message.body is ChatTextMessageBody) {
      content = (message.body as ChatTextMessageBody).content;
    } else if (message.body is ChatImageMessageBody) {
      final imgBody = message.body as ChatImageMessageBody;
      attachmentUrls.add({
        'url': imgBody.remotePath ?? imgBody.localPath,
        'type': 'image',
      });
    } else if (message.body is ChatFileMessageBody) {
      final fileBody = message.body as ChatFileMessageBody;
      attachmentUrls.add({
        'url': fileBody.remotePath ?? fileBody.localPath,
        'type': 'file',
      });
    }

    final bool isMe = message.from == _currentUserId;

    return {
      '_id': message.msgId,
      'content': content,
      'sender': {
        '_id': message.from,
        'role': isMe ? 'patient' : 'doctor',
        'fullName': isMe ? _currentUserName : _actualDoctorName,
        'avatar': {'url': isMe ? _currentUserAvatar : _actualDoctorAvatar},
      },
      'fileUrl': attachmentUrls,
      ...message.attributes ?? {},
      'sender_fullName': isMe
          ? (_currentUserName ?? AppLocalizations.of(context)!.meLabel)
          : (_actualDoctorName ?? widget.doctorName),
      'createdAt': DateTime.fromMillisecondsSinceEpoch(
        message.serverTime,
      ).toIso8601String(),
    };
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();

    debugPrint(
      '📤 Attempting to send message. Content length: ${content.length}, Files: ${_selectedFiles.length}',
    );

    if (content.isEmpty && _selectedFiles.isEmpty) {
      debugPrint('⚠️ Send aborted: Content is empty');
      return;
    }
    if (_isSending) {
      debugPrint('⚠️ Send aborted: Already sending');
      return;
    }

    setState(() => _isSending = true);

    try {
      if (widget.doctorId == null) {
        debugPrint('❌ Send aborted: widget.doctorId is NULL');
        throw Exception('Recipient ID missing');
      }

      debugPrint('✉️ [Patient] Sending to DoctorID: ${widget.doctorId}');
      debugPrint('   - Me (UID): $_currentUserId');

      final sentMessage = await AgoraChatService.instance.sendMessage(
        conversationId: widget.doctorId!,
        content: content,
        files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
      );

      debugPrint(
        '✅ Message returned from SDK: ${sentMessage?.msgId ?? "NULL"}',
      );

      if (sentMessage != null && mounted) {
        _controller.clear();
        setState(() {
          _selectedFiles = [];
          _isAutoScrollEnabled = true;
          // Optimistic update: Add message to list immediately
          _messages.add(_convertAgoraMessage(sentMessage));
        });

        // Scroll to bottom
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
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSendMessage),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedFiles.add(File(image.path)));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotStartCallNoId),
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
          debugPrint('❌ Socket reconnection failed: $e');
        }
      }

      if (SocketService.instance.socket == null ||
          !SocketService.instance.socket!.connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.failedToStartCall('Connection failed'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // ✅ Use API Service to initiate call (matches Doctor implementation)
    // This ensures backend sets up the call properly and sends caller info
    Map<String, dynamic> result;
    try {
      result = await ApiService.initiateCall(
        chatId: widget.chatId,
        receiverId: _otherUserId!,
        isVideo: isVideo,
      );

      if (result['success'] != true) {
        final message = result['message'] as String? ?? '';
        final errorCode = result['code'] as String?;

        if (mounted) {
          // Enhanced error handling for doctor unavailable
          if (errorCode == 'DOCTOR_UNAVAILABLE' ||
              message.toLowerCase().contains('not available')) {
            _showDoctorUnavailableDialog(isVideo);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.failedToStartCall(message),
                ),
              ),
            );
          }
        }
        return;
      }
    } catch (e) {
      debugPrint('❌ Call initiation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToStartCall(e.toString()),
            ),
          ),
        );
      }
      return;
    }

    // Call triggered successfully via API, navigation handles locally
    debugPrint('📞 Call initiated via API successfully');

    final String stableChatId =
        result['data']?['chatId']?.toString() ?? widget.chatId;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => isVideo
              ? VideoCallScreen(
                  chatId: stableChatId,
                  userName: widget.doctorName,
                  userAvatar: _actualDoctorAvatar ?? widget.doctorAvatar,
                  otherUserId: _otherUserId!,
                  isInitiator: true,
                )
              : AudioCallScreen(
                  chatId: stableChatId,
                  userName: widget.doctorName,
                  userAvatar: _actualDoctorAvatar ?? widget.doctorAvatar,
                  otherUserId: _otherUserId!,
                  isInitiator: true,
                ),
        ),
      );
    }
  }

  /// Show doctor unavailable dialog
  void _showDoctorUnavailableDialog(bool isVideo) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.phone_missed, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Doctor Unavailable',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C49),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.doctorUnavailableForCallsDescription(
                isVideo ? 'video' : 'audio',
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: const TextStyle(color: Color(0xFF1664CD))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Send Message',
              style: const TextStyle(color: Color(0xFF1664CD)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: ChatAppBar(
        userName: _actualDoctorName ?? widget.doctorName,
        userAvatar: _actualDoctorAvatar ?? widget.doctorAvatar,
        placeholderAsset: 'assets/images/doctor1.png',
        isSelectionMode: _isSelectionMode,
        selectedCount: _selectedMessageIds.length,
        onCancelSelection: _cancelSelection,
        onDeleteSelected: _deleteSelectedMessages,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
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
                          AppLocalizations.of(context)!.noMessagesYet,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.startConversationWith(widget.doctorName),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    separatorBuilder: (context, index) {
                      final currentMsgDate = _messages[index]['createdAt'];
                      final nextMsgDate = (index + 1 < _messages.length)
                          ? _messages[index + 1]['createdAt']
                          : null;

                      if (nextMsgDate != null &&
                          !_isSameDay(currentMsgDate, nextMsgDate)) {
                        return ChatDateSeparator(timestamp: nextMsgDate);
                      }
                      return const SizedBox.shrink();
                    },
                    itemBuilder: (context, index) {
                      // Show initial date separator for the first message
                      if (index == 0) {
                        return Column(
                          children: [
                            ChatDateSeparator(
                              timestamp: _messages[0]['createdAt'],
                            ),
                            _buildMessageItem(_messages[index]),
                          ],
                        );
                      }
                      return _buildMessageItem(_messages[index]);
                    },
                  ),
          ),

          if (_isOtherUserTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${widget.doctorName} is typing...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[400]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ChatInput(
            controller: _controller,
            selectedFiles: _selectedFiles,
            isSending: _isSending,
            onPickImage: _pickImage,
            onRemoveFile: _removeFile,
            onSendMessage: _sendMessage,
            onChanged: _onTextChanged,
          ),
        ],
      ),
    );
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

  bool _isSameDay(String? ts1, String? ts2) {
    if (ts1 == null || ts2 == null) return false;
    try {
      final d1 = DateTime.parse(ts1).toLocal();
      final d2 = DateTime.parse(ts2).toLocal();
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (e) {
      return false;
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    if (message['type'] == 'call_log') {
      final String msgId = message['_id']?.toString() ?? '';
      return CallLogBubble(
        message: message,
        isSelected: _selectedMessageIds.contains(msgId),
        onTap: _isSelectionMode ? () => _toggleSelection(msgId) : null,
        onLongPress: () => _toggleSelection(msgId),
      );
    }

    final String msgId = message['_id']?.toString() ?? '';
    final String senderId = message['sender']?['_id']?.toString() ?? '';
    final bool isMe = _currentUserId != null && senderId == _currentUserId;

    return ChatBubble(
      message: message,
      isMe: isMe,
      isSelected: _selectedMessageIds.contains(msgId),
      currentUserAvatar: _currentUserAvatar,
      otherUserAvatar: _actualDoctorAvatar,
      otherUserPlaceholder: 'assets/images/doctor1.png',
      onTap: _isSelectionMode ? () => _toggleSelection(msgId) : null,
      onLongPress: () => _toggleSelection(msgId),
      formatTime: _formatTime,
    );
  }

  @override
  void dispose() {
    _myTypingTimer?.cancel();
    _otherUserTypingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    SocketService.instance.off('chat:typing');
    SocketService.instance.off('chat:stopTyping');
    AgoraChatService.instance.removeMessageListener(
      'patient_chat_${widget.chatId}',
    );
    super.dispose();
  }
}
