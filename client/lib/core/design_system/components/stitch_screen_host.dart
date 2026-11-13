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
  ConsumerState<StitchScreenHostWidget> createState() => _StitchScreenHostWidgetState();
}

class _StitchScreenHostWidgetState extends ConsumerState<StitchScreenHostWidget> {
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
      if (journey.healthGoals.isNotEmpty) params['goals'] = journey.healthGoals.join(',');
      if (journey.difficulties.isNotEmpty) params['difficulties'] = journey.difficulties.join(',');
      if (journey.dietaryPattern.isNotEmpty) params['pattern'] = journey.dietaryPattern;
      if (journey.foodIntolerances.isNotEmpty) params['intolerances'] = journey.foodIntolerances.join(',');
      if (journey.foodsToAvoid.isNotEmpty) params['avoid'] = journey.foodsToAvoid.join(',');
      if (journey.dailyImpacts.isNotEmpty) params['impacts'] = jsonEncode(journey.dailyImpacts);
    } else if (widget.screenIndex == 9) {
      if (journey.firstName.isNotEmpty) params['name'] = journey.firstName;
      if (journey.age > 0) params['age'] = journey.age.toString();
    } else if (widget.screenIndex == 10) {
      if (journey.heightCm != null) params['heightCm'] = journey.heightCm.toString();
      if (journey.weightKg != null) params['weightKg'] = journey.weightKg.toString();
      params['heightUnit'] = journey.heightUnit;
      params['weightUnit'] = journey.weightUnit;
      if (journey.weightSkipped) params['weightSkipped'] = 'true';
    } else if (widget.screenIndex == 11) {
      if (journey.prioritizedConcerns.isNotEmpty) {
        params['concerns'] = journey.prioritizedConcerns.join(',');
      }
    } else if (widget.screenIndex == 12) {
      if (journey.strictlyNoRestrictions) params['strictlyNoRestrictions'] = 'true';
      if (journey.allergens.isNotEmpty) params['allergens'] = journey.allergens.join(',');
      if (journey.customAllergen.isNotEmpty) params['customAllergen'] = journey.customAllergen;
    } else if (widget.screenIndex == 13) {
      if (journey.eatingRoutine.isNotEmpty) params['routine'] = journey.eatingRoutine;
    } else if (widget.screenIndex == 14) {
      if (journey.activityLevel.isNotEmpty) params['level'] = journey.activityLevel;
    } else if (widget.screenIndex == 15) {
      if (journey.sleepQuality.isNotEmpty) params['quality'] = journey.sleepQuality;
    } else if (widget.screenIndex == 16) {
      if (journey.knowledgeLevel.isNotEmpty) params['level'] = journey.knowledgeLevel;
    } else if (widget.screenIndex == 17) {
      if (journey.healthGoals.isNotEmpty) params['goals'] = journey.healthGoals.join(',');
      if (journey.difficulties.isNotEmpty) params['difficulties'] = journey.difficulties.join(',');
      if (journey.dailyImpacts.isNotEmpty) params['impacts'] = jsonEncode(journey.dailyImpacts);
      if (journey.dietaryPattern.isNotEmpty) params['pattern'] = journey.dietaryPattern;
      if (journey.foodIntolerances.isNotEmpty) params['intolerances'] = journey.foodIntolerances.join(',');
      if (journey.foodsToAvoid.isNotEmpty) params['avoid'] = journey.foodsToAvoid.join(',');
      if (journey.firstName.isNotEmpty) params['name'] = journey.firstName;
      if (journey.age > 0) params['age'] = journey.age.toString();
      if (journey.heightCm != null) params['heightCm'] = journey.heightCm.toString();
      if (journey.weightKg != null) params['weightKg'] = journey.weightKg.toString();
      if (journey.prioritizedConcerns.isNotEmpty) params['concerns'] = journey.prioritizedConcerns.join(',');
      if (journey.strictlyNoRestrictions) params['strictlyNoRestrictions'] = 'true';
      if (journey.allergens.isNotEmpty) params['allergens'] = journey.allergens.join(',');
      if (journey.customAllergen.isNotEmpty) params['customAllergen'] = journey.customAllergen;
      if (journey.eatingRoutine.isNotEmpty) params['routine'] = journey.eatingRoutine;
      if (journey.activityLevel.isNotEmpty) params['activity'] = journey.activityLevel;
      if (journey.sleepQuality.isNotEmpty) params['sleep'] = journey.sleepQuality;
      if (journey.knowledgeLevel.isNotEmpty) params['knowledge'] = journey.knowledgeLevel;
    } else if (widget.screenIndex == 18) {
      if (journey.firstName.trim().isNotEmpty) {
        params['name'] = journey.firstName.trim();
      } else {
        final cached = ref.read(profileRepositoryProvider).getCachedProfileSync(ref.read(authServiceProvider).currentUser?.id);
        if (cached != null && cached.displayName.trim().isNotEmpty && cached.displayName != 'User') {
          params['name'] = cached.displayName.trim();
        }
      }
    }

    final query = params.isNotEmpty ? '?${Uri(queryParameters: params).query}' : '';
    return 'stitch/screen_$idxStr/$query';
  }

  @visibleForTesting
  Future<void> handleStitchMessageForTesting(Map<String, dynamic> msg) => _handleStitchMessage(msg);

  Future<void> _handlePostSaveNavigation(String defaultNextRoute) async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final isEditingProfile = widget.returnTo == '/profile';

    if (isEditingProfile && authService.isAuthenticated && user != null) {
      try {
        final journey = ref.read(onboardingJourneyProvider);
        final profileRepo = ref.read(profileRepositoryProvider);
        final existing = await profileRepo.getCurrentUserProfile(explicitUserId: user.id);

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
          activityLevel: journey.activityLevel.isNotEmpty ? journey.activityLevel : (existing?.activityLevel ?? ''),
          dietaryPreference: journey.dietaryPattern.isNotEmpty ? journey.dietaryPattern : (existing?.dietaryPreference ?? ''),
          budgetConstraint: existing?.budgetConstraint ?? '',
          willingnessToChange: existing?.willingnessToChange ?? '',
          knownConditions: knownConditionsList.isNotEmpty ? knownConditionsList : (existing?.knownConditions ?? const []),
          activeSupplements: existing?.activeSupplements ?? const [],
          allergies: journey.allergens.isNotEmpty ? journey.allergens.toList() : (existing?.allergies ?? const []),
          heightCm: journey.heightCm ?? existing?.heightCm,
          weightKg: journey.weightSkipped ? null : (journey.weightKg ?? existing?.weightKg),
          eatingRoutine: journey.eatingRoutine.isNotEmpty ? journey.eatingRoutine : (existing?.eatingRoutine ?? ''),
          sleepQuality: journey.sleepQuality.isNotEmpty ? journey.sleepQuality : (existing?.sleepQuality ?? ''),
          knowledgeLevel: journey.knowledgeLevel.isNotEmpty ? journey.knowledgeLevel : (existing?.knowledgeLevel ?? ''),
          difficulties: journey.difficulties.isNotEmpty ? journey.difficulties.toList() : (existing?.difficulties ?? const []),
          difficultiesNote: journey.difficultiesNote.isNotEmpty ? journey.difficultiesNote : (existing?.difficultiesNote ?? ''),
          dailyImpacts: journey.dailyImpacts.isNotEmpty ? journey.dailyImpacts : (existing?.dailyImpacts ?? const {}),
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
    debugPrint('[StitchScreenHost] Screen ${widget.screenIndex} received: $type => $msg');

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
            final isSignin = GoRouterState.of(context).uri.queryParameters['mode'] == 'signin';
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
                final existingProfile = await profileRepo.getCurrentUserProfile(explicitUserId: user.id);
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
              final staged = await ref.read(onboardingStorageServiceProvider).loadStagedOnboarding();
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
          debugPrint('[StitchScreenHost] Google sign-in already in progress. Ignoring duplicate.');
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = kIsWeb ? 'Connecting to Google...' : 'Opening Google account chooser...';
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
              await ref.read(profileSyncServiceProvider).synchronizeStagedOnboarding(
                user: user,
                notifier: notifier,
              );

              final destination = await AuthDestinationResolver.resolveDestination(
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
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
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
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
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
        final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
        if (!emailRegex.hasMatch(cleanEmail) || cleanEmail.length > 254) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email format (e.g. name@example.com).'),
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
                content: Text('Security verification token invalid. Please refresh the page.'),
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
                content: Text('Security verification required. Please complete the verification challenge.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        // 3. Duplicate request guard
        if (_isAuthenticating) {
          debugPrint('[StitchScreenHost] Authentication already in progress. Ignoring duplicate request.');
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
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            final returnTarget = widget.returnTo != null && widget.returnTo!.isNotEmpty
                ? '&returnTo=${Uri.encodeComponent(widget.returnTo!)}'
                : '';
            context.go('/auth/verify-email?email=${Uri.encodeComponent(cleanEmail)}$returnTarget');
          }
        } on AuthException catch (ae) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            final msg = ae.message.toLowerCase();
            final displayError = msg.contains('captcha')
                ? 'Verification check expired or invalid. Please retry the security challenge.'
                : ae.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
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
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Failed to send sign-in link: $e')),
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
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/difficulties');
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
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/daily-impact');
        break;

      case 'SAVE_DAILY_IMPACTS':
      case 'SAVE_STEP_06':
        try {
          final isSkipped = msg['skipped'] == true || msg['dailyImpactsSkipped'] == true;
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
          await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
          await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/food-choices');
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
        final pattern = msg['dietaryPattern'] ?? msg['pattern'];
        if (pattern is String && pattern.isNotEmpty) {
          notifier.setDietaryPattern(pattern, custom: msg['customDietaryPattern'] as String?);
        }
        final rawIntolerances = msg['foodIntolerances'] ?? msg['intolerances'];
        if (rawIntolerances is List) {
          notifier.setFoodIntolerances(rawIntolerances.map((e) => e.toString()).toSet());
        }
        final rawAvoid = msg['foodsToAvoid'] ?? msg['avoid'];
        if (rawAvoid is List) {
          notifier.setFoodsToAvoid(rawAvoid.map((e) => e.toString()).toSet());
        }
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/review-phase1');
        break;

      case 'CONFIRM_PHASE1':
      case 'SAVE_STEP_08':
        notifier.setPhase1Reviewed(true);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/personal-details');
        break;

      case 'SAVE_PERSONAL_DETAILS':
      case 'SAVE_STEP_09':
        final name = msg['name'] as String? ?? '';
        final age = (msg['age'] as num?)?.toInt() ?? 25;
        notifier.setPersonalDetails(name: name, age: age);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/body-measurements');
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
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/health-concerns');
        break;

      case 'SAVE_CONCERNS':
      case 'SAVE_STEP_11':
        final rawConcerns = msg['concerns'] ?? msg['prioritizedConcerns'];
        if (rawConcerns is List) {
          notifier.setPrioritizedConcerns(rawConcerns.map((e) => e.toString()).toSet());
        }
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/food-restrictions');
        break;

      case 'SAVE_RESTRICTIONS':
      case 'SAVE_STEP_12':
        final strictlyNoRestrictions = msg['strictlyNoRestrictions'] == true;
        if (strictlyNoRestrictions) {
          notifier.setStrictlyNoRestrictions(true);
        } else {
          final rawAllergens = msg['allergens'];
          if (rawAllergens is List) {
            notifier.setAllergens(rawAllergens.map((e) => e.toString()).toSet());
          }
          final customAllergen = msg['customAllergen'] as String? ?? msg['custom'] as String?;
          if (customAllergen != null && customAllergen.isNotEmpty) {
            notifier.setCustomAllergen(customAllergen);
          }
        }
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/eating-routine');
        break;

      case 'SAVE_EATING_ROUTINE':
      case 'SAVE_STEP_13':
        final routine = msg['routine'] as String?;
        if (routine != null) notifier.setEatingRoutine(routine);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/daily-activity');
        break;

      case 'SAVE_ACTIVITY_LEVEL':
      case 'SAVE_STEP_14':
        final level = msg['level'] as String?;
        if (level != null) notifier.setActivityLevel(level);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/sleep-patterns');
        break;

      case 'SAVE_SLEEP_QUALITY':
      case 'SAVE_STEP_15':
        final quality = msg['quality'] as String?;
        if (quality != null) notifier.setSleepQuality(quality);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/knowledge-level');
        break;

      case 'SAVE_KNOWLEDGE_LEVEL':
      case 'SAVE_STEP_16':
        final level = msg['level'] as String?;
        if (level != null) notifier.setKnowledgeLevel(level);
        await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
        await _handlePostSaveNavigation(msg['nextRoute'] as String? ?? '/onboarding/completion');
        break;

      case 'COMPLETE_ONBOARDING':
        final authService = ref.read(authServiceProvider);
        notifier.setOnboardingFinished(true);
        if (!authService.isAuthenticated) {
          // Unauthenticated user finished onboarding questions -> proceed to Screen 03 (Auth Trust Protocol)
          await ref.read(onboardingStorageServiceProvider).saveStagedOnboarding(ref.read(onboardingJourneyProvider));
          if (mounted) context.go('/auth?mode=signup');
        } else {
          // Authenticated user completing onboarding
          try {
            await notifier.completeOnboarding(
              auth: authService,
              profileRepo: ref.read(profileRepositoryProvider),
              taskRepo: ref.read(taskRepositoryProvider),
            );
            await ref.read(onboardingStorageServiceProvider).clearStagedOnboarding();
          } catch (e) {
            debugPrint('Onboarding completion persistence note: $e');
          }
          if (mounted) context.go('/today');
        }
        break;

      case 'CHAT_PROMPT':
        final text = msg['text'] as String?;
        if (text != null && text.isNotEmpty) {
          ref.read(todayStateProvider.notifier).submitResearch(text);
        }
        break;

      case 'TOGGLE_TASK':
        final rawIndex = msg['index'] ?? msg['taskId'];
        final index = rawIndex is int ? rawIndex : int.tryParse(rawIndex?.toString() ?? '0') ?? 0;
        ref.read(todayStateProvider.notifier).toggleTask(index);
        break;

      default:
        final next = msg['nextRoute'] as String?;
        if (next != null && mounted) {
          context.go(next);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: SafeArea(
        top: false,
        bottom: false,
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
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
    );
  }
}
