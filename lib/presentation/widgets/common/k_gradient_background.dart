// lib/presentation/widgets/common/k_gradient_background.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';

class KGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool applyWavePattern;

  const KGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.applyWavePattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            AppTheme.electricViolet,
            AppTheme.heliotrope,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (applyWavePattern) 
            Positioned.fill(
              child: CustomPaint(
                painter: WavePatternPainter(
                  waveColor: AppTheme.snowWhite.withAlpha(13),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class WavePatternPainter extends CustomPainter {
  final Color waveColor;

  WavePatternPainter({required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // First wave
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height * 0.30, 
      size.width * 0.5, 
      size.height * 0.25
    );
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height * 0.20, 
      size.width, 
      size.height * 0.25
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.quadraticBezierTo(
      size.width * 0.25, 
      size.height * 0.95, 
      size.width * 0.5, 
      size.height * 0.98
    );
    path2.quadraticBezierTo(
      size.width * 0.75, 
      size.height * 1.05, 
      size.width, 
      size.height * 0.95
    );
    path2.lineTo(size.width, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}