import 'package:flutter/material.dart';
import 'package:docmobi/services/webrtc_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AudioCallScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String? userAvatar;
  final String otherUserId;
  final bool isInitiator;

  const AudioCallScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.userAvatar,
    required this.otherUserId,
    required this.isInitiator,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  WebRTCService? _webrtcService;
  bool _isMuted = false;
  bool _callConnected = false;
  String _callDuration = '00:00';
  String _callStatus = 'Calling...';
  Timer? _timer;
  Timer? _timeoutTimer;
  int _seconds = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      final socket = SocketService.instance.socket;
      if (socket == null || !socket.connected) {
        throw Exception('Socket not connected');
      }

      setState(() {
        _callStatus = 'Setting up...';
      });

      // ✅ Create WebRTC service (audio only)
      _webrtcService = WebRTCService(
        chatId: widget.chatId,
        isVideo: false,
        onRemoteStream: (stream) {
          setState(() {
            _callConnected = true;
          });
          _startTimer();
        },
        onCallEnded: () {
          _endCall();
        },
      );

      await _webrtcService!.initialize();

      // Setup socket listeners
      socket.on('call:offer', (data) async {
        if (data['chatId'] == widget.chatId) {
          await _webrtcService!.handleOffer(data['offer']);
        }
      });

      socket.on('call:answer', (data) async {
        if (data['chatId'] == widget.chatId) {
          await _webrtcService!.handleAnswer(data['answer']);
          setState(() {
            _callConnected = true;
          });
          _startTimer();
        }
      });

      socket.on('call:iceCandidate', (data) async {
        if (data['chatId'] == widget.chatId) {
          await _webrtcService!.addIceCandidate(data['candidate']);
        }
      });

      socket.on('call:end', (data) {
        if (data['chatId'] == widget.chatId) {
          _endCall();
        }
      });

      // If initiator, create offer
      if (widget.isInitiator) {
        await _webrtcService!.createOffer(widget.otherUserId);
      }
    } catch (e) {
      print('❌ Error initializing call: $e');
      _showError('Failed to start call: $e');
    }
  }

  void _startTimer() {
    if (_isTimerRunning()) {
      print('⏱️ Timer already running');
      return;
    }
    
    print('⏱️ Starting call timer');
    _timer?.cancel();
    _seconds = 0; // Reset to 0
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
        final secs = (_seconds % 60).toString().padLeft(2, '0');
        _callDuration = '$minutes:$secs';
      });
    });
    
    print('✅ Call timer started');
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _webrtcService?.toggleAudio();
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
      // TODO: Implement speaker toggle
    });
  }

  void _endCall() {
    SocketService.instance.emit('call:end', {
      'chatId': widget.chatId,
      'toUserId': widget.otherUserId,
    });
    
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _timer?.cancel();
    _webrtcService?.dispose();
    
    // Remove socket listeners
    SocketService.instance.off('call:offer');
    SocketService.instance.off('call:answer');
    SocketService.instance.off('call:iceCandidate');
    SocketService.instance.off('call:end');
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // User Avatar
              CircleAvatar(
                radius: 80,
                backgroundImage: widget.userAvatar != null
                    ? NetworkImage(widget.userAvatar!)
                    : const AssetImage('assets/images/doctor.png') as ImageProvider,
              ),
              
              const SizedBox(height: 30),
              
              // User Name
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Call Status
              Text(
                _callConnected ? _callDuration : 'Calling...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
              
              const Spacer(),
              
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      onPressed: _toggleMute,
                      backgroundColor: _isMuted ? Colors.red : Colors.white.withOpacity(0.3),
                    ),
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      label: 'Speaker',
                      onPressed: _toggleSpeaker,
                      backgroundColor: _isSpeakerOn ? Colors.blue : Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // End Call Button
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}