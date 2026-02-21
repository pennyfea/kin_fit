import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../../utils/extensions/context_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Never Miss\nA Workout.',
      description:
          'Join a private squad of friends and stay accountable together.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    _OnboardingPage(
      title: 'Snap Daily\nCheck-ins.',
      description: 'Take a quick photo after your workout to prove you did it.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    _OnboardingPage(
      title: 'Keep The\nStreak Alive.',
      description:
          "If one person misses a day, the whole squad's streak resets. Don't be that guy.",
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(Routes.login),
                child: Text(
                  'Skip',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // Pager with Background Image
            Expanded(
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset(
                        _pages[_currentPage].imagePath,
                        key: ValueKey<int>(_currentPage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.colorScheme.surface.withValues(alpha: 0.1),
                            context.colorScheme.surface.withValues(alpha: 0.5),
                            context.colorScheme.surface,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.title,
                              style: context.textTheme.displayMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go(Routes.login);
                        }
                      },
                      style: ElevatedButton.styleFrom(elevation: 0),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  _OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
