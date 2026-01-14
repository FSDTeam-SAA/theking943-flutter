import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../utils/api_config.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  String? _currentUserId;

  bool _isConnecting = false;
  



  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  SocketService._();

  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;
  String? get currentUserId => _currentUserId;

  
  Future<void> connect(String userId) async {
    // If already connecting, wait
    if (_isConnecting) {
      print('⏳ Socket connection in progress, waiting...');
      int attempts = 0;
      while (_isConnecting && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
    }
    
    // If already connected with same user, don't reconnect


  Future<bool> connect(String userId) async {
    if (_socket != null && _socket!.connected && _currentUserId == userId) {
      print('✅ Socket already connected');
      return true;
    }

    
    // If connected with different user, disconnect first
    if (_socket != null && _socket!.connected && _currentUserId != userId) {
      print('⚠️ Disconnecting previous socket connection');
      disconnect();
    }
    
    _isConnecting = true;
    _currentUserId = userId;
    
    try {
      print('🔌 Connecting socket for user: $userId');
      print('📡 Server URL: ${ApiConfig.baseUrl}');
      
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(10000)
            .build(),
      );
      
      _socket!.onConnect((_) {
        print('✅ Socket connected: ${_socket!.id}');
        print('📡 Joining chat room for user: $userId');
        _socket!.emit('joinChatRoom', userId);
        _isConnecting = false;
      });
      
      _socket!.on('joinedRoom', (data) {
        print('✅ Successfully joined room: $data');
      });
      
      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
        _isConnecting = false;
      });
      
      _socket!.onError((error) {
        print('❌ Socket error: $error');
        _isConnecting = false;
      });
      
      _socket!.onReconnect((_) {
        print('🔄 Socket reconnected');
        if (_currentUserId != null) {
          _socket!.emit('joinChatRoom', _currentUserId);
        }
      });
      
      _socket!.on('connect_error', (data) {
        print('❌ Connection error: $data');
        _isConnecting = false;
      });
      
      _socket!.on('connect_timeout', (data) {
        print('❌ Connection timeout: $data');
        _isConnecting = false;
      });
      
      // ✅ Listen for call events
      _socket!.on('call:failed', (data) {
        print('❌ Call failed: $data');
      });
      
      _socket!.on('call:sent', (data) {
        print('✅ Call sent successfully: $data');
      });
      
      _socket!.connect();
      
      // Wait for connection with timeout
      int attempts = 0;
      while (!_socket!.connected && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (!_socket!.connected) {
        throw Exception('Socket connection timeout');
      }
      
      print('✅ Socket connection established');
    } catch (e) {
      print('❌ Socket connection error: $e');
      _isConnecting = false;
      rethrow;
    disconnect();
    _currentUserId = userId;
    final completer = Completer<bool>();
    final String serverUrl = ApiConfig.baseUrl;

    print('');
    print('╔══════════════════════════════════════════╗');
    print('║        🔌 CONNECTING SOCKET              ║');
    print('╚══════════════════════════════════════════╝');
    print('   • User ID : $userId');
    print('   • Server  : $serverUrl');
    print('');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .setExtraHeaders({'userId': userId})
          .build(),
    );

    _setupListeners(userId, completer);
    _socket!.connect();

    return await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        print('⏱️ Socket connection timeout');
        return false;
      },
    );
  }

  void _setupListeners(String userId, Completer<bool> completer) {
    _socket!.onConnect((_) {
      print('');
      print('✅ SOCKET CONNECTED');
      print('   • Socket ID: ${_socket!.id}');
      print('   • User ID  : $userId');

      _socket!.emit('joinChatRoom', userId);
      print('📡 Emitted: joinChatRoom with userId: $userId');
      
      Future.delayed(const Duration(milliseconds: 800), () {
        print('✅ Waiting for room join confirmation...');
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });
    });

    _socket!.onDisconnect((reason) {
      print('❌ Socket disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connect error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    _socket!.onReconnect((attempt) {
      print('🔄 Socket reconnected (attempt $attempt)');
      if (_currentUserId != null) {
        _socket!.emit('joinChatRoom', _currentUserId);
        print('📡 Re-joined room after reconnect');
      }
    });

    _socket!.onReconnectFailed((_) {
      print('❌ Socket reconnection failed');
    });
    
    _socket!.on('socket:connected', (data) {
      print('✅ Backend confirmed connection:');
      print('   • Data: $data');
      print('');
    });
  }

  Future<bool> emit(String event, dynamic data) async {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket not connected, attempting reconnect...');
      if (_currentUserId != null) {
        final ok = await connect(_currentUserId!);
        if (!ok) {
          print('❌ Reconnection failed');
          return false;
        }
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        print('❌ No user ID for reconnection');
        return false;
      }
    }

    print('');
    print('📤 Emitting event: $event');
    print('   Data: $data');
    print('   Socket ID: ${_socket!.id}');
    print('   Connected: ${_socket!.connected}');
    print('   User ID: $_currentUserId');

    try {
      _socket!.emit(event, data);
      print('✅ Event emitted successfully');
      print('');
      return true;
    } catch (e) {
      print('❌ Error emitting event: $e');
      print('');
      return false;

    }
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      print('👂 Listening to: $event');
    }
  }

  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
      print('🔇 Stopped listening to: $event');
    }
  }

  void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting socket');

      if (_currentUserId != null && _socket!.connected) {
        _socket!.emit('user:offline', {'userId': _currentUserId});
      }

      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();

      _socket = null;
      _currentUserId = null;

      _isConnecting = false;
      print('✅ Socket disconnected and disposed');
    }
  }
  
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting event: $event');
      print('📦 Data: $data');
      _socket!.emit(event, data);
    } else {
      print('⚠️ Cannot emit $event - socket not connected');
      print('⚠️ Socket status: ${_socket?.connected}');
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
  
  void clearListeners() {
    _socket?.clearListeners();
    print('🔇 All listeners cleared');


      print('✅ Socket disposed');
    }
  }

  Future<bool> ensureConnected() async {
    if (_socket == null || !_socket!.connected) {
      if (_currentUserId != null) {
        return await connect(_currentUserId!);
      }
      return false;
    }
    return true;

  }
}