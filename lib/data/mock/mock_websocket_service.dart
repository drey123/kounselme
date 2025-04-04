// lib/data/mock/mock_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kounselme/data/services/websocket_service.dart';
import 'package:kounselme/domain/models/chat_message.dart';
import 'package:kounselme/domain/models/chat_participant.dart';
import 'package:uuid/uuid.dart';

/// A mock implementation of WebSocketService for testing
class MockWebSocketService implements WebSocketService {
  // Stream controllers
  final _messageStreamController = StreamController<ChatMessage>.broadcast();
  final _connectionStreamController =
      StreamController<ConnectionStatus>.broadcast();
  final _typingStreamController =
      StreamController<Map<String, bool>>.broadcast();
  final _participantStreamController =
      StreamController<List<ChatParticipant>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  // Mock state
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String? _sessionId;
  String? _userId;
  String? _token;
  final List<ChatParticipant> _participants = [];
  final Map<String, bool> _typingStatus = {};

  // AI response delay simulation
  final Duration _aiResponseDelay = const Duration(milliseconds: 1500);

  // Mock data
  final List<String> _aiResponses = [
    "I understand how you're feeling. Anxiety can be challenging to manage. Let's explore some techniques that might help you cope with these feelings.",
    "That's a great question. When we talk about stress management, it's important to consider both short-term relief and long-term strategies.",
    "I hear you. Sleep issues can significantly impact your mental health. Let's discuss some evidence-based approaches to improve your sleep quality.",
    "Thank you for sharing that with me. It takes courage to talk about these feelings. Let's work together to understand what might be triggering them.",
    "That's an interesting perspective. Could you tell me more about how these thoughts affect your daily activities?",
    "It sounds like you've been going through a lot lately. Remember that it's okay to take things one step at a time.",
    "I notice you've mentioned this concern several times. It seems like this is really important to you. Let's explore it further.",
    "Mindfulness can be a powerful tool for managing those feelings. Would you like to try a brief mindfulness exercise together?",
    "That's excellent progress! It's important to acknowledge these positive steps, no matter how small they might seem.",
    "I'm wondering if we could explore how your relationships might be influencing these feelings. Would that be okay?",
  ];

  // Constructor
  MockWebSocketService() {
    // Simulate connected status after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateConnectionStatus(ConnectionStatus.connected);
    });
  }

  // Getters for streams
  @override
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  @override
  Stream<ConnectionStatus> get connectionStream =>
      _connectionStreamController.stream;

  @override
  Stream<Map<String, bool>> get typingStream => _typingStreamController.stream;

  @override
  Stream<List<ChatParticipant>> get participantStream =>
      _participantStreamController.stream;

  @override
  Stream<String> get errorStream => _errorStreamController.stream;

  @override
  ConnectionStatus get connectionStatus => _connectionStatus;

  // Methods
  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _updateConnectionStatus(ConnectionStatus.connected);
    debugPrint('MockWebSocketService: Connected');
  }

  @override
  Future<void> disconnect() async {
    _updateConnectionStatus(ConnectionStatus.disconnected);
    debugPrint('MockWebSocketService: Disconnected');
  }

  @override
  Future<void> reconnect() async {
    if (_userId == null || _token == null) {
      _errorStreamController.add('Cannot reconnect without userId and token');
      return;
    }

    _updateConnectionStatus(ConnectionStatus.connecting);

    // Simulate reconnection delay
    await Future.delayed(const Duration(seconds: 1));

    _updateConnectionStatus(ConnectionStatus.connected);
    debugPrint('MockWebSocketService: Reconnected');

    // Rejoin session if there was one
    if (_sessionId != null) {
      joinSession(_sessionId!);
    }
  }

  @override
  Future<void> sendMessage(String message, {String? sessionId}) async {
    if (_connectionStatus != ConnectionStatus.connected) {
      _errorStreamController.add('Cannot send message while disconnected');
      return;
    }

    final currentSessionId = sessionId ?? _sessionId;
    if (currentSessionId == null) {
      _errorStreamController.add('Cannot send message without a session');
      return;
    }

    if (_userId == null) {
      _errorStreamController.add('Cannot send message without a user ID');
      return;
    }

    // Create user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: _userId!,
      content: message,
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: currentSessionId,
    );

    // Add user message to stream
    _messageStreamController.add(userMessage);

    // Simulate AI typing
    _simulateAiTyping();

    // Simulate AI response after delay
    _simulateAiResponse(currentSessionId);
  }

  @override
  Future<String> createSession(
      {String? topic, int durationMinutes = 30}) async {
    if (_connectionStatus != ConnectionStatus.connected) {
      _errorStreamController.add('Cannot create session while disconnected');
      return '';
    }

    if (_userId == null) {
      _errorStreamController.add('Cannot create session without a user ID');
      return '';
    }

    // Generate session ID
    final sessionId = 'mock-session-${const Uuid().v4().substring(0, 8)}';
    _sessionId = sessionId;

    // Add user as participant
    final user = ChatParticipant(
      id: _userId!,
      name: 'You',
      isHost: true,
      isSpeaking: false,
    );

    // Add AI as participant
    final ai = ChatParticipant(
      id: 'ai-assistant',
      name: 'KounselMe AI',
      isHost: false,
      isSpeaking: false,
    );

    _participants.clear();
    _participants.addAll([user, ai]);
    _participantStreamController.add(_participants);

    // Add system message
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'system',
      content: 'Session started. Duration: $durationMinutes minutes.',
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: sessionId,
    );

    _messageStreamController.add(systemMessage);

    // Add welcome message from AI
    final welcomeMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'ai-assistant',
      content:
          'Hello! I\'m your KounselMe AI assistant. How can I help you today?',
      timestamp: DateTime.now().add(const Duration(seconds: 1)),
      isAI: true,
      sessionId: sessionId,
    );

    // Simulate AI typing
    _simulateAiTyping();

    // Add welcome message after delay
    Future.delayed(const Duration(seconds: 2), () {
      _messageStreamController.add(welcomeMessage);
      _updateAiSpeakingStatus(false);
    });

    debugPrint('MockWebSocketService: Created session $sessionId');
    return sessionId;
  }

  @override
  Future<void> joinSession(String sessionId) async {
    if (_connectionStatus != ConnectionStatus.connected) {
      _errorStreamController.add('Cannot join session while disconnected');
      return;
    }

    if (_userId == null) {
      _errorStreamController.add('Cannot join session without a user ID');
      return;
    }

    _sessionId = sessionId;

    // Add user as participant if not already present
    if (!_participants.any((p) => p.id == _userId)) {
      final user = ChatParticipant(
        id: _userId!,
        name: 'You',
        isHost: false,
        isSpeaking: false,
      );

      _participants.add(user);
    }

    // Make sure AI is a participant
    if (!_participants.any((p) => p.id == 'ai-assistant')) {
      final ai = ChatParticipant(
        id: 'ai-assistant',
        name: 'KounselMe AI',
        isHost: false,
        isSpeaking: false,
      );

      _participants.add(ai);
    }

    _participantStreamController.add(_participants);

    // Add system message
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'system',
      content: 'You joined the session.',
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: sessionId,
    );

    _messageStreamController.add(systemMessage);

    debugPrint('MockWebSocketService: Joined session $sessionId');
  }

  @override
  Future<void> leaveSession() async {
    if (_sessionId == null) {
      return;
    }

    final sessionId = _sessionId;
    _sessionId = null;

    // Remove user from participants
    _participants.removeWhere((p) => p.id == _userId);
    _participantStreamController.add(_participants);

    // Add system message
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'system',
      content: 'You left the session.',
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: sessionId,
    );

    _messageStreamController.add(systemMessage);

    debugPrint('MockWebSocketService: Left session $sessionId');
  }

  @override
  Future<void> endSession() async {
    if (_sessionId == null) {
      return;
    }

    final sessionId = _sessionId;
    _sessionId = null;

    // Add system message
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'system',
      content: 'Session ended.',
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: sessionId,
    );

    _messageStreamController.add(systemMessage);

    // Clear participants
    _participants.clear();
    _participantStreamController.add(_participants);

    debugPrint('MockWebSocketService: Ended session $sessionId');
  }

  @override
  void inviteUser(String email, {String? message}) {
    debugPrint('MockWebSocketService: Invited $email with message: $message');
  }

  @override
  Future<void> removeUser(String userId) async {
    if (_sessionId == null) {
      _errorStreamController.add('Cannot remove user without a session');
      return;
    }

    // Remove user from participants
    _participants.removeWhere((p) => p.id == userId);
    _participantStreamController.add(_participants);

    // Add system message
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'system',
      content: 'User removed from session.',
      timestamp: DateTime.now(),
      isAI: false,
      sessionId: _sessionId,
    );

    _messageStreamController.add(systemMessage);

    debugPrint(
        'MockWebSocketService: Removed user $userId from session $_sessionId');
  }

  @override
  Future<void> updateTypingStatus(bool isTyping) async {
    if (_sessionId == null || _userId == null) {
      return;
    }

    _typingStatus[_userId!] = isTyping;
    _typingStreamController.add(_typingStatus);
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _connectionStreamController.close();
    _typingStreamController.close();
    _participantStreamController.close();
    _errorStreamController.close();
  }

  // Helper methods
  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _connectionStreamController.add(status);
  }

  void _simulateAiTyping() {
    // Update AI typing status
    _updateAiSpeakingStatus(true);

    // Update typing status
    _typingStatus['ai-assistant'] = true;
    _typingStreamController.add(_typingStatus);
  }

  void _updateAiSpeakingStatus(bool isSpeaking) {
    // Update AI speaking status in participants
    final aiIndex = _participants.indexWhere((p) => p.id == 'ai-assistant');
    if (aiIndex >= 0) {
      final ai = _participants[aiIndex];
      _participants[aiIndex] = ChatParticipant(
        id: ai.id,
        name: ai.name,
        isHost: ai.isHost,
        isSpeaking: isSpeaking,
      );
      _participantStreamController.add(_participants);
    }
  }

  void _simulateAiResponse(String sessionId) {
    // Get random AI response
    final random = DateTime.now().millisecondsSinceEpoch % _aiResponses.length;
    final responseText = _aiResponses[random];

    // Create AI message
    final aiMessage = ChatMessage(
      id: const Uuid().v4(),
      userId: 'ai-assistant',
      content: responseText,
      timestamp: DateTime.now().add(_aiResponseDelay),
      isAI: true,
      sessionId: sessionId,
    );

    // Add AI message after delay
    Future.delayed(_aiResponseDelay, () {
      // Stop AI typing
      _typingStatus['ai-assistant'] = false;
      _typingStreamController.add(_typingStatus);

      // Add message
      _messageStreamController.add(aiMessage);

      // Update AI speaking status
      _updateAiSpeakingStatus(false);
    });
  }
}
