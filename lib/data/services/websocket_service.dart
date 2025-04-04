import 'dart:async';
import 'package:kounselme/domain/models/chat_participant.dart';

// Enum to represent connection status
enum ConnectionStatus { connected, disconnected, connecting, error, reconnecting }

// Abstract class for WebSocketService
abstract class WebSocketService {
  Stream<ConnectionStatus> get connectionStream;
  ConnectionStatus get connectionStatus;
  
  // Stream getters
  Stream<Map<String, dynamic>> get messageStream;
  Stream<Map<String, bool>> get typingStream;
  Stream<List<ChatParticipant>> get participantStream;
  Stream<String> get errorStream;

  // Set credentials before connecting
  void setCredentials({
    required String userId,
    required String authToken,
    String? sessionId,
  });

  Future<void> connect();
  Future<void> disconnect();
  
  // Session management
  void joinSession(String sessionId, {bool isHost = false});
  void leaveSession();
  void endSession();
  
  // Messaging
  void sendMessage(String content);
  void sendTypingIndicator(bool isTyping);
  
  // User management
  void inviteUser(String email, {String? message});
  void removeUser(String userId);
}
