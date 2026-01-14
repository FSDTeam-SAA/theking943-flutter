import 'package:flutter/material.dart';
import 'package:docmobi/services/socket_service.dart';
import 'package:docmobi/screens/common/calls/video_call_screen.dart';
import 'package:docmobi/screens/common/calls/audio_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String chatId;
  final String callerName;
  final String? callerAvatar;
  final String callerId;
  final bool isVideoCall;

  const IncomingCallScreen({
    super.key,
    required this.chatId,
    required this.callerName,
    this.callerAvatar,
    required this.callerId,
    required this.isVideoCall,
  });

  void _acceptCall(BuildContext context) {
    SocketService.instance.emit('call:accept', {
      'chatId': chatId,
      'toUserId': callerId,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isVideoCall
            ? VideoCallScreen(
                chatId: chatId,
                userName: callerName,
                userAvatar: callerAvatar,
                otherUserId: callerId,
                isInitiator: false,
              )
            : AudioCallScreen(
                chatId: chatId,
                userName: callerName,
                userAvatar: callerAvatar,
                otherUserId: callerId,
                isInitiator: false,
              ),
      ),
    );
  }

  void _rejectCall(BuildContext context) {
    SocketService.instance.emit('call:reject', {
      'chatId': chatId,
      'toUserId': callerId,
    });

    Navigator.pop(context);
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Caller Avatar
              CircleAvatar(
                radius: 80,
                backgroundImage: callerAvatar != null
                    ? NetworkImage(callerAvatar!)
                    : const AssetImage('assets/images/doctor.png') as ImageProvider,
              ),
              
              const SizedBox(height: 30),
              
              // Caller Name
              Text(
                callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              // Call Type
              Text(
                isVideoCall ? 'Incoming Video Call...' : 'Incoming Audio Call...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Accept/Reject Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject Button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _rejectCall(context),
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
                      const SizedBox(height: 10),
                      const Text(
                        'Decline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  // Accept Button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _acceptCall(context),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isVideoCall ? Icons.videocam : Icons.call,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    SocketService.instance.off('call:ended');
    SocketService.instance.off('call:failed');
    super.dispose();
  }
}