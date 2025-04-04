// lib/presentation/widgets/common/k_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';

class KBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snowWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.codGray.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.snowWhite,
          selectedItemColor: AppTheme.electricViolet,
          unselectedItemColor: AppTheme.secondaryText,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.home),
              activeIcon: Icon(AppIcons.filled(AppIcons.home)),
              label: Strings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.chat),
              activeIcon: Icon(AppIcons.filled(AppIcons.chat)),
              label: Strings.chat,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.journal),
              activeIcon: Icon(AppIcons.filled(AppIcons.journal)),
              label: Strings.journal,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.sentiment),
              activeIcon: Icon(AppIcons.filled(AppIcons.sentiment)),
              label: Strings.mood,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              activeIcon: Icon(AppIcons.filled(AppIcons.profile)),
              label: Strings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
