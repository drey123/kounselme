// lib/presentation/widgets/chat/k_session_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KSessionTimer extends StatefulWidget {
  final DateTime? startTime;
  final VoidCallback? onTimerEnd;
  final Duration duration;
  final bool isActive;

  const KSessionTimer({
    super.key,
    this.startTime,
    this.onTimerEnd,
    this.duration = const Duration(minutes: 30),
    this.isActive = true,
  });

  @override
  State<KSessionTimer> createState() => _KSessionTimerState();
}

class _KSessionTimerState extends State<KSessionTimer> {
  late Timer _timer;
  late DateTime _startTime;
  late Duration _remainingTime;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime ?? DateTime.now();
    _remainingTime = widget.duration;

    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(KSessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }

    if (widget.startTime != oldWidget.startTime && widget.startTime != null) {
      _startTime = widget.startTime!;
      _updateRemainingTime();
    }

    if (widget.duration != oldWidget.duration) {
      _remainingTime = widget.duration;
      _updateRemainingTime();
    }
  }

  void _startTimer() {
    _isRunning = true;
    _updateRemainingTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();

      if (_remainingTime.inSeconds <= 0) {
        _stopTimer();
        if (widget.onTimerEnd != null) {
          widget.onTimerEnd!();
        }
      }
    });
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void _updateRemainingTime() {
    final elapsed = DateTime.now().difference(_startTime);
    final remaining = widget.duration - elapsed;

    setState(() {
      _remainingTime = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime = _remainingTime.inMinutes < 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Adjust sizes based on screen width
    final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
    final verticalPadding = isSmallScreen ? 4.0 : 6.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final spacerWidth = isSmallScreen ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: isLowTime
          ? AppTheme.gradientDecoration(
              colors: [
                AppTheme.error.withValues(alpha: 0.15),
                AppTheme.error.withValues(alpha: 0.05),
              ],
              borderRadius: 16,
            )
          : AppTheme.glassDecoration(
              baseColor: AppTheme.electricViolet,
              opacity: 0.1,
              borderRadius: 16,
              borderOpacity: 0.05,
            ),
      // Add subtle pulsing animation for low time
      foregroundDecoration: isLowTime
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.timer,
            size: iconSize,
            color: isLowTime ? AppTheme.error : AppTheme.electricViolet,
          ),
          SizedBox(width: spacerWidth),
          Text(
            _formatDuration(_remainingTime),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: isLowTime ? AppTheme.error : AppTheme.electricViolet,
            ),
          ),
        ],
      ),
    );
  }
}
