// lib/presentation/widgets/chat/k_typing_indicator.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';

class KTypingIndicator extends StatefulWidget {
  const KTypingIndicator({super.key});

  @override
  State<KTypingIndicator> createState() => _KTypingIndicatorState();
}

class _KTypingIndicatorState extends State<KTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
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
          shadowColor: AppTheme.codGray.withValues(alpha: 0.05),
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
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8 + (_animations[index].value * 8),
                  decoration: BoxDecoration(
                    color: Color.lerp(AppTheme.heliotrope,
                        AppTheme.electricViolet, _animations[index].value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
