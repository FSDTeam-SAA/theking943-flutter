import 'package:flutter/material.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/screens/common/calls/video_call_screen.dart';
import 'package:docmobi/screens/common/calls/audio_call_screen.dart';

class CallManager {
  static final CallManager _instance = CallManager._internal();
  static CallManager get instance => _instance;

  CallManager._internal();

  BuildContext? _context;
  bool _isListening = false;

  void initialize(BuildContext context) {
    _context = context;

    if (_isListening) {
      print('⚠️ CallManager already listening - reinitializing');
      _cleanup();
    }

    _setupCallListeners();
    _isListening = true;

    print('');
    print('╔═══════════════════════════════════════════╗');
    print('║     📞 CALL MANAGER INITIALIZED           ║');
    print('╚═══════════════════════════════════════════╝');
    print('✅ Context: ${_context != null ? "Available" : "NULL"}');
    print(
      '✅ Socket: ${SocketService.instance.isConnected ? "Connected" : "Disconnected"}',
    );
    print('✅ Listening for incoming calls');
    print('');
  }

  void _setupCallListeners() {
    final socket = SocketService.instance.socket;
    if (socket == null) {
      print('⚠️ Socket not available for CallManager');
      return;
    }

    socket.off('call:incoming');
    socket.off('call:accepted');
    socket.off('call:rejected');

    socket.on('call:incoming', (data) {
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║              📞 INCOMING CALL RECEIVED                    ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('   • Raw data: $data');
      print('   • Data type: ${data.runtimeType}');

      Map<String, dynamic> callData;
      if (data is Map<String, dynamic>) {
        callData = data;
      } else if (data is Map) {
        callData = Map<String, dynamic>.from(data);
      } else {
        print('❌ Invalid data format: ${data.runtimeType}');
        return;
      }

      print('   • From: ${callData['fromUserId']}');
      print('   • Chat: ${callData['chatId']}');
      print('   • Type: ${callData['isVideo'] ? "VIDEO 📹" : "AUDIO 📞"}');
      print('   • Context: ${_context != null ? "Available" : "NULL"}');
      print('   • Mounted: ${_context?.mounted}');
      print('');

      if (_context != null && _context!.mounted) {
        _handleIncomingCall(callData);
      } else {
        print('❌ Context not available or not mounted');
      }
    });

    socket.on('call:accepted', (data) {
      print('✅ Call accepted by other user');
    });

    socket.on('call:rejected', (data) {
      print('❌ Call rejected by other user');
      _showSnackbar('Call rejected');
    });

    print('👂 Listening: call:incoming, call:accepted, call:rejected');
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    if (_context == null || !_context!.mounted) {
      print('⚠️ Context not available');
      return;
    }

    final fromUserId =
        data['fromUserId']?.toString() ?? data['callerId']?.toString();
    final chatId = data['chatId']?.toString();
    final isVideo = data['isVideo'] == true;
    final callerName = data['callerName']?.toString() ?? 'Unknown User';
    final callerAvatar = data['callerAvatar']?.toString();

    print('📋 Extracted:');
    print('   • fromUserId: $fromUserId');
    print('   • chatId: $chatId');
    print('   • isVideo: $isVideo');
    print('   • callerName: $callerName');

    if (fromUserId == null ||
        fromUserId.isEmpty ||
        chatId == null ||
        chatId.isEmpty) {
      print('❌ Missing required fields');
      return;
    }

    print('📱 Showing incoming call dialog');

    try {
      showDialog(
        context: _context!,
        barrierDismissible: false,
        builder: (context) => IncomingCallDialog(
          fromUserId: fromUserId,
          chatId: chatId,
          isVideo: isVideo,
          callerName: callerName,
          callerAvatar: callerAvatar,
        ),
      );
      print('✅ Dialog shown successfully');
    } catch (e) {
      print('❌ Error showing dialog: $e');
    }
  }

  void _showSnackbar(String message) {
    if (_context == null || !_context!.mounted) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _cleanup() {
    final socket = SocketService.instance.socket;
    socket?.off('call:incoming');
    socket?.off('call:accepted');
    socket?.off('call:rejected');
    _isListening = false;
  }

  void dispose() {
    _cleanup();
    _context = null;
    print('🧹 CallManager disposed');
  }
}

class IncomingCallDialog extends StatefulWidget {
  final String fromUserId;
  final String chatId;
  final bool isVideo;
  final String callerName;
  final String? callerAvatar;

  const IncomingCallDialog({
    super.key,
    required this.fromUserId,
    required this.chatId,
    required this.isVideo,
    required this.callerName,
    this.callerAvatar,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    print('🎬 IncomingCallDialog initialized');
    print('   • From: ${widget.fromUserId}');
    print('   • Chat: ${widget.chatId}');
    print('   • Type: ${widget.isVideo ? "VIDEO" : "AUDIO"}');

    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && !_isProcessing) {
        print('⏱️ Call timeout - Auto rejecting');
        _rejectCall();
      }
    });

    _setupCallEndListener();
  }

  void _setupCallEndListener() {
    final socket = SocketService.instance.socket;
    if (socket != null) {
      socket.on('call:end', (data) {
        final endChatId = data is Map ? data['chatId']?.toString() : null;
        if (endChatId == widget.chatId && mounted && !_isProcessing) {
          print('📞 Call ended by caller');
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isProcessing) {
          _rejectCall();
        }
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1664CD), Color(0xFF0D4DA1)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isVideo ? Icons.videocam : Icons.phone,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage:
                    widget.callerAvatar != null &&
                        widget.callerAvatar!.isNotEmpty &&
                        widget.callerAvatar != 'file:///' &&
                        (widget.callerAvatar!.startsWith('http://') ||
                            widget.callerAvatar!.startsWith('https://'))
                    ? NetworkImage(widget.callerAvatar!)
                    : null,
                child:
                    widget.callerAvatar == null ||
                        widget.callerAvatar!.isEmpty ||
                        widget.callerAvatar == 'file:///' ||
                        (!widget.callerAvatar!.startsWith('http://') &&
                            !widget.callerAvatar!.startsWith('https://'))
                    ? Text(
                        widget.callerName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 16),

              Text(
                widget.callerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              Text(
                'Incoming ${widget.isVideo ? "Video" : "Audio"} Call',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: Colors.red,
                    onPressed: _isProcessing ? null : _rejectCall,
                  ),

                  _buildActionButton(
                    icon: widget.isVideo ? Icons.videocam : Icons.phone,
                    label: _isProcessing ? 'Connecting...' : 'Accept',
                    color: Colors.green,
                    onPressed: _isProcessing ? null : _acceptCall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDisabled ? color.withOpacity(0.5) : color,
          shape: const CircleBorder(),
          elevation: isDisabled ? 0 : 4,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isProcessing && label == 'Connecting...'
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.white.withOpacity(0.5) : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _acceptCall() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    print('');
    print('✅ ACCEPTING CALL');
    print('   • From: ${widget.fromUserId}');
    print('   • Chat: ${widget.chatId}');

    try {
      await SocketService.instance.emit('call:accept', {
        'chatId': widget.chatId,
        'fromUserId': widget
            .fromUserId, // ✅ FIXED: Backend expects 'fromUserId' as target
        'isVideo': widget.isVideo,
      });

      print('   ✅ Accept event sent');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.of(context).pop();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isVideo
              ? VideoCallScreen(
                  chatId: widget.chatId,
                  userName: widget.callerName,
                  userAvatar: widget.callerAvatar,
                  otherUserId: widget.fromUserId,
                  isInitiator: false,
                )
              : AudioCallScreen(
                  chatId: widget.chatId,
                  userName: widget.callerName,
                  userAvatar: widget.callerAvatar,
                  otherUserId: widget.fromUserId,
                  isInitiator: false,
                ),
        ),
      );
    } catch (e) {
      print('❌ Error accepting call: $e');

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectCall() {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    print('❌ REJECTING CALL');

    try {
      SocketService.instance.emit('call:reject', {
        'chatId': widget.chatId,
        'toUserId': widget.fromUserId,
      });

      SocketService.instance.emit('call:end', {
        'chatId': widget.chatId,
        'toUserId': widget.fromUserId,
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error rejecting call: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    SocketService.instance.socket?.off('call:end');
    super.dispose();
  }
}
