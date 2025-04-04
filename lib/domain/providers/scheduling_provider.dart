// lib/domain/providers/scheduling_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/data/models/scheduled_chat.dart';
import 'package:kounselme/data/remote/session_service.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class SchedulingState {
  final List<ScheduledChat> scheduledChats;
  final bool isLoading;
  final String? error;

  SchedulingState({
    this.scheduledChats = const [],
    this.isLoading = false,
    this.error,
  });

  SchedulingState copyWith({
    List<ScheduledChat>? scheduledChats,
    bool? isLoading,
    String? error,
  }) {
    return SchedulingState(
      scheduledChats: scheduledChats ?? this.scheduledChats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SchedulingNotifier extends StateNotifier<SchedulingState> {
  final SessionService _sessionService;
  final DeviceCalendarPlugin _deviceCalendarPlugin;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  SchedulingNotifier({
    required SessionService sessionService,
    required DeviceCalendarPlugin deviceCalendarPlugin,
    required FlutterLocalNotificationsPlugin notificationsPlugin,
  })  : _sessionService = sessionService,
        _deviceCalendarPlugin = deviceCalendarPlugin,
        _notificationsPlugin = notificationsPlugin,
        super(SchedulingState()) {
    // Initialize timezone
    tz_init.initializeTimeZones();
    _initializeNotifications();
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Load user's scheduled chats
  Future<void> loadScheduledChats({
    required String userId,
    required String token,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final scheduledChats = await _sessionService.getScheduledChats(
        userId: userId,
        token: token,
      );

      state = state.copyWith(
        scheduledChats: scheduledChats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load scheduled chats: ${e.toString()}',
      );
    }
  }

  // Schedule a new chat
  Future<ScheduledChat?> scheduleChat({
    required String userId,
    required String token,
    required DateTime scheduledTime,
    String? title,
    bool addToCalendar = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Schedule in backend
      final scheduledChat = await _sessionService.scheduleChat(
        userId: userId,
        token: token,
        scheduledTime: scheduledTime,
        title: title,
        addToCalendar: addToCalendar,
      );

      // Add to device calendar if requested
      if (addToCalendar) {
        await _addToDeviceCalendar(scheduledChat);
      }

      // Schedule local notification
      await _scheduleNotification(scheduledChat);

      // Update state
      state = state.copyWith(
        scheduledChats: [...state.scheduledChats, scheduledChat],
        isLoading: false,
      );

      return scheduledChat;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to schedule chat: ${e.toString()}',
      );
      return null;
    }
  }

  // Cancel a scheduled chat
  Future<bool> cancelScheduledChat({
    required String chatId,
    required String userId,
    required String token,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Verify the chat exists before cancelling
      state.scheduledChats.firstWhere(
        (c) => c.id == chatId,
        orElse: () => throw Exception('Chat not found'),
      );

      // Proceed with cancellation

      // Cancel in backend
      final success = await _sessionService.cancelScheduledChat(
        chatId: chatId,
        userId: userId,
        token: token,
      );

      if (success) {
        // Remove from state
        state = state.copyWith(
          scheduledChats:
              state.scheduledChats.where((c) => c.id != chatId).toList(),
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel scheduled chat: ${e.toString()}',
      );
      return false;
    }
  }

  // Add to device calendar
  Future<void> _addToDeviceCalendar(ScheduledChat chat) async {
    try {
      // Check calendar permission
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return;
        }
      }

      // Get available calendars
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data;

      if (calendars != null && calendars.isNotEmpty) {
        // Find default calendar (first calendar for simplicity)
        final defaultCalendar = calendars.first;

        // Create event
        final event = Event(
          defaultCalendar.id,
          title: chat.title ?? 'KounselMe Chat',
          description: 'Scheduled counseling session in KounselMe app',
          start: tz.TZDateTime.from(chat.scheduledTime, tz.local),
          end: tz.TZDateTime.from(
              chat.scheduledTime.add(const Duration(minutes: 30)), tz.local),
        );

        // Add reminder 15 minutes before
        event.reminders = [Reminder(minutes: 15)];

        // Create event
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
      }
    } catch (e) {
      debugPrint('Error adding to calendar: $e');
    }
  }

  // Schedule local notification
  Future<void> _scheduleNotification(ScheduledChat chat) async {
    try {
      // Skip scheduling notifications on Android due to compatibility issues
      // This is a temporary workaround until we can resolve the plugin issues
      if (Platform.isAndroid) {
        debugPrint(
            'Skipping notification scheduling on Android due to plugin compatibility issues');
        return;
      }

      final scheduledTime = tz.TZDateTime.from(
        chat.scheduledTime.subtract(const Duration(minutes: 5)),
        tz.local,
      );

      // Create notification details only for iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin.zonedSchedule(
        chat.id.hashCode, // ID based on chat ID
        'Upcoming Chat Session',
        'Your chat is scheduled to start in 5 minutes',
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}

// Provider for device calendar
final deviceCalendarProvider = Provider<DeviceCalendarPlugin>((ref) {
  return DeviceCalendarPlugin();
});

// Provider for local notifications
final notificationsProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

// Provider for scheduling service
final schedulingProvider =
    StateNotifierProvider<SchedulingNotifier, SchedulingState>((ref) {
  return SchedulingNotifier(
    sessionService: ref.watch(sessionServiceProvider),
    deviceCalendarPlugin: ref.watch(deviceCalendarProvider),
    notificationsPlugin: ref.watch(notificationsProvider),
  );
});

// Provider for session service
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});
