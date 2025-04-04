// lib/presentation/widgets/chat/k_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:intl/intl.dart';

class KMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const KMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final bubbleMaxWidth = screenWidth * (isSmallScreen ? 0.8 : 0.75);
    final horizontalMargin = isSmallScreen ? 12.0 : 16.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 10.0 : 12.0;
    final messageFontSize = isSmallScreen ? 14.0 : 16.0;
    final timestampFontSize = isSmallScreen ? 10.0 : 12.0;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: bubbleMaxWidth,
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: isUser
            ? AppTheme.gradientDecoration(
                colors: [
                  AppTheme.electricViolet,
                  AppTheme.electricVioletLight,
                ],
                borderRadius: 16,
              )
            : AppTheme.cardDecoration(
                backgroundColor: AppTheme.snowWhite,
                borderRadius: 16,
                elevation: 1,
                shadowColor: AppTheme.codGray,
              ),
        // Custom border radius for chat bubbles
        clipBehavior: Clip.antiAlias,
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: (isUser
                      ? AppTheme.bodyM.copyWith(color: AppTheme.snowWhite)
                      : AppTheme.bodyM)
                  .copyWith(fontSize: messageFontSize),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('h:mm a').format(timestamp),
                style: (isUser
                        ? AppTheme.labelS.copyWith(color: AppTheme.snowWhite)
                        : AppTheme.labelS
                            .copyWith(color: AppTheme.secondaryText))
                    .copyWith(fontSize: timestampFontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
