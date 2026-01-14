import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRTCService {
  final String chatId;
  final bool isVideo;
  final Function(MediaStream) onRemoteStream;
  final Function() onCallEnded;

  String? _remoteUserId;
  String? _currentUserId;

  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _isRemoteDescriptionSet = false;
  bool _isDisposed = false;

  WebRTCService({
    required this.chatId,
    required this.isVideo,
    required this.onRemoteStream,
    required this.onCallEnded,
  });

  // ✅ Static method to check and request permissions
  static Future<bool> checkPermissions(bool isVideo) async {
    try {
      // Check current statuses
      var micStatus = await Permission.microphone.status;
      var cameraStatus = isVideo
          ? await Permission.camera.status
          : PermissionStatus.granted;

      // If already denied permanently, we should tell them to go to settings
      if (micStatus.isPermanentlyDenied ||
          (isVideo && cameraStatus.isPermanentlyDenied)) {
        print('⚠️ Permissions permanently denied. Opening settings...');
        await openAppSettings();
        return false;
      }

      // Otherwise, request it (this shows the system popup if not already granted)
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        if (isVideo) Permission.camera,
      ].request();

      bool micGranted =
          statuses[Permission.microphone] == PermissionStatus.granted;
      bool cameraGranted =
          !isVideo || statuses[Permission.camera] == PermissionStatus.granted;

      print('🎙️ Mic permission: $micGranted');
      if (isVideo) print('📷 Camera permission: $cameraGranted');

      return micGranted && cameraGranted;
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception('Service already disposed');
    }

    try {
      print('🎥 Initializing WebRTC...');

      // Check for available devices
      final devices = await navigator.mediaDevices.enumerateDevices();
      bool hasCamera = devices.any((device) => device.kind == 'videoinput');
      print('🔦 Hardware check - Has Camera: $hasCamera');
      print('   • isVideo: $isVideo');
      print('   • chatId: $chatId');

      Map<String, dynamic> mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': (isVideo && hasCamera)
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
                'frameRate': {'ideal': 30},
              }
            : false,
      };

      try {
        localStream = await navigator.mediaDevices.getUserMedia(
          mediaConstraints,
        );
      } catch (e) {
        print('⚠️ Failed to get media with initial constraints: $e');
        if (isVideo && hasCamera) {
          print('🔄 Retrying with audio-only fallback...');
          mediaConstraints['video'] = false;
          localStream = await navigator.mediaDevices.getUserMedia(
            mediaConstraints,
          );
        } else {
          rethrow;
        }
      }

      print('✅ Got local stream: ${localStream!.id}');

      await _createPeerConnection();

      print('✅ WebRTC initialized successfully');
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      rethrow;
    }
  }

  Future<void> _createPeerConnection() async {
    if (_isDisposed) return;

    final Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
            'stun:stun3.l.google.com:19302',
            'stun:stun4.l.google.com:19302',
          ],
        },
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        {
          'urls': 'turn:openrelay.metered.ca:443',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
      ],
      'sdpSemantics': 'unified-plan',
      'iceCandidatePoolSize': 10,
    };

    _peerConnection = await createPeerConnection(configuration);
    print('✅ Peer connection created');

    // Add local tracks
    localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, localStream!);
      print('📤 Added track to peer connection: ${track.kind}');
    });

      // ✅ Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (_isDisposed) return;

        print('🎬 Received remote track: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams[0];
          print('✅ Remote stream received: ${remoteStream!.id}');

          // ✅ Call the callback immediately
          try {
            onRemoteStream(remoteStream!);
            print('✅ onRemoteStream callback executed');
          } catch (e) {
            print('❌ Error in onRemoteStream callback: $e');
          }
        }
      };

      // ✅ Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (_isDisposed) return;

        print('🧊 ICE candidate generated');
        print('📤 Sending ICE to: $_remoteUserId');

        socket.emit('call:iceCandidate', {
          'chatId': chatId,
          'toUserId': _remoteUserId,
          'fromUserId': _currentUserId, // ✅ Include sender ID
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
        print('✅ ICE candidate sent');
      };

      // Handle connection state changes
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        if (_isDisposed) return;

        print('🔗 Connection state: $state');

        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          print('✅ Peer connection established!');
        } else if (state ==
            RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          print('❌ Connection failed!');
          onCallEnded();
        } else if (state ==
            RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          print('📴 Connection closed');
          if (!_isDisposed) {
            onCallEnded();
          }
        }
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        print('🧊 ICE connection state: $state');

        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          print('✅ ICE connection established!');
        } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          print('❌ ICE connection failed!');
        }
      };

      _peerConnection!.onSignalingState = (RTCSignalingState state) {
        print('📡 Signaling state: $state');
      };

      print('✅ Peer connection setup complete');
    } catch (e) {
      print('❌ Error creating peer connection: $e');
      throw Exception('Failed to create peer connection: $e');
    }
  }

  // ✅ Create offer (caller side)
  Future<void> createOffer(String toUserId) async {
    if (_isDisposed) return;

    _remoteUserId = toUserId;

    // ✅ Get current user ID from socket service
    try {
      // Extract from socket connection or pass it explicitly
      print('📤 Creating offer for user: $toUserId');

      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideo,
      });

      await _peerConnection!.setLocalDescription(offer);
      
      print('✅ Offer created and local description set');
      print('   • Type: ${offer.type}');
      print('   • SDP length: ${offer.sdp?.length}');

      final emitResult = await SocketService.instance.emit('call:offer', {
        'chatId': chatId,
        'toUserId': toUserId,
        'fromUserId': _currentUserId, // ✅ Include sender
        'offer': {'type': offer.type, 'sdp': offer.sdp},
      });
      
      print('📤 Offer emit result: $emitResult');
    } catch (e) {
      print('❌ Error creating offer: $e');
      rethrow;
    }
  }

  // ✅ Set current user ID (call this before creating offer)
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    print('✅ Current user ID set: $_currentUserId');
  }

  // ✅ Handle offer (receiver side)
  Future<void> handleOffer(
    Map<String, dynamic> offerData,
    String fromUserId,
  ) async {
    if (_isDisposed) return;

  Future<void> handleOffer(Map<String, dynamic> offerData, String fromUserId) async {
    if (_isDisposed || _peerConnection == null) {
      print('❌ Cannot handle offer - disposed or no peer connection');
      return;
    }
    
    _remoteUserId = fromUserId;

    try {
      print('📥 Handling incoming offer from: $fromUserId');
      print('📋 Offer type: ${offerData['type']}');

      final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);

      await _peerConnection!.setRemoteDescription(offer);
      _isRemoteDescriptionSet = true;
      print('✅ Remote description set (offer)');

      await _processPendingCandidates();

      RTCSessionDescription answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideo,
      });

      await _peerConnection!.setLocalDescription(answer);
      print('✅ Answer created and local description set');

      final emitResult = await SocketService.instance.emit('call:answer', {
        'chatId': chatId,
        'toUserId': fromUserId,
        'fromUserId': _currentUserId, // ✅ Include sender
        'answer': {'type': answer.type, 'sdp': answer.sdp},
      });
      
      print('📤 Answer emit result: $emitResult');
    } catch (e) {
      print('❌ Error handling offer: $e');
      rethrow;
    }
  }

  Future<void> handleAnswer(Map<String, dynamic> answerData) async {
    if (_isDisposed) return;

    try {
      print('📥 Handling incoming answer');
      print('📋 Answer type: ${answerData['type']}');

      final answer = RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      );

      await _peerConnection!.setRemoteDescription(answer);
      _isRemoteDescriptionSet = true;
      print('✅ Remote description set (answer)');

      await _processPendingCandidates();
    } catch (e) {
      print('❌ Error handling answer: $e');
      rethrow;
    }
  }

  Future<void> addIceCandidate(Map<String, dynamic> candidateData) async {
    if (_isDisposed) return;

    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );

      if (_isRemoteDescriptionSet && _peerConnection != null) {
        await _peerConnection!.addCandidate(candidate);
        print('✅ ICE candidate added immediately');
      } else {
        _pendingCandidates.add(candidate);
        print('⏳ ICE candidate queued (${_pendingCandidates.length} pending)');
      }
    } catch (e) {
      print('❌ Error adding ICE candidate: $e');
    }
  }

  Future<void> _processPendingCandidates() async {
    if (_isDisposed || _pendingCandidates.isEmpty) return;

    print('🔄 Processing ${_pendingCandidates.length} pending ICE candidates');

    for (final candidate in _pendingCandidates) {
      try {
        await _peerConnection!.addCandidate(candidate);
        print('✅ Pending candidate added');
      } catch (e) {
        print('❌ Error adding pending candidate: $e');
      }
    }

    _pendingCandidates.clear();
    print('✅ All pending candidates processed');
  }

  void toggleAudio() {
    if (_isDisposed) return;

    try {
      final audioTrack = localStream?.getAudioTracks().firstOrNull;
      if (audioTrack != null) {
        audioTrack.enabled = !audioTrack.enabled;
        print('🎤 Audio ${audioTrack.enabled ? "enabled" : "disabled"}');
      }
    } catch (e) {
      print('❌ Error toggling audio: $e');
    }
  }

  void toggleVideo() {
    if (_isDisposed) return;

    try {
      final videoTrack = localStream?.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        videoTrack.enabled = !videoTrack.enabled;
        print('📹 Video ${videoTrack.enabled ? "enabled" : "disabled"}');

        // Notify remote peer
        socket.emit('call:media_update', {
          'chatId': chatId,
          'toUserId': _remoteUserId,
          'videoEnabled': videoTrack.enabled,
        });
      }
    } catch (e) {
      print('❌ Error toggling video: $e');
    }
  }

  // ✅ Force enable video (for audio -> video switch)
  Future<void> enableVideo() async {
    if (_isDisposed) return;

    try {
      var videoTrack = localStream?.getVideoTracks().firstOrNull;

      if (videoTrack == null) {
        print('📹 No video track found, adding one...');
        final devices = await navigator.mediaDevices.enumerateDevices();
        bool hasCamera = devices.any((device) => device.kind == 'videoinput');

        if (!hasCamera) throw Exception('No camera found');

        final videoStream = await navigator.mediaDevices.getUserMedia({
          'video': {'facingMode': 'user'},
        });

        videoTrack = videoStream.getVideoTracks().first;
        await localStream?.addTrack(videoTrack);

        // Add to peer connection
        if (_peerConnection != null) {
          await _peerConnection!.addTrack(videoTrack, localStream!);
          // Trigger renegotiation
          await createOffer(_remoteUserId!);
        }
      } else {
        videoTrack.enabled = true;
      }

      socket.emit('call:media_update', {
        'chatId': chatId,
        'toUserId': _remoteUserId,
        'videoEnabled': true,
      });

      print('📹 Video enabled and signaled');
    } catch (e) {
      print('❌ Error enabling video: $e');
    }
  }

  // ✅ Send a request to switch media type (e.g., Audio -> Video)
  void requestSwitchToVideo() {
    if (_isDisposed) return;
    print('📤 Sending switch to video request...');
    socket.emit('call:switch_request', {
      'chatId': chatId,
      'toUserId': _remoteUserId,
      'fromUserId': _currentUserId,
      'type': 'video', // we can expand this later if needed
    });
  }

  // ✅ Respond to a switch request
  void respondToSwitchRequest(bool accepted) {
    if (_isDisposed) return;
    print('📤 Sending switch response: ${accepted ? "Accepted" : "Declined"}');
    socket.emit('call:switch_response', {
      'chatId': chatId,
      'toUserId': _remoteUserId,
      'fromUserId': _currentUserId,
      'accepted': accepted,
    });
  }

  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      print('🧹 Disposing WebRTC service');

      // Stop all tracks
      localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // Dispose streams
      await localStream?.dispose();
      await remoteStream?.dispose();

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection?.dispose();

      _peerConnection = null;
      localStream = null;
      remoteStream = null;
      _remoteUserId = null;
      _currentUserId = null;
      _pendingCandidates.clear();

      print('✅ WebRTC service disposed');
    } catch (e) {
      print('❌ Error disposing WebRTC: $e');
    }
  }
}

