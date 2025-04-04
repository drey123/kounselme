// lib/presentation/screens/chat/session_start_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/domain/providers/chat_provider.dart';
import 'package:kounselme/domain/providers/scheduling_provider.dart';
import 'package:kounselme/presentation/screens/chat/chat_screen.dart';
import 'package:kounselme/presentation/widgets/chat/k_chat_scheduling.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';
import 'package:kounselme/presentation/widgets/common/k_button.dart';
import 'package:kounselme/presentation/widgets/common/k_gradient_background.dart';

class SessionStartScreen extends ConsumerStatefulWidget {
  const SessionStartScreen({super.key});

  @override
  ConsumerState<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends ConsumerState<SessionStartScreen> {
  bool _isLoading = false;
  String? _selectedTopic;

  // Sample topics
  final List<String> _suggestedTopics = [
    'Anxiety Management',
    'Work Stress',
    'Relationship Advice',
    'Personal Growth',
    'Sleep Problems',
    'Just Chat',
  ];

  @override
  void initState() {
    super.initState();
    // Load user's time availability
    _loadTimeAvailability();

    // Initialize providers with user info
    // In a real app, this would come from your auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = ref.read(chatProvider.notifier);
      chatNotifier.initialize('user123', 'demo_token');
    });
  }

  Future<void> _loadTimeAvailability() async {
    // In a real implementation, this would load user's time from the backend
    // For now, we'll just simulate a loading state
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  void _startChat() async {
    setState(() {
      _isLoading = true;
    });

    final chatNotifier = ref.read(chatProvider.notifier);

    // Start a new session
    await chatNotifier.startSession(
      durationMinutes: 30,
      title: _selectedTopic == 'Just Chat' ? null : _selectedTopic,
      isMultiUser: false,
    );

    setState(() {
      _isLoading = false;
    });

    // Navigate to chat screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const ChatScreen(sessionDuration: Duration(minutes: 30)),
        ),
      );
    }
  }

  void _showSchedulingDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
        child: KChatScheduling(
          onSchedule: (DateTime scheduledTime) {
            _scheduleChat(scheduledTime, false);
          },
          onAddToCalendar: (DateTime scheduledTime, bool addToCalendar) {
            _scheduleChat(scheduledTime, addToCalendar);
          },
        ),
      ),
    );
  }

  Future<void> _scheduleChat(DateTime scheduledTime, bool addToCalendar) async {
    final schedulingNotifier = ref.read(schedulingProvider.notifier);

    // Get user ID and token from auth provider (will be implemented later)
    final userId = 'user123';
    final token = 'demo_token';

    final scheduledChat = await schedulingNotifier.scheduleChat(
      userId: userId,
      token: token,
      scheduledTime: scheduledTime,
      title: _selectedTopic == 'Just Chat' ? null : _selectedTopic,
      addToCalendar: addToCalendar,
    );

    if (scheduledChat != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat scheduled for ${scheduledTime.toString()}'),
          backgroundColor: AppTheme.robinsGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: KAppBar(
        title: 'Start Chat',
        showBackButton: true,
      ),
      body: KGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time remaining indicator
                      _buildTimeRemainingCard(chatState.monthlyTimeRemaining),
                      const SizedBox(height: 32),

                      // Start chat section
                      Text(
                        'What would you like to talk about today?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),

                      // Topic selection
                      _buildTopicGrid(),
                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: KButton(
                              label: 'Schedule for Later',
                              onPressed: _showSchedulingDialog,
                              type: KButtonType.outline,
                              icon: AppIcons.calendar,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: KButton(
                              label: 'Start Chat Now',
                              onPressed: _startChat,
                              type: KButtonType.primary,
                              icon: AppIcons.chat,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTimeRemainingCard(Duration remainingTime) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snowWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getShadow(
          elevation: AppTheme.elevationS,
          shadowColor: AppTheme.codGray,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.timer,
            color: AppTheme.electricViolet,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Remaining This Month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$hours hours $minutes minutes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.arrowRight,
            color: AppTheme.codGray,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _suggestedTopics.length,
      itemBuilder: (context, index) {
        final topic = _suggestedTopics[index];
        final isSelected = _selectedTopic == topic;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTopic = topic;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.electricViolet : AppTheme.snowWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.electricViolet : AppTheme.divider,
              ),
            ),
            child: Center(
              child: Text(
                topic,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.snowWhite
                          : AppTheme.primaryText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
