import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:docmobi/utils/api_config.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  String? _currentUserId;
  
  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }
  
  SocketService._();
  
  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;
  String? get currentUserId => _currentUserId;
  
  Future<void> connect(String userId) async {
    // ✅ If already connected with same user, don't reconnect
    if (_socket != null && _socket!.connected && _currentUserId == userId) {
      print('✅ Socket already connected for user: $userId');
      return;
    }
    
    // ✅ If connected with different user, disconnect first
    if (_socket != null && _socket!.connected && _currentUserId != userId) {
      print('⚠️ Disconnecting previous socket connection');
      disconnect();
    }
    
    _currentUserId = userId;
    
    try {
      print('🔌 Connecting socket for user: $userId');
      
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );
      
      _socket!.onConnect((_) {
        print('✅ Socket connected: ${_socket!.id}');
        print('📡 Joining chat room for user: $userId');
        _socket!.emit('joinChatRoom', userId);
      });
      
      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
      });
      
      _socket!.onError((error) {
        print('❌ Socket error: $error');
      });
      
      _socket!.onReconnect((_) {
        print('🔄 Socket reconnected');
        if (_currentUserId != null) {
          _socket!.emit('joinChatRoom', _currentUserId);
        }
      });
      
      _socket!.connect();
    } catch (e) {
      print('❌ Socket connection error: $e');
    }
  }
  
  void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _currentUserId = null;
      print('✅ Socket disconnected and disposed');
    }
  }
  
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting event: $event');
      _socket!.emit(event, data);
    } else {
      print('⚠️ Cannot emit $event - socket not connected');
    }
  }
  
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
    print('👂 Listening to event: $event');
  }
  
  void off(String event) {
    _socket?.off(event);
    print('🔇 Stopped listening to event: $event');
  }
  
  // ✅ Clear all listeners
  void clearListeners() {
    _socket?.clearListeners();
    print('🔇 All listeners cleared');
  }
}