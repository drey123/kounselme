// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _journalReminders = true;
  bool _chatNotifications = false;
  bool _moodLogging = true;
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(
        title: Strings.settings,
        backgroundColor: AppTheme.electricViolet,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(AppIcons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Strings.accountAndPrivacy),
            _buildSettingItem(
              icon: AppIcons.profile,
              title: Strings.profileInformation,
              showArrow: true,
              onTap: () {
                // Navigate to profile information
              },
            ),
            _buildSettingItem(
              icon: AppIcons.lock,
              title: Strings.changePassword,
              showArrow: true,
              onTap: () {
                // Navigate to change password
              },
            ),
            _buildSettingItem(
              icon: AppIcons.lock,
              title: Strings.privacySettings,
              showArrow: true,
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            _buildSettingItem(
              icon: AppIcons.attachment,
              title: Strings.dataStorage,
              showArrow: true,
              onTap: () {
                // Navigate to data storage settings
              },
            ),

            _buildSectionHeader(Strings.notifications),
            _buildToggleSettingItem(
              icon: AppIcons.bell,
              title: Strings.enableNotifications,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildToggleSettingItem(
              icon: AppIcons.journal,
              title: Strings.journalReminders,
              value: _journalReminders,
              onChanged: (value) {
                setState(() {
                  _journalReminders = value;
                });
              },
            ),
            _buildToggleSettingItem(
              icon: AppIcons.chat,
              title: Strings.chatNotifications,
              value: _chatNotifications,
              onChanged: (value) {
                setState(() {
                  _chatNotifications = value;
                });
              },
            ),
            _buildToggleSettingItem(
              icon: AppIcons.sentiment,
              title: Strings.moodLogging,
              value: _moodLogging,
              onChanged: (value) {
                setState(() {
                  _moodLogging = value;
                });
              },
            ),

            _buildSectionHeader(Strings.appearance),
            _buildSelectSettingItem(
              icon: AppIcons.edit,
              title: Strings.theme,
              value: _theme,
              onTap: () {
                _showThemeSelector(context);
              },
            ),
            _buildToggleSettingItem(
              icon: AppIcons.topic,
              title: Strings.textSize,
              value: true,
              onChanged: (value) {
                // Text size toggle
              },
            ),
            _buildToggleSettingItem(
              icon: AppIcons.refresh,
              title: Strings.reduceMotion,
              value: true,
              onChanged: (value) {
                // Reduce motion toggle
              },
            ),

            const SizedBox(height: 32),

            // App version
            Center(
              child: Text(
                'KounselMe v1.0.0',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.secondaryText.withAlpha(179),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.codGray,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required bool showArrow,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.codGray,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppTheme.codGray,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                AppIcons.arrowRight,
                color: AppTheme.secondaryText,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.codGray,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.codGray,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.robinsGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.codGray,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppTheme.codGray,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              AppIcons.arrowRight,
              color: AppTheme.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themes = ['System', 'Light', 'Dark'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Theme',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.codGray,
                ),
              ),
              const SizedBox(height: 16),
              ...themes.map((theme) => InkWell(
                    onTap: () {
                      setState(() {
                        _theme = theme;
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            theme == 'System'
                                ? AppIcons.settings
                                : theme == 'Light'
                                    ? AppIcons.star
                                    : AppIcons.star,
                            color: AppTheme.codGray,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            theme,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: AppTheme.codGray,
                            ),
                          ),
                          const Spacer(),
                          if (_theme == theme)
                            const Icon(
                              Icons.check,
                              color: AppTheme.electricViolet,
                            ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
