// =============================================================================
// screens/onboarding_screen.dart
// Enhancement #12 — First-launch welcome screen
// Shows 4 pages explaining the app, then saves seen flag to SharedPreferences
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      emoji: '🌍',
      title: 'Discover Your World',
      body:
          'Browse cities, hobbies, and books from around the world. '
          'Find things that inspire you every day.',
      color: Color(0xFF7C4DFF),
    ),
    _OnboardPage(
      emoji: '❤️',
      title: 'Save Your Favorites',
      body:
          'Tap the heart on anything you love. '
          'Your favorites are saved and always ready for you.',
      color: Color(0xFFE91E8C),
    ),
    _OnboardPage(
      emoji: '📝',
      title: 'Add Personal Notes',
      body:
          'Tap any item to add your own note — a memory, a reminder, '
          'or anything you want to remember about it.',
      color: Color(0xFF00897B),
    ),
    _OnboardPage(
      emoji: '⚙️',
      title: 'Make It Yours',
      body:
          'Choose your accent color, font size, and default tab. '
          'Everything is saved so the app feels just right.',
      color: Color(0xFFFF6D00),
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ContentView(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Pages ───────────────────────────────────────────────────
          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
          ),

          // ── Bottom controls ─────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 48,
            child: Column(
              children: [
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width:  _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      // Skip (hidden on last page)
                      if (_page < _pages.length - 1)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                            ),
                            onPressed: _finish,
                            child: const Text('Skip'),
                          ),
                        ),

                      if (_page < _pages.length - 1)
                        const SizedBox(width: 12),

                      // Next / Get Started
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                _pages[_page].color,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            if (_page < _pages.length - 1) {
                              _ctrl.nextPage(
                                duration: const Duration(
                                    milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _finish();
                            }
                          },
                          child: Text(
                            _page < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page data model ───────────────────────────────────────────────────────────

class _OnboardPage {
  final String emoji;
  final String title;
  final String body;
  final Color  color;
  final bool   isLast;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
    this.isLast = false,
  });
}

// ── Single page view ──────────────────────────────────────────────────────────

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            page.color,
            page.color.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji in circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(page.emoji,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),

              const SizedBox(height: 48),

              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                page.body,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
