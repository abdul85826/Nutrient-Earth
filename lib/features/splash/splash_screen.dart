import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/lifecycle/app_lifecycle_notifier.dart';
import '../../core/lifecycle/app_lifecycle_state.dart';
import '../../core/utils/error_utils.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifecycle = ref.watch(appLifecycleProvider);
    final startupState = lifecycle.startupState;
    final errorMessage = lifecycle.error;

    return Scaffold(
      backgroundColor: NEColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BRANDING
              _buildLogo(),
              const SizedBox(height: 32),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildSubtitle(context),
              
              const SizedBox(height: 64),

              // LOADING OR ERROR
              if (startupState == AppStartupState.error)
                _buildErrorFailsafe(errorMessage)
              else
                _buildLoader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: NEColors.morningGradient,
        boxShadow: [
          BoxShadow(
            color: NEColors.accent.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_mosaic_rounded,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'NUTRIENT EARTH',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'BIOLOGICAL OPERATING SYSTEM',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: NEColors.accent.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
    );
  }

  Widget _buildLoader() {
    return const CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(NEColors.accent),
    );
  }

  Widget _buildErrorFailsafe(String? error) {
    final friendlyMsg = getFriendlyErrorMessage(error);
    return Column(
      children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 48),
        const SizedBox(height: 16),
        const Text(
          "Initialization Issue",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Text(
            friendlyMsg,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.read(appLifecycleProvider.notifier).initializeApp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NEColors.accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Retry Connection"),
        ),
      ],
    );
  }
}
