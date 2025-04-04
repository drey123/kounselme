// lib/data/models/chat_message.dart
import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String sessionId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isSynced;

  ChatMessage({
    String? id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isSynced = false,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? map['local_id'],
      sessionId: map['session_id'],
      content: map['message'] ?? map['content'],
      isUser: map['is_user'] == 1 || map['is_user'] == true,
      timestamp: map['timestamp'] is DateTime 
          ? map['timestamp'] 
          : DateTime.parse(map['timestamp']),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': id,
      'session_id': sessionId,
      'message': content,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isSynced,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
