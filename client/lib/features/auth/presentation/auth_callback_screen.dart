// ==============================================================================
// Nutrient Earth — Auth Callback Screen
// Production PKCE OAuth & Email Magic-Link Callback Handler
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_destination_resolver.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/services/profile_sync_service.dart';
import '../../onboarding/state/onboarding_journey_state.dart';

class AuthCallbackScreen extends ConsumerStatefulWidget {
  final String? code;
  final String? error;
  final String? errorDescription;
  final String? returnTo;

  const AuthCallbackScreen({
    super.key,
    this.code,
    this.error,
    this.errorDescription,
    this.returnTo,
  });

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _isProcessing = true;
  String _statusMessage = 'Securing your evidence session...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Schedule exchange after first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAuthenticationCallback();
    });
  }

  Future<void> _processAuthenticationCallback() async {
    // 1. Check for provider error in redirect URL
    if (widget.error != null && widget.error!.isNotEmpty) {
      final desc = widget.errorDescription ?? widget.error!;
      setState(() {
        _isProcessing = false;
        _errorMessage = desc.toLowerCase().contains('cancel')
            ? 'Sign-in was cancelled. Please try again.'
            : 'Authentication was declined: $desc';
      });
      return;
    }

    final authService = ref.read(authServiceProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final profileSync = ref.read(profileSyncServiceProvider);
    final journeyNotifier = ref.read(onboardingJourneyProvider.notifier);

    try {
      // 2. PKCE code exchange if code parameter is present
      if (widget.code != null && widget.code!.isNotEmpty) {
        setState(() {
          _statusMessage = 'Exchanging authentication token...';
        });

        try {
          await authService.exchangeCodeForSession(widget.code!);
        } catch (exchangeError) {
          debugPrint('[AuthCallbackScreen] exchangeCodeForSession error: $exchangeError');
          // If exchange failed because session was already automatically established by SDK, continue
          if (!authService.isAuthenticated) {
            rethrow;
          }
        }
      }

      // 3. Verify authenticated user presence
      final user = authService.currentUser;
      if (user == null || !authService.isAuthenticated) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No active session was found. Please sign in again.';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Synchronizing health profile...';
      });

      // 4. Synchronize staged in-flight onboarding responses
      try {
        await profileSync.synchronizeStagedOnboarding(
          user: user,
          notifier: journeyNotifier,
        );
      } catch (syncError) {
        debugPrint('[AuthCallbackScreen] Staged answers sync warning: $syncError');
      }

      // 5. Resolve canonical user destination
      setState(() {
        _statusMessage = 'Opening your personal journey...';
      });

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: profileRepo,
        userId: user.id,
        returnTo: widget.returnTo,
      );

      if (mounted) {
        context.go(destination);
      }
    } catch (e) {
      debugPrint('[AuthCallbackScreen] Callback processing exception: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              'Authentication could not be completed. Please return to sign-in and retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nutrient Earth Brand Emblem
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE4E9E2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140B2B26),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.eco_rounded,
                            size: 36,
                            color: Color(0xFF00251D),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Nutrient Earth',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00251D),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    'EVIDENCE COMPANION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF38675A),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  if (_isProcessing) ...[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00251D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F6359),
                      ),
                    ),
                  ] else ...[
                    // Error state
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFBA1A1A),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage ??
                                  'Authentication failed. Please retry.',
                              style: GoogleFonts.manrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF410002),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => context.go('/auth?mode=signin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00251D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Return to Sign In',
                          style: GoogleFonts.manrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
