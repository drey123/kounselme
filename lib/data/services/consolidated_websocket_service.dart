// lib/data/services/consolidated_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/data/services/websocket_service.dart';
import 'package:kounselme/domain/models/chat_message.dart';
import 'package:kounselme/domain/models/chat_participant.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

/// A consolidated implementation of WebSocketService that works with both
/// real backend connections and mock data for development.
class ConsolidatedWebSocketService implements WebSocketService {
  // WebSocket channel
  WebSocketChannel? _channel;
  
  // Stream controllers
  final _connectionStreamController = StreamController<ConnectionStatus>.broadcast();
  final _messageStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingStreamController = StreamController<Map<String, bool>>.broadcast();
  final _participantStreamController = StreamController<List<ChatParticipant>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();
  
  // Connection status
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  
  // Session information
  String? _sessionId;
  String? _userId;
  String? _token;
  
  // Implement setCredentials method from WebSocketService interface
  @override
  void setCredentials({
    required String userId,
    required String authToken,
    String? sessionId,
  }) {
    _userId = userId;
    _token = authToken;
    _sessionId = sessionId;
    debugPrint('Credentials set: userId=$userId, sessionId=$sessionId');
  }
  
  // Reconnection variables
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  
  // UUID generator for mock mode
  final _uuid = const Uuid();
  
  // Mock data for development
  final List<ChatParticipant> _mockParticipants = [];
  final Map<String, bool> _mockTypingStatus = {};
  
  // Stream getters
  @override
  Stream<ConnectionStatus> get connectionStream => _connectionStreamController.stream;
  
  @override
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;
  
  @override
  Stream<Map<String, bool>> get typingStream => _typingStreamController.stream;
  
  @override
  Stream<List<ChatParticipant>> get participantStream => _participantStreamController.stream;
  
  @override
  Stream<String> get errorStream => _errorStreamController.stream;
  
  // Connection status getter
  @override
  ConnectionStatus get connectionStatus => _connectionStatus;
  
  // Connect to WebSocket server
  @override
  Future<void> connect() async {
    // If already connected or connecting, return
    if (_connectionStatus == ConnectionStatus.connected || 
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }
    
    // Update connection status
    _connectionStatus = ConnectionStatus.connecting;
    _connectionStreamController.add(_connectionStatus);
    
    try {
      // Determine if we should use mock data
      if (Env.useMockData && Env.isDev()) {
        _setupMockWebSocket();
        return;
      }
      
      // Build WebSocket URL
      final wsBaseUrl = Env.wsBaseUrl;
      final wsPort = Env.wsPort;
      
      // Build URL with port if provided
      final uri = Uri.parse(wsBaseUrl);
      final wsUri = uri.replace(port: wsPort > 0 ? wsPort : uri.port);
      
      // Connect to chat endpoint
      final fullWsUrl = '${wsUri.toString()}/chat';
      debugPrint('Connecting to WebSocket: $fullWsUrl');
      
      // Create WebSocket channel
      _channel = IOWebSocketChannel.connect(fullWsUrl);
      
      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleDisconnect,
        onError: _handleError,
        cancelOnError: false,
      );
      
      // Update connection status
      _connectionStatus = ConnectionStatus.connected;
      _connectionStreamController.add(_connectionStatus);
      
      // Reset reconnect attempts
      _reconnectAttempts = 0;
    } catch (e) {
      // Handle connection error
      _handleError(e);
    }
  }
  
  // Disconnect from WebSocket server
  @override
  Future<void> disconnect() async {
    // Cancel reconnect timer if active
    _reconnectTimer?.cancel();
    
    // Close WebSocket channel if open
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    
    // Update connection status
    _connectionStatus = ConnectionStatus.disconnected;
    _connectionStreamController.add(_connectionStatus);
  }
  
  // Send message to server
  void sendMessage(String content) {
    if (_connectionStatus != ConnectionStatus.connected) {
      debugPrint('Cannot send message: WebSocket not connected');
      return;
    }
    
    final message = {
      'type': 'message',
      'content': content,
      'sessionId': _sessionId,
      'userId': _userId,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockMessage(message);
    } else {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Join a session
  void joinSession(String sessionId, {bool isHost = false}) {
    if (_connectionStatus != ConnectionStatus.connected) {
      debugPrint('Cannot join session: WebSocket not connected');
      return;
    }
    
    _sessionId = sessionId;
    
    final message = {
      'type': 'join_session',
      'sessionId': sessionId,
      'userId': _userId,
      'isHost': isHost,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockJoinSession(message);
    } else {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Leave a session
  void leaveSession() {
    if (_connectionStatus != ConnectionStatus.connected || _sessionId == null) {
      return;
    }
    
    final message = {
      'type': 'leave_session',
      'sessionId': _sessionId,
      'userId': _userId,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockLeaveSession(message);
    } else {
      _channel!.sink.add(jsonEncode(message));
    }
    
    _sessionId = null;
  }
  
  // End a session (host only)
  @override
  void endSession() {
    if (_connectionStatus != ConnectionStatus.connected || _sessionId == null) {
      debugPrint('Cannot end session: WebSocket not connected or no active session');
      return;
    }
    
    final message = {
      'type': 'end_session',
      'sessionId': _sessionId,
      'userId': _userId,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockEndSession(message);
    } else {
      _channel!.sink.add(jsonEncode(message));
    }
    
    _sessionId = null;
  }
  
  // This duplicate sendTypingIndicator method has been removed
  
  // This helper method has been removed as it's replaced by _handleMockTyping
    
  // Helper method for handling mock end session
  void _handleMockEndSession(Map<String, dynamic> message) {
    // Clear participants and notify
    _mockParticipants.clear();
    _participantStreamController.add(_mockParticipants);
    
    // Update connection status
    _connectionStatus = ConnectionStatus.disconnected;
    _connectionStreamController.add(_connectionStatus);
    
    // Clear session ID
    _sessionId = null;
  }
    
  // Private methods for WebSocket handling
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final messageType = message['type'] as String?;
      
      switch (messageType) {
        case 'message':
          _messageStreamController.add(message);
          break;
        case 'typing':
          final userId = message['userId'] as String?;
          final isTyping = message['isTyping'] as bool?;
          
          if (userId != null && isTyping != null) {
            _typingStreamController.add({userId: isTyping});
          }
          break;
        case 'participant_update':
          final participants = (message['participants'] as List<dynamic>)
              .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
              .toList();
          
          _participantStreamController.add(participants);
          break;
        case 'error':
          final errorMsg = message['message'] as String? ?? 'Unknown error';
          _errorStreamController.add(errorMsg);
          break;
        default:
          // Forward all other messages to the message stream
          _messageStreamController.add(message);
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
      _errorStreamController.add('Error processing message: $e');
    }
  }
  
  // This duplicate sendTypingIndicator method has been removed
  
  // Invite a user to the session
  @override
  void inviteUser(String email, {String? message}) {
    if (_connectionStatus != ConnectionStatus.connected || _sessionId == null) {
      return;
    }
    
    final inviteMessage = {
      'type': 'invite',
      'sessionId': _sessionId,
      'userId': _userId,
      'email': email,
      'message': message,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockInvite(inviteMessage);
    } else {
      _channel!.sink.add(jsonEncode(inviteMessage));
    }
  }
  
  // Remove a user from the session
  @override
  void removeUser(String userId) {
    if (_connectionStatus != ConnectionStatus.connected || _sessionId == null) {
      return;
    }
    
    final message = {
      'type': 'remove_user',
      'sessionId': _sessionId,
      'userId': _userId,
      'targetUserId': userId,
    };
    
    if (Env.useMockData && Env.isDev()) {
      _handleMockRemoveUser(message);
    } else {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Handle incoming WebSocket message
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final messageType = message['type'] as String?;
      
      switch (messageType) {
        case 'message':
          _messageStreamController.add(message);
          break;
        case 'typing':
          final userId = message['userId'] as String?;
          final isTyping = message['isTyping'] as bool?;
          
          if (userId != null && isTyping != null) {
            _typingStreamController.add({userId: isTyping});
          }
          break;
        case 'participant_update':
          final participants = (message['participants'] as List<dynamic>)
              .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
              .toList();
          
          _participantStreamController.add(participants);
          break;
        case 'error':
          final errorMsg = message['message'] as String? ?? 'Unknown error';
          _errorStreamController.add(errorMsg);
          break;
        default:
          // Forward all other messages to the message stream
          _messageStreamController.add(message);
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
      _errorStreamController.add('Error processing message: $e');
    }
  }
  
  // Handle WebSocket disconnect
  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    
    _connectionStatus = ConnectionStatus.disconnected;
    _connectionStreamController.add(_connectionStatus);
    
    // Attempt to reconnect if not manually disconnected
    _attemptReconnect();
  }
  
  // Handle WebSocket error
  void _handleError(dynamic error) {
    final errorMsg = error.toString();
    debugPrint('WebSocket error: $errorMsg');
    
    _connectionStatus = ConnectionStatus.error;
    _connectionStreamController.add(_connectionStatus);
    _errorStreamController.add('Connection error: $errorMsg');
    
    // Attempt to reconnect
    _attemptReconnect();
  }
  
  // Attempt to reconnect to WebSocket server
  void _attemptReconnect() {
    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();
    
    // If max reconnect attempts reached, give up
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }
    
    // Increment reconnect attempts
    _reconnectAttempts++;
    
    // Calculate backoff delay (exponential backoff)
    final delay = Duration(milliseconds: 1000 * (1 << _reconnectAttempts));
    debugPrint('Attempting to reconnect in ${delay.inSeconds} seconds');
    
    // Schedule reconnect
    _reconnectTimer = Timer(delay, () {
      if (_connectionStatus != ConnectionStatus.connected) {
        connect();
      }
    });
  }
  
  // Setup mock WebSocket for development
  void _setupMockWebSocket() {
    debugPrint('Setting up mock WebSocket');
    
    // Simulate connection
    Future.delayed(const Duration(milliseconds: 500), () {
      _connectionStatus = ConnectionStatus.connected;
      _connectionStreamController.add(_connectionStatus);
      
      // Add self as participant
      if (_userId != null) {
        final selfParticipant = ChatParticipant(
          id: _userId!,
          name: 'You',
          isHost: true,
          isOnline: true,
          userId: _userId!,
        );
        
        _mockParticipants.add(selfParticipant);
        
        // Add AI as participant
        final aiParticipant = ChatParticipant(
          id: 'ai',
          name: 'KounselMe AI',
          isOnline: true,
          userId: 'ai',
        );
        
        _mockParticipants.add(aiParticipant);
        
        // Send participant update
        _participantStreamController.add(_mockParticipants);
      }
      
      // Send welcome message
      final welcomeMessage = {
        'type': 'message',
        'messageId': _uuid.v4(),
        'sessionId': _sessionId,
        'senderId': 'ai',
        'content': 'Hello! I\'m here to listen and support you. How are you feeling today?',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _messageStreamController.add(welcomeMessage);
    });
  }
  
  // Handle mock message
  void _handleMockMessage(Map<String, dynamic> message) {
    // Add user message to stream
    final userMessage = {
      'type': 'message',
      'messageId': _uuid.v4(),
      'sessionId': _sessionId,
      'senderId': _userId,
      'content': message['content'],
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _messageStreamController.add(userMessage);
    
    // Simulate AI typing
    final typingStatus = {'ai': true};
    _typingStreamController.add(typingStatus);
    
    // Simulate AI response after delay
    Future.delayed(const Duration(seconds: 2), () {
      // Stop typing
      _typingStreamController.add({'ai': false});
      
      // Generate AI response
      final responses = [
        "I understand how you're feeling. Anxiety can be challenging to manage. Let's explore some techniques that might help you cope with these feelings.",
        "That's a great question. When we talk about stress management, it's important to consider both short-term relief and long-term strategies.",
        "I hear you. Sleep issues can significantly impact your mental health. Let's discuss some evidence-based approaches to improve your sleep quality.",
        "Thank you for sharing that with me. It takes courage to talk about these feelings. Let's work together to understand what might be triggering them.",
        "That's an interesting perspective. Could you tell me more about how these thoughts affect your daily activities?",
        "It sounds like you've been going through a lot lately. Remember that it's okay to take things one step at a time.",
        "Mindfulness can be a powerful tool for managing those feelings. Would you like to try a brief mindfulness exercise together?",
        "That's excellent progress! It's important to acknowledge these positive steps, no matter how small they might seem.",
      ];
      
      // Select random response
      final response = responses[DateTime.now().millisecond % responses.length];
      
      // Send AI response
      final aiMessage = {
        'type': 'message',
        'messageId': _uuid.v4(),
        'sessionId': _sessionId,
        'senderId': 'ai',
        'content': response,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _messageStreamController.add(aiMessage);
    });
  }
  
  // Handle mock join session
  void _handleMockJoinSession(Map<String, dynamic> message) {
    _sessionId = message['sessionId'] as String?;
    
    // Create session joined message
    final joinedMessage = {
      'type': 'session_joined',
      'sessionId': _sessionId,
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _messageStreamController.add(joinedMessage);
    
    // Add self as participant if not already present
    if (_userId != null && !_mockParticipants.any((p) => p.id == _userId)) {
      final selfParticipant = ChatParticipant(
        id: _userId!,
        name: 'You',
        isHost: message['isHost'] as bool? ?? false,
        isOnline: true,
        userId: _userId!,
      );
      
      _mockParticipants.add(selfParticipant);
    }
    
    // Add AI as participant if not already present
    if (!_mockParticipants.any((p) => p.id == 'ai')) {
      final aiParticipant = ChatParticipant(
        id: 'ai',
        name: 'KounselMe AI',
        isOnline: true,
        userId: 'ai',
      );
      
      _mockParticipants.add(aiParticipant);
    }
    
    // Send participant update
    _participantStreamController.add(_mockParticipants);
    
    // Send welcome message
    final welcomeMessage = {
      'type': 'message',
      'messageId': _uuid.v4(),
      'sessionId': _sessionId,
      'senderId': 'ai',
      'content': 'Hello! I\'m here to listen and support you. How are you feeling today?',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _messageStreamController.add(welcomeMessage);
  }
  
  // Handle mock leave session
  void _handleMockLeaveSession(Map<String, dynamic> message) {
    // Create session left message
    final leftMessage = {
      'type': 'session_left',
      'sessionId': _sessionId,
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _messageStreamController.add(leftMessage);
    
    // Remove self from participants
    if (_userId != null) {
      _mockParticipants.removeWhere((p) => p.id == _userId);
    }
    
    // Send participant update
    _participantStreamController.add(_mockParticipants);
    
    // Clear session ID
    _sessionId = null;
  }
  
  // Handle mock end session
  void _handleMockEndSession(Map<String, dynamic> message) {
    // Create session ended message
    final endedMessage = {
      'type': 'session_ended',
      'sessionId': _sessionId,
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _messageStreamController.add(endedMessage);
    
    // Clear participants
    _mockParticipants.clear();
    
    // Send participant update
    _participantStreamController.add(_mockParticipants);
    
    // Clear session ID
    _sessionId = null;
  }
  
  // Handle mock typing
  void _handleMockTyping(Map<String, dynamic> message) {
    final userId = message['userId'] as String?;
    final isTyping = message['isTyping'] as bool?;
    
    if (userId != null && isTyping != null) {
      _mockTypingStatus[userId] = isTyping;
      _typingStreamController.add({userId: isTyping});
    }
  }
  
  // Handle mock invite
  void _handleMockInvite(Map<String, dynamic> message) {
    final email = message['email'] as String?;
    final inviteMessage = message['message'] as String?;
    
    if (email != null) {
      // Create invite sent message
      final inviteSentMessage = {
        'type': 'invite_sent',
        'sessionId': _sessionId,
        'userId': _userId,
        'email': email,
        'message': inviteMessage,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _messageStreamController.add(inviteSentMessage);
      
      // Simulate user joining after delay
      Future.delayed(const Duration(seconds: 3), () {
        // Create new participant
        final newUserId = 'user_${_uuid.v4().substring(0, 8)}';
        final newParticipant = ChatParticipant(
          id: newUserId,
          name: email.split('@')[0],
          isHost: false,
          isOnline: true,
          userId: newUserId,
        );
        
        // Add to participants
        _mockParticipants.add(newParticipant);
        
        // Send participant update
        _participantStreamController.add(_mockParticipants);
        
        // Create user joined message
        final userJoinedMessage = {
          'type': 'user_joined',
          'sessionId': _sessionId,
          'userId': newUserId,
          'name': newParticipant.name,
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        _messageStreamController.add(userJoinedMessage);
      });
    }
  }
  
  // Handle mock remove user
  void _handleMockRemoveUser(Map<String, dynamic> message) {
    final targetUserId = message['targetUserId'] as String?;
    
    if (targetUserId != null) {
      // Find participant
      final participant = _mockParticipants.firstWhere(
        (p) => p.id == targetUserId,
        orElse: () => ChatParticipant(id: targetUserId, name: 'Unknown', userId: targetUserId),
      );
      
      // Create user removed message
      final userRemovedMessage = {
        'type': 'user_removed',
        'sessionId': _sessionId,
        'userId': _userId,
        'targetUserId': targetUserId,
        'name': participant.name,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _messageStreamController.add(userRemovedMessage);
      
      // Remove from participants
      _mockParticipants.removeWhere((p) => p.id == targetUserId);
      
      // Send participant update
      _participantStreamController.add(_mockParticipants);
    }
  }
  
  // Dispose resources
  void dispose() {
    // Cancel reconnect timer
    _reconnectTimer?.cancel();
    
    // Close WebSocket channel
    _channel?.sink.close();
    
    // Close stream controllers
    _connectionStreamController.close();
    _messageStreamController.close();
    _typingStreamController.close();
    _participantStreamController.close();
    _errorStreamController.close();
  }
}