import 'package:docmobi/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/services/webrtc_service.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoCallScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String? userAvatar;
  final String otherUserId;
  final bool isInitiator;

  const VideoCallScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.userAvatar,
    required this.otherUserId,
    required this.isInitiator,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  WebRTCService? _webRTCService;
  bool _isMuted = false;
  bool _isVideoEnabled = true; // ✅ Track video state
  bool _isFrontCamera = true;
  bool _callConnected = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      final socket = SocketService.instance.socket;
      if (socket == null) {
        throw Exception('Socket not connected');
      }

      _webrtcService = WebRTCService(
        socket: socket,
        chatId: widget.chatId,
        isVideo: true,
        onRemoteStream: (stream) {
          if (mounted) {
            setState(() {
              _remoteRenderer.srcObject = stream;
              _callConnected = true;
            });
          }
        },
        onCallEnded: () {
          _endCall();
        },
      );

      await _webrtcService!.initialize();
      
      if (mounted) {
        setState(() {
          _localRenderer.srcObject = _webrtcService!.localStream;
        });
      }

      // Setup socket listeners
      socket.on('call:offer', (data) async {
        if (data['chatId'] == widget.chatId) {
          await _webrtcService!.handleOffer(data['offer']);
        }
      });

      socket.on('call:answer', (data) async {
        if (data['chatId'] == widget.chatId) {
          await _webrtcService!.handleAnswer(data['answer']);
          if (mounted) {
            setState(() {
              _callConnected = true;
            });
          }
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

  void _toggleMute() {
    if (_webrtcService != null) {
      setState(() {
        _isMuted = !_isMuted;
      });
      _webrtcService!.toggleAudio();
    }
  }

  void _toggleVideo() {
    if (_webrtcService != null) {
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
      _webrtcService!.toggleVideo();
      
      // Update local renderer visibility
      if (!_isVideoEnabled) {
        // Video is OFF - hide local video
        setState(() {});
      }
    }
  }

  // ✅ FIXED: Camera switch
  Future<void> _switchCamera() async {
    if (_webrtcService == null || !_isVideoEnabled) return;
    
    try {
      final videoTrack = _webrtcService!.localStream?.getVideoTracks().first;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
        setState(() {
          _isFrontCamera = !_isFrontCamera;
        });
      }
    } catch (e) {
      print('❌ Error switching camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to switch camera')),
      );
    }
  }

  void _endCall() {
    print('📴 Ending call...');
    
    _callTimer?.cancel();
    _callTimer = null;
    
    SocketService.instance.emit('call:end', {
      'chatId': widget.chatId,
      'toUserId': widget.otherUserId,
    });
    
    Navigator.pop(context);
  }

  void _showError(String message) {
    if (!mounted) return;
    
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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ Remote video (full screen)
          if (_callConnected)
            Positioned.fill(
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            )
          else
            // ✅ Connecting state
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: widget.userAvatar != null
                        ? NetworkImage(widget.userAvatar!)
                        : const AssetImage('assets/images/doctor.png') as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connecting...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),

          // ✅ Local video preview (small box)
          if (_isVideoEnabled) // Only show if video is enabled
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: _isFrontCamera,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

          // ✅ User name badge
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_callConnected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (_callConnected) const SizedBox(width: 8),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Controls at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: _toggleMute,
                  backgroundColor: _isMuted 
                      ? Colors.red 
                      : Colors.white.withOpacity(0.3),
                ),
                
                // End call button
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: _endCall,
                  backgroundColor: Colors.red,
                ),
                
                // Video toggle button
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoEnabled 
                      ? Colors.white.withOpacity(0.3) 
                      : Colors.red,
                ),
                
                // Camera switch button
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  onPressed: _isVideoEnabled ? _switchCamera : null,
                  backgroundColor: _isVideoEnabled
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🧹 Disposing VideoCallScreen');
    
    _callTimer?.cancel();
    _callTimer = null;
    
    _webRTCService?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    
    final socket = SocketService.instance.socket;
    socket?.off('call:offer');
    socket?.off('call:answer');
    socket?.off('call:iceCandidate');
    socket?.off('call:ended');
    socket?.off('call:rejected');
    socket?.off('call:accepted');
    
    print('✅ VideoCallScreen disposed');
    
    super.dispose();
  }
}

// ✅ Import for API service
