// lib/presentation/screens/journal/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  final List<String> _tags = [Strings.calmTag, Strings.reflectiveTag];
  final DateTime _selectedDate = DateTime.now();
  final List<int> _dates = List.generate(30, (index) => index + 1);

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KAppBar(
        title: Strings.journal,
        backgroundColor: AppTheme.heliotrope,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Journal content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title placeholder
                  const Text(
                    Strings.whatsOnYourMind,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Journal text area
                  TextField(
                    controller: _journalController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start typing here...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: AppTheme.codGray,
                      height: 1.5,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),

          // Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ..._tags.map((tag) => _buildTag(tag)),
                IconButton(
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppTheme.secondaryText,
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    // Add tag functionality
                  },
                ),
              ],
            ),
          ),

          // Bottom toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.snowWhite,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gallery,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left tools
                Row(
                  children: [
                    _buildToolButton(AppIcons.camera, onPressed: () {}),
                    const SizedBox(width: 16),
                    _buildToolButton(AppIcons.sentiment, onPressed: () {}),
                  ],
                ),

                // Voice record button
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.pink,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(
                            77, 255, 105, 180), // Light pink with 30% opacity
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic,
                    color: AppTheme.snowWhite,
                    size: 28,
                  ),
                ),

                // Right tools
                Row(
                  children: [
                    _buildToolButton(Icons.save, onPressed: () {}),
                    const SizedBox(width: 16),
                    _buildToolButton(AppIcons.calendar, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),

          // Calendar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.snowWhite,
              border: Border(
                top: BorderSide(color: AppTheme.divider, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _dates.map((date) {
                  final isSelected = date == _selectedDate.day;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.electricViolet
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        date.toString(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.snowWhite
                              : AppTheme.codGray,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.heliotrope.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppTheme.heliotrope,
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, {required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.gallery,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.secondaryText),
        onPressed: onPressed,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
