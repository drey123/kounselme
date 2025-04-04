// lib/presentation/widgets/common/k_button.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';

enum KButtonType { primary, secondary, text, outline }

class KButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final KButtonType type;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final bool fullWidth;

  const KButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = KButtonType.primary,
    this.isLoading = false,
    this.width,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: fullWidth ? double.infinity : width,
      height: 56,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case KButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.robinsGreen,
            foregroundColor: AppTheme.snowWhite,
            disabledBackgroundColor: AppTheme.successLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: _buildButtonContent(),
        );
      case KButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.yellowSea,
            foregroundColor: AppTheme.codGray,
            disabledBackgroundColor: AppTheme.warningLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: _buildButtonContent(),
        );
      case KButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.electricViolet,
            side: const BorderSide(color: AppTheme.electricViolet, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: _buildButtonContent(),
        );
      case KButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.electricViolet,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    return isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.snowWhite,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.buttonL,
              ),
            ],
          );
  }
}
