// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  List<Map<String, String>> onboardingData = [
    {
      'title': AppStrings.onboardingTitle1,
      'description': AppStrings.onboardingDesc1,
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': AppStrings.onboardingTitle2,
      'description': AppStrings.onboardingDesc2,
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': AppStrings.onboardingTitle3,
      'description': AppStrings.onboardingDesc3,
      'image': 'assets/images/onboarding3.png',
    },
    {
      'title': AppStrings.onboardingTitle4,
      'description': AppStrings.onboardingDesc4,
      'image': 'assets/images/onboarding4.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppRoutes.navigateTo(context, AppRoutes.login, replace: true);
    }
  }

  void _skipToLogin() {
    AppRoutes.navigateTo(context, AppRoutes.login, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _numPages - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacing4),
                  child: TextButton(
                    onPressed: _skipToLogin,
                    child: const Text('Skip'),
                  ),
                ),
              )
            else
              SizedBox(height: AppDimensions.spacing4 * 2),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _numPages,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image placeholder
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                          ),
                          child: Center(
                            child: Icon(
                              _getIconForPage(index),
                              size: 100,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacing8),
                        Text(
                          onboardingData[index]['title']!,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppDimensions.spacing4),
                        Text(
                          onboardingData[index]['description']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms);
                },
              ),
            ),

            // Pagination indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _numPages,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacing1),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.gray40,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacing6),

            // Bottom button
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacing6,
                AppDimensions.spacing4,
                AppDimensions.spacing6,
                AppDimensions.spacing6,
              ),
              child: PrimaryButton(
                text: _currentPage < _numPages - 1 ? 'Next' : 'Get Started',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.air;
      case 1:
        return Icons.favorite;
      case 2:
        return Icons.map;
      case 3:
        return Icons.track_changes;
      default:
        return Icons.info;
    }
  }
}