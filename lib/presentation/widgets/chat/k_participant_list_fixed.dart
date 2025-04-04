// lib/presentation/widgets/chat/k_participant_list_fixed.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/domain/models/chat_participant.dart';

class KParticipantListFixed extends StatelessWidget {
  final List<ChatParticipant> participants;
  final bool isCompact;
  final Function()? onInviteParticipant;
  final Function(ChatParticipant)? onParticipantTap;
  final Function(ChatParticipant)? onRemoveParticipant;

  const KParticipantListFixed({
    super.key,
    required this.participants,
    this.isCompact = false,
    this.onInviteParticipant,
    this.onParticipantTap,
    this.onRemoveParticipant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with permissions info
        if (!isCompact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants (${participants.length})',
                  style: AppTheme.subtitleM,
                ),
                IconButton(
                  icon: Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context),
                  style: AppTheme.iconButtonStyle(
                      iconColor: AppTheme.secondaryText),
                ),
              ],
            ),
          ),

        // Permissions legend
        if (!isCompact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Host indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.robinsGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.verified,
                          size: 12, color: AppTheme.robinsGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Host',
                        style: AppTheme.labelS
                            .copyWith(color: AppTheme.robinsGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Participant indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.electricViolet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.person,
                          size: 12, color: AppTheme.electricViolet),
                      const SizedBox(width: 4),
                      Text(
                        'Participant',
                        style: AppTheme.labelS
                            .copyWith(color: AppTheme.electricViolet),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Divider
        if (!isCompact) const Divider(),

        // Participants list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return ListTile(
              leading: _buildAvatar(participant),
              title: Text(
                participant.name,
                style: participant.isHost
                    ? AppTheme.subtitleS.copyWith(color: AppTheme.robinsGreen)
                    : AppTheme.subtitleS,
              ),
              subtitle: Text(
                participant.isHost ? 'Host' : 'Participant',
                style: AppTheme.bodyXS.copyWith(color: AppTheme.secondaryText),
              ),
              trailing: participant.isHost
                  ? Icon(AppIcons.verified, color: AppTheme.robinsGreen)
                  : (onRemoveParticipant != null
                      ? IconButton(
                          icon: Icon(AppIcons.close),
                          onPressed: () => onRemoveParticipant!(participant),
                          style: AppTheme.iconButtonStyle(
                              iconColor: AppTheme.secondaryText),
                        )
                      : null),
              onTap: onParticipantTap != null
                  ? () => onParticipantTap!(participant)
                  : null,
            );
          },
        ),

        // Add participant button
        if (onInviteParticipant != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: onInviteParticipant,
              icon: Icon(AppIcons.addUser),
              label: const Text('Invite Participant'),
              style: AppTheme.primaryButtonStyle(),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(ChatParticipant participant) {
    final String initial =
        participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?';

    return Stack(
      children: [
        // Avatar circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: participant.isHost
                ? AppTheme.robinsGreen.withValues(alpha: 0.2)
                : AppTheme.electricViolet.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: participant.isHost
                    ? AppTheme.robinsGreen
                    : AppTheme.electricViolet,
              ),
            ),
          ),
        ),

        // Speaking indicator
        if (participant.isSpeaking)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.yellowSea,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.snowWhite,
                  width: 2,
                ),
              ),
            ),
          ),

        // Online indicator
        if (participant.isOnline)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.snowWhite,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
