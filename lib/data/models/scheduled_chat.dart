// lib/data/models/scheduled_chat.dart

class ScheduledChat {
  final String id;
  final DateTime scheduledTime;
  final String? title;
  final bool hasCalendarEvent;
  final String userId;
  final DateTime createdAt;
  
  ScheduledChat({
    required this.id,
    required this.scheduledTime,
    this.title,
    this.hasCalendarEvent = false,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  ScheduledChat copyWith({
    String? id,
    DateTime? scheduledTime,
    String? title,
    bool? hasCalendarEvent,
    String? userId,
    DateTime? createdAt,
  }) {
    return ScheduledChat(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      title: title ?? this.title,
      hasCalendarEvent: hasCalendarEvent ?? this.hasCalendarEvent,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'title': title,
      'hasCalendarEvent': hasCalendarEvent,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory ScheduledChat.fromJson(Map<String, dynamic> json) {
    return ScheduledChat(
      id: json['id'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      title: json['title'] as String?,
      hasCalendarEvent: json['hasCalendarEvent'] as bool? ?? false,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ScheduledChat &&
           other.id == id &&
           other.scheduledTime == scheduledTime &&
           other.title == title &&
           other.hasCalendarEvent == hasCalendarEvent &&
           other.userId == userId &&
           other.createdAt == createdAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
           scheduledTime.hashCode ^
           title.hashCode ^
           hasCalendarEvent.hashCode ^
           userId.hashCode ^
           createdAt.hashCode;
  }
}