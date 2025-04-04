// lib/presentation/widgets/common/k_card.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';

class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool animate;

  const KCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: backgroundColor ?? AppTheme.snowWhite,
      elevation: elevation ?? 2,
      shadowColor: AppTheme.electricViolet.withAlpha(25),
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        splashColor: AppTheme.electricViolet.withAlpha(13),
        highlightColor: AppTheme.electricViolet.withAlpha(13),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    return animate
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            child: card,
          )
        : card;
  }
}
