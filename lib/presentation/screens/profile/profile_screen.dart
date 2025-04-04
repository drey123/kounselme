// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/data/remote/auth_service.dart';
import 'package:kounselme/core/constants/string_constants.dart';
import 'package:kounselme/presentation/screens/auth/login_screen.dart';
import 'package:kounselme/presentation/widgets/common/k_app_bar.dart';
import 'package:kounselme/presentation/widgets/common/k_button.dart';
import 'package:kounselme/presentation/widgets/common/k_card.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const KAppBar(
        title: Strings.profile,
        backgroundColor: AppTheme.electricViolet,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.electricViolet, AppTheme.heliotrope],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Profile image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.gallery,
                        child: Icon(
                          AppIcons.profile,
                          size: 60,
                          color: AppTheme.snowWhite,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.snowWhite,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.codGray.withAlpha(25),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            AppIcons.camera,
                            size: 20,
                            color: AppTheme.electricViolet,
                          ),
                          onPressed: () {
                            // Add photo functionality
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User info
                  const Text(
                    'Jane Doe',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.snowWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'jane.doe@example.com',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.snowWhite,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Premium badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.yellowSea,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.codGray,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.codGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            KCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(120, Strings.journalEntries),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.divider,
                      ),
                      _buildStat(45, Strings.chatSessions),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.divider,
                      ),
                      _buildStat(66, Strings.moodEntries),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    Strings.viewDetails,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.electricViolet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings sections
            _buildSettingsSection(
              AppIcons.profile,
              Strings.accountSettings,
              AppTheme.electricViolet,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              AppIcons.settings,
              Strings.appPreferences,
              AppTheme.robinsGreen,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              AppIcons.star,
              Strings.subscription,
              AppTheme.yellowSea,
              subtitle: 'Premium',
              showButton: true,
              buttonText: Strings.upgrade,
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Sign out button
            KButton(
              label: 'Sign Out',
              type: KButtonType.outline,
              fullWidth: true,
              onPressed: () async {
                try {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(int number, String label) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.codGray,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildSettingsSection(
    IconData icon,
    String title,
    Color color, {
    String? subtitle,
    bool showButton = false,
    String buttonText = '',
    required VoidCallback onTap,
  }) {
    return KCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.codGray,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showButton)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.yellowSea,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.codGray,
                ),
              ),
            )
          else
            Icon(
              AppIcons.arrowRight,
              color: AppTheme.secondaryText,
              size: 20,
            ),
        ],
      ),
    );
  }
}
