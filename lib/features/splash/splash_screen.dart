import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward().then((_) => _navigateToNext());
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Navigate to root and let the router's redirect logic handle the destination
    // (e.g., /auth, /onboarding, or /)
    context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle background glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.nutrientGreen.withValues(alpha: 0.15),
                    AppColors.nutrientGreen.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'NUTRIENT EARTH',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          letterSpacing: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PRECISION WELLNESS',
                        style: TextStyle(
                          color: AppColors.nutrientGreen.withValues(alpha: 0.5),
                          letterSpacing: 4,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 1,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.nutrientGreen.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
