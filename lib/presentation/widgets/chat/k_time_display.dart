// lib/presentation/widgets/chat/k_time_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
// import 'package:kounselme/domain/providers/chat_provider.dart';

class KTimeDisplay extends ConsumerWidget {
  final bool showDetails;
  final bool showMonthlyTime;
  final bool isCompact;
  final VoidCallback? onTap;
  final Duration timeUsed;
  final Duration monthlyRemaining;
  final bool isPaused;

  const KTimeDisplay({
    super.key,
    this.showDetails = false,
    this.showMonthlyTime = true,
    this.isCompact = false,
    this.onTap,
    required this.timeUsed,
    required this.monthlyRemaining,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Format time as HH:MM:SS
    String formatDuration(Duration duration) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

      if (duration.inHours > 0) {
        return '$hours:$minutes:$seconds';
      } else {
        return '$minutes:$seconds';
      }
    }

    // Color based on time remaining (changes when less than 5 minutes)
    Color getTimeColor() {
      if (isPaused) {
        return AppTheme.yellowSea;
      }

      if (showMonthlyTime) {
        if (monthlyRemaining.inMinutes <= 5) {
          return AppTheme.error;
        }
      } else {
        // For session time display
        if (timeUsed.inMinutes >= 25) {
          // Approaching 30 min
          return AppTheme.yellowSeaLight;
        }
      }

      return AppTheme.robinsGreen;
    }

    // If compact, just show a simple display
    if (isCompact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: AppTheme.glassDecoration(
            baseColor: showMonthlyTime
                ? AppTheme.electricViolet
                : AppTheme.robinsGreen,
            opacity: 0.1,
            borderRadius: AppTheme.radiusXL,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPaused ? AppIcons.timerPause : AppIcons.timer,
                size: 16,
                color: getTimeColor(),
              ),
              const SizedBox(width: 4),
              Text(
                showMonthlyTime
                    ? formatDuration(monthlyRemaining)
                    : formatDuration(timeUsed),
                style: AppTheme.labelM.copyWith(
                  color: getTimeColor(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Full time display
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: AppTheme.glassDecoration(
          baseColor: AppTheme.snowWhite,
          opacity: 0.1,
          borderRadius: AppTheme.radiusL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPaused ? AppIcons.timerPause : AppIcons.timer,
                  size: 18,
                  color: getTimeColor(),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session time: ${formatDuration(timeUsed)}',
                      style: AppTheme.labelM.copyWith(
                        color: AppTheme.snowWhite,
                      ),
                    ),
                    if (showDetails)
                      Text(
                        'Monthly remaining: ${formatDuration(monthlyRemaining)}',
                        style: AppTheme.labelS.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Show pause status if paused
            if (isPaused && showDetails)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.yellowSeaLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Text(
                  'Paused',
                  style: AppTheme.labelS.copyWith(
                    color: AppTheme.yellowSea,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
