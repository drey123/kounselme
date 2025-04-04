// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';
import 'package:kounselme/presentation/screens/home/home_screen.dart';
import 'package:kounselme/presentation/widgets/common/k_button.dart';
import 'package:kounselme/presentation/widgets/common/k_gradient_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      Strings.skip,
                      style: TextStyle(
                        color: AppTheme.snowWhite,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildFeaturePage(),
                    _buildPrivacyPage(),
                    _buildCompletePage(),
                  ],
                ),
              ),

              // Dots indicator and next button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots indicator
                    Row(
                      children: List.generate(
                        _totalPages,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppTheme.snowWhite
                                : AppTheme.snowWhite.withAlpha(77),
                          ),
                        ),
                      ),
                    ),

                    // Next button
                    KButton(
                      label: _currentPage == _totalPages - 1
                          ? Strings.startYourJourney
                          : Strings.next,
                      onPressed: _nextPage,
                      type: KButtonType.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            Strings.discoverKounselMePower,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.snowWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            Strings.exploreFeatures,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.snowWhite.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            icon: Icons.chat_bubble_outline,
            title: Strings.aiChat,
            description: Strings.aiChatDesc,
            color: AppTheme.robinsGreen,
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(
            icon: Icons.book_outlined,
            title: Strings.journal,
            description: Strings.journalingDesc,
            color: AppTheme.yellowSea,
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(
            icon: Icons.show_chart,
            title: Strings.moodTracking,
            description: Strings.moodTrackingDesc,
            color: AppTheme.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 80,
            color: AppTheme.snowWhite,
          ),
          const SizedBox(height: 24),
          const Text(
            Strings.yourPrivacyComesFirst,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.snowWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            Strings.conversationsStored,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.snowWhite.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildPrivacyFeature(Icons.lock, Strings.endToEndEncrypted),
          const SizedBox(height: 16),
          _buildPrivacyFeature(Icons.phone_android, Strings.localFirstAI),
          const SizedBox(height: 16),
          _buildPrivacyFeature(Icons.control_point, Strings.youControlSaved),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple illustration of a person using the app
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.snowWhite.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppTheme.snowWhite,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            Strings.youreAllSet,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.snowWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            Strings.beginJourney,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.snowWhite.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features checklist
          _buildChecklistItem(Strings.aiChat),
          const SizedBox(height: 8),
          _buildChecklistItem(Strings.journal),
          const SizedBox(height: 8),
          _buildChecklistItem(Strings.moodTracking),
          const SizedBox(height: 24),

          Text(
            Strings.premiumToolsAvailable,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.yellowSea,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snowWhite.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.snowWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.snowWhite.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.snowWhite.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.snowWhite,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: AppTheme.snowWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: AppTheme.robinsGreen,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.snowWhite,
          ),
        ),
      ],
    );
  }
}
