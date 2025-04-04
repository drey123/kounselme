// lib/data/remote/session_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kounselme/config/env.dart';
import 'package:kounselme/data/models/scheduled_chat.dart';
import 'package:uuid/uuid.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();
  
  // API base URL
  final String _baseUrl = '${Env.backendUrl}/api/v1';
  
  // HTTP client
  final http.Client _client = http.Client();
  
  // UUID generator
  final _uuid = const Uuid();
  
  // Headers
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Create a new session
  Future<Map<String, dynamic>> createSession({
    required String userId,
    required String token,
    int? duration,
    bool? isMultiUser,
    String? title,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/sessions'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'userId': userId,
          'duration': duration,
          'isMultiUser': isMultiUser,
          'title': title,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error creating session: $e');
      rethrow;
    }
  }
  
  // Get session details
  Future<Map<String, dynamic>> getSession({
    required String sessionId,
    required String token,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/sessions/$sessionId'),
        headers: _getHeaders(token),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error getting session: $e');
      rethrow;
    }
  }
  
  // End a session
  Future<Map<String, dynamic>> endSession({
    required String sessionId,
    required String userId,
    required String token,
    int? timeUsedMinutes,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/sessions/$sessionId/end'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'userId': userId,
          'timeUsedMinutes': timeUsedMinutes,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error ending session: $e');
      rethrow;
    }
  }
  
  // Get user's recent sessions
  Future<Map<String, dynamic>> getUserSessions({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/users/$userId/sessions'),
        headers: _getHeaders(token),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error getting user sessions: $e');
      rethrow;
    }
  }
  
  // Check session availability
  Future<Map<String, dynamic>> checkSessionAvailability({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/users/$userId/session-availability'),
        headers: _getHeaders(token),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error checking session availability: $e');
      rethrow;
    }
  }
  
  // Schedule a chat for later
  Future<ScheduledChat> scheduleChat({
    required String userId,
    required String token,
    required DateTime scheduledTime,
    String? title,
    bool addToCalendar = false,
  }) async {
    try {
      // In a real implementation, this would call the backend API
      // For now, we'll simulate a successful response
      await Future.delayed(const Duration(milliseconds: 300));
      
      final scheduledChat = ScheduledChat(
        id: _uuid.v4(),
        scheduledTime: scheduledTime,
        title: title,
        hasCalendarEvent: addToCalendar,
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      return scheduledChat;
    } catch (e) {
      debugPrint('Error scheduling chat: $e');
      rethrow;
    }
  }
  
  // Get user's scheduled chats
  Future<List<ScheduledChat>> getScheduledChats({
    required String userId,
    required String token,
  }) async {
    try {
      // In a real implementation, this would call the backend API
      // For now, we'll simulate a successful response with some scheduled chats
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Create some sample scheduled chats
      final now = DateTime.now();
      
      return [
        ScheduledChat(
          id: _uuid.v4(),
          scheduledTime: now.add(const Duration(days: 1, hours: 2)),
          title: 'Anxiety Discussion',
          hasCalendarEvent: true,
          userId: userId,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ScheduledChat(
          id: _uuid.v4(),
          scheduledTime: now.add(const Duration(days: 3, hours: 5)),
          title: 'Weekly Check-in',
          hasCalendarEvent: false,
          userId: userId,
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
      ];
    } catch (e) {
      debugPrint('Error getting scheduled chats: $e');
      rethrow;
    }
  }
  
  // Cancel a scheduled chat
  Future<bool> cancelScheduledChat({
    required String chatId,
    required String userId,
    required String token,
  }) async {
    try {
      // In a real implementation, this would call the backend API
      // For now, we'll simulate a successful response
      await Future.delayed(const Duration(milliseconds: 300));
      
      return true;
    } catch (e) {
      debugPrint('Error canceling scheduled chat: $e');
      rethrow;
    }
  }
  
  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] as String? ?? 'Unknown error';
      throw Exception(message);
    }
  }
  
  // Dispose resources
  void dispose() {
    _client.close();
  }
}