// lib/domain/models/chat_history_item.dart
import 'package:uuid/uuid.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final String previewMessage;
  final DateTime timestamp;
  final Duration? duration;
  final bool isActive;
  final int? messageCount;
  final String? sessionType;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.previewMessage,
    required this.timestamp,
    this.duration,
    this.isActive = false,
    this.messageCount,
    this.sessionType,
  });

  factory ChatHistoryItem.fromMap(Map<String, dynamic> map) {
    return ChatHistoryItem(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? 'Chat Session',
      previewMessage: map['preview_message'] ?? map['previewMessage'] ?? '',
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp']),
      duration: map['duration'] != null
          ? Duration(minutes: map['duration'])
          : null,
      isActive: map['is_active'] == true || map['isActive'] == true,
      messageCount: map['message_count'] ?? map['messageCount'],
      sessionType: map['session_type'] ?? map['sessionType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'preview_message': previewMessage,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration?.inMinutes,
      'is_active': isActive,
      'message_count': messageCount,
      'session_type': sessionType,
    };
  }

  ChatHistoryItem copyWith({
    String? id,
    String? title,
    String? previewMessage,
    DateTime? timestamp,
    Duration? duration,
    bool? isActive,
    int? messageCount,
    String? sessionType,
  }) {
    return ChatHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      previewMessage: previewMessage ?? this.previewMessage,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      messageCount: messageCount ?? this.messageCount,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}
