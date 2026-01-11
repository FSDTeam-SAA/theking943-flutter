import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final IO.Socket socket;
  final String chatId;
  final bool isVideo;
  
  Function(MediaStream)? onRemoteStream;
  Function()? onCallEnded;
  
  WebRTCService({
    required this.socket,
    required this.chatId,
    required this.isVideo,
    this.onRemoteStream,
    this.onCallEnded,
  });
  
  Future<void> initialize() async {
    // Get user media (camera/microphone)
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {'facingMode': 'user'}
          : false,
    };
    
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    
    // Create peer connection
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    
    _peerConnection = await createPeerConnection(configuration);
    
    // Add local stream tracks
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
    
    // Listen for remote stream
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        onRemoteStream?.call(_remoteStream!);
      }
    };
    
    // Listen for ICE candidates
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      socket.emit('call:iceCandidate', {
        'chatId': chatId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };
    
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        onCallEnded?.call();
      }
    };
  }
  
  Future<void> createOffer(String toUserId) async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    socket.emit('call:offer', {
      'chatId': chatId,
      'toUserId': toUserId,
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
    });
  }
  
  Future<void> handleOffer(Map<String, dynamic> offer) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );
    
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    
    socket.emit('call:answer', {
      'chatId': chatId,
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      },
    });
  }
  
  Future<void> handleAnswer(Map<String, dynamic> answer) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(answer['sdp'], answer['type']),
    );
  }
  
  Future<void> addIceCandidate(Map<String, dynamic> candidate) async {
    await _peerConnection!.addCandidate(
      RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ),
    );
  }
  
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  
  void toggleAudio() {
    final audioTrack = _localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
    }
  }
  
  void toggleVideo() {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      videoTrack.enabled = !videoTrack.enabled;
    }
  }
  
  Future<void> dispose() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
  }
}