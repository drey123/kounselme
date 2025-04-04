// lib/presentation/screens/chat/chat_dialogs.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/presentation/widgets/chat/k_time_purchase_dialog.dart';

class ChatDialogs {
  static void showChatEndDialog(
    BuildContext context, {
    required int chatDurationMinutes,
    required VoidCallback onEndChat,
    required VoidCallback onExtendChat,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Chat Ended',
            style:
                TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your therapy chat has ended. Would you like to:',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(AppIcons.timer,
                      color: AppTheme.electricViolet, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Chat duration:',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$chatDurationMinutes minutes',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: AppTheme.electricViolet,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onEndChat();
              },
              child: const Text('End Chat'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onExtendChat();
              },
              style:
                  TextButton.styleFrom(foregroundColor: AppTheme.robinsGreen),
              child: const Text('Extend Chat'),
            ),
          ],
        );
      },
    );
  }

  static void showExtendChatOptions(
    BuildContext context, {
    required Function(int) onExtend,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return KTimePurchaseDialog(
          onPurchase: (minutes) {
            Navigator.pop(context);
            onExtend(minutes);
          },
          onUpgradePlan: () {
            Navigator.pop(context);
            // Show upgrade plan options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upgrade plan feature coming soon')),
            );
          },
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }
}
