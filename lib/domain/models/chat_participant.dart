// lib/domain/models/chat_participant.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final Color avatarColor;
  final bool isUser;
  final bool isSpeaking;
  final bool isTyping;
  final bool isOnline;
  final bool isHost;
  final String userId;

  ChatParticipant({
    String? id,
    required this.name,
    this.avatarUrl,
    Color? avatarColor,
    this.isUser = false,
    this.isSpeaking = false,
    this.isTyping = false,
    this.isOnline = true,
    this.isHost = false,
    String? userId,
  })  : id = id ?? const Uuid().v4(),
        avatarColor = avatarColor ?? Colors.blue,
        userId = userId ?? const Uuid().v4(); // Initialize userId with provided value or generate new

  ChatParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? avatarColor,
    bool? isUser,
    bool? isSpeaking,
    bool? isTyping,
    bool? isOnline,
    bool? isHost,
    String? userId,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
      isUser: isUser ?? this.isUser,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isTyping: isTyping ?? this.isTyping,
      isOnline: isOnline ?? this.isOnline,
      isHost: isHost ?? this.isHost,
      userId: userId ?? this.userId,
    );
  }
}
