// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/presentation/screens/chat/chat_screen.dart';
import 'package:kounselme/presentation/screens/journal/journal_screen.dart';
import 'package:kounselme/presentation/screens/mood/mood_screen.dart';
import 'package:kounselme/presentation/screens/profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeContentScreen(),
    ChatScreen(sessionDuration: const Duration(minutes: 30)),
    const JournalScreen(),
    const MoodScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: AppTheme.getShadow(
            elevation: AppTheme.elevationM,
            shadowColor: AppTheme.codGray,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.snowWhite,
          selectedItemColor: AppTheme.electricViolet,
          unselectedItemColor: AppTheme.secondaryText,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.home),
              activeIcon: Icon(AppIcons.filled(AppIcons.home)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.chat),
              activeIcon: Icon(AppIcons.filled(AppIcons.chat)),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.journal),
              activeIcon: Icon(AppIcons.filled(AppIcons.journal)),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.sentiment),
              activeIcon: Icon(AppIcons.filled(AppIcons.sentiment)),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              activeIcon: Icon(AppIcons.filled(AppIcons.profile)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  // Helper method to get light color for cards based on the main color
  Color _getLightColorForCard(Color color) {
    if (color == AppTheme.electricViolet) {
      return AppTheme.heliotropeLight;
    } else if (color == AppTheme.robinsGreen) {
      return AppTheme.successLight;
    } else if (color == AppTheme.yellowSea) {
      return AppTheme.warningLight;
    } else {
      // Use a default light color for fallback
      return AppTheme.gallery;
    }
  }

  // Helper method to get light color for icons based on the main color
  Color _getLightColorForIcon(Color color) {
    if (color == AppTheme.electricViolet) {
      return AppTheme.heliotrope;
    } else if (color == AppTheme.robinsGreen) {
      return AppTheme.robinsGreenLight;
    } else if (color == AppTheme.yellowSea) {
      return AppTheme.yellowSeaLight;
    } else {
      // Use a default light color for fallback
      return AppTheme.silver;
    }
  }

  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'KounselMe',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                color: AppTheme.electricViolet,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.bell, color: AppTheme.codGray),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: Icon(AppIcons.settings, color: AppTheme.codGray),
            onPressed: () {
              // Show settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sarah',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.heliotropeLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.calendar,
                          color: AppTheme.electricViolet,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your next session',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Today, 3:00 PM',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.codGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                    sessionDuration:
                                        const Duration(minutes: 30)),
                              ),
                            );
                          },
                          child: const Text('Join'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: AppIcons.chat,
                          title: 'Start Therapy',
                          color: AppTheme.robinsGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                    sessionDuration:
                                        const Duration(minutes: 30)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: AppIcons.calendar,
                          title: 'Schedule',
                          color: AppTheme.yellowSea,
                          onTap: () {
                            // Navigate to scheduling screen
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: AppIcons.journal,
                          title: 'Journal',
                          color: AppTheme.electricViolet,
                          onTap: () {
                            // Navigate to journal screen
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: AppIcons.sentiment,
                          title: 'Mood Check',
                          color: AppTheme.robinsGreen,
                          onTap: () {
                            // Navigate to mood check screen
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent sessions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSessionCard(
                    context,
                    title: 'Anxiety Management',
                    date: 'Yesterday, 4:30 PM',
                    duration: '30 min',
                    onTap: () {
                      // View session details
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSessionCard(
                    context,
                    title: 'Stress Reduction',
                    date: 'Oct 20, 2:00 PM',
                    duration: '60 min',
                    onTap: () {
                      // View session details
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSessionCard(
                    context,
                    title: 'Sleep Improvement',
                    date: 'Oct 18, 7:00 PM',
                    duration: '30 min',
                    onTap: () {
                      // View session details
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Resources
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resources',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.codGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildResourceCard(
                    context,
                    title: 'Mindfulness Meditation',
                    description:
                        'Learn techniques to stay present and reduce anxiety',
                    icon: AppIcons.heart,
                    color: AppTheme.electricViolet,
                    onTap: () {
                      // View resource
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildResourceCard(
                    context,
                    title: 'Sleep Hygiene Guide',
                    description: 'Tips for better sleep quality and habits',
                    icon: AppIcons.star,
                    color: AppTheme.robinsGreen,
                    onTap: () {
                      // View resource
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.electricViolet,
        child: Icon(AppIcons.chat, color: AppTheme.snowWhite),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(sessionDuration: const Duration(minutes: 30)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getLightColorForCard(color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getLightColorForIcon(color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.codGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required String title,
    required String date,
    required String duration,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.snowWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.heliotropeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppIcons.chat,
                color: AppTheme.electricViolet,
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
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.heliotropeLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.electricViolet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.snowWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getLightColorForCard(color),
                borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.arrowRight,
              color: AppTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
