// lib/presentation/widgets/chat/k_time_purchase_dialog.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KTimePurchaseDialog extends StatelessWidget {
  final Function(int) onPurchase;
  final VoidCallback onUpgradePlan;
  final VoidCallback onCancel;

  const KTimePurchaseDialog({
    super.key,
    required this.onPurchase,
    required this.onUpgradePlan,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add More Time',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.codGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how much time you want to add to your session',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 1 hour option
            _buildTimeOption(
              icon: AppIcons.timer,
              title: '1 Hour',
              price: '\$2',
              onTap: () => onPurchase(60),
            ),

            const SizedBox(height: 16),

            // 3 hours option
            _buildTimeOption(
              icon: AppIcons.timer,
              title: '3 Hours',
              price: '\$5',
              onTap: () => onPurchase(180),
              isBestValue: true,
            ),

            const SizedBox(height: 16),

            // Upgrade plan option
            _buildTimeOption(
              icon: AppIcons.star,
              title: 'Upgrade Plan',
              subtitle: 'Get more hours monthly',
              onTap: onUpgradePlan,
              isUpgrade: true,
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancel',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOption({
    required IconData icon,
    required String title,
    String? price,
    String? subtitle,
    required VoidCallback onTap,
    bool isBestValue = false,
    bool isUpgrade = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isUpgrade ? Colors.purple.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpgrade
                ? AppTheme.electricViolet
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUpgrade
                    ? Colors.purple.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    isUpgrade ? AppTheme.electricViolet : AppTheme.robinsGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.codGray,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                ],
              ),
            ),
            if (price != null)
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.robinsGreen,
                ),
              ),
            if (isBestValue)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Best Value',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.robinsGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
