// lib/presentation/widgets/chat/k_chat_scheduling.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

import 'package:kounselme/presentation/widgets/common/k_button.dart';

class KChatScheduling extends ConsumerStatefulWidget {
  final Function(DateTime) onSchedule;
  final Function(DateTime, bool) onAddToCalendar;

  const KChatScheduling({
    super.key,
    required this.onSchedule,
    required this.onAddToCalendar,
  });

  @override
  ConsumerState<KChatScheduling> createState() => _KChatSchedulingState();
}

class _KChatSchedulingState extends ConsumerState<KChatScheduling> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _addToCalendar = true;

  @override
  void initState() {
    super.initState();
    // Default to tomorrow at 10:00 AM
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day + 1);
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.electricViolet,
              onPrimary: AppTheme.snowWhite,
              surface: AppTheme.snowWhite,
              onSurface: AppTheme.codGray,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.snowWhite),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.electricViolet,
              onPrimary: AppTheme.snowWhite,
              surface: AppTheme.snowWhite,
              onSurface: AppTheme.codGray,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.snowWhite),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snowWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.codGray.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Chat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Date Selection
          _buildSelectionRow(
            'Select Date',
            DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
            AppIcons.calendar,
            () => _selectDate(context),
          ),
          const SizedBox(height: 16),

          // Time Selection
          _buildSelectionRow(
            'Select Time',
            _selectedTime.format(context),
            AppIcons.time,
            () => _selectTime(context),
          ),
          const SizedBox(height: 24),

          // Add to Calendar Option
          _buildCalendarOption(),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: KButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  type: KButtonType.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KButton(
                  label: 'Schedule',
                  onPressed: () {
                    final scheduledDateTime = _combineDateAndTime();
                    widget.onSchedule(scheduledDateTime);
                    if (_addToCalendar) {
                      widget.onAddToCalendar(scheduledDateTime, _addToCalendar);
                    }
                    Navigator.of(context).pop();
                  },
                  type: KButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRow(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryText,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.electricViolet),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  AppIcons.arrowRight,
                  color: AppTheme.codGray,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarOption() {
    // Get the right calendar icon based on platform
    final calendarIcon =
        Platform.isIOS ? AppIcons.appleCalendar : AppIcons.googleCalendar;

    return InkWell(
      onTap: () {
        setState(() {
          _addToCalendar = !_addToCalendar;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              calendarIcon,
              color: _addToCalendar
                  ? AppTheme.electricViolet
                  : AppTheme.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to Calendar',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Create a reminder in your device calendar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: _addToCalendar,
              onChanged: (value) {
                setState(() {
                  _addToCalendar = value ?? false;
                });
              },
              activeColor: AppTheme.electricViolet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
