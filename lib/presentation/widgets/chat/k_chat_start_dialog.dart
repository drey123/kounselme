// lib/presentation/widgets/chat/k_chat_start_dialog.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KChatStartDialog extends StatelessWidget {
  final int remainingSessions;
  final DateTime? nextFreeSession;
  final Function(int) onStartChat;
  final VoidCallback onScheduleChat;
  final VoidCallback? onBuyMoreSessions;

  const KChatStartDialog({
    super.key,
    required this.remainingSessions,
    this.nextFreeSession,
    required this.onStartChat,
    required this.onScheduleChat,
    this.onBuyMoreSessions,
  });

  String _formatTimeRemaining() {
    if (nextFreeSession == null) return 'Available now';

    final now = DateTime.now();
    final difference = nextFreeSession!.difference(now);

    if (difference.isNegative) return 'Available now';

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return '$hours:${minutes.toString().padLeft(2, '0')} remaining';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: AppTheme.cardDecoration(
          backgroundColor: AppTheme.snowWhite,
          borderRadius: 20,
          elevation: 4,
          shadowColor: AppTheme.electricViolet.withValues(alpha: 0.1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start a Chat',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppTheme.codGray,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.divider.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(AppIcons.close, size: 20),
                    color: AppTheme.secondaryText,
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose a chat duration:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // 30-minute chat option
            _buildChatOption(
              context,
              duration: 30,
              description: 'A focused conversation',
              color: AppTheme.robinsGreen,
              onTap: () {
                Navigator.pop(context);
                onStartChat(30);
              },
              isDisabled: remainingSessions <= 0 &&
                  nextFreeSession != null &&
                  nextFreeSession!.isAfter(DateTime.now()),
            ),

            const SizedBox(height: 12),

            // 60-minute chat option
            _buildChatOption(
              context,
              duration: 60,
              description: 'An in-depth conversation',
              color: AppTheme.electricViolet,
              onTap: () {
                Navigator.pop(context);
                onStartChat(60);
              },
              isDisabled: remainingSessions <= 0 &&
                  nextFreeSession != null &&
                  nextFreeSession!.isAfter(DateTime.now()),
            ),

            const SizedBox(height: 16),

            // Chat info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassDecoration(
                baseColor: AppTheme.electricViolet,
                opacity: 0.05,
                borderRadius: 16,
                borderOpacity: 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining chats:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      Text(
                        '$remainingSessions',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.codGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Next free chat:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      Text(
                        _formatTimeRemaining(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.codGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onScheduleChat();
                    },
                    icon: Icon(AppIcons.calendar),
                    label: const Text('Schedule'),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                      overlayColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return AppTheme.electricViolet
                                .withValues(alpha: 0.05);
                          }
                          return Colors.transparent;
                        },
                      ),
                    ),
                  ),
                ),
                if (onBuyMoreSessions != null && remainingSessions <= 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onBuyMoreSessions!();
                      },
                      icon: Icon(AppIcons.money),
                      label: const Text('Buy More'),
                      style: AppTheme.primaryButtonStyle(
                        backgroundColor: AppTheme.yellowSea,
                        foregroundColor: AppTheme.snowWhite,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption(
    BuildContext context, {
    required int duration,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isDisabled
            ? BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.divider.withValues(alpha: 0.05),
              )
            : AppTheme.cardDecoration(
                backgroundColor: Colors.transparent,
                borderRadius: 16,
                borderColor: color,
                borderWidth: 1.5,
                elevation: 0,
              ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: isDisabled
                  ? BoxDecoration(
                      color: AppTheme.divider.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : AppTheme.glassDecoration(
                      baseColor: color,
                      opacity: 0.1,
                      borderRadius: 12,
                    ),
              child: Center(
                child: Icon(
                  AppIcons.timer,
                  color: isDisabled ? AppTheme.secondaryText : color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$duration Minutes',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDisabled
                          ? AppTheme.secondaryText
                          : AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      letterSpacing: -0.2,
                      color: isDisabled
                          ? AppTheme.secondaryText
                          : AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: isDisabled
                  ? null
                  : BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
              child: Icon(
                AppIcons.arrowRight,
                color: isDisabled ? AppTheme.secondaryText : color,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
