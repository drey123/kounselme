// lib/data/remote/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/core/constants/app_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
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

  // Streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  // Reconnection variables
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  // Session information
  String? _sessionId;
  String? _userId;
  String? _authToken;

  // Connect to the WebSocket server
  Future<void> connect({
    required String userId,
    required String authToken,
    String? sessionId,
  }) async {
    if (_status == ConnectionStatus.connected ||
        _status == ConnectionStatus.connecting) {
      return;
    }

    _userId = userId;
    _authToken = authToken;
    _sessionId = sessionId;

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
        _channel = IOWebSocketChannel.connect(fullWsUrl);

        // Listen for messages
        _channel!.stream.listen(
          _handleMessage,
          onDone: _handleDisconnect,
          onError: _handleError,
          cancelOnError: false,
        );
      }

      // Authenticate after connection
      _authenticate();

      // If we have a session ID, join it
      if (_sessionId != null) {
        joinSession(_sessionId!);
      }

      _setStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _handleError(e);
    }
  }

  // Disconnect from the WebSocket server
  void disconnect() {
    _cancelReconnect();
    _channel?.sink.close();
    _channel = null;
    _setStatus(ConnectionStatus.disconnected);
  }

  // Send a message
  void send(Map<String, dynamic> message) {
    if (_status != ConnectionStatus.connected) {
      debugPrint('Cannot send message: WebSocket not connected');
      return;
    }

    _channel?.sink.add(jsonEncode(message));
  }

  // Send authentication
  void _authenticate() {
    if (_userId == null || _authToken == null) {
      debugPrint('Cannot authenticate: userId or authToken is null');
      return;
    }

    send({
      'type': 'auth',
      'userId': _userId,
      'token': _authToken,
    });
  }

  // Join a chat session
  void joinSession(
    String sessionId, {
    bool isHost = false,
    String? name,
    int? duration,
    bool isMultiUser = false,
  }) {
    if (_status != ConnectionStatus.connected) {
      debugPrint('Cannot join session: WebSocket not connected');
      return;
    }

    _sessionId = sessionId;

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
  }

  // Send a chat message
  void sendMessage(String content, {bool requestAIResponse = true}) {
    if (_sessionId == null) {
      debugPrint('Cannot send message: Not in a session');
      return;
    }

    send({
      'type': 'chat_message',
      'sessionId': _sessionId,
      'content': content,
      'requestAIResponse': requestAIResponse,
    });
  }

  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_sessionId == null) return;

    send({
      'type': 'typing',
      'sessionId': _sessionId,
      'isTyping': isTyping,
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
    // This is a bit of a hack, but it works for development
    (_channel as dynamic).stream = controller.stream;

    // Simulate connection success
    Future.delayed(const Duration(milliseconds: 500), () {
      _setStatus(ConnectionStatus.connected);

      // Simulate authentication success response
      controller.add(jsonEncode({
        'type': 'auth_success',
        'userId': _userId,
      }));
    });

    // Setup a timer to periodically check for pending messages
    Timer.periodic(const Duration(seconds: 2), (timer) {
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

      // Handle specific message types if needed
      final type = message['type'] as String?;

      if (type == 'error') {
        debugPrint('WebSocket error: ${message['message']}');
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
    debugPrint('WebSocket error: $error');

    if (_status != ConnectionStatus.disconnected) {
      _setStatus(ConnectionStatus.disconnected);
      _attemptReconnect();
    }
  }

  // Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectAttempts >= AppConstants.connectionRetryAttempts) {
      debugPrint('Maximum reconnection attempts reached');
      return;
    }

    _setStatus(ConnectionStatus.reconnecting);

    _cancelReconnect();

    final delay = Duration(
        seconds: AppConstants.connectionRetryDelaySeconds *
            (_reconnectAttempts + 1));

    debugPrint('Attempting to reconnect in ${delay.inSeconds} seconds...');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect(
        userId: _userId!,
        authToken: _authToken!,
        sessionId: _sessionId,
      );
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

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}
