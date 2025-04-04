// lib/presentation/widgets/chat/k_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/domain/models/chat_message.dart';
import 'package:intl/intl.dart';

enum MessageType {
  text,
  voice,
  image,
  file,
  system,
}

class KMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final MessageType messageType;
  final MessageStatus status;
  final String? senderName;
  final VoidCallback? onRetry;

  const KMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.messageType = MessageType.text,
    this.status = MessageStatus.delivered,
    this.senderName,
    this.onRetry,
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

    // System messages have a different style
    if (messageType == MessageType.system) {
      return _buildSystemMessage(context, messageFontSize);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show sender name for multi-user chats (only for non-user messages)
          if (senderName != null && !isUser)
            Padding(
              padding: EdgeInsets.only(left: horizontalMargin, bottom: 4),
              child: Text(
                senderName!,
                style: AppTheme.labelM.copyWith(
                  color: AppTheme.secondaryText,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ),

          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: bubbleMaxWidth,
            ),
            margin:
                EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
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
                    shadowColor: AppTheme.codGray.withValues(alpha: 0.05),
                  ),
            // Custom border radius for chat bubbles
            clipBehavior: Clip.antiAlias,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content based on type
                _buildMessageContent(messageFontSize),

                const SizedBox(height: 4),

                // Timestamp and status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Status indicator for user messages
                    if (isUser && status != MessageStatus.delivered)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildStatusIndicator(),
                      ),

                    // Timestamp
                    Text(
                      DateFormat('h:mm a').format(timestamp),
                      style: (isUser
                              ? AppTheme.labelS.copyWith(
                                  color:
                                      AppTheme.snowWhite.withValues(alpha: 0.8))
                              : AppTheme.labelS
                                  .copyWith(color: AppTheme.secondaryText))
                          .copyWith(fontSize: timestampFontSize),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(double fontSize) {
    switch (messageType) {
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.microphone,
              size: 16,
              color: isUser ? AppTheme.snowWhite : AppTheme.electricViolet,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Voice message',
                style: (isUser
                        ? AppTheme.bodyM.copyWith(color: AppTheme.snowWhite)
                        : AppTheme.bodyM)
                    .copyWith(fontSize: fontSize),
              ),
            ),
          ],
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: AppTheme.divider,
                  child: Center(
                    child: Icon(
                      AppIcons.image,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.file,
              size: 16,
              color: isUser ? AppTheme.snowWhite : AppTheme.electricViolet,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: (isUser
                        ? AppTheme.bodyM.copyWith(color: AppTheme.snowWhite)
                        : AppTheme.bodyM)
                    .copyWith(fontSize: fontSize),
              ),
            ),
          ],
        );

      case MessageType.system:
        // Handled separately
        return const SizedBox();

      case MessageType.text:
        return Text(
          message,
          style: (isUser
                  ? AppTheme.bodyM.copyWith(color: AppTheme.snowWhite)
                  : AppTheme.bodyM)
              .copyWith(fontSize: fontSize),
        );
    }
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.snowWhite.withValues(alpha: 0.8)),
          ),
        );

      case MessageStatus.failed:
        return GestureDetector(
          onTap: onRetry,
          child: Icon(
            AppIcons.refresh,
            size: 14,
            color: AppTheme.error.withValues(alpha: 0.9),
          ),
        );

      case MessageStatus.delivered:
        return const SizedBox();
    }
  }

  Widget _buildSystemMessage(BuildContext context, double fontSize) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: AppTheme.glassDecoration(
          baseColor: AppTheme.electricViolet,
          opacity: 0.05,
          borderRadius: 16,
          borderOpacity: 0.1,
        ),
        child: Text(
          message,
          style: AppTheme.labelM.copyWith(
            color: AppTheme.secondaryText,
            fontSize: fontSize - 2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
