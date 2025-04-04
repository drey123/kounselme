// lib/domain/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/data/models/chat_message.dart';
import 'package:kounselme/data/remote/session_service.dart';
import 'package:kounselme/data/remote/websocket_service.dart';
import 'package:kounselme/domain/models/chat_participant.dart';
import 'package:uuid/uuid.dart';

// Chat state class
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String sessionId;
  final List<ChatParticipant> participants;
  final bool isConnected;
  final bool isSessionActive;
  final bool isMultiUser;
  final DateTime? sessionStartTime;
  final Duration sessionDuration;
  
  // Time management
  final Duration timeUsedThisSession;
  final Duration monthlyTimeRemaining;
  final Duration personalTimeLimit;
  final bool isPersonalTimeLimitSet;
  final bool isPaused;
  final DateTime? lastActivityTime;
  final bool isThinking; // Advanced thinking indicator

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
    String? sessionId,
    this.participants = const [],
    this.isConnected = false,
    this.isSessionActive = false,
    this.isMultiUser = false,
    this.sessionStartTime,
    this.sessionDuration = const Duration(minutes: 30),
    this.timeUsedThisSession = Duration.zero,
    this.monthlyTimeRemaining = const Duration(hours: 1), // Default free plan
    this.personalTimeLimit = const Duration(minutes: 30),
    this.isPersonalTimeLimitSet = false,
    this.isPaused = false,
    this.lastActivityTime,
    this.isThinking = false,
  }) : sessionId = sessionId ?? const Uuid().v4();

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? sessionId,
    List<ChatParticipant>? participants,
    bool? isConnected,
    bool? isSessionActive,
    bool? isMultiUser,
    DateTime? sessionStartTime,
    Duration? sessionDuration,
    Duration? timeUsedThisSession,
    Duration? monthlyTimeRemaining,
    Duration? personalTimeLimit,
    bool? isPersonalTimeLimitSet,
    bool? isPaused,
    DateTime? lastActivityTime,
    bool? isThinking,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      participants: participants ?? this.participants,
      isConnected: isConnected ?? this.isConnected,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isMultiUser: isMultiUser ?? this.isMultiUser,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      timeUsedThisSession: timeUsedThisSession ?? this.timeUsedThisSession,
      monthlyTimeRemaining: monthlyTimeRemaining ?? this.monthlyTimeRemaining,
      personalTimeLimit: personalTimeLimit ?? this.personalTimeLimit,
      isPersonalTimeLimitSet: isPersonalTimeLimitSet ?? this.isPersonalTimeLimitSet,
      isPaused: isPaused ?? this.isPaused,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final WebSocketService _webSocketService;
  final SessionService _sessionService;
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _statusSubscription;
  
  // Time tracking
  Timer? _timeTrackingTimer;
  Timer? _inactivityTimer;
  DateTime? _sessionStartTimestamp;
  
  // User information
  String? _userId;
  String? _token;
  
  ChatNotifier({
    required WebSocketService webSocketService,
    required SessionService sessionService,
  }) : 
    _webSocketService = webSocketService,
    _sessionService = sessionService,
    super(ChatState(messages: [])) {
    _listenToWebSocketMessages();
    _listenToConnectionStatus();
  }
  
  // Initialize with user information
  void initialize(String userId, String token) {
    _userId = userId;
    _token = token;
  }
  
  // Connect to WebSocket
  Future<void> connect() async {
    if (_userId == null || _token == null) {
      state = state.copyWith(
        error: 'User ID and token are required for connection'
      );
      return;
    }
    
    try {
      await _webSocketService.connect(
        userId: _userId!,
        authToken: _token!,
        sessionId: state.isSessionActive ? state.sessionId : null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to connect to chat service: ${e.toString()}'
      );
    }
  }
  
  // Listen to WebSocket messages
  void _listenToWebSocketMessages() {
    _webSocketSubscription?.cancel();
    _webSocketSubscription = _webSocketService.messageStream.listen((message) {
      _handleWebSocketMessage(message);
    });
  }
  
  // Listen to connection status changes
  void _listenToConnectionStatus() {
    _statusSubscription?.cancel();
    _statusSubscription = _webSocketService.statusStream.listen((status) {
      state = state.copyWith(
        isConnected: status == ConnectionStatus.connected
      );
      
      // Show error if reconnecting
      if (status == ConnectionStatus.reconnecting) {
        state = state.copyWith(
          error: 'Reconnecting to chat service...'
        );
      }
    });
  }
  
  // Handle WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    
    switch (type) {
      case 'auth_success':
        debugPrint('Authentication successful');
        state = state.copyWith(error: null);
        break;
        
      case 'session_joined':
        _handleSessionJoined(message);
        break;
        
      case 'participant_joined':
        _handleParticipantJoined(message);
        break;
        
      case 'participant_left':
        _handleParticipantLeft(message);
        break;
        
      case 'new_message':
        _handleNewMessage(message);
        break;
        
      case 'typing':
        _handleTypingIndicator(message);
        break;
        
      case 'error':
        state = state.copyWith(
          error: message['message'] as String? ?? 'Unknown error'
        );
        break;
        
      default:
        debugPrint('Unknown message type: $type');
    }
  }
  
  // Handle session_joined event
  void _handleSessionJoined(Map<String, dynamic> message) {
    final sessionId = message['sessionId'] as String;
    final duration = message['duration'] as int? ?? 30;
    final isMultiUser = message['isMultiUser'] as bool? ?? false;
    final participantsData = message['participants'] as List<dynamic>? ?? [];
    
    // Convert participants data to ChatParticipant objects
    final participants = participantsData.map((p) {
      return ChatParticipant(
        id: p['userId'] as String,
        name: p['name'] as String? ?? p['userId'] as String,
        isHost: p['isHost'] as bool? ?? false,
        isOnline: true,
      );
    }).toList();
    
    // Convert messages data to ChatMessage objects
    final messagesData = message['messages'] as List<dynamic>? ?? [];
    final messages = messagesData.map((m) {
      return ChatMessage(
        id: m['id'] as String,
        sessionId: sessionId,
        content: m['content'] as String,
        isUser: m['userId'] != 'ai',
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
    }).toList();
    
    state = state.copyWith(
      sessionId: sessionId,
      isSessionActive: true,
      sessionStartTime: DateTime.now(),
      sessionDuration: Duration(minutes: duration),
      isMultiUser: isMultiUser,
      participants: participants,
      messages: messages,
      error: null,
    );
    
    debugPrint('Joined session: $sessionId');
  }
  
  // Handle participant_joined event
  void _handleParticipantJoined(Map<String, dynamic> message) {
    final participantData = message['participant'] as Map<String, dynamic>;
    
    final participant = ChatParticipant(
      id: participantData['userId'] as String,
      name: participantData['name'] as String? ?? participantData['userId'] as String,
      isHost: participantData['isHost'] as bool? ?? false,
      isOnline: true,
    );
    
    // Add participant if not already in the list
    if (!state.participants.any((p) => p.id == participant.id)) {
      state = state.copyWith(
        participants: [...state.participants, participant],
      );
      
      // Add system message
      final systemMessage = ChatMessage(
        sessionId: state.sessionId,
        content: '${participant.name} joined the session',
        isUser: false,
      );
      
      state = state.copyWith(
        messages: [...state.messages, systemMessage],
      );
    }
  }
  
  // Handle participant_left event
  void _handleParticipantLeft(Map<String, dynamic> message) {
    final userId = message['userId'] as String;
    
    // Find participant
    final participant = state.participants.firstWhere(
      (p) => p.id == userId,
      orElse: () => ChatParticipant(id: userId, name: 'Unknown'),
    );
    
    // Remove participant
    state = state.copyWith(
      participants: state.participants.where((p) => p.id != userId).toList(),
    );
    
    // Add system message
    final systemMessage = ChatMessage(
      sessionId: state.sessionId,
      content: '${participant.name} left the session',
      isUser: false,
    );
    
    state = state.copyWith(
      messages: [...state.messages, systemMessage],
    );
  }
  
  // Handle new_message event
  void _handleNewMessage(Map<String, dynamic> message) {
    final messageData = message['message'] as Map<String, dynamic>;
    
    final chatMessage = ChatMessage(
      id: messageData['id'] as String,
      sessionId: state.sessionId,
      content: messageData['content'] as String,
      isUser: messageData['userId'] != 'ai',
      timestamp: DateTime.parse(messageData['timestamp'] as String),
    );
    
    state = state.copyWith(
      messages: [...state.messages, chatMessage],
      isLoading: false,
    );
  }
  
  // Handle typing indicator
  void _handleTypingIndicator(Map<String, dynamic> message) {
    final userId = message['userId'] as String;
    final isTyping = message['isTyping'] as bool;
    
    // Find participant
    final participantIndex = state.participants.indexWhere((p) => p.id == userId);
    
    if (participantIndex >= 0) {
      // Create new participants list
      final newParticipants = [...state.participants];
      
      // Update participant
      newParticipants[participantIndex] = newParticipants[participantIndex].copyWith(
        isSpeaking: isTyping,
      );
      
      state = state.copyWith(
        participants: newParticipants,
      );
    }
    
    // If AI is typing, update isLoading
    if (userId == 'ai') {
      state = state.copyWith(isLoading: isTyping);
    }
  }
  
  // Start a new session
  Future<void> startSession({
    required int durationMinutes,
    String? title,
    bool isMultiUser = false,
    Duration? personalTimeLimit,
  }) async {
    if (_userId == null || _token == null) {
      state = state.copyWith(
        error: 'User ID and token are required to start a session'
      );
      return;
    }
    
    try {
      // Create session via API
      final response = await _sessionService.createSession(
        userId: _userId!,
        token: _token!,
        duration: durationMinutes,
        isMultiUser: isMultiUser,
        title: title,
      );
      
      final sessionData = response['session'] as Map<String, dynamic>;
      final sessionId = sessionData['id'] as String;
      
      // First, check if user has enough monthly time
      final userTimeResponse = await _sessionService.checkSessionAvailability(
        userId: _userId!,
        token: _token!,
      );
      
      final monthlyTimeRemainingMinutes = 
          userTimeResponse['remainingTimeMinutes'] as int? ?? 60; // Default to 1hr
      
      // Set session info in state
      state = state.copyWith(
        sessionId: sessionId,
        sessionDuration: Duration(minutes: durationMinutes),
        isMultiUser: isMultiUser,
        sessionStartTime: DateTime.now(),
        isSessionActive: true,
        personalTimeLimit: personalTimeLimit ?? Duration(minutes: durationMinutes),
        isPersonalTimeLimitSet: personalTimeLimit != null,
        monthlyTimeRemaining: Duration(minutes: monthlyTimeRemainingMinutes),
        timeUsedThisSession: Duration.zero,
        isPaused: false,
        lastActivityTime: DateTime.now(),
      );
      
      // Connect to WebSocket if not already connected
      if (!state.isConnected) {
        await connect();
      }
      
      // Join session via WebSocket
      _webSocketService.joinSession(
        sessionId,
        isHost: true,
        duration: durationMinutes,
        isMultiUser: isMultiUser,
      );
      
      // Start time tracking
      _startTimeTracking();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to start session: ${e.toString()}'
      );
    }
  }
  
  // End the current session
  Future<void> endSession() async {
    if (_userId == null || _token == null || !state.isSessionActive) {
      return;
    }
    
    try {
      // Stop time tracking first
      _cancelTimeTrackingTimer();
      _inactivityTimer?.cancel();
      
      // Calculate final time used
      final timeUsed = state.timeUsedThisSession;
      
      // End session via API with time tracking info
      await _sessionService.endSession(
        sessionId: state.sessionId,
        userId: _userId!,
        token: _token!,
        timeUsedMinutes: timeUsed.inMinutes,
      );
      
      // Leave session via WebSocket
      _webSocketService.leaveSession();
      
      // Clear session info in state but retain time used for display
      state = state.copyWith(
        isSessionActive: false,
        isPaused: true,
        sessionStartTime: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to end session: ${e.toString()}'
      );
    }
  }
  
  // Set a personal time limit for the current session
  void setPersonalTimeLimit(Duration limit) {
    if (state.isSessionActive) {
      state = state.copyWith(
        personalTimeLimit: limit,
        isPersonalTimeLimitSet: true,
      );
    }
  }
  
  // Manually pause the session (user initiated)
  void pauseSession() {
    if (state.isSessionActive && !state.isPaused) {
      _pauseTimeTracking();
      state = state.copyWith(
        error: 'Session paused. Timer stopped.'
      );
    }
  }
  
  // Manually resume the session (user initiated)
  void resumeSession() {
    if (state.isSessionActive && state.isPaused) {
      _resumeTimeTracking();
      state = state.copyWith(
        error: null
      );
    }
  }
  
  // Join an existing session
  void joinSession(String sessionId) {
    if (!state.isConnected) {
      connect().then((_) {
        _webSocketService.joinSession(sessionId);
      });
    } else {
      _webSocketService.joinSession(sessionId);
    }
  }
  
  // Add a user message
  void addUserMessage(String content) {
    if (!state.isSessionActive) {
      state = state.copyWith(
        error: 'No active session'
      );
      return;
    }
    
    // Set loading state immediately for better UX
    state = state.copyWith(isLoading: true);
    
    // Record activity and manage timers
    _recordUserActivity();
    
    // Send message via WebSocket
    _webSocketService.sendMessage(content);
  }
  
  // Record user activity and reset inactivity timer
  void _recordUserActivity() {
    // Resume time tracking if paused
    if (state.isPaused) {
      _resumeTimeTracking();
    }
    
    // Reset inactivity timer
    state = state.copyWith(lastActivityTime: DateTime.now());
    _resetInactivityTimer();
  }
  
  // Start time tracking
  void _startTimeTracking() {
    _cancelTimeTrackingTimer();
    _sessionStartTimestamp = DateTime.now();
    
    // Start a timer that updates the time used every second
    _timeTrackingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPaused && state.isSessionActive) {
        final now = DateTime.now();
        final timeUsed = now.difference(_sessionStartTimestamp!);
        
        // Update time used and remaining
        state = state.copyWith(
          timeUsedThisSession: timeUsed,
          monthlyTimeRemaining: _calculateRemainingTime(timeUsed),
        );
        
        // Check if personal time limit reached
        if (state.isPersonalTimeLimitSet && 
            timeUsed >= state.personalTimeLimit) {
          _handlePersonalTimeLimitReached();
        }
        
        // Check if approaching monthly limit
        if (state.monthlyTimeRemaining.inMinutes <= 5 && 
            state.monthlyTimeRemaining.inMinutes > 0) {
          _handleApproachingMonthlyLimit();
        }
        
        // Check if monthly limit reached
        if (state.monthlyTimeRemaining <= Duration.zero) {
          _handleMonthlyLimitReached();
        }
      }
    });
    
    // Start inactivity detection
    _resetInactivityTimer();
  }
  
  // Calculate remaining monthly time
  Duration _calculateRemainingTime(Duration timeUsed) {
    final initialRemaining = state.monthlyTimeRemaining;
    final remaining = initialRemaining - const Duration(seconds: 1);
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  // Reset inactivity timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 60), () {
      // Auto-pause after 1 minute of inactivity
      if (!state.isPaused && state.isSessionActive) {
        _pauseTimeTracking();
      }
    });
  }
  
  // Pause time tracking
  void _pauseTimeTracking() {
    if (!state.isPaused) {
      state = state.copyWith(isPaused: true);
      _cancelTimeTrackingTimer();
    }
  }
  
  // Resume time tracking
  void _resumeTimeTracking() {
    if (state.isPaused) {
      _sessionStartTimestamp = DateTime.now().subtract(state.timeUsedThisSession);
      state = state.copyWith(isPaused: false);
      _startTimeTracking();
    }
  }
  
  // Handle personal time limit reached
  void _handlePersonalTimeLimitReached() {
    // Notify user but don't automatically end the session
    state = state.copyWith(
      error: 'Your personal time limit has been reached'
    );
  }
  
  // Handle approaching monthly limit
  void _handleApproachingMonthlyLimit() {
    // Notify user that they're approaching their monthly limit
    state = state.copyWith(
      error: 'You have ${state.monthlyTimeRemaining.inMinutes} minutes remaining this month'
    );
  }
  
  // Handle monthly limit reached
  void _handleMonthlyLimitReached() {
    // Notify user that they've reached their monthly limit
    state = state.copyWith(
      error: 'You have reached your monthly time limit'
    );
    
    // Let AI complete current response but prevent new messages
    // This will be handled in the UI layer
  }
  
  // Cancel time tracking timer
  void _cancelTimeTrackingTimer() {
    _timeTrackingTimer?.cancel();
    _timeTrackingTimer = null;
  }
  
  // Send typing indicator
  void setTyping(bool isTyping) {
    if (state.isSessionActive) {
      _webSocketService.sendTypingIndicator(isTyping);
    }
  }
  
  // Clear all messages (for local testing)
  void clearChat() {
    state = state.copyWith(messages: []);
  }
  
  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _statusSubscription?.cancel();
    _timeTrackingTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

// Providers
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    webSocketService: ref.watch(webSocketServiceProvider),
    sessionService: ref.watch(sessionServiceProvider),
  );
});