// lib/domain/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/data/remote/session_service.dart';
import 'package:kounselme/data/services/websocket_service.dart';
import 'package:kounselme/data/service_factory.dart';
import 'package:kounselme/domain/models/chat_message.dart';
import 'package:kounselme/domain/models/chat_participant.dart';

// Chat state provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    SessionService(),
    ServiceFactory.createWebSocketService(),
  );
});

// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final List<ChatParticipant> participants;
  final bool isLoading;
  final bool isConnected;
  final bool isConnecting;
  final bool connectionError;
  final String? error;
  final String? sessionId;
  final bool isSessionActive;
  final bool isPaused;
  final bool isMultiUser;
  final DateTime? sessionStartTime;
  final Duration sessionDuration;
  final Duration timeUsedThisSession;
  final Duration monthlyTimeRemaining;
  final Duration personalTimeLimit;
  final bool isPersonalTimeLimitSet;
  final DateTime? lastActivityTime;
  final Map<String, bool> typingUsers;

  ChatState({
    this.messages = const [],
    this.participants = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isConnecting = false,
    this.connectionError = false,
    this.error,
    this.sessionId,
    this.isSessionActive = false,
    this.isPaused = false,
    this.isMultiUser = false,
    this.sessionStartTime,
    this.sessionDuration = const Duration(minutes: 60),
    this.timeUsedThisSession = Duration.zero,
    this.monthlyTimeRemaining = const Duration(minutes: 60),
    this.personalTimeLimit = const Duration(minutes: 60),
    this.isPersonalTimeLimitSet = false,
    this.lastActivityTime,
    this.typingUsers = const {},
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatParticipant>? participants,
    bool? isLoading,
    bool? isConnected,
    bool? isConnecting,
    bool? connectionError,
    String? error,
    String? sessionId,
    bool? isSessionActive,
    bool? isPaused,
    bool? isMultiUser,
    DateTime? sessionStartTime,
    Duration? sessionDuration,
    Duration? timeUsedThisSession,
    Duration? monthlyTimeRemaining,
    Duration? personalTimeLimit,
    bool? isPersonalTimeLimitSet,
    DateTime? lastActivityTime,
    Map<String, bool>? typingUsers,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      connectionError: connectionError ?? this.connectionError,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isPaused: isPaused ?? this.isPaused,
      isMultiUser: isMultiUser ?? this.isMultiUser,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      timeUsedThisSession: timeUsedThisSession ?? this.timeUsedThisSession,
      monthlyTimeRemaining: monthlyTimeRemaining ?? this.monthlyTimeRemaining,
      personalTimeLimit: personalTimeLimit ?? this.personalTimeLimit,
      isPersonalTimeLimitSet: isPersonalTimeLimitSet ?? this.isPersonalTimeLimitSet,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }

  // Helper methods
  bool get isNearMonthlyLimit {
    final percentRemaining = monthlyTimeRemaining.inSeconds / (30 * 60 * 60) * 100;
    return percentRemaining <= 25;
  }

  bool get isNearPersonalLimit {
    if (!isPersonalTimeLimitSet) return false;
    final percentRemaining = (personalTimeLimit.inSeconds - timeUsedThisSession.inSeconds) / personalTimeLimit.inSeconds * 100;
    return percentRemaining <= 20;
  }

  Duration get timeRemaining {
    return isPersonalTimeLimitSet
        ? personalTimeLimit - timeUsedThisSession
        : monthlyTimeRemaining;
  }

  bool get hasReachedTimeLimit {
    return isPersonalTimeLimitSet
        ? timeUsedThisSession >= personalTimeLimit
        : timeUsedThisSession >= monthlyTimeRemaining;
  }

  bool get isUserTyping {
    return typingUsers.values.any((isTyping) => isTyping);
  }

  List<String> get typingUserIds {
    return typingUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  List<ChatParticipant> get typingParticipants {
    final typingIds = typingUserIds;
    return participants
        .where((p) => typingIds.contains(p.userId))
        .toList();
  }

  bool get shouldShowInactivityWarning {
    if (lastActivityTime == null || isPaused) return false;
    final inactivityDuration = DateTime.now().difference(lastActivityTime!);
    return inactivityDuration.inSeconds >= 45;
  }

  bool get shouldAutoPause {
    if (lastActivityTime == null || isPaused) return false;
    final inactivityDuration = DateTime.now().difference(lastActivityTime!);
    return inactivityDuration.inMinutes >= 1;
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SessionService _sessionService;
  final WebSocketService _webSocketService;
  
  // Subscriptions
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _participantSubscription;
  StreamSubscription? _errorSubscription;
  
  // Timers
  Timer? _timeTrackingTimer;
  Timer? _inactivityTimer;
  
  // User credentials
  String? _userId;
  String? _token;
  
  ChatNotifier(this._sessionService, this._webSocketService) : super(ChatState()) {
    _setupWebSocketListeners();
  }
  
  // Setup WebSocket listeners
  void _setupWebSocketListeners() {
    // Listen for WebSocket messages
    _webSocketSubscription = _webSocketService.messageStream.listen(_handleWebSocketMessage);
    
    // Listen for connection status changes
    _statusSubscription = _webSocketService.statusStream.listen(_handleConnectionStatusChange);
    
    // Listen for typing indicators
    _typingSubscription = _webSocketService.typingStream.listen(_handleTypingIndicator);
    
    // Listen for participant updates
    _participantSubscription = _webSocketService.participantStream.listen(_handleParticipantUpdate);
    
    // Listen for errors
    _errorSubscription = _webSocketService.errorStream.listen(_handleWebSocketError);
  }
  
  // Connect to WebSocket
  Future<bool> connect({String? userId, String? token}) async {
    if (state.isConnected) return true;
    
    // Store credentials
    _userId = userId ?? _userId;
    _token = token ?? _token;
    
    if (_userId == null || _token == null) {
      _handleApiError('User ID and token are required to connect', 'Connection');
      return false;
    }
    
    state = state.copyWith(
      isConnecting: true,
      error: null,
    );
    
    try {
      // Store credentials in the WebSocket service before connecting
      _webSocketService.setCredentials(
        userId: _userId!,
        authToken: _token!,
        sessionId: state.sessionId,
      );
      
      // Connect to WebSocket service
      await _webSocketService.connect();
      
      return true;
    } catch (e) {
      _handleApiError(e, 'Connection');
      return false;
    }
  }
  
  // Handle WebSocket message
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    
    switch (type) {
      case 'chat_message':
        _handleChatMessage(message);
        break;
      case 'session_joined':
        _handleSessionJoined(message);
        break;
      case 'session_ended':
        _handleSessionEnded(message);
        break;
      case 'error':
        _handleWebSocketError(message['message'] as String? ?? 'Unknown error');
        break;
    }
  }
  
  // Handle chat message
  void _handleChatMessage(Map<String, dynamic> message) {
    final userId = message['userId'] as String?;
    final content = message['content'] as String?;
    final timestamp = message['timestamp'] as String?;
    
    if (userId == null || content == null) return;
    
    final chatMessage = ChatMessage(
      id: message['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      timestamp: timestamp != null ? DateTime.parse(timestamp) : DateTime.now(),
      isAI: userId == 'ai_assistant',
      status: MessageStatus.delivered,
    );
    
    // Update state with new message
    state = state.copyWith(
      messages: [...state.messages, chatMessage],
      lastActivityTime: DateTime.now(),
    );
    
    // Reset typing indicator for this user
    _updateTypingIndicator(userId, false);
  }
  
  // Handle session joined
  void _handleSessionJoined(Map<String, dynamic> message) {
    final sessionId = message['sessionId'] as String?;
    
    if (sessionId == null) return;
    
    state = state.copyWith(
      sessionId: sessionId,
      isSessionActive: true,
      lastActivityTime: DateTime.now(),
    );
    
    // Start time tracking
    _startTimeTracking();
  }
  
  // Handle session ended
  void _handleSessionEnded(Map<String, dynamic> message) {
    _cancelTimeTrackingTimer();
    
    state = state.copyWith(
      isSessionActive: false,
      isPaused: false,
      error: 'Session has ended',
    );
  }
  
  // Handle connection status change
  void _handleConnectionStatusChange(ConnectionStatus status) {
    state = state.copyWith(
      isConnected: status == ConnectionStatus.connected,
      isConnecting: status == ConnectionStatus.connecting || 
                   status == ConnectionStatus.reconnecting,
      connectionError: status == ConnectionStatus.error,
    );
    
    // If reconnected after being disconnected, try to rejoin session
    if (status == ConnectionStatus.connected && 
        state.sessionId != null && 
        !state.isSessionActive) {
      _rejoinSession();
    }
  }
  
  // Handle typing indicator
  void _handleTypingIndicator(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final isTyping = data['isTyping'] as bool?;
    
    if (userId == null || isTyping == null) return;
    
    _updateTypingIndicator(userId, isTyping);
  }
  
  // Update typing indicator
  void _updateTypingIndicator(String userId, bool isTyping) {
    final updatedTypingUsers = Map<String, bool>.from(state.typingUsers);
    
    if (isTyping) {
      updatedTypingUsers[userId] = true;
    } else {
      updatedTypingUsers.remove(userId);
    }
    
    state = state.copyWith(typingUsers: updatedTypingUsers);
  }
  
  // Handle participant update
  void _handleParticipantUpdate(List<ChatParticipant> participants) {
    state = state.copyWith(participants: participants);
  }
  
  // Handle WebSocket error
  void _handleWebSocketError(String error) {
    _handleApiError(error, 'WebSocket');
  }
  
  // Handle API error
  void _handleApiError(dynamic error, String context) {
    final errorMessage = error is Exception 
        ? error.toString().replaceAll('Exception: ', '') 
        : error.toString();
        
    debugPrint('$context: $errorMessage');
    
    // Update state with the error
    state = state.copyWith(
      error: '$context: $errorMessage',
      isLoading: false, // Always ensure loading is reset on error
    );
    
    // Schedule error clearing after a few seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && state.error == '$context: $errorMessage') {
        state = state.copyWith(error: null);
      }
    });
  }
  
  // Rejoin session after reconnection
  Future<void> _rejoinSession() async {
    if (state.sessionId == null || _userId == null || _token == null) return;
    
    try {
      // Get session details from API
      final response = await _sessionService.getSession(
        sessionId: state.sessionId!,
        token: _token!,
      );
      
      final sessionData = response['session'] as Map<String, dynamic>;
      final isActive = sessionData['isActive'] as bool? ?? false;
      
      if (isActive) {
        // Update state with session info
        state = state.copyWith(
          isSessionActive: true,
          isPaused: false,
          lastActivityTime: DateTime.now(),
        );
        
        // Join session via WebSocket
        _webSocketService.joinSession(
          state.sessionId!,
          isHost: sessionData['hostId'] == _userId,
          isMultiUser: state.isMultiUser,
        );
        
        // Restart time tracking
        _startTimeTracking();
      } else {
        // Session is no longer active
        state = state.copyWith(
          isSessionActive: false,
          error: 'Session has ended',
        );
      }
    } catch (e) {
      _handleApiError(e, 'Rejoin Session');
    }
  }
  
  // Start session
  Future<void> startSession({
    required int durationMinutes,
    String? title,
    bool isMultiUser = false,
    Duration? personalTimeLimit,
  }) async {
    if (_userId == null || _token == null) {
      _handleApiError('User ID and token are required to start a session', 'Session Start');
      return;
    }
    
    // Set loading state immediately for better UX
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First, check if user has enough monthly time
      final userTimeResponse = await _sessionService.checkSessionAvailability(
        userId: _userId!,
        token: _token!,
      );
      
      final monthlyTimeRemainingMinutes = 
          userTimeResponse['remainingTimeMinutes'] as int? ?? 60;
          
      if (monthlyTimeRemainingMinutes < durationMinutes) {
        _handleApiError(
          'Not enough monthly time remaining. You have $monthlyTimeRemainingMinutes minutes left.',
          'Session Start'
        );
        return;
      }
      
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
        isLoading: false,
        error: null,
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
      _handleApiError(e, 'Session Start');
    }
  }
  
  // Join existing session
  Future<void> joinSession(String sessionId) async {
    if (_userId == null || _token == null) {
      _handleApiError('User ID and token are required to join a session', 'Session Join');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Get session details from API
      final response = await _sessionService.getSession(
        sessionId: sessionId,
        token: _token!,
      );
      
      final sessionData = response['session'] as Map<String, dynamic>;
      final isActive = sessionData['isActive'] as bool? ?? false;
      final durationMinutes = sessionData['durationMinutes'] as int? ?? 60;
      final isMultiUser = sessionData['isMultiUser'] as bool? ?? false;
      
      if (!isActive) {
        _handleApiError('Session is no longer active', 'Session Join');
        return;
      }
      
      // Set session info in state
      state = state.copyWith(
        sessionId: sessionId,
        sessionDuration: Duration(minutes: durationMinutes),
        isMultiUser: isMultiUser,
        isSessionActive: true,
        isPaused: false,
        lastActivityTime: DateTime.now(),
        isLoading: false,
        error: null,
      );
      
      // Connect to WebSocket if not already connected
      if (!state.isConnected) {
        await connect();
      }
      
      // Join session via WebSocket
      _webSocketService.joinSession(
        sessionId,
        isHost: false,
        isMultiUser: isMultiUser,
      );
      
    } catch (e) {
      _handleApiError(e, 'Session Join');
    }
  }
  
  // End session
  Future<void> endSession() async {
    if (state.sessionId == null || _token == null) return;
    
    try {
      await _sessionService.endSession(
        sessionId: state.sessionId!,
        token: _token!,
      );
      
      _cancelTimeTrackingTimer();
      
      state = state.copyWith(
        isSessionActive: false,
        isPaused: false,
      );
      
      // Leave session via WebSocket
      _webSocketService.leaveSession();
      
    } catch (e) {
      _handleApiError(e, 'End Session');
    }
  }
  
  // Send message
  void sendMessage(String content) {
    if (!state.isSessionActive || !state.isConnected) {
      _handleApiError('Cannot send message: Not connected or session not active', 'Send Message');
      return;
    }
    
    // Create local message
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId ?? 'user',
      content: content,
      timestamp: DateTime.now(),
      isAI: false,
      status: MessageStatus.sending,
    );
    
    // Add message to state
    state = state.copyWith(
      messages: [...state.messages, message],
      lastActivityTime: DateTime.now(),
    );
    
    // Send message via WebSocket
    _webSocketService.sendMessage(content);
    
    // Update typing indicator
    sendTypingIndicator(false);
  }
  
  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (!state.isSessionActive || !state.isConnected) return;
    
    _webSocketService.sendTypingIndicator(isTyping);
  }
  
  // Invite user to session
  void inviteUser(String email, {String? message}) {
    if (!state.isSessionActive || !state.isConnected) {
      _handleApiError('Cannot invite user: Not connected or session not active', 'Invite User');
      return;
    }
    
    _webSocketService.inviteUser(email, message: message);
  }
  
  // Remove user from session
  void removeUser(String userId) {
    if (!state.isSessionActive || !state.isConnected) {
      _handleApiError('Cannot remove user: Not connected or session not active', 'Remove User');
      return;
    }
    
    _webSocketService.removeUser(userId);
  }
  
  // Pause session
  void pauseSession() {
    if (!state.isSessionActive) return;
    
    state = state.copyWith(
      isPaused: true,
    );
    
    // Stop time tracking
    _cancelTimeTrackingTimer();
  }
  
  // Resume session
  void resumeSession() {
    if (!state.isSessionActive || !state.isPaused) return;
    
    state = state.copyWith(
      isPaused: false,
      lastActivityTime: DateTime.now(),
    );
    
    // Restart time tracking
    _startTimeTracking();
  }
  
  // Start time tracking
  void _startTimeTracking() {
    _cancelTimeTrackingTimer();
    
    // Create timer to update time used
    _timeTrackingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isSessionActive || state.isPaused) return;
      
      // Update time used
      state = state.copyWith(
        timeUsedThisSession: state.timeUsedThisSession + const Duration(seconds: 1),
      );
      
      // Check for inactivity
      if (state.shouldAutoPause) {
        pauseSession();
      }
    });
    
    // Create timer to check for inactivity
    _inactivityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!state.isSessionActive || state.isPaused) return;
      
      // Check if we should show inactivity warning
      if (state.shouldShowInactivityWarning) {
        // This will trigger UI to show warning
        state = state.copyWith(
          lastActivityTime: state.lastActivityTime,
        );
      }
    });
  }
  
  // Cancel time tracking timer
  void _cancelTimeTrackingTimer() {
    _timeTrackingTimer?.cancel();
    _timeTrackingTimer = null;
    
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }
  
  // Set user credentials
  void setCredentials(String userId, String token) {
    _userId = userId;
    _token = token;
  }
  
  // Clear chat history
  void clearChatHistory() {
    state = state.copyWith(
      messages: [],
    );
  }
  
  // Set personal time limit
  void setPersonalTimeLimit(Duration limit) {
    state = state.copyWith(
      personalTimeLimit: limit,
      isPersonalTimeLimitSet: true,
    );
  }
  
  // Clear personal time limit
  void clearPersonalTimeLimit() {
    state = state.copyWith(
      isPersonalTimeLimitSet: false,
    );
  }
  
  // Record user activity
  void recordActivity() {
    state = state.copyWith(
      lastActivityTime: DateTime.now(),
    );
  }
  
  // Ensure all resources are properly disposed
  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _statusSubscription?.cancel();
    _typingSubscription?.cancel();
    _participantSubscription?.cancel();
    _errorSubscription?.cancel();
    _cancelTimeTrackingTimer();
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
