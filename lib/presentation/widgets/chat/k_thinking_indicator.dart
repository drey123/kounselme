// lib/presentation/widgets/chat/k_thinking_indicator.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KThinkingIndicator extends StatefulWidget {
  const KThinkingIndicator({super.key});

  @override
  State<KThinkingIndicator> createState() => _KThinkingIndicatorState();
}

class _KThinkingIndicatorState extends State<KThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.cardDecoration(
          backgroundColor: AppTheme.snowWhite,
          borderRadius: 16,
          elevation: AppTheme.elevationXS,
        ).copyWith(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated brain icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    AppIcons.brain,
                    color: AppTheme.electricViolet,
                    size: 24,
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            // Text
            Text(
              'Thinking deeply...',
              style: AppTheme.bodyS.copyWith(
                color: AppTheme.electricViolet,
                fontWeight: AppTheme.weightMedium,
              ),
            ),

            const SizedBox(width: 12),

            // Progress indicator
            SizedBox(
              width: 60,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor:
                        AppTheme.electricViolet.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.electricViolet),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
