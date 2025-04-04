// lib/presentation/widgets/chat/k_chat_history_drawer.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final String previewMessage;
  final DateTime timestamp;
  final int durationMinutes;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.previewMessage,
    required this.timestamp,
    required this.durationMinutes,
  });
}

class KChatHistoryDrawer extends StatefulWidget {
  final List<ChatHistoryItem> chatHistory;
  final Function(String sessionId) onSelectChat;
  final VoidCallback onNewChat;

  const KChatHistoryDrawer({
    super.key,
    required this.chatHistory,
    required this.onSelectChat,
    required this.onNewChat,
  });

  @override
  State<KChatHistoryDrawer> createState() => _KChatHistoryDrawerState();
}

class _KChatHistoryDrawerState extends State<KChatHistoryDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<ChatHistoryItem> get filteredChats {
    if (_searchQuery.isEmpty) return widget.chatHistory;

    return widget.chatHistory.where((chat) {
      return chat.title.toLowerCase().contains(_searchQuery) ||
          chat.previewMessage.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // Group chats by time periods
  Map<String, List<ChatHistoryItem>> get groupedChats {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final result = <String, List<ChatHistoryItem>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final chat in filteredChats) {
      final chatDate = DateTime(
        chat.timestamp.year,
        chat.timestamp.month,
        chat.timestamp.day,
      );

      if (chatDate == today) {
        result['Today']!.add(chat);
      } else if (chatDate == yesterday) {
        result['Yesterday']!.add(chat);
      } else if (chatDate.isAfter(weekAgo)) {
        result['This Week']!.add(chat);
      } else {
        result['Earlier']!.add(chat);
      }
    }

    // Sort each group by time (newest first)
    for (final key in result.keys) {
      result[key]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.snowWhite,
      child: Column(
        children: [
          // Drawer header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.electricViolet,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chat History',
                        style: AppTheme.headingM.copyWith(
                          color: AppTheme.snowWhite,
                        ),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.close, color: AppTheme.snowWhite),
                        onPressed: () => Navigator.pop(context),
                        style: AppTheme.iconButtonStyle(
                          iconColor: AppTheme.snowWhite,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    height: 44,
                    decoration: AppTheme.glassDecoration(
                      baseColor: AppTheme.snowWhite,
                      opacity: 0.15,
                      borderRadius: AppTheme.radiusL,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTheme.bodyM.copyWith(color: AppTheme.snowWhite),
                      decoration: InputDecoration(
                        hintText: 'Search chats',
                        hintStyle: AppTheme.bodyM.copyWith(
                          color: AppTheme.snowWhite.withValues(alpha: 0.7),
                        ),
                        prefixIcon: Icon(
                          AppIcons.search,
                          color: AppTheme.snowWhite.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Chat history list
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildFilteredList()
                : _buildGroupedList(),
          ),

          // New chat button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onNewChat();
              },
              icon: Icon(AppIcons.addCircle),
              label: const Text('New Chat'),
              style: AppTheme.primaryButtonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    if (filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.search,
              size: 48,
              color: AppTheme.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matching chats found',
              style: AppTheme.subtitleM.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildGroupedList() {
    return ListView.builder(
      itemCount: groupedChats.keys.length,
      itemBuilder: (context, sectionIndex) {
        final sectionKey = groupedChats.keys.elementAt(sectionIndex);
        final sectionChats = groupedChats[sectionKey]!;

        if (sectionChats.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                sectionKey,
                style: AppTheme.subtitleM.copyWith(
                  color: AppTheme.electricViolet,
                ),
              ),
            ),

            // Section chats
            ...sectionChats.map((chat) => _buildChatItem(chat)),

            // Divider except for last section
            if (sectionIndex < groupedChats.keys.length - 1) const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildChatItem(ChatHistoryItem chat) {
    // Format relative time
    String getRelativeTime() {
      final now = DateTime.now();
      final difference = now.difference(chat.timestamp);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.electricViolet.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Center(
          child: Icon(
            AppIcons.chat,
            color: AppTheme.electricViolet,
            size: 24,
          ),
        ),
      ),
      title: Text(
        chat.title,
        style: AppTheme.subtitleM,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Preview message
          Text(
            chat.previewMessage,
            style: AppTheme.bodyS.copyWith(
              color: AppTheme.secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Relative time
          Text(
            getRelativeTime(),
            style: AppTheme.labelM.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.robinsGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXS),
            ),
            child: Text(
              '${chat.durationMinutes} min',
              style: AppTheme.labelS.copyWith(
                color: AppTheme.robinsGreen,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onSelectChat(chat.id);
      },
    );
  }
}
