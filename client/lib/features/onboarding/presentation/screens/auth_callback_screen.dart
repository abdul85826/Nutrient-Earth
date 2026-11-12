// ==============================================================================
// Nutrient Earth — OAuth Callback Processor & Session Restoration Screen
// Handles authorization code exchange via Supabase Flutter SDK (PKCE),
// callback parameter parsing, session establishment, error/cancellation handling,
// and canonical three-tier user routing (New -> Screen 04, Incomplete -> Resume,
// Completed -> Screen 18 Today).
// ==============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/domain/personalization/user_profile_context.dart';
import '../../../../core/services/auth_destination_resolver.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_repository.dart';
import '../../../../core/services/profile_sync_service.dart';
import '../../state/onboarding_journey_state.dart';

class AuthCallbackScreen extends ConsumerStatefulWidget {
  final Map<String, String>? queryParams;

  const AuthCallbackScreen({
    super.key,
    this.queryParams,
  });

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _isLoading = true;
  String _statusMessage = 'Securing clinical authentication session...';
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processOAuthCallback();
    });
  }



  Future<void> _processOAuthCallback() async {
    if (_isProcessing) return;
    _isProcessing = true;

    // Aggregate parameters from GoRouter and browser window
    final params = <String, String>{};
    if (widget.queryParams != null) {
      params.addAll(widget.queryParams!);
    }
    if (kIsWeb) {
      try {
        params.addAll(Uri.base.queryParameters);
        final fragment = Uri.base.fragment;
        if (fragment.isNotEmpty) {
          final queryPart = fragment.contains('?')
              ? fragment.substring(fragment.indexOf('?') + 1)
              : (fragment.startsWith('/') ? (fragment.contains('?') ? fragment.split('?').last : '') : fragment);
          if (queryPart.contains('=')) {
            params.addAll(Uri.splitQueryString(queryPart));
          }
        }
      } catch (_) {}
    }

    // 1. Check for cancellation or provider errors
    final error = params['error'] ?? params['error_code'];
    final errorDescription = params['error_description'];

    if (error != null) {
      if (error == 'access_denied' || (errorDescription != null && errorDescription.toLowerCase().contains('cancel'))) {
        final isGoogle = errorDescription != null && errorDescription.toLowerCase().contains('google');
        setState(() {
          _isLoading = false;
          _statusMessage = 'Sign-in was cancelled.';
          _errorMessage = isGoogle
              ? 'Google sign-in was cancelled. Returning to sign-in screen...'
              : 'Sign-in was cancelled. Returning to sign-in screen...';
        });
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) {
          if (GoRouter.maybeOf(context) != null) {
            context.go('/auth?mode=signin');
          }
        }
        return;
      }

      if (error == 'otp_expired' ||
          (errorDescription != null &&
              (errorDescription.toLowerCase().contains('expired') ||
                  errorDescription.toLowerCase().contains('invalid')))) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Your sign-in link has expired or has already been used. Please request a new link.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorDescription ?? 'Authentication failed: $error';
      });
      return;
    }

    final code = params['code'];
    final auth = ref.read(authServiceProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    try {
      // 2. Session verification and code exchange via Supabase SDK
      if (!auth.isAuthenticated) {
        Session? activeSession = SupabaseConfig.client?.auth.currentSession;

        if (activeSession == null && code != null && code.trim().isNotEmpty) {
          setState(() {
            _statusMessage = 'Securing clinical authentication session...';
          });

          // Wait up to 1500ms for Gotrue's internal auto-exchange on web
          try {
            final authState = await SupabaseConfig.client?.auth.onAuthStateChange
                .firstWhere((e) => e.session != null)
                .timeout(const Duration(milliseconds: 1500));
            activeSession = authState?.session;
          } catch (_) {
            // Internal listener timed out; perform explicit exchange below
          }

          if (activeSession == null) {
            try {
              final exchangeResponse = await auth.exchangeCodeForSession(code.trim());
              activeSession = exchangeResponse.session;
            } catch (exchangeError) {
              // Final check: did internal Gotrue complete the exchange concurrently?
              activeSession = SupabaseConfig.client?.auth.currentSession;
              if (activeSession == null) {
                final errStr = exchangeError.toString().toLowerCase();
                if (errStr.contains('expired') || errStr.contains('invalid') || errStr.contains('already used')) {
                  throw Exception('Your sign-in link has expired or has already been used. Please request a fresh link.');
                }
                throw Exception('Authorization code expired or invalid: $exchangeError');
              }
            }
          }
        } else if (activeSession == null) {
          // If no code present and no session, wait up to 1500ms for session restoration from local storage
          await Future.delayed(const Duration(milliseconds: 1200));
          activeSession = SupabaseConfig.client?.auth.currentSession;
          if (activeSession == null && !auth.isAuthenticated) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'No active authentication session found. Please sign in again.';
            });
            return;
          }
        }
      }

      // Re-verify authenticated user session
      final user = auth.currentUser ?? SupabaseConfig.client?.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication could not establish a valid user context.';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Verifying health profile and onboarding state...';
      });

      // 3. User Routing Enforcement via AuthDestinationResolver
      final profile = await profileRepo.getCurrentUserProfile(explicitUserId: user.id);

      if (!mounted) return;

      if (profile == null) {
        // New User: Initialize baseline profile context and persist
        final rawName = (user.userMetadata?['full_name'] as String?)?.trim() ??
            (user.userMetadata?['name'] as String?)?.trim() ??
            user.email?.split('@').first ??
            'User';

        final baseline = UserProfileContext(
          userId: user.id,
          displayName: rawName.isNotEmpty ? rawName : 'User',
          age: 0,
          biologicalSex: 'unspecified',
          primaryGoals: const [],
          activityLevel: '',
          dietaryPreference: '',
          budgetConstraint: '',
          willingnessToChange: '',
          onboardingCompleted: false,
        );

        await profileRepo.saveUserProfile(baseline);
      }

      // Synchronize staged onboarding answers if present
      await ref.read(profileSyncServiceProvider).synchronizeStagedOnboarding(
        user: user,
        notifier: ref.read(onboardingJourneyProvider.notifier),
      );

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: profileRepo,
        userId: user.id,
        returnTo: params['returnTo'],
      );

      if (mounted) {
        if (GoRouter.maybeOf(context) != null) {
          context.go(destination);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication verification error: ${e.toString().replaceAll('Exception: ', '')}';
      });
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Brand Monogram Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF0EEE9),
                      border: Border.all(
                        color: const Color(0xFFC1C8C4).withValues(alpha: 0.40),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B2B26).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.eco_rounded, size: 32, color: Color(0xFF0B2B26)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NUTRIENT EARTH',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 14 * 0.24,
                      color: const Color(0xFF0B2B26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SECURE OAUTH VERIFICATION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: const Color(0xFF4F6359),
                    ),
                  ),
                  const SizedBox(height: 36),

                  if (_isLoading) ...[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF0B2B26),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F6359),
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1C8C8)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 28, color: Color(0xFFBA1A1A)),
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7E1010),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.go('/auth?mode=signin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B2B26),
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
                            fontWeight: FontWeight.w600,
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
