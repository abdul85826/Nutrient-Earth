// ==============================================================================
// Nutrient Earth — Auth Destination Resolver
// Resolves post-authentication navigation destination based on the user's
// verified, persisted onboarding status across Web, Android, and iOS.
// Rules:
// - New account (no profile or goals empty) -> /onboarding/health-goals (Screen 04)
// - Incomplete onboarding -> Resume first incomplete onboarding step
// - Completed account (onboardingCompleted == true) -> /today (Screen 18)
// ==============================================================================

import 'package:flutter/foundation.dart';
import '../domain/personalization/user_profile_context.dart';
import 'profile_repository.dart';

class AuthDestinationResolver {
  const AuthDestinationResolver._();

  /// Resolves the canonical destination route for an authenticated user.
  static Future<String> resolveDestination({
    required ProfileRepository profileRepository,
    required String userId,
    String? returnTo,
  }) async {
    // 1. Honor valid, safe returnTo parameters if specified (e.g. deep-linking to /today or specific screen)
    if (returnTo != null && returnTo.isNotEmpty) {
      final decoded = Uri.decodeComponent(returnTo);
      if (!decoded.startsWith('/auth') && !decoded.startsWith('/welcome')) {
        return decoded;
      }
    }

    // 2. Query persisted profile context (Supabase remote first, local cache fallback)
    try {
      final profile = await profileRepository.getCurrentUserProfile(explicitUserId: userId);

      // New account: No profile record exists yet
      if (profile == null) {
        debugPrint('[AuthDestinationResolver] New account detected for user $userId -> /onboarding/health-goals');
        return '/onboarding/health-goals';
      }

      // Completed account: User has finished all onboarding steps
      if (profile.onboardingCompleted) {
        debugPrint('[AuthDestinationResolver] Completed account for user $userId -> /today');
        return '/today';
      }

      // Incomplete account: Determine first incomplete step
      final nextStep = resolveFirstIncompleteStep(profile);
      debugPrint('[AuthDestinationResolver] Incomplete onboarding for user $userId -> $nextStep');
      return nextStep;
    } catch (e) {
      debugPrint('[AuthDestinationResolver] Error fetching profile: $e -> fallback to /onboarding/health-goals');
      return '/onboarding/health-goals';
    }
  }

  /// Evaluates profile attributes sequentially to determine the first incomplete onboarding screen.
  static String resolveFirstIncompleteStep(UserProfileContext? profile) {
    if (profile == null) {
      return '/onboarding/health-goals';
    }
    if (profile.primaryGoals.isEmpty) {
      return '/onboarding/health-goals'; // Screen 04
    }
    if (profile.difficulties.isEmpty && profile.dailyImpacts.isEmpty) {
      return '/onboarding/difficulties'; // Screen 05
    }
    if (profile.dailyImpacts.isEmpty) {
      return '/onboarding/daily-impact'; // Screen 06
    }
    if (profile.dietaryPreference.isEmpty || profile.dietaryPreference == 'unspecified') {
      return '/onboarding/food-choices'; // Screen 07
    }
    if (profile.displayName.isEmpty || profile.displayName == 'User') {
      return '/onboarding/personal-details'; // Screen 09
    }
    if (profile.heightCm == null && profile.weightKg == null) {
      return '/onboarding/body-measurements'; // Screen 10
    }
    if (profile.knownConditions.isEmpty) {
      return '/onboarding/health-concerns'; // Screen 11
    }
    if (profile.allergies.isEmpty) {
      return '/onboarding/food-restrictions'; // Screen 12
    }
    return '/onboarding/health-goals';
  }
}

