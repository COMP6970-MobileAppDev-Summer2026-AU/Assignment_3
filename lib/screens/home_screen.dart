// =============================================================================
// screens/home_screen.dart
// App landing page — design mirrors Assignment 2 splash screen
// Favorite Explorer — COMP 6910 Assignment 3
// Developer: Jahidul Arafat (JAJI)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'content_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
            parent: _animController, curve: Curves.elasticOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    final prefs          = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            onboardingDone
                ? const ContentView()
                : const OnboardingScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final primaryContainer =
        Theme.of(context).colorScheme.primaryContainer;

    return GestureDetector(
      onTap: _enter,
      child: Container(
        // Sky-style gradient matching Assignment 2 feel
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryContainer,
              primaryContainer.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // ── Logo ────────────────────────────────────────
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── App Name ─────────────────────────────────────
                        Text(
                          'Favorite Explorer',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Discover · Save · Explore',
                          style: TextStyle(
                            fontSize: 15,
                            color: primary.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Developer Card ───────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: primary.withValues(alpha: 0.3),
                                width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.person_outline,
                                  color: primary, size: 28),
                              const SizedBox(height: 8),
                              const Text(
                                'Developed by',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Text(
                                'Jahidul Arafat',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _infoRow(
                                  context,
                                  Icons.school_outlined,
                                  'PhD Student, Dept. of Computer Science & Software Engineering'),
                              _infoRow(
                                  context,
                                  Icons.star_outline,
                                  'Presidential & Woltosz Graduate Research Fellow'),
                              _infoRow(
                                  context,
                                  Icons.work_outline,
                                  'Former L3 Senior Solution Architect (MLOps), Oracle (Singapore)'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── App Info Card ────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'About This App',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _appInfoRow('App',
                                  'Favorite Explorer'),
                              _appInfoRow('Course',
                                  'COMP 6910 — Mobile App Development'),
                              _appInfoRow('Module',
                                  'M3 — State & Architecture'),
                              _appInfoRow('Assignment',
                                  'Assignment 3'),
                              _appInfoRow('Track',
                                  'Flutter / Dart'),
                              _appInfoRow('Version', '1.0.0'),
                              _appInfoRow('Categories',
                                  'Cities · Hobbies · Books'),
                              _appInfoRow('Enhancements',
                                  '14 Beyond-Requirements'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Enter Button ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.explore, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Start Exploring',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          'Tap anywhere to continue',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers — exactly like Assignment 2 ──────────────────────────────

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15,
              color: primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _appInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
