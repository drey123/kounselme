import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/domain/models/chat_participant.dart';

class KParticipantList extends StatelessWidget {
  final List<ChatParticipant> participants;
  final VoidCallback? onInviteParticipant;
  final Function(ChatParticipant)? onParticipantTap;
  final bool isCompact;

  const KParticipantList({
    super.key,
    required this.participants,
    this.onInviteParticipant,
    this.onParticipantTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    // Define font sizes based on screen size
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isCompact) ...[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.codGray,
                  ),
                ),
                Text(
                  '${participants.length} people',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: smallFontSize,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
        ],

        // Participant list
        isCompact ? _buildCompactList(context) : _buildFullList(context),

        // Invite button
        if (!isCompact && onInviteParticipant != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: onInviteParticipant,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.addUser,
                      color: AppTheme.electricViolet,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Invite Participant',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.electricViolet,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactList(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isSmallScreen ? 36.0 : 40.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          ...participants.map((participant) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: onParticipantTap != null
                      ? () => onParticipantTap!(participant)
                      : null,
                  child: _buildParticipantAvatar(participant),
                ),
              )),
          if (onInviteParticipant != null)
            InkWell(
              onTap: onInviteParticipant,
              borderRadius: BorderRadius.circular(avatarSize / 2),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  AppIcons.addUser,
                  color: AppTheme.electricViolet,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullList(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final nameFontSize = isSmallScreen ? 14.0 : 16.0;
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;
    final statusFontSize = isSmallScreen ? 12.0 : 14.0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return ListTile(
          onTap: onParticipantTap != null
              ? () => onParticipantTap!(participant)
              : null,
          leading: _buildParticipantAvatar(participant),
          title: Row(
            children: [
              Text(
                participant.name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (participant.isHost) ...[
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6, vertical: isSmallScreen ? 1 : 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.verified,
                        color: AppTheme.electricViolet,
                        size: labelFontSize + 2,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Host',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: labelFontSize,
                          color: AppTheme.electricViolet,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            participant.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: statusFontSize,
              color: participant.isOnline
                  ? AppTheme.robinsGreen
                  : AppTheme.codGray.withValues(alpha: 0.5),
            ),
          ),
          trailing: participant.isSpeaking
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.robinsGreen,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildParticipantAvatar(ChatParticipant participant) {
    return Builder(builder: (context) {
      // Responsive sizing based on screen width
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final avatarRadius = isSmallScreen ? 18.0 : 20.0;
      final initialsFontSize = isSmallScreen ? 14.0 : 16.0;
      final indicatorSize = isSmallScreen ? 10.0 : 12.0;
      final borderWidth = isSmallScreen ? 1.5 : 2.0;

      return Stack(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.purple.withValues(alpha: 0.2),
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null
                ? Text(
                    participant.name.isNotEmpty
                        ? participant.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: initialsFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.electricViolet,
                    ),
                  )
                : null,
          ),
          if (participant.isSpeaking)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: AppTheme.robinsGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.snowWhite,
                    width: borderWidth,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
