// lib/presentation/screens/chat/session_dialogs.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/presentation/widgets/chat/k_time_purchase_dialog.dart';

class SessionDialogs {
  static void showSessionEndDialog(
    BuildContext context, {
    required int sessionDurationMinutes,
    required VoidCallback onEndSession,
    required VoidCallback onExtendSession,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Session Ended',
            style:
                TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your therapy session has ended. Would you like to:',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(AppIcons.timer,
                      color: AppTheme.electricViolet, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Session duration:',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$sessionDurationMinutes minutes',
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
                onEndSession();
              },
              child: const Text('End Session'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onExtendSession();
              },
              style:
                  TextButton.styleFrom(foregroundColor: AppTheme.robinsGreen),
              child: const Text('Extend Session'),
            ),
          ],
        );
      },
    );
  }

  static void showExtendSessionOptions(
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
