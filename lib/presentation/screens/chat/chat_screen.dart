// lib/presentation/screens/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

import 'package:kounselme/domain/models/chat_message.dart';
import 'package:kounselme/domain/models/chat_history_item.dart' as history;
import 'package:kounselme/domain/models/chat_participant.dart';
import 'package:kounselme/domain/providers/chat_provider.dart';
import 'package:kounselme/presentation/widgets/chat/k_chat_input.dart';
import 'package:kounselme/presentation/widgets/chat/k_invite_modal.dart';
import 'package:kounselme/presentation/widgets/chat/k_message_bubble.dart';
import 'package:kounselme/presentation/widgets/chat/k_participant_list.dart';
import 'package:kounselme/presentation/widgets/chat/k_chat_history_drawer.dart';
import 'package:kounselme/presentation/screens/chat/session_dialogs.dart';
import 'package:kounselme/presentation/widgets/chat/k_session_start_dialog.dart';
// import 'package:kounselme/presentation/widgets/chat/k_session_timer.dart';
import 'package:kounselme/presentation/widgets/chat/k_typing_indicator.dart';
import 'package:kounselme/presentation/widgets/chat/k_time_display.dart';
// import 'package:kounselme/presentation/widgets/chat/k_thinking_indicator.dart';
import 'package:kounselme/presentation/widgets/chat/k_time_limit_notification.dart';
// import 'package:kounselme/presentation/widgets/chat/k_time_purchase_dialog.dart';
import 'package:kounselme/presentation/widgets/chat/k_voice_input.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Duration sessionDuration;
  final DateTime? sessionStartTime;
  final String? sessionTitle;

  const ChatScreen({
    super.key,
    required this.sessionDuration,
    this.sessionStartTime,
    this.sessionTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showParticipants = false;
  bool _isMultiUserSession = false;
  bool _isTimerActive = true; // Always active since we start with a session
  // Using sessionStartTime from widget parameter directly
  late Duration _sessionDuration;
  bool _isSessionEnded = false;
  bool _isApproachingTimeLimit = false;
  String _sessionTitle = 'Therapy Session';

  // User ID for message ownership
  final String _userId = 'user123'; // In a real app, this would come from auth

  // Sample participants for demo
  final List<ChatParticipant> _participants = [
    ChatParticipant(
      id: '1',
      name: 'You',
      isHost: true,
      isSpeaking: false,
      isOnline: true,
    ),
    ChatParticipant(
      id: '2',
      name: 'KounselMe AI',
      isSpeaking: false,
      isOnline: true,
    ),
  ];

  // Sample chat history for drawer
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'id': '1',
      'title': 'Anxiety management techniques',
      'lastMessage': 'Let\'s try some breathing exercises...',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '2',
      'title': 'Sleep improvement strategies',
      'lastMessage': 'Creating a bedtime routine can help...',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '3',
      'title': 'Stress reduction',
      'lastMessage': 'Mindfulness meditation is effective for...',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize session data from widget parameters
    _sessionDuration = widget.sessionDuration;
    _sessionTitle = widget.sessionTitle ?? 'Therapy Session';

    // Initialize WebSocket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // For demo purposes we'll use a fixed user ID and token
      // In a real app, you would get these from your authentication provider
      final chatNotifier = ref.read(chatProvider.notifier);
      chatNotifier.setCredentials('user123', 'demo_token');

      // Connect to WebSocket
      chatNotifier.connect().then((_) {
        final chatState = ref.read(chatProvider);
        if (chatState.messages.isEmpty) {
          // Show session start dialog
          _showSessionStartDialog();
        } else {
          // Add welcome message for existing session
          _addWelcomeMessage();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    // In a real implementation, welcome messages should come from the server
    // But for demonstration, we'll send a user message to trigger an AI response
    final chatNotifier = ref.read(chatProvider.notifier);

    // Join existing session if needed
    if (widget.sessionStartTime != null &&
        ref.read(chatProvider).sessionId != null) {
      chatNotifier.joinSession(ref.read(chatProvider).sessionId!);
    }

    // Send initial user message if there are no messages
    if (ref.read(chatProvider).messages.isEmpty) {
      chatNotifier.sendMessage("I'd like to start my session now.");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleParticipants() {
    setState(() {
      _showParticipants = !_showParticipants;
    });
  }

  void _toggleChatHistory() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  void _showExtendSessionOptions() {
    SessionDialogs.showExtendSessionOptions(
      context,
      onExtend: (minutes) {
        // Simulate payment processing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing payment...')),
        );

        // After "payment" is processed, extend the session
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _sessionDuration =
                  Duration(minutes: _sessionDuration.inMinutes + minutes);
              _isSessionEnded = false;
              _isApproachingTimeLimit = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session extended by $minutes minutes')),
            );
          }
        });
      },
    );
  }

  void _showSessionStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KSessionStartDialog(
        remainingSessions: 3, // This would come from user's subscription
        nextFreeSession: DateTime.now()
            .add(const Duration(hours: 2)), // This would be calculated
        onStartSession: (minutes) {
          // Start real WebSocket session
          final chatNotifier = ref.read(chatProvider.notifier);
          chatNotifier
              .startSession(
            durationMinutes: minutes,
            title: '$minutes-Minute Therapy Session',
            isMultiUser: false,
          )
              .then((_) {
            setState(() {
              _sessionDuration = Duration(minutes: minutes);
              // Session start time is tracked by the provider
              _isTimerActive = true;
              _isSessionEnded = false;
              _isApproachingTimeLimit = false;
              _sessionTitle = '$minutes-Minute Therapy Session';
            });

            // The welcome message will come from the server via WebSocket
            // But we'll add it manually if we don't receive it within a second
            Future.delayed(const Duration(seconds: 1), () {
              if (ref.read(chatProvider).messages.isEmpty) {
                chatNotifier.sendMessage("I'm ready to start my session.");
              }
            });
          });
        },
        onScheduleSession: () {
          // Show date picker
          _showDateTimePicker();
        },
        onBuyMoreSessions: () {
          // Show purchase options
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase feature coming soon')),
          );
        },
      ),
    );
  }

  void _showInviteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: KInviteModal(
            sessionId: ref.read(chatProvider).sessionId ?? 'temp-session',
            onInvite: _handleInvite,
          ),
        );
      },
    );
  }

  void _handleInvite(List<String> emails) {
    // In a real app, this would send invitations to the emails
    Navigator.pop(context);

    // For demo purposes, add a fake participant
    if (emails.isNotEmpty) {
      setState(() {
        _isMultiUserSession = true;
        _participants.add(
          ChatParticipant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: emails[0].split('@')[0], // Use part before @ as name
            isOnline: false,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to ${emails.length} people')),
      );
    }
  }

  void _toggleTimer() {
    setState(() {
      _isTimerActive = !_isTimerActive;
      // Timer state is tracked by the provider
      // We don't set _sessionStartTime to null as it's a non-nullable field
    });
  }

  // Simulate approaching time limit (would be called by a timer in a real app)
  void _simulateApproachingTimeLimit() {
    setState(() {
      _isApproachingTimeLimit = true;
    });
  }

  // Method to handle date and time picking with proper async handling
  void _showDateTimePicker() async {
    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      // Show time picker
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        // Combine date and time
        final scheduledDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session scheduled for ${scheduledDateTime.toString().substring(0, 16)}',
            ),
            backgroundColor: AppTheme.electricViolet,
          ),
        );
      }
    }
  }

  void _handleVoiceInput() {
    // Show voice input UI
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false, // Prevent dismissing by tapping outside
      enableDrag: false, // Prevent dragging down to dismiss
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: AppTheme.snowWhite,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXL),
              topRight: Radius.circular(AppTheme.radiusXL),
            ),
            boxShadow: AppTheme.getShadow(
              elevation: AppTheme.elevationM,
              shadowColor: AppTheme.codGray,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Consumer(builder: (context, ref, _) {
              final isAIResponding = ref.watch(chatProvider).isLoading;

              return KVoiceInput(
                isAIResponding: isAIResponding,
                onClose: () {
                  Navigator.pop(context);
                },
                onTranscription: (transcription) {
                  // Update speaking state - user is speaking
                  _updateSpeakingState(_participants[0].id, true);

                  // Send message via WebSocket
                  ref.read(chatProvider.notifier).sendMessage(transcription);

                  // After a short delay, user is no longer speaking
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _updateSpeakingState(_participants[0].id, false);
                    }
                  });

                  // Don't close the bottom sheet - allow continuous voice conversation
                  // as described in the chat user flow
                },
              );
            }),
          ),
        );
      },
    );
  }

  void _updateSpeakingState(String id, bool isSpeaking) {
    setState(() {
      for (final participant in _participants) {
        if (participant.id == id) {
          _participants[_participants.indexOf(participant)] = ChatParticipant(
            id: participant.id,
            name: participant.name,
            avatarUrl: participant.avatarUrl,
            isHost: participant.isHost,
            isSpeaking: isSpeaking,
            isOnline: participant.isOnline,
          );
        } else if (participant.isSpeaking) {
          // Only one participant can be speaking at a time
          _participants[_participants.indexOf(participant)] = ChatParticipant(
            id: participant.id,
            name: participant.name,
            avatarUrl: participant.avatarUrl,
            isHost: participant.isHost,
            isSpeaking: false,
            isOnline: participant.isOnline,
          );
        }
      }
    });
  }

  void _showTimeOptions(BuildContext context) {
    final chatNotifier = ref.read(chatProvider.notifier);
    final chatState = ref.read(chatProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.snowWhite,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time Management', style: AppTheme.headingS),
              const SizedBox(height: 16),

              // Display time info
              KTimeDisplay(
                timeUsed: chatState.timeUsedThisSession,
                monthlyRemaining: chatState.monthlyTimeRemaining,
                isPaused: chatState.isPaused,
                showDetails: true,
              ),
              const SizedBox(height: 20),

              // Pause/Resume button
              ElevatedButton.icon(
                onPressed: () {
                  if (chatState.isPaused) {
                    chatNotifier.resumeSession();
                  } else {
                    chatNotifier.pauseSession();
                  }
                  Navigator.pop(context);
                },
                icon: Icon(chatState.isPaused ? AppIcons.play : AppIcons.pause),
                label: Text(
                    chatState.isPaused ? 'Resume Session' : 'Pause Session'),
                style: AppTheme.primaryButtonStyle(),
              ),
              const SizedBox(height: 12),

              // Set personal time limit button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSetPersonalTimeLimit(context);
                },
                icon: Icon(AppIcons.clock),
                label: const Text('Set Personal Time Limit'),
                style: AppTheme.secondaryButtonStyle(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSetPersonalTimeLimit(BuildContext context) {
    final chatNotifier = ref.read(chatProvider.notifier);

    // Time limit options in minutes
    final timeOptions = [5, 15, 30, 45, 60];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Personal Time Limit', style: AppTheme.headingS),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a time limit for this session:',
              style: AppTheme.bodyM,
            ),
            const SizedBox(height: 16),

            // Time options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeOptions.map((minutes) {
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: false,
                  onSelected: (selected) {
                    if (selected) {
                      chatNotifier
                          .setPersonalTimeLimit(Duration(minutes: minutes));
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Set personal time limit to $minutes minutes'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              style: AppTheme.textButtonStyle(),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatState.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    // Update speaking state based on typing
    if (chatState.isLoading && _participants.length > 1) {
      // AI is typing, so it's speaking
      _updateSpeakingState(_participants[1].id, true);
    } else if (!chatState.isLoading &&
        _participants.length > 1 &&
        _participants[1].isSpeaking) {
      // AI stopped typing
      _updateSpeakingState(_participants[1].id, false);
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildChatHistoryDrawer(),
      appBar: KAppBar(
        title: _sessionTitle,
        showBackButton: false,
        leading: IconButton(
          icon: Icon(AppIcons.menu),
          onPressed: _toggleChatHistory,
        ),
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KTimeDisplay(
              timeUsed: chatState.timeUsedThisSession,
              monthlyRemaining: chatState.monthlyTimeRemaining,
              isPaused: chatState.isPaused,
              isCompact: true,
              showMonthlyTime: false,
              onTap: () => _showTimeOptions(context),
            ),
          ],
        ),
        backgroundColor: AppTheme.electricViolet,
        actions: [
          // Participants button (only visible in multi-user mode)
          if (_isMultiUserSession)
            IconButton(
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(AppIcons.users),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.robinsGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.snowWhite, width: 1),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _participants.length.toString(),
                      style: const TextStyle(
                        color: AppTheme.snowWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              onPressed: _toggleParticipants,
            ),

          // More options menu
          IconButton(
            icon: Icon(AppIcons.more),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message if any
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppTheme.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(AppIcons.warning, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: AppTheme.bodyM.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.close, color: AppTheme.error),
                    onPressed: () {
                      // Clear error
                      ref.read(chatProvider.notifier).recordActivity();
                    },
                  ),
                ],
              ),
            ),

          // Participant list (visible when toggled)
          if (_showParticipants)
            Container(
              decoration: AppTheme.cardDecoration(
                backgroundColor: AppTheme.snowWhite,
                elevation: AppTheme.elevationXS,
              ),
              child: KParticipantList(
                participants: _participants,
                isCompact: true,
                onInviteParticipant: _showInviteModal,
                onParticipantTap: (participant) {
                  // Handle participant tap
                },
              ),
            ),

          // Chat messages
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : _buildChatMessages(chatState),
          ),

          // Typing indicator or thinking indicator
          if (chatState.isLoading) const KTypingIndicator(),

          // Input field
          KChatInput(
            isLoading: chatState.isLoading,
            isDisabled: _isSessionEnded || !chatState.isSessionActive,
            onSendMessage: (message) {
              // Update speaking state - user is speaking
              _updateSpeakingState(_participants[0].id, true);

              // Send message via WebSocket
              ref.read(chatProvider.notifier).sendMessage(message);

              // After a short delay, user is no longer speaking
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _updateSpeakingState(_participants[0].id, false);
                }
              });
            },
            onInviteUser: _isMultiUserSession ? null : _showInviteModal,
            onStartTimer: _isTimerActive ? null : _toggleTimer,
            onVoiceInput: _handleVoiceInput,
            onShareLink: () {
              // Share link functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share link feature coming soon')),
              );
            },
            onUpload: () {
              // Upload functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload feature coming soon')),
              );
            },
            onReminder: () {
              // Reminder functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder feature coming soon')),
              );
            },
          ),

          // Time limit notifications
          if (_isApproachingTimeLimit && !_isSessionEnded)
            KTimeLimitNotification(
              type: TimeLimitType.approaching,
              onAddTime: _showExtendSessionOptions,
              onContinue: () {
                setState(() {
                  _isApproachingTimeLimit = false;
                });
              },
            ),

          // Session ended message
          if (_isSessionEnded)
            KTimeLimitNotification(
              type: TimeLimitType.reached,
              onAddTime: _showExtendSessionOptions,
              onEndChat: _showSessionStartDialog,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.chat,
            size: 80,
            color: AppTheme.electricViolet,
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: AppTheme.headingM,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Send a message to start chatting with your AI counselor.',
              style: AppTheme.bodyM.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];

        // Check if this is a system message (from participant joins/leaves)
        final bool isSystemMessage =
            !message.isAI && message.content.contains("joined") ||
                !message.isAI && message.content.contains("left");

        // Determine message type
        MessageType messageType = MessageType.text;
        if (isSystemMessage) {
          messageType = MessageType.system;
        } else if (message.content.startsWith('voice:')) {
          messageType = MessageType.voice;
        } else if (message.content.startsWith('http') &&
            (message.content.endsWith('.jpg') ||
                message.content.endsWith('.png') ||
                message.content.endsWith('.jpeg'))) {
          messageType = MessageType.image;
        } else if (message.content.startsWith('file:')) {
          messageType = MessageType.file;
        }

        // Find sender name for multi-user chats
        String? senderName;
        if (_isMultiUserSession &&
            !message.isAI &&
            !message.userId.contains('user')) {
          final participant = _participants.firstWhere(
            (p) => p.id == message.userId,
            orElse: () => ChatParticipant(name: 'Unknown', id: message.userId),
          );
          senderName = participant.name;
        }

        // Return appropriate message bubble
        return KMessageBubble(
          message: messageType == MessageType.voice
              ? message.content.substring(6) // Remove 'voice:' prefix
              : messageType == MessageType.file
                  ? message.content.substring(5) // Remove 'file:' prefix
                  : message.content,
          isUser: message.userId == _userId,
          timestamp: message.timestamp,
          messageType: messageType,
          status: message.status,
          senderName: senderName,
          onRetry: message.status == MessageStatus.failed
              ? () => _retryMessage(message)
              : null,
        );
      },
    );
  }

  void _retryMessage(ChatMessage message) {
    // Implement retry logic
    final chatNotifier = ref.read(chatProvider.notifier);
    // Resend the message
    chatNotifier.sendMessage(message.content);
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Session options
              if (!_isTimerActive) ...[
                ListTile(
                  leading: Icon(AppIcons.timer, color: AppTheme.robinsGreen),
                  title: const Text(
                    'Start 30-min Session',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isTimerActive = true;
                      // Session start time is tracked by the provider
                      _sessionDuration = const Duration(minutes: 30);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(AppIcons.timer, color: AppTheme.electricViolet),
                  title: const Text(
                    'Start 60-min Session',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isTimerActive = true;
                      // Session start time is tracked by the provider
                      _sessionDuration = const Duration(minutes: 60);
                    });
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(AppIcons.timerPause, color: AppTheme.warning),
                  title: const Text(
                    'End Session Early',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isTimerActive = false;
                      // Don't set _sessionStartTime to null as it's a non-nullable field
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Session ended')),
                    );
                  },
                ),
              ],

              // Participant options
              if (!_isMultiUserSession) ...[
                ListTile(
                  leading:
                      Icon(AppIcons.addUser, color: AppTheme.electricViolet),
                  title: const Text(
                    'Invite participants',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showInviteModal();
                  },
                ),
              ] else ...[
                ListTile(
                  leading:
                      Icon(AppIcons.addUser, color: AppTheme.electricViolet),
                  title: const Text(
                    'Manage participants',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleParticipants();
                  },
                ),
              ],

              // Chat management options
              const Divider(),
              ListTile(
                leading: Icon(AppIcons.delete, color: AppTheme.electricViolet),
                title: const Text(
                  'Clear chat',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatConfirmation(context);
                },
              ),
              ListTile(
                leading: Icon(AppIcons.export, color: AppTheme.electricViolet),
                title: const Text(
                  'Export chat',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Export functionality will be added later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.search, color: AppTheme.electricViolet),
                title: const Text(
                  'Search in chat',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Search functionality will be added later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search feature coming soon')),
                  );
                },
              ),

              // Schedule options
              const Divider(),
              ListTile(
                leading:
                    Icon(AppIcons.calendar, color: AppTheme.electricViolet),
                title: const Text(
                  'Schedule next session',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Schedule functionality will be added later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Scheduling feature coming soon')),
                  );
                },
              ),

              // For testing time limit notifications
              if (!_isSessionEnded) ...[
                const Divider(),
                ListTile(
                  leading: Icon(AppIcons.warning, color: Colors.orange),
                  title: const Text(
                    'Simulate approaching time limit',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateApproachingTimeLimit();
                  },
                ),
                ListTile(
                  leading: Icon(AppIcons.warning, color: Colors.red),
                  title: const Text(
                    'Simulate session end',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSessionEnded = true;
                      _isApproachingTimeLimit = false;
                    });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatHistoryDrawer() {
    // Convert the chat history data to the format expected by KChatHistoryDrawer
    final chatHistoryItems = _chatHistory.map((chat) {
      return ChatHistoryItem(
        id: chat['id'] as String,
        title: chat['title'] as String,
        previewMessage: chat['lastMessage'] as String,
        timestamp: chat['timestamp'] as DateTime,
        durationMinutes: 30, // Default duration for demo
      );
    }).toList();

    return KChatHistoryDrawer(
      chatHistory: chatHistoryItems,
      onSelectChat: (sessionId) {
        // In a real app, you would load the selected chat session
        // For now, we'll just show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loading session $sessionId')),
        );
      },
      onNewChat: () {
        // Show session start dialog
        ref.read(chatProvider.notifier).clearChatHistory();
        _showSessionStartDialog();
      },
    );
  }

  void _showClearChatConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clear chat',
            style: AppTheme.headingS,
          ),
          content: Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
            style: AppTheme.bodyM,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(chatProvider.notifier).clearChatHistory();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
