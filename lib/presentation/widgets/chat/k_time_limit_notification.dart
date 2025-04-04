// lib/presentation/widgets/chat/k_time_limit_notification.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

enum TimeLimitType {
  approaching, // 5 minutes remaining
  reached, // Time limit reached
}

class KTimeLimitNotification extends StatelessWidget {
  final TimeLimitType type;
  final VoidCallback? onAddTime;
  final VoidCallback? onContinue;
  final VoidCallback? onEndChat;

  const KTimeLimitNotification({
    super.key,
    required this.type,
    this.onAddTime,
    this.onContinue,
    this.onEndChat,
  });

  @override
  Widget build(BuildContext context) {
    final isApproaching = type == TimeLimitType.approaching;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isApproaching
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproaching ? AppTheme.yellowSea : AppTheme.error,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isApproaching ? AppIcons.timer : AppIcons.warning,
                color: isApproaching ? AppTheme.yellowSea : AppTheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    isApproaching
                        ? 'You have 5 minutes remaining in this session'
                        : 'Your session time has ended',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isApproaching ? AppTheme.yellowSea : AppTheme.error,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isApproaching
                ? 'You can add more time or continue with your remaining time.'
                : 'To continue chatting, please add more time or end this session.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onAddTime != null)
                ElevatedButton(
                  onPressed: onAddTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.robinsGreen,
                    foregroundColor: AppTheme.snowWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Add Time',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.snowWhite,
                      )),
                ),
              const SizedBox(width: 16),
              if (isApproaching && onContinue != null)
                OutlinedButton(
                  onPressed: onContinue,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.robinsGreen,
                    side: const BorderSide(color: AppTheme.robinsGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Continue',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.robinsGreen,
                      )),
                )
              else if (!isApproaching && onEndChat != null)
                OutlinedButton(
                  onPressed: onEndChat,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('End Chat',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      )),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
