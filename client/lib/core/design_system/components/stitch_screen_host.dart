// ==============================================================================
// Nutrient Earth — Exact Stitch Screen Host Widget
// Directly embeds the authentic, pixel-exact Stitch HTML/CSS/JS screens
// with bidirectional JavaScript bridge connecting to Riverpod & Supabase.
// ==============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../../features/onboarding/data/onboarding_storage_service.dart';
import '../../../features/onboarding/state/onboarding_journey_state.dart';
import '../../../features/today/state/today_state.dart';
import '../../services/auth_destination_resolver.dart';
import '../../services/auth_service.dart';
import '../../services/profile_repository.dart';
import '../../domain/personalization/user_profile_context.dart';
import '../../services/profile_sync_service.dart';
import '../../services/task_repository.dart';
import '../../services/learn_repository.dart';
import '../tokens/ne_tokens.dart';
import '../../../features/today/presentation/widgets/learn_detail_modal.dart';
import '../../../features/today/presentation/widgets/research_result_modal.dart';
import 'stitch_view_interface.dart';
import 'stitch_view_selector.dart';

class StitchScreenHostWidget extends ConsumerStatefulWidget {
  final int screenIndex;
  final String? returnTo;
  final void Function(String type, Map<String, dynamic> payload)? onAction;

  const StitchScreenHostWidget({
    super.key,
    required this.screenIndex,
    this.returnTo,
    this.onAction,
  });

  @override
  ConsumerState<StitchScreenHostWidget> createState() =>
      _StitchScreenHostWidgetState();
}

class _StitchScreenHostWidgetState
    extends ConsumerState<StitchScreenHostWidget> {
  late final StitchViewPlatform _platformView;
  bool _isAuthenticating = false;
  String _authLoadingMessage = 'Connecting with Google...';
  late final String _initialUrl;

  @override
  void initState() {
    super.initState();
    _platformView = getPlatformStitchView();
    _initialUrl = _computeInitialUrl();
  }

  String _computeInitialUrl() {
    final idxStr = widget.screenIndex.toString().padLeft(2, '0');
    final journey = ref.read(onboardingJourneyProvider);
    final params = <String, String>{};

    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      params['returnTo'] = widget.returnTo!;
    }

    if (widget.screenIndex == 3) {
      final siteKey = AppConfig.turnstileSiteKey;
      if (siteKey.isNotEmpty) params['sitekey'] = siteKey;
    } else if (widget.screenIndex == 4) {
      if (journey.healthGoals.isNotEmpty) {
        params['goals'] = journey.healthGoals.join(',');
      }
    } else if (widget.screenIndex == 5) {
      if (journey.healthGoals.isNotEmpty) {
        params['goals'] = journey.healthGoals.join(',');
      }
      if (journey.selectedConcernIds.isNotEmpty) {
        params['concerns'] = journey.selectedConcernIds.join(',');
      }
      if (journey.difficulties.isNotEmpty) {
        params['difficulties'] = journey.difficulties.join(',');
      }
      if (journey.difficultiesNote.isNotEmpty) {
        params['note'] = journey.difficultiesNote;
      }
    } else if (widget.screenIndex == 6) {
      if (journey.healthGoals.isNotEmpty) {
        params['goals'] = journey.healthGoals.join(',');
      }
      if (journey.selectedConcernIds.isNotEmpty) {
        params['concerns'] = journey.selectedConcernIds.join(',');
      }
      if (journey.difficulties.isNotEmpty) {
        params['difficulties'] = journey.difficulties.join(',');
      }
      if (journey.dailyImpacts.isNotEmpty) {
        params['impacts'] = jsonEncode(journey.dailyImpacts);
      }
      if (journey.impactFluctuates) {
        params['fluctuates'] = 'true';
      }
      if (journey.dailyImpactsSkipped) {
        params['skipped'] = 'true';
      }
    } else if (widget.screenIndex == 7) {
      if (journey.dietaryPattern.isNotEmpty) {
        params['pattern'] = journey.dietaryPattern;
      }
      if (journey.customDietaryPattern.isNotEmpty) {
        params['custom'] = journey.customDietaryPattern;
      }
      if (journey.foodIntolerances.isNotEmpty) {
        params['intolerances'] = journey.foodIntolerances.join(',');
      }
      if (journey.foodsToAvoid.isNotEmpty) {
        params['avoid'] = journey.foodsToAvoid.join(',');
      }
    } else if (widget.screenIndex == 8) {
      if (journey.healthGoals.isNotEmpty) {
        params['goals'] = journey.healthGoals.join(',');
      }
      if (journey.difficulties.isNotEmpty) {
        params['difficulties'] = journey.difficulties.join(',');
      }
      if (journey.dietaryPattern.isNotEmpty) {
        params['pattern'] = journey.dietaryPattern;
      }
      if (journey.foodIntolerances.isNotEmpty) {
        params['intolerances'] = journey.foodIntolerances.join(',');
      }
      if (journey.foodsToAvoid.isNotEmpty) {
        params['avoid'] = journey.foodsToAvoid.join(',');
      }
      if (journey.dailyImpacts.isNotEmpty) {
        params['impacts'] = jsonEncode(journey.dailyImpacts);
      }
    } else if (widget.screenIndex == 9) {
      if (journey.firstName.isNotEmpty) params['name'] = journey.firstName;
      if (journey.age > 0) params['age'] = journey.age.toString();
      if (journey.biologicalSex.isNotEmpty && journey.biologicalSex != 'unspecified') {
        params['gender'] = journey.biologicalSex;
      }
    } else if (widget.screenIndex == 10) {
      if (journey.heightCm != null) {
        params['heightCm'] = journey.heightCm.toString();
      }
      if (journey.weightKg != null) {
        params['weightKg'] = journey.weightKg.toString();
      }
      params['heightUnit'] = journey.heightUnit;
      params['weightUnit'] = journey.weightUnit;
      if (journey.weightSkipped) params['weightSkipped'] = 'true';
    } else if (widget.screenIndex == 11) {
      if (journey.prioritizedConcerns.isNotEmpty) {
        params['concerns'] = journey.prioritizedConcerns.join(',');
      }
    } else if (widget.screenIndex == 12) {
      if (journey.strictlyNoRestrictions) {
        params['strictlyNoRestrictions'] = 'true';
      }
      if (journey.allergens.isNotEmpty) {
        params['allergens'] = journey.allergens.join(',');
      }
      if (journey.customAllergen.isNotEmpty) {
        params['customAllergen'] = journey.customAllergen;
      }
    } else if (widget.screenIndex == 13) {
      if (journey.eatingRoutine.isNotEmpty) {
        params['routine'] = journey.eatingRoutine;
      }
    } else if (widget.screenIndex == 14) {
      if (journey.activityLevel.isNotEmpty) {
        params['level'] = journey.activityLevel;
      }
    } else if (widget.screenIndex == 15) {
      if (journey.sleepQuality.isNotEmpty) {
        params['quality'] = journey.sleepQuality;
      }
    } else if (widget.screenIndex == 16) {
      if (journey.knowledgeLevel.isNotEmpty) {
        params['level'] = journey.knowledgeLevel;
      }
    } else if (widget.screenIndex == 17) {
      if (journey.healthGoals.isNotEmpty) {
        params['goals'] = journey.healthGoals.join(',');
      }
      if (journey.difficulties.isNotEmpty) {
        params['difficulties'] = journey.difficulties.join(',');
      }
      if (journey.dailyImpacts.isNotEmpty) {
        params['impacts'] = jsonEncode(journey.dailyImpacts);
      }
      if (journey.dietaryPattern.isNotEmpty) {
        params['pattern'] = journey.dietaryPattern;
      }
      if (journey.foodIntolerances.isNotEmpty) {
        params['intolerances'] = journey.foodIntolerances.join(',');
      }
      if (journey.foodsToAvoid.isNotEmpty) {
        params['avoid'] = journey.foodsToAvoid.join(',');
      }
      if (journey.firstName.isNotEmpty) params['name'] = journey.firstName;
      if (journey.age > 0) params['age'] = journey.age.toString();
      if (journey.heightCm != null) {
        params['heightCm'] = journey.heightCm.toString();
      }
      if (journey.weightKg != null) {
        params['weightKg'] = journey.weightKg.toString();
      }
      if (journey.prioritizedConcerns.isNotEmpty) {
        params['concerns'] = journey.prioritizedConcerns.join(',');
      }
      if (journey.strictlyNoRestrictions) {
        params['strictlyNoRestrictions'] = 'true';
      }
      if (journey.allergens.isNotEmpty) {
        params['allergens'] = journey.allergens.join(',');
      }
      if (journey.customAllergen.isNotEmpty) {
        params['customAllergen'] = journey.customAllergen;
      }
      if (journey.eatingRoutine.isNotEmpty) {
        params['routine'] = journey.eatingRoutine;
      }
      if (journey.activityLevel.isNotEmpty) {
        params['activity'] = journey.activityLevel;
      }
      if (journey.sleepQuality.isNotEmpty) {
        params['sleep'] = journey.sleepQuality;
      }
      if (journey.knowledgeLevel.isNotEmpty) {
        params['knowledge'] = journey.knowledgeLevel;
      }
    } else if (widget.screenIndex == 18) {
      if (journey.firstName.trim().isNotEmpty) {
        params['name'] = journey.firstName.trim();
      } else {
        final cached = ref.read(profileRepositoryProvider).getCachedProfileSync(
            ref.read(authServiceProvider).currentUser?.id);
        if (cached != null &&
            cached.displayName.trim().isNotEmpty &&
            cached.displayName != 'User') {
          params['name'] = cached.displayName.trim();
        }
      }
    }

    final query =
        params.isNotEmpty ? '?${Uri(queryParameters: params).query}' : '';
    return '/stitch/screen_$idxStr/index.html$query';
  }

  @visibleForTesting
  Future<void> handleStitchMessageForTesting(Map<String, dynamic> msg) =>
      _handleStitchMessage(msg);

  Future<void> _handlePostSaveNavigation(String defaultNextRoute) async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final isEditingProfile = widget.returnTo == '/profile';

    if (isEditingProfile && authService.isAuthenticated && user != null) {
      try {
        final journey = ref.read(onboardingJourneyProvider);
        final profileRepo = ref.read(profileRepositoryProvider);
        final existing =
            await profileRepo.getCurrentUserProfile(explicitUserId: user.id);

        final primaryGoalsList = journey.healthGoals.isNotEmpty
            ? journey.healthGoals.toList()
            : (journey.prioritizedConcerns.isNotEmpty
                ? journey.prioritizedConcerns.toList()
                : (existing?.primaryGoals ?? <String>[]));

        final knownConditionsList = <String>[
          ...journey.difficulties.map((d) => 'Difficulty: $d'),
          ...journey.allergens.map((a) => 'Allergy: $a'),
        ];
        if (journey.customAllergen.trim().isNotEmpty) {
          knownConditionsList.add('Allergy: ${journey.customAllergen.trim()}');
        }

        final profile = UserProfileContext(
          userId: user.id.trim(),
          displayName: journey.firstName.trim().isNotEmpty
              ? journey.firstName.trim()
              : (existing?.displayName ?? 'Explorer'),
          age: journey.age > 0 ? journey.age : (existing?.age ?? 0),
          biologicalSex: existing?.biologicalSex ?? 'unspecified',
          primaryGoals: primaryGoalsList,
          activityLevel: journey.activityLevel.isNotEmpty
              ? journey.activityLevel
              : (existing?.activityLevel ?? ''),
          dietaryPreference: journey.dietaryPattern.isNotEmpty
              ? journey.dietaryPattern
              : (existing?.dietaryPreference ?? ''),
          budgetConstraint: existing?.budgetConstraint ?? '',
          willingnessToChange: existing?.willingnessToChange ?? '',
          knownConditions: knownConditionsList.isNotEmpty
              ? knownConditionsList
              : (existing?.knownConditions ?? const []),
          activeSupplements: existing?.activeSupplements ?? const [],
          allergies: journey.allergens.isNotEmpty
              ? journey.allergens.toList()
              : (existing?.allergies ?? const []),
          heightCm: journey.heightCm ?? existing?.heightCm,
          weightKg: journey.weightSkipped
              ? null
              : (journey.weightKg ?? existing?.weightKg),
          eatingRoutine: journey.eatingRoutine.isNotEmpty
              ? journey.eatingRoutine
              : (existing?.eatingRoutine ?? ''),
          sleepQuality: journey.sleepQuality.isNotEmpty
              ? journey.sleepQuality
              : (existing?.sleepQuality ?? ''),
          knowledgeLevel: journey.knowledgeLevel.isNotEmpty
              ? journey.knowledgeLevel
              : (existing?.knowledgeLevel ?? ''),
          difficulties: journey.difficulties.isNotEmpty
              ? journey.difficulties.toList()
              : (existing?.difficulties ?? const []),
          difficultiesNote: journey.difficultiesNote.isNotEmpty
              ? journey.difficultiesNote
              : (existing?.difficultiesNote ?? ''),
          dailyImpacts: journey.dailyImpacts.isNotEmpty
              ? journey.dailyImpacts
              : (existing?.dailyImpacts ?? const {}),
          onboardingCompleted: true,
        );

        await profileRepo.saveUserProfile(profile);
      } catch (e) {
        debugPrint('[StitchScreenHost] Error synchronizing profile update: $e');
      }
    }

    final next = (widget.returnTo != null && widget.returnTo!.isNotEmpty)
        ? widget.returnTo!
        : defaultNextRoute;
    if (mounted) context.go(next);
  }

  Future<void> _handleStitchMessage(Map<String, dynamic> msg) async {
    final type = msg['type'] as String? ?? '';
    debugPrint(
        '[StitchScreenHost] Screen ${widget.screenIndex} received: $type => $msg');

    if (widget.onAction != null) {
      widget.onAction!(type, msg);
    }

    final notifier = ref.read(onboardingJourneyProvider.notifier);

    switch (type) {
      case 'NAVIGATE':
        var route = msg['route'] as String?;
        if (route != null && mounted) {
          if (widget.screenIndex == 3 && route == '/welcome') {
            // Screen 03 Back button: if in signup mode or completed onboarding, return to completion screen
            final isSignin =
                GoRouterState.of(context).uri.queryParameters['mode'] ==
                    'signin';
            if (!isSignin) {
              route = '/onboarding/completion';
            }
          }
          if (widget.screenIndex == 1 && route == '/welcome') {
            final authService = ref.read(authServiceProvider);
            if (authService.isAuthenticated) {
              final user = authService.currentUser;
              if (user != null) {
                final profileRepo = ref.read(profileRepositoryProvider);
                final existingProfile = await profileRepo.getCurrentUserProfile(
                    explicitUserId: user.id);
                if (existingProfile != null) {
                  notifier.hydrateFromProfile(existingProfile);
                }
                final dest = await AuthDestinationResolver.resolveDestination(
                  profileRepository: profileRepo,
                  userId: user.id,
                );
                if (mounted) {
                  context.go(dest);
                  break;
                }
              }
            } else {
              // Unauthenticated visitor: restore any active in-flight onboarding progress
              final staged = await ref
                  .read(onboardingStorageServiceProvider)
                  .loadStagedOnboarding();
              if (staged != null && staged.healthGoals.isNotEmpty) {
                notifier.hydrate(staged);
              }
            }
          }
          if (mounted) {
            context.go(route);
          }
        }
        break;

      case 'GOOGLE_SIGN_IN':
        if (_isAuthenticating) {
          debugPrint(
              '[StitchScreenHost] Google sign-in already in progress. Ignoring duplicate.');
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = kIsWeb
              ? 'Connecting to Google...'
              : 'Opening Google account chooser...';
        });

        try {
          final authService = ref.read(authServiceProvider);
          final profileRepo = ref.read(profileRepositoryProvider);

          final success = await authService.signInWithGoogle();

          if (kIsWeb) {
            // On web, signInWithOAuth initiates redirect; loading message is displayed until page navigates
            if (mounted) {
              setState(() {
                _authLoadingMessage = 'Redirecting to Google...';
              });
            }
          } else {
            // Native Mobile (Android & iOS)
            if (!success) {
              // User cancelled native account chooser
              if (mounted) {
                setState(() {
                  _isAuthenticating = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google sign-in was cancelled.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF38675A),
                  ),
                );
              }
              return;
            }

            // Successfully authenticated on mobile
            final user = authService.currentUser;
            if (user != null && mounted) {
              setState(() {
                _authLoadingMessage = 'Opening your personal plan...';
              });

              // Synchronize staged onboarding answers if present
              await ref
                  .read(profileSyncServiceProvider)
                  .synchronizeStagedOnboarding(
                    user: user,
                    notifier: notifier,
                  );

              final destination =
                  await AuthDestinationResolver.resolveDestination(
                profileRepository: profileRepo,
                userId: user.id,
                returnTo: widget.returnTo,
              );

              if (mounted) {
                context.go(destination);
              }
            }
          }
        } on AuthException catch (ae) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ae.message)),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Google sign-in failed: $e')),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } finally {
          if (mounted && !kIsWeb) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
        break;

      case 'EMAIL_SIGN_IN':
        final email = msg['email'] as String?;
        final captchaToken = msg['captchaToken'] as String?;

        // 1. Validate email structure
        if (email == null || email.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email address.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        final cleanEmail = email.trim().toLowerCase();
        final emailRegex = RegExp(
            r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
        if (!emailRegex.hasMatch(cleanEmail) || cleanEmail.length > 254) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please enter a valid email format (e.g. name@example.com).'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        // 2. Validate CAPTCHA Token
        if (captchaToken != null && captchaToken.length > 4096) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Security verification token invalid. Please refresh the page.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        if (kIsWeb && (captchaToken == null || captchaToken.trim().isEmpty)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Security verification required. Please complete the verification challenge.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        // 3. Duplicate request guard
        if (_isAuthenticating) {
          debugPrint(
              '[StitchScreenHost] Authentication already in progress. Ignoring duplicate request.');
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = 'Sending secure verification code...';
        });

        try {
          final authService = ref.read(authServiceProvider);
          await authService.signInWithOtp(
            email: cleanEmail,
            captchaToken: captchaToken,
          );
          _platformView.sendMessage({
            'type': 'EMAIL_SENT_SUCCESS',
            'email': cleanEmail,
          });
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code & magic link sent! Enter code or tap the email link.'),
                backgroundColor: Color(0xFF0B2B26),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } on AuthException catch (ae) {
          final msg = ae.message.toLowerCase();
          final displayError = msg.contains('captcha')
              ? 'Verification check expired or invalid. Please retry the security challenge.'
              : ae.message;
          _platformView.sendMessage({
            'type': 'EMAIL_SEND_FAILED',
            'error': displayError,
          });
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(displayError)),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          final displayError = 'Failed to send sign-in link: $e';
          _platformView.sendMessage({
            'type': 'EMAIL_SEND_FAILED',
            'error': displayError,
          });
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(displayError)),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
        break;

      case 'VERIFY_OTP':
        final email = msg['email'] as String?;
        final token = msg['token'] as String?;
        if (email == null || email.trim().isEmpty || token == null || token.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter the 6-digit verification code.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = 'Verifying code...';
        });

        try {
          final authService = ref.read(authServiceProvider);
          final cleanEmail = email.trim().toLowerCase();
          final cleanToken = token.trim();
          
          AuthResponse res;
          try {
            res = await authService.verifyOtp(
              email: cleanEmail,
              token: cleanToken,
              type: OtpType.email,
            );
          } on AuthException catch (e) {
            // Fallback for initial signup OTPs which may use OtpType.signup
            if (e.message.toLowerCase().contains('invalid') || e.message.toLowerCase().contains('expired')) {
              try {
                res = await authService.verifyOtp(
                  email: cleanEmail,
                  token: cleanToken,
                  type: OtpType.signup,
                );
              } catch (_) {
                rethrow; // Rethrow original or secondary
              }
            } else {
              rethrow;
            }
          }

          final user = res.user ?? authService.currentUser;
          if (user != null && mounted) {
            setState(() {
              _authLoadingMessage = 'Personalizing your plan...';
            });

            await ref.read(profileSyncServiceProvider).synchronizeStagedOnboarding(
              user: user,
              notifier: notifier,
            );

            final destination = await AuthDestinationResolver.resolveDestination(
              profileRepository: ref.read(profileRepositoryProvider),
              userId: user.id,
              returnTo: widget.returnTo,
            );

            if (mounted) {
              context.go(destination);
            }
          }
        } on AuthException catch (ae) {
          _platformView.sendMessage({
            'type': 'OTP_VERIFICATION_FAILED',
            'error': ae.message,
          });
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ae.message),
                backgroundColor: const Color(0xFFBA1A1A),
              ),
            );
          }
        } catch (e) {
          _platformView.sendMessage({
            'type': 'OTP_VERIFICATION_FAILED',
            'error': 'Verification failed: $e',
          });
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: $e'),
                backgroundColor: const Color(0xFFBA1A1A),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
        break;

      case 'RESEND_OTP':
        final email = msg['email'] as String?;
        if (email == null || email.trim().isEmpty) break;
        final cleanEmail = email.trim().toLowerCase();
        try {
          final authService = ref.read(authServiceProvider);
          await authService.resendOtp(
            email: cleanEmail,
            type: OtpType.email,
          );
          _platformView.sendMessage({'type': 'RESEND_SUCCESS'});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New verification code sent to your email.'),
                backgroundColor: Color(0xFF0B2B26),
              ),
            );
          }
        } on AuthException catch (ae) {
          _platformView.sendMessage({
            'type': 'RESEND_FAILED',
            'error': ae.message,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ae.message),
                backgroundColor: const Color(0xFFBA1A1A),
              ),
            );
          }
        } catch (e) {
          _platformView.sendMessage({
            'type': 'RESEND_FAILED',
            'error': 'Failed to resend code: $e',
          });
        }
        break;

      case 'SAVE_GOALS':
        final rawGoals = msg['goals'];
        if (rawGoals is List) {
          final goalsSet = rawGoals.map((e) => e.toString()).toSet();
          notifier.setHealthGoals(goalsSet);
          notifier.setSelectedConcernIds(goalsSet);
        }
        final customConcern = msg['customConcern'] as String?;
        if (customConcern != null && customConcern.trim().isNotEmpty) {
          notifier.setCustomPrimaryConcern(customConcern.trim());
        }
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/difficulties');
        break;

      case 'SAVE_DIFFICULTIES':
        final rawDiffs = msg['difficulties'];
        if (rawDiffs is List) {
          notifier.setDifficulties(rawDiffs.map((e) => e.toString()).toSet());
        }
        final note = msg['note'] as String?;
        if (note != null) {
          notifier.setDifficultiesNote(note);
        }
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/daily-impact');
        break;

      case 'SAVE_DAILY_IMPACTS':
      case 'SAVE_STEP_06':
        try {
          final isSkipped =
              msg['skipped'] == true || msg['dailyImpactsSkipped'] == true;
          if (isSkipped) {
            notifier.setDailyImpactsSkipped(true);
            notifier.setDailyImpacts({});
            notifier.setImpactFluctuates(false);
          } else {
            notifier.setDailyImpactsSkipped(false);
            final rawImpacts = msg['impacts'];
            if (rawImpacts is Map) {
              final parsed = <String, int>{};
              rawImpacts.forEach((k, v) {
                if (v is num) {
                  parsed[k.toString()] = v.toInt();
                } else if (v is String) {
                  parsed[k.toString()] = int.tryParse(v) ?? 2;
                }
              });
              notifier.setDailyImpacts(parsed);
            }
            if (msg.containsKey('impactFluctuates')) {
              notifier.setImpactFluctuates(msg['impactFluctuates'] == true);
            }
          }
          await ref
              .read(onboardingStorageServiceProvider)
              .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
          await _handlePostSaveNavigation(
              msg['nextRoute'] as String? ?? '/onboarding/food-choices');
        } catch (e) {
          debugPrint('[StitchScreenHost] Error saving daily impacts: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save impact assessment: $e'),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
        break;

      case 'SAVE_FOOD_CHOICES':
      case 'SAVE_STEP_07':
        final pattern =
            msg['dietaryPattern'] ?? msg['pattern'] ?? msg['dietPattern'];
        if (pattern is String && pattern.isNotEmpty) {
          notifier.setDietaryPattern(pattern,
              custom: (msg['customDietaryPattern'] ??
                  msg['customDiet'] ??
                  msg['custom']) as String?);
        }
        final rawAllergens = msg['allergens'] ?? msg['allergyList'];
        if (rawAllergens is List) {
          notifier.setAllergens(
              rawAllergens.map((e) => e.toString()).toSet());
        }
        final customAllergen =
            (msg['customAllergen'] ?? msg['customAllergens']) as String?;
        if (customAllergen != null && customAllergen.isNotEmpty) {
          notifier.setCustomAllergen(customAllergen);
        }
        final rawIntolerances = msg['foodIntolerances'] ?? msg['intolerances'];
        if (rawIntolerances is List) {
          notifier.setFoodIntolerances(
              rawIntolerances.map((e) => e.toString()).toSet());
        }
        final rawAvoid = msg['foodsToAvoid'] ?? msg['avoid'];
        if (rawAvoid is List) {
          notifier.setFoodsToAvoid(rawAvoid.map((e) => e.toString()).toSet());
        }
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/review-phase1');
        break;

      case 'CONFIRM_PHASE1':
      case 'SAVE_STEP_08':
        notifier.setPhase1Reviewed(true);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/personal-details');
        break;

      case 'SAVE_PERSONAL_DETAILS':
      case 'SAVE_STEP_09':
        final name = msg['name'] as String? ?? '';
        final age = (msg['age'] as num?)?.toInt() ?? 25;
        final gender = (msg['gender'] ?? msg['biologicalSex']) as String? ?? 'unspecified';
        notifier.setPersonalDetails(name: name, age: age, biologicalSex: gender);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/body-measurements');
        break;

      case 'SAVE_MEASUREMENTS':
      case 'SAVE_STEP_10':
        final heightCm = (msg['heightCm'] as num?)?.toDouble();
        final weightKg = (msg['weightKg'] as num?)?.toDouble();
        final heightUnit = msg['heightUnit'] as String?;
        final weightUnit = msg['weightUnit'] as String?;
        final weightSkipped = msg['weightSkipped'] == true;
        notifier.setBodyMeasurements(
          heightCm: heightCm,
          weightKg: weightKg,
          heightUnit: heightUnit,
          weightUnit: weightUnit,
          weightSkipped: weightSkipped,
        );
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/health-concerns');
        break;

      case 'SAVE_CONCERNS':
      case 'SAVE_STEP_11':
        final rawConcerns = msg['concerns'] ?? msg['prioritizedConcerns'];
        if (rawConcerns is List) {
          notifier.setPrioritizedConcerns(
              rawConcerns.map((e) => e.toString()).toSet());
        }
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/food-restrictions');
        break;

      case 'SAVE_RESTRICTIONS':
      case 'SAVE_STEP_12':
        final strictlyNoRestrictions = msg['strictlyNoRestrictions'] == true;
        if (strictlyNoRestrictions) {
          notifier.setStrictlyNoRestrictions(true);
        } else {
          final rawAllergens = msg['allergens'];
          if (rawAllergens is List) {
            notifier
                .setAllergens(rawAllergens.map((e) => e.toString()).toSet());
          }
          final customAllergen =
              msg['customAllergen'] as String? ?? msg['custom'] as String?;
          if (customAllergen != null && customAllergen.isNotEmpty) {
            notifier.setCustomAllergen(customAllergen);
          }
        }
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/eating-routine');
        break;

      case 'SAVE_EATING_ROUTINE':
      case 'SAVE_STEP_13':
        final routine = msg['routine'] as String?;
        if (routine != null) notifier.setEatingRoutine(routine);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/daily-activity');
        break;

      case 'SAVE_ACTIVITY_LEVEL':
      case 'SAVE_STEP_14':
        final level = msg['level'] as String?;
        if (level != null) notifier.setActivityLevel(level);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/sleep-patterns');
        break;

      case 'SAVE_SLEEP_QUALITY':
      case 'SAVE_STEP_15':
        final quality = msg['quality'] as String?;
        if (quality != null) notifier.setSleepQuality(quality);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/knowledge-level');
        break;

      case 'SAVE_KNOWLEDGE_LEVEL':
      case 'SAVE_STEP_16':
        final level = msg['level'] as String?;
        if (level != null) notifier.setKnowledgeLevel(level);
        await ref
            .read(onboardingStorageServiceProvider)
            .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(
            msg['nextRoute'] as String? ?? '/onboarding/completion');
        break;

      case 'COMPLETE_ONBOARDING':
        final authService = ref.read(authServiceProvider);
        notifier.setOnboardingFinished(true);
        if (!authService.isAuthenticated) {
          // Unauthenticated user finished onboarding questions -> proceed to Screen 03 (Auth Trust Protocol)
          await ref
              .read(onboardingStorageServiceProvider)
              .saveStagedOnboarding(ref.read(onboardingJourneyProvider));
          if (mounted) context.go('/auth?mode=signup');
        } else {
          // Authenticated user completing onboarding
          try {
            await notifier.completeOnboarding(
              auth: authService,
              profileRepo: ref.read(profileRepositoryProvider),
              taskRepo: ref.read(taskRepositoryProvider),
            );
            await ref
                .read(onboardingStorageServiceProvider)
                .clearStagedOnboarding();
          } catch (e) {
            debugPrint('Onboarding completion persistence note: $e');
          }
          if (mounted) context.go('/today');
        }
        break;

      case 'OPEN_MENU':
        _showTodayMenuModal(context);
        break;

      case 'LOGO_ACTION':
        if (mounted) context.go('/today');
        break;

      case 'OPEN_CAMERA':
        _handleCameraAction(context);
        break;

      case 'OPEN_MIC':
        _handleMicAction(context);
        break;

      case 'VIEW_EVIDENCE':
        final taskId = msg['taskId']?.toString() ?? 'task-03';
        final title = msg['title']?.toString() ?? 'Post-run refuel & electrolytes';
        _handleViewEvidenceAction(context, taskId, title);
        break;

      case 'OPEN_LEARN_ITEM':
        final itemId = msg['itemId']?.toString() ?? 'vid-01';
        _handleOpenLearnItem(context, itemId);
        break;

      case 'SEE_ALL_LEARN':
        _showAllLearnModal(context);
        break;

      case 'SUBMIT_FEEDBACK':
        final feedback = msg['feedback']?.toString() ?? msg['text']?.toString() ?? '';
        if (feedback.isNotEmpty) {
          ref.read(todayStateProvider.notifier).submitFeedback(feedback);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback received. Thank you!'),
                backgroundColor: NETokens.emerald,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
        break;

      case 'CHAT_PROMPT':
        final text = msg['text'] as String?;
        if (text != null && text.isNotEmpty) {
          _handleChatPromptAction(context, text);
        }
        break;

      case 'TOGGLE_TASK':
        final rawIndex = msg['index'] ?? msg['taskId'];
        final index = rawIndex is int
            ? rawIndex
            : int.tryParse(rawIndex?.toString() ?? '0') ?? 0;
        ref.read(todayStateProvider.notifier).toggleTask(index);
        break;

      case 'UPDATE_AVATAR':
        final skinTone = msg['skinTone'] as String? ?? msg['tone'] as String? ?? '#E0AC69';
        final avatarConfig = msg['avatarConfig'] is Map<String, dynamic>
            ? msg['avatarConfig'] as Map<String, dynamic>
            : <String, dynamic>{};
        await ref.read(profileRepositoryProvider).updateAvatar(
              skinTone: skinTone,
              avatarConfig: avatarConfig,
            );
        await ref.read(todayNotifierProvider.notifier).loadUserProfile();
        break;

      default:
        final next = msg['nextRoute'] as String?;
        if (next != null && mounted) {
          context.go(next);
        }
        break;
    }
  }

  void _showTodayMenuModal(BuildContext context) {
    final state = ref.read(todayStateProvider);
    final name = state.userProfile?.displayName ?? 'Sarah Jenkins';
    final goal = state.userProfile?.primaryGoal ?? 'Endurance Recovery';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: NETokens.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NETokens.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE2EDE5),
                    child: Icon(Icons.person_rounded, color: NETokens.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: NETokens.primary,
                          ),
                        ),
                        Text(
                          'Goal: $goal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NETokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: NETokens.borderSubtle, height: 1),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.add_comment_outlined, color: NETokens.primary),
                title: const Text('New Research Inquiry', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleChatPromptAction(context, 'Explore evidence-based nutrition protocols');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined, color: NETokens.primary),
                title: const Text('Personal Health Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hub_outlined, color: NETokens.primary),
                title: const Text('Intelligence Workspace', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/workspace');
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: NETokens.primary),
                title: const Text('Browse Scientific Feed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAllLearnModal(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCameraAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        icon: const Icon(Icons.camera_alt_rounded, color: NETokens.emerald, size: 32),
        title: const Text('Scan Meal or Food Label', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: const Text(
          'Take a photo or choose an image from gallery to analyze nutrition with research evidence.',
          style: TextStyle(fontSize: 13.5, color: NETokens.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.deepGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleChatPromptAction(context, 'Analyze nutritional composition of this meal');
            },
            child: const Text('Select Image & Analyze'),
          ),
        ],
      ),
    );
  }

  void _handleMicAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        icon: const Icon(Icons.mic_rounded, color: NETokens.emerald, size: 32),
        title: const Text('Voice Research Input', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: const Text(
          'Tap start to record your scientific inquiry. Speech-to-text will transcribe and verify evidence.',
          style: TextStyle(fontSize: 13.5, color: NETokens.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.deepGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleChatPromptAction(context, 'How does dietary magnesium glycinate compare for sleep quality?');
            },
            child: const Text('Start Recording'),
          ),
        ],
      ),
    );
  }

  void _handleViewEvidenceAction(BuildContext context, String taskId, String title) {
    _handleChatPromptAction(context, 'Evidence basis for $title');
  }

  void _handleOpenLearnItem(BuildContext context, String itemId) {
    final all = [
      ...LearnRepository.featuredItems,
      ...LearnRepository.getArticles(),
      ...LearnRepository.getVideos(),
    ];
    final match = all.firstWhere(
      (item) => item.id == itemId,
      orElse: () => LearnRepository.featuredItems.first,
    );
    LearnDetailModal.show(context, match);
  }

  void _showAllLearnModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final articles = LearnRepository.getArticles();
        final videos = LearnRepository.getVideos();

        return Container(
          decoration: const BoxDecoration(
            color: NETokens.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: NETokens.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    labelColor: NETokens.primary,
                    unselectedLabelColor: NETokens.textMuted,
                    indicatorColor: NETokens.emerald,
                    tabs: [
                      Tab(text: 'Articles (10)'),
                      Tab(text: 'Videos (10)'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final item = articles[index];
                            return ListTile(
                              dense: true,
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              subtitle: Text(item.description, style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                              onTap: () {
                                Navigator.pop(ctx);
                                LearnDetailModal.show(context, item);
                              },
                            );
                          },
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final item = videos[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.play_circle_fill_rounded, color: NETokens.emerald),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              subtitle: Text('${item.duration ?? ""} • ${item.description}', style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                              onTap: () {
                                Navigator.pop(ctx);
                                LearnDetailModal.show(context, item);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleChatPromptAction(BuildContext context, String text) async {
    final notifier = ref.read(todayStateProvider.notifier);
    await notifier.submitResearch(text);

    if (!mounted) return;
    final currentState = ref.read(todayStateProvider);
    if (currentState.activeAnswer != null) {
      ResearchResultModal.show(context, currentState.activeAnswer!);
    } else if (currentState.researchError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Research error: ${currentState.researchError}'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _platformView.buildView(
                    screenIndex: widget.screenIndex,
                    initialUrl: _initialUrl,
                    onMessage: _handleStitchMessage,
                  ),
                ),
                if (_isAuthenticating)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0x99051F20),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF9F4),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color(0xFF38675A),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _authLoadingMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000A06),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Verifying clinical identity session',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 11,
                                  color: Color(0xFF414845),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
