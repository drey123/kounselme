// lib/domain/models/chat_message.dart
import 'package:uuid/uuid.dart';

enum MessageStatus {
  sending,
  delivered,
  failed,
}

class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final bool isAI;
  final MessageStatus status;
  final String? sessionId;

  ChatMessage({
    String? id,
    required this.userId,
    required this.content,
    DateTime? timestamp,
    this.isAI = false,
    this.status = MessageStatus.delivered,
    this.sessionId,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? map['local_id'],
      userId: map['user_id'] ?? map['userId'],
      content: map['message'] ?? map['content'],
      timestamp: map['timestamp'] is DateTime 
          ? map['timestamp'] 
          : DateTime.parse(map['timestamp']),
      isAI: map['is_ai'] == 1 || map['is_ai'] == true || map['isAI'] == true,
      status: _parseStatus(map['status']),
      sessionId: map['session_id'] ?? map['sessionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_ai': isAI ? 1 : 0,
      'status': status.toString().split('.').last,
      'session_id': sessionId,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? timestamp,
    bool? isAI,
    MessageStatus? status,
    String? sessionId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isAI: isAI ?? this.isAI,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
    );
  }
  
  static MessageStatus _parseStatus(dynamic status) {
    if (status == null) return MessageStatus.delivered;
    
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'sending':
          return MessageStatus.sending;
        case 'failed':
          return MessageStatus.failed;
        case 'delivered':
        default:
          return MessageStatus.delivered;
      }
    }
    
    if (status is int) {
      switch (status) {
        case 0:
          return MessageStatus.sending;
        case 2:
          return MessageStatus.failed;
        case 1:
        default:
          return MessageStatus.delivered;
      }
    }
    
    return MessageStatus.delivered;
  }
}
