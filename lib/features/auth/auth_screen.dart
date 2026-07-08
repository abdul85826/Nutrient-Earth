import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/bootstrap/identity_manager.dart';
import '../../core/lifecycle/app_lifecycle_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_utils.dart';

/// Auth Screen — Google Sign-In + Guest access only.
/// Email/OTP and Magic Link are disabled until email confirmation flow is ready.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      // The scheme MUST match applicationId in build.gradle.kts AND
      // android:scheme in AndroidManifest.xml intent-filter.
      // Current applicationId = com.nutrientearth.app
      final String redirectTo = kIsWeb
          ? Uri.base.origin
          : 'com.nutrientearth.app://login-callback/';

      debugPrint('AUTH: Triggering Google OAuth');

      final success = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );

      if (success) {
        debugPrint('AUTH: Google OAuth initiated — awaiting callback');
      } else {
        throw Exception('OAuth trigger failed to initiate.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getFriendlyErrorMessage(e)),
            backgroundColor: NEColors.statusRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ne_auth_mode', 'guest');
      await IdentityManager().initialize();
      await ref.read(appLifecycleProvider.notifier).initializeApp();
      debugPrint('AUTH: Guest mode initialized');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getFriendlyErrorMessage(e)),
            backgroundColor: NEColors.statusRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NEColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: NEColors.morningGradient,
                          boxShadow: [
                            BoxShadow(
                              color: NEColors.accent.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.black, size: 44),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Nutrient Earth',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        fontSize: 32,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your Biological Operating System',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: NEColors.textSecondary,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Google Sign-In
                    _AuthButton(
                      onTap: _handleGoogleSignIn,
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Sign in with Google',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      isLoading: _isLoading,
                    ).animate().shimmer(duration: 2.seconds, color: Colors.white54),

                    const SizedBox(height: 16),

                    // Guest Sign-In
                    _AuthButton(
                      onTap: _handleGuestSignIn,
                      icon: Icons.person_outline_rounded,
                      label: 'Continue as Guest',
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white70,
                      border: const BorderSide(color: Colors.white24),
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Connect your biological data to begin intelligence calibration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: NEColors.textTertiary, fontSize: 11),
                    ),

                    const SizedBox(height: 48),

                    Text(
                      'By continuing, you agree to our Terms and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NEColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: NEColors.scrim,
              child: const Center(
                child: CircularProgressIndicator(color: NEColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide? border;
  final bool isLoading;

  const _AuthButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: border != null ? Border.fromBorderSide(border!) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            else
              Icon(icon, color: foregroundColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
