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
  })  : id = id ?? const Uuid().v4(),
        avatarColor = avatarColor ?? Colors.blue;

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
    );
  }
}
