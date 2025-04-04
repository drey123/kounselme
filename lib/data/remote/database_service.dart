// lib/data/remote/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' show pow;
import 'package:flutter/foundation.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/core/constants/app_constants.dart';
import 'package:kounselme/domain/models/chat_participant.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  authenticating,
  error,
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // WebSocket channel
  WebSocketChannel? _channel;

  // Connection status
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;

  // Streaming controllers
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _participantController = StreamController<List<ChatParticipant>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<List<ChatParticipant>> get participantStream => _participantController.stream;

  // Message queue for offline support
  final List<Map<String, dynamic>> _messageQueue = [];
  
  // Reconnection variables
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  
  // Authentication completer
  Completer<bool>? _authCompleter;
  Timer? _authTimeoutTimer;
  final Duration _authTimeout = const Duration(seconds: 10);
  
  // Heartbeat timer
  Timer? _heartbeatTimer;
  final Duration _heartbeatInterval = const Duration(seconds: 30);
  int _missedHeartbeats = 0;
  final int _maxMissedHeartbeats = 3;
  
  // Session information
  String? _sessionId;
  String? _userId;
  String? _authToken;
  bool _isHost = false;
  List<ChatParticipant> _participants = [];

  // Connect to the WebSocket server
  Future<bool> connect({
    required String userId,
    required String authToken,
    String? sessionId,
    bool isHost = false,
  }) async {
    // Prevent multiple connection attempts
    if (_status == ConnectionStatus.connecting || 
        _status == ConnectionStatus.reconnecting ||
        _status == ConnectionStatus.authenticating) {
      debugPrint('Connection already in progress, status: $_status');
      return false;
    }
    
    // Allow reconnection if disconnected or in error state
    if (_status == ConnectionStatus.connected) {
      debugPrint('Already connected, ignoring connect request');
      return true;
    }

    _userId = userId;
    _authToken = authToken;
    _sessionId = sessionId;
    _isHost = isHost;

    _setStatus(ConnectionStatus.connecting);

    try {
      // Use environment configuration to determine WebSocket URL
      String fullWsUrl;

      if (Env.useMockData && Env.isDev()) {
        // In development with mock data, use a dummy URL that will trigger the mock handler
        fullWsUrl = 'ws://localhost:0000/mock';
        debugPrint('Using mock WebSocket connection');
      } else {
        // Use configured WebSocket settings
        final wsBaseUrl = Env.wsBaseUrl;
        final wsPort = Env.wsPort;

        // Build URL with port if provided
        final uri = Uri.parse(wsBaseUrl);
        final wsUri = uri.replace(port: wsPort > 0 ? wsPort : uri.port);

        // Connect to chat endpoint
        fullWsUrl = '${wsUri.toString()}/chat';
      }
      debugPrint('Connecting to WebSocket: $fullWsUrl');

      // For development with mock data, use a mock channel
      if (Env.useMockData && Env.isDev() && fullWsUrl.contains('/mock')) {
        _setupMockWebSocket();
      } else {
        _channel = IOWebSocketChannel.connect(
          fullWsUrl,
          pingInterval: const Duration(seconds: 20),
        );

        // Listen for messages
        _channel!.stream.listen(
          _handleMessage,
          onDone: _handleDisconnect,
          onError: _handleError,
          cancelOnError: false,
        );
      }

      // Authenticate after connection
      final authSuccess = await _authenticate();
      if (!authSuccess) {
        _setStatus(ConnectionStatus.error);
        _emitError('Authentication failed');
        return false;
      }

      // Start heartbeat
      _startHeartbeat();
      
      // If we have a session ID, join it
      if (_sessionId != null) {
        joinSession(_sessionId!, isHost: _isHost);
      }

      _setStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
      
      // Process any queued messages
      _processMessageQueue();
      
      return true;
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _handleError(e);
      return false;
    }
  }

  // Process queued messages
  void _processMessageQueue() {
    if (_messageQueue.isEmpty || _status != ConnectionStatus.connected) {
      return;
    }
    
    debugPrint('Processing ${_messageQueue.length} queued messages');
    
    // Create a copy of the queue to avoid modification during iteration
    final queueCopy = List<Map<String, dynamic>>.from(_messageQueue);
    _messageQueue.clear();
    
    // Send each queued message
    for (final message in queueCopy) {
      send(message);
    }
  }

  // Start heartbeat mechanism
  void _startHeartbeat() {
    _cancelHeartbeat();
    _missedHeartbeats = 0;
    
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_status == ConnectionStatus.connected) {
        send({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        }).then((sent) {
          if (!sent) {
            _missedHeartbeats++;
            debugPrint('Missed heartbeat: $_missedHeartbeats');
            
            if (_missedHeartbeats >= _maxMissedHeartbeats) {
              debugPrint('Too many missed heartbeats, reconnecting...');
              _handleDisconnect();
            }
          } else {
            _missedHeartbeats = 0;
          }
        });
      }
    });
  }

  // Cancel heartbeat timer
  void _cancelHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // Send a message with offline support
  Future<bool> send(Map<String, dynamic> message) async {
    // If not connected, queue the message for later
    if (_status != ConnectionStatus.connected) {
      _messageQueue.add(message);
      
      // If disconnected, try to reconnect
      if (_status == ConnectionStatus.disconnected || _status == ConnectionStatus.error) {
        if (_userId != null && _authToken != null) {
          connect(
            userId: _userId!,
            authToken: _authToken!,
            sessionId: _sessionId,
            isHost: _isHost,
          );
        }
      }
      
      return false;
    }

    try {
      _channel?.sink.add(jsonEncode(message));
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      _messageQueue.add(message);
      return false;
    }
  }

  // Authenticate with the server
  Future<bool> _authenticate() async {
    if (_userId == null || _authToken == null) {
      _emitError('Cannot authenticate: userId or authToken is null');
      return false;
    }

    _setStatus(ConnectionStatus.authenticating);
    
    // Create a completer to handle the auth response
    _authCompleter = Completer<bool>();
    
    // Set timeout for authentication
    _authTimeoutTimer = Timer(_authTimeout, () {
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete(false);
        _emitError('Authentication timeout after ${_authTimeout.inSeconds} seconds');
      }
    });

    // Send auth message
    final messageSent = await send({
      'type': 'auth',
      'userId': _userId,
      'token': _authToken,
    });
    
    if (!messageSent) {
      _cancelAuthTimeout();
      return false;
    }
    
    try {
      // Wait for auth response
      final result = await _authCompleter!.future;
      return result;
    } catch (e) {
      _emitError('Authentication error: $e');
      return false;
    } finally {
      _cancelAuthTimeout();
    }
  }

  // Cancel authentication timeout
  void _cancelAuthTimeout() {
    _authTimeoutTimer?.cancel();
    _authTimeoutTimer = null;
  }

  // Join a chat session
  void joinSession(
    String sessionId, {
    bool isHost = false,
    String? name,
    int? duration,
    bool isMultiUser = false,
  }) {
    _sessionId = sessionId;
    _isHost = isHost;

    send({
      'type': 'join_session',
      'sessionId': sessionId,
      'isHost': isHost,
      'name': name ?? _userId,
      'duration': duration,
      'isMultiUser': isMultiUser,
    });
  }

  // Leave the current session
  void leaveSession() {
    if (_sessionId == null) return;

    send({
      'type': 'leave_session',
      'sessionId': _sessionId,
    });

    _sessionId = null;
    _isHost = false;
    _participants = [];
  }

  // Send a chat message
  void sendMessage(String content, {bool requestAIResponse = true}) {
    if (_sessionId == null) {
      _emitError('Cannot send message: Not in a session');
      return;
    }

    final message = {
      'type': 'chat_message',
      'sessionId': _sessionId,
      'content': content,
      'requestAIResponse': requestAIResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    send(message);
  }

  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_sessionId == null) return;

    send({
      'type': 'typing',
      'sessionId': _sessionId,
      'userId': _userId,
      'isTyping': isTyping,
    });
  }

  // Invite a user to the current session
  void inviteUser(String email, {String? message}) {
    if (_sessionId == null || !_isHost) {
      _emitError('Cannot invite user: Not a host or not in a session');
      return;
    }

    send({
      'type': 'invite_user',
      'sessionId': _sessionId,
      'email': email,
      'message': message,
    });
  }

  // Remove a user from the current session
  void removeUser(String userId) {
    if (_sessionId == null || !_isHost) {
      _emitError('Cannot remove user: Not a host or not in a session');
      return;
    }

    send({
      'type': 'remove_user',
      'sessionId': _sessionId,
      'userId': userId,
    });
  }

  // Setup mock WebSocket for development
  void _setupMockWebSocket() {
    debugPrint('Setting up mock WebSocket');
    // Create a StreamController to simulate WebSocket messages
    final controller = StreamController<dynamic>.broadcast();

    // Create a mock channel
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:0000/mock'))
      ..sink.done.catchError((e) {});

    // Override the stream with our controlled stream
    (_channel as dynamic).stream = controller.stream;

    // Simulate connection success
    Future.delayed(const Duration(milliseconds: 500), () {
      // Simulate authentication success response
      controller.add(jsonEncode({
        'type': 'auth_success',
        'userId': _userId,
      }));
      
      // Complete the auth completer
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete(true);
      }
      
      // If we have a session ID, simulate joining
      if (_sessionId != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          controller.add(jsonEncode({
            'type': 'session_joined',
            'sessionId': _sessionId,
            'participants': [
              {
                'userId': _userId,
                'name': 'You',
                'isHost': _isHost,
                'isAI': false,
              },
              {
                'userId': 'ai_assistant',
                'name': 'KounselMe AI',
                'isHost': false,
                'isAI': true,
              }
            ],
          }));
          
          // Simulate AI greeting
          Future.delayed(const Duration(seconds: 1), () {
            controller.add(jsonEncode({
              'type': 'chat_message',
              'sessionId': _sessionId,
              'userId': 'ai_assistant',
              'content': 'Hello! How can I help you today?',
              'timestamp': DateTime.now().toIso8601String(),
            }));
          });
        });
      }
    });

    // Setup a timer to handle mock responses
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // If disconnected, stop the timer
      if (_status == ConnectionStatus.disconnected) {
        timer.cancel();
        controller.close();
        return;
      }
    });
  }

  // Handle incoming message
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      _messageController.add(message);

      // Handle specific message types
      final type = message['type'] as String?;

      switch (type) {
        case 'auth_success':
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.complete(true);
          }
          break;
          
        case 'heartbeat_ack':
          _missedHeartbeats = 0;
          break;
          
        case 'chat_message':
          // No additional processing needed, already sent to message stream
          break;
          
        case 'typing':
          _typingController.add({
            'userId': message['userId'],
            'isTyping': message['isTyping'],
          });
          break;
          
        case 'session_joined':
        case 'participant_update':
          if (message['participants'] != null) {
            final participantsList = (message['participants'] as List)
                .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
                .toList();
            _participants = participantsList;
            _participantController.add(_participants);
          }
          break;
          
        case 'error':
          final errorMsg = message['message'] as String? ?? 'Unknown error';
          debugPrint('WebSocket error: $errorMsg');
          _emitError(errorMsg);
          
          // If it's an auth error, complete the auth completer with error
          if (_status == ConnectionStatus.authenticating && 
              _authCompleter != null && 
              !_authCompleter!.isCompleted) {
            _authCompleter!.complete(false);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
    }
  }

  // Handle WebSocket disconnect
  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');

    if (_status != ConnectionStatus.disconnected) {
      _setStatus(ConnectionStatus.disconnected);
      _attemptReconnect();
    }
  }

  // Handle WebSocket error
  void _handleError(dynamic error) {
    final errorMsg = error.toString();
    debugPrint('WebSocket error: $errorMsg');
    _emitError('Connection error: $errorMsg');

    if (_status != ConnectionStatus.disconnected) {
      _setStatus(ConnectionStatus.error);
      _attemptReconnect();
    }
  }

  // Emit error to error stream
  void _emitError(String error) {
    _errorController.add(error);
  }

  // Attempt to reconnect with exponential backoff
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Maximum reconnection attempts reached');
      _emitError('Failed to reconnect after $_maxReconnectAttempts attempts');
      return;
    }

    _setStatus(ConnectionStatus.reconnecting);
    _cancelReconnect();
    _cancelHeartbeat();

    // Calculate backoff delay with exponential increase
    final delay = Duration(
      milliseconds: (1000 * 
          pow(1.5, _reconnectAttempts)).round()
    );

    debugPrint('Attempting to reconnect in ${delay.inSeconds} seconds... (Attempt ${_reconnectAttempts + 1}/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      
      if (_userId != null && _authToken != null) {
        connect(
          userId: _userId!,
          authToken: _authToken!,
          sessionId: _sessionId,
          isHost: _isHost,
        );
      } else {
        _emitError('Cannot reconnect: Missing user credentials');
        _setStatus(ConnectionStatus.error);
      }
    });
  }

  // Cancel reconnection attempt
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // Update connection status
  void _setStatus(ConnectionStatus status) {
    _status = status;
    _statusController.add(status);
  }

  // Get current participants
  List<ChatParticipant> get participants => _participants;

  // Check if user is host
  bool get isHost => _isHost;

  // Dispose resources
  void dispose() {
    _cancelReconnect();
    _cancelHeartbeat();
    _cancelAuthTimeout();
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
    _statusController.close();
    _errorController.close();
    _typingController.close();
    _participantController.close();
  }
}
