// lib/presentation/screens/mood/mood_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';
import 'package:kounselme/presentation/widgets/common/k_button.dart';
import 'package:kounselme/presentation/widgets/common/k_card.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  String _selectedPeriod = Strings.week;
  final List<String> _periods = [Strings.week, Strings.month, Strings.year];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(
        title: Strings.moodTrends,
        backgroundColor: AppTheme.robinsGreen,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Show help information
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.divider.withAlpha(128),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _periods.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.snowWhite
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.codGray.withAlpha(25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.codGray
                              : AppTheme.secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Mood chart
            KCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Y-axis labels
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAxisLabel(Strings.great),
                            const SizedBox(height: 20),
                            _buildAxisLabel(Strings.good),
                            const SizedBox(height: 20),
                            _buildAxisLabel(Strings.neutral),
                            const SizedBox(height: 20),
                            _buildAxisLabel(Strings.low),
                            const SizedBox(height: 20),
                            _buildAxisLabel(Strings.veryLow),
                          ],
                        ),
                      ),

                      // Chart
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: CustomPaint(
                            painter: MoodChartPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // X-axis labels
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAxisLabel('Sat'),
                        _buildAxisLabel('Mon'),
                        _buildAxisLabel('Wed'),
                        _buildAxisLabel('Fri'),
                        _buildAxisLabel('Today'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add mood button
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () {
                  _showAddMoodBottomSheet(context);
                },
                backgroundColor: AppTheme.robinsGreen,
                child: const Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 24),

            // Insights
            const Text(
              Strings.insights,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.codGray,
              ),
            ),
            const SizedBox(height: 16),

            KCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You're less stressed on weekends compared to weekdays.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodLegendItem(
                          Strings.veryLow, AppTheme.error.withAlpha(204)),
                      _buildMoodLegendItem(
                          Strings.low, AppTheme.yellowSea.withAlpha(153)),
                      _buildMoodLegendItem(
                          Strings.neutral, AppTheme.pink.withAlpha(179)),
                      _buildMoodLegendItem(
                          Strings.good, Colors.blue.withAlpha(179)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: AppTheme.secondaryText,
      ),
    );
  }

  Widget _buildMoodLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sentiment_satisfied_alt,
            color: AppTheme.snowWhite,
            size: 16,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  void _showAddMoodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How are you feeling?',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.codGray,
                ),
              ),
              const SizedBox(height: 24),

              // Mood options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodOption('😞', Strings.veryLow),
                  _buildMoodOption('😔', Strings.low),
                  _buildMoodOption('😐', Strings.neutral),
                  _buildMoodOption('🙂', Strings.good),
                  _buildMoodOption('😃', Strings.great),
                ],
              ),
              const SizedBox(height: 24),

              // Notes input
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save button
              KButton(
                label: 'Save',
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodOption(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.gallery,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }
}

class MoodChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.robinsGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.successLight,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppTheme.divider
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = i * (size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.25, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    // Create path for line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final controlPoint = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i].dy,
      );

      final controlPoint2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );

      path.cubicTo(
        controlPoint.dx,
        controlPoint.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    // Create path for fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final dotPaint = Paint()
      ..color = AppTheme.robinsGreen
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 4, Paint()..color = AppTheme.snowWhite);
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
