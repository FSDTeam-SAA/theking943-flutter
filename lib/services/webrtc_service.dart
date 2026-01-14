import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:docmobi/services/socket_service.dart';

class WebRTCService {
<<<<<<< HEAD
  final IO.Socket socket;
  final String chatId;
  final bool isVideo;
  final Function(MediaStream) onRemoteStream;
  final Function() onCallEnded;
  
  String? _remoteUserId;
  String? _currentUserId; // ✅ Store current user ID

  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  
  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _isOfferAnswerSet = false;
  bool _isDisposed = false;
=======
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final String chatId;
  final bool isVideo;

  Function(MediaStream)? onRemoteStream;
  Function()? onCallEnded;
  Function(String)? onError;

  bool _isDisposed = false;
  bool _hasSetRemoteDescription = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

  String? _otherUserId;
>>>>>>> 410893a (calling)

  WebRTCService({
    required this.chatId,
    required this.isVideo,
<<<<<<< HEAD
    required this.onRemoteStream,
    required this.onCallEnded,
  });

  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception('Service already disposed');
    }
    
    try {
      print('🎥 Initializing WebRTC...');
      
      // Get user media
      final Map<String, dynamic> mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': isVideo
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
                'frameRate': {'ideal': 30},
              }
            : false,
      };

      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      print('✅ Got local stream: ${localStream!.id}');

      // Create peer connection
      await _createPeerConnection();
      
      print('✅ WebRTC initialized successfully');
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      throw Exception('Failed to initialize WebRTC: $e');
    }
  }

  Future<void> _createPeerConnection() async {
    if (_isDisposed) return;
    
    try {
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {
            'urls': [
              'stun:stun.l.google.com:19302',
              'stun:stun1.l.google.com:19302',
              'stun:stun2.l.google.com:19302',
              'stun:stun3.l.google.com:19302',
              'stun:stun4.l.google.com:19302',
            ]
=======
    this.onRemoteStream,
    this.onCallEnded,
    this.onError,
  });

  // ================= GETTERS =================
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  void setOtherUserId(String userId) {
    _otherUserId = userId;
  }

  // ================= INITIALIZE =================
  Future<void> initialize() async {
    try {
      print('');
      print('╔═══════════════════════════════════════════╗');
      print('║     🎬 INITIALIZING WEBRTC SERVICE        ║');
      print('╚═══════════════════════════════════════════╝');
      print('   • Chat ID: $chatId');
      print('   • Type: ${isVideo ? "VIDEO 📹" : "AUDIO 📞"}');
      print('');

      // ✅ Multiple STUN/TURN servers for better connectivity
      final Map<String, dynamic> configuration = {
        'iceServers': [
          // ✅ Google STUN servers (multiple for redundancy)
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
          
          // ✅ Free TURN servers with credentials
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
          {
            'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
            'username': 'openrelayproject',
            'credential': 'openrelayproject',
          },
          
          // ✅ Backup TURN server
          {
            'urls': 'turn:numb.viagenie.ca',
            'username': 'webrtc@live.com',
            'credential': 'muazkh',
>>>>>>> 410893a (calling)
          },
        ],
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 10,
<<<<<<< HEAD
      };

      _peerConnection = await createPeerConnection(configuration);
      print('✅ Peer connection created');

      // Add local stream tracks
      if (localStream != null) {
        localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, localStream!);
          print('✅ Added track to peer connection: ${track.kind}');
        });
      }

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
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          print('❌ Connection failed!');
          onCallEnded();
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
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
      _isOfferAnswerSet = true;
      print('✅ Local description set (offer)');
      print('📋 Offer SDP type: ${offer.type}');

      socket.emit('call:offer', {
=======
        
        // ✅ Better connectivity settings
        'iceTransportPolicy': 'all', // Use all available methods
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
      };

      print('   • ICE Servers: ${configuration['iceServers'].length} configured');

      _peerConnection = await createPeerConnection(configuration);
      _setupPeerConnectionCallbacks();

      // ✅ Optimized media constraints
      final mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'googEchoCancellation': true,
          'googNoiseSuppression': true,
          'googAutoGainControl': true,
        },
        'video': isVideo
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280, 'max': 1920},
                'height': {'ideal': 720, 'max': 1080},
                'frameRate': {'ideal': 30, 'max': 30},
              }
            : false,
      };

      print('   • Requesting media access...');
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      print('   • Media stream obtained ✅');

      for (var track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      print('   • ${_localStream!.getTracks().length} tracks added to peer connection');
      print('');
      print('✅ WebRTC initialized successfully');
      print('╚═══════════════════════════════════════════╝');
      print('');
    } catch (e) {
      print('❌ WebRTC init failed: $e');
      onError?.call('Failed to initialize: $e');
      rethrow;
    }
  }

  // ================= CALLBACKS =================
  void _setupPeerConnectionCallbacks() {
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        onRemoteStream?.call(_remoteStream!);
        print('✅ Remote stream received (${event.streams.first.getTracks().length} tracks)');
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (_otherUserId == null || candidate.candidate == null) return;

      print('📤 Sending ICE candidate to $_otherUserId');
      SocketService.instance.emit('call:iceCandidate', {
        'toUserId': _otherUserId,
>>>>>>> 410893a (calling)
        'chatId': chatId,
        'toUserId': toUserId,
        'fromUserId': _currentUserId, // ✅ Include sender
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
      });
<<<<<<< HEAD
      print('📤 Offer sent to $toUserId');

      // Add pending candidates after a small delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _processPendingCandidates();
      });
    } catch (e) {
      print('❌ Error creating offer: $e');
      throw Exception('Failed to create offer: $e');
    }
  }

  // ✅ Set current user ID (call this before creating offer)
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    print('✅ Current user ID set: $_currentUserId');
  }

  // ✅ Handle offer (receiver side)
  Future<void> handleOffer(Map<String, dynamic> offerData, String fromUserId) async {
    if (_isDisposed) return;
    
    _remoteUserId = fromUserId;
    
    try {
      print('📥 Handling incoming offer from: $fromUserId');
      print('📋 Offer type: ${offerData['type']}');
      
      final offer = RTCSessionDescription(
        offerData['sdp'],
        offerData['type'],
      );
      
      await _peerConnection!.setRemoteDescription(offer);
      _isOfferAnswerSet = true;
      print('✅ Remote description set (offer)');

      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideo,
      });
      
      await _peerConnection!.setLocalDescription(answer);
      print('✅ Local description set (answer)');
      print('📋 Answer SDP type: ${answer.type}');

      socket.emit('call:answer', {
        'chatId': chatId,
        'toUserId': fromUserId,
        'fromUserId': _currentUserId, // ✅ Include sender
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
      });
      print('📤 Answer sent to $fromUserId');

      // Add pending candidates after a small delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _processPendingCandidates();
      });
    } catch (e) {
      print('❌ Error handling offer: $e');
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
      _isOfferAnswerSet = true;
      print('✅ Remote description set (answer)');

      // Add pending candidates after a small delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _processPendingCandidates();
      });
    } catch (e) {
      print('❌ Error handling answer: $e');
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

      if (_isOfferAnswerSet && _peerConnection != null) {
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
=======
    };

    // ✅ ICE connection state monitoring
    _peerConnection!.onIceConnectionState = (state) {
      print('🔌 ICE Connection State: $state');
      
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        print('❌ ICE connection failed - attempting restart');
        _restartIce();
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        print('⚠️ ICE disconnected');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        print('✅ ICE connected successfully');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        print('✅ ICE connection completed');
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('🔌 Peer Connection State: $state');
      
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print('❌ Peer connection failed');
        onError?.call('Connection failed');
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        print('🔚 Peer connection closed');
        onCallEnded?.call();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('✅ Peer connection established');
      }
    };

    // ✅ ICE gathering state
    _peerConnection!.onIceGatheringState = (state) {
      print('🧊 ICE Gathering State: $state');
    };
  }

  // ✅ ICE restart mechanism for failed connections
  Future<void> _restartIce() async {
    try {
      print('🔄 Attempting ICE restart...');
      final offer = await _peerConnection!.createOffer({
        'iceRestart': true,
      });
      await _peerConnection!.setLocalDescription(offer);
      
      if (_otherUserId != null) {
        await SocketService.instance.emit('call:offer', {
          'toUserId': _otherUserId,
          'chatId': chatId,
          'offer': {'type': offer.type, 'sdp': offer.sdp},
          'isVideo': isVideo,
        });
        print('✅ ICE restart offer sent');
      }
    } catch (e) {
      print('❌ ICE restart failed: $e');
    }
  }

  // ================= OFFER / ANSWER =================
  Future<void> createOffer(String toUserId) async {
    _otherUserId = toUserId;

    try {
      print('📤 Creating offer for: $toUserId');
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _hasSetRemoteDescription = false;

      await SocketService.instance.emit('call:offer', {
        'toUserId': toUserId,
        'chatId': chatId,
        'offer': {'type': offer.type, 'sdp': offer.sdp},
        'isVideo': isVideo,
      });

      print('✅ Offer created and sent');
    } catch (e) {
      print('❌ Error creating offer: $e');
      onError?.call('Failed to create offer');
      rethrow;
    }
  }

  Future<void> handleOffer(Map<String, dynamic> offer) async {
    try {
      print('📥 Handling incoming offer');
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      _hasSetRemoteDescription = true;
      await _processPendingCandidates();

      print('📤 Creating answer');
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      if (_otherUserId != null) {
        await SocketService.instance.emit('call:answer', {
          'toUserId': _otherUserId,
          'chatId': chatId,
          'answer': {'type': answer.type, 'sdp': answer.sdp},
        });
      }

      print('✅ Offer handled, answer sent');
    } catch (e) {
      print('❌ Error handling offer: $e');
      onError?.call('Failed to process offer');
      rethrow;
    }
  }

  Future<void> handleAnswer(Map<String, dynamic> answer) async {
    try {
      print('📥 Handling answer');
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );

      _hasSetRemoteDescription = true;
      await _processPendingCandidates();
      
      print('✅ Answer handled successfully');
    } catch (e) {
      print('❌ Error handling answer: $e');
      onError?.call('Failed to process answer');
      rethrow;
    }
  }

  // ================= ICE =================
  Future<void> addIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );

      if (!_hasSetRemoteDescription) {
        _pendingCandidates.add(candidate);
        print('📥 ICE candidate queued (remote description not set yet)');
        return;
      }

      await _peerConnection!.addCandidate(candidate);
      print('✅ ICE candidate added');
    } catch (e) {
      print('⚠️ Error adding ICE candidate: $e');
    }
  }

  Future<void> _processPendingCandidates() async {
    if (_pendingCandidates.isEmpty) return;
    
    print('📥 Processing ${_pendingCandidates.length} pending ICE candidates');
    for (var c in _pendingCandidates) {
      try {
        await _peerConnection!.addCandidate(c);
      } catch (e) {
        print('⚠️ Error processing pending candidate: $e');
      }
    }
    _pendingCandidates.clear();
    print('✅ All pending candidates processed');
  }

  // ================= CONTROLS =================
  void toggleAudio() {
    final tracks = _localStream?.getAudioTracks();
    if (tracks != null && tracks.isNotEmpty) {
      tracks.first.enabled = !tracks.first.enabled;
      print('🎤 Audio ${tracks.first.enabled ? "enabled" : "muted"}');
>>>>>>> 410893a (calling)
    }
  }

  void toggleVideo() {
<<<<<<< HEAD
    if (_isDisposed) return;
    
    try {
      final videoTrack = localStream?.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        videoTrack.enabled = !videoTrack.enabled;
        print('📹 Video ${videoTrack.enabled ? "enabled" : "disabled"}');
      }
    } catch (e) {
      print('❌ Error toggling video: $e');
    }
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
=======
    if (!isVideo) return;
    final tracks = _localStream?.getVideoTracks();
    if (tracks != null && tracks.isNotEmpty) {
      tracks.first.enabled = !tracks.first.enabled;
      print('📹 Video ${tracks.first.enabled ? "enabled" : "disabled"}');
    }
  }

  void switchCamera() {
    final tracks = _localStream?.getVideoTracks();
    if (tracks != null && tracks.isNotEmpty) {
      Helper.switchCamera(tracks.first);
      print('🔄 Camera switched');
    }
  }

  // ================= DISPOSE =================
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    print('');
    print('🧹 Disposing WebRTC resources');

    for (var t in _localStream?.getTracks() ?? []) {
      t.stop();
    }
    for (var t in _remoteStream?.getTracks() ?? []) {
      t.stop();
    }

    await _peerConnection?.close();
    await _peerConnection?.dispose();

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _pendingCandidates.clear();
    
    print('✅ WebRTC disposed successfully');
    print('');
>>>>>>> 410893a (calling)
  }
}