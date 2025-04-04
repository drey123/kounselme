// lib/presentation/widgets/chat/k_quick_actions_bar.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KQuickActionsBar extends StatelessWidget {
  final VoidCallback? onAddParticipant;
  final VoidCallback? onShareLink;
  final VoidCallback? onUpload;
  final VoidCallback? onReminder;
  final bool isExpanded;
  final Function(bool) onToggle;

  const KQuickActionsBar({
    super.key,
    this.onAddParticipant,
    this.onShareLink,
    this.onUpload,
    this.onReminder,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final buttonSize = isSmallScreen ? 36.0 : 40.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isExpanded ? 50 : 0,
      child: SingleChildScrollView(
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Toggle button
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_down : AppIcons.arrowRight,
                  size: iconSize,
                  color: AppTheme.electricViolet,
                ),
                onPressed: () => onToggle(!isExpanded),
                constraints: BoxConstraints.tightFor(
                  width: buttonSize,
                  height: buttonSize,
                ),
                padding: EdgeInsets.zero,
                splashRadius: buttonSize / 2,
              ),

              if (isExpanded) ...[
                const SizedBox(width: 8),

                // Add Participant button
                if (onAddParticipant != null)
                  _buildActionButton(
                    icon: AppIcons.addUser,
                    label: 'Add',
                    onTap: onAddParticipant,
                    iconSize: iconSize,
                    buttonSize: buttonSize,
                  ),

                const SizedBox(width: 8),

                // Share Link button
                if (onShareLink != null)
                  _buildActionButton(
                    icon: AppIcons.link,
                    label: 'Share',
                    onTap: onShareLink,
                    iconSize: iconSize,
                    buttonSize: buttonSize,
                  ),

                const SizedBox(width: 8),

                // Upload button
                if (onUpload != null)
                  _buildActionButton(
                    icon: AppIcons.upload,
                    label: 'Upload',
                    onTap: onUpload,
                    iconSize: iconSize,
                    buttonSize: buttonSize,
                  ),

                const SizedBox(width: 8),

                // Reminder button
                if (onReminder != null)
                  _buildActionButton(
                    icon: AppIcons.clock,
                    label: 'Remind',
                    onTap: onReminder,
                    iconSize: iconSize,
                    buttonSize: buttonSize,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required double iconSize,
    required double buttonSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppTheme.electricViolet,
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppTheme.electricViolet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
