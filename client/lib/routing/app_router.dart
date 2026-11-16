// ==============================================================================
// Nutrient Earth — App Router (GoRouter)
// Production router connecting all 18 authentic Stitch screens via StitchScreenHostWidget.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/supabase_config.dart';
import '../core/design_system/components/stitch_screen_host.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_repository.dart';
import '../features/onboarding/data/onboarding_storage_service.dart';
import '../features/onboarding/state/onboarding_journey_state.dart';

/// Listens to a Stream and notifies GoRouter to re-evaluate route guards
class GoRouterRefreshStream extends ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

Listenable? _buildAuthRefreshListenable() {
  final client = SupabaseConfig.client;
  if (client != null && SupabaseConfig.isInitialized) {
    return GoRouterRefreshStream(client.auth.onAuthStateChange);
  }
  return null;
}

/// Route redirect guard for App Router
String? appRouterRedirect(
  BuildContext context,
  GoRouterState state, {
  AuthService? authService,
  ProfileRepository? profileRepository,
  OnboardingStorageService? storageService,
  OnboardingJourneyState Function()? onboardingStateProvider,
}) {
  return null;
}

/// Factory function to create GoRouter instance
GoRouter createAppRouter({
  AuthService? authService,
  ProfileRepository? profileRepository,
  OnboardingStorageService? storageService,
  OnboardingJourneyState Function()? onboardingStateProvider,
  Listenable? refreshListenable,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) => appRouterRedirect(
      context,
      state,
      authService: authService,
      profileRepository: profileRepository,
      storageService: storageService,
      onboardingStateProvider: onboardingStateProvider,
    ),
    routes: [
      // Screen 01: Brand Splash Screen (Canonical Default Entry)
      GoRoute(
        path: '/',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 1),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 1),
      ),

      // Screen 02: Welcome Screen (Botanical Evidence Edition)
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 2),
      ),

      // Screen 03: Authentication Trust Verification
      GoRoute(
        path: '/auth',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 3,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 3,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 18),
      ),

      // Screen 04: Health Goals Conditions Discovery
      GoRoute(
        path: '/onboarding/health-goals',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 4,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 4,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 4),
      ),

      // Screen 05: Practical Difficulties & Functional Challenges
      GoRoute(
        path: '/onboarding/practical-difficulties',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 5,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/difficulties',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 5,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 06: Daily Impact Rating
      GoRoute(
        path: '/onboarding/daily-impact',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 6,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/impact',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 6,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 07: Food Choices & Dietary Profile
      GoRoute(
        path: '/onboarding/food-choices',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 7,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 08: Review Health Profile Phase 1 Checkpoint
      GoRoute(
        path: '/onboarding/review-phase1',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 8,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 09: Personal Details
      GoRoute(
        path: '/onboarding/personal-details',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 9,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 10: Body Measurements
      GoRoute(
        path: '/onboarding/body-measurements',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 10,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/measurements',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 10,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 11: Health Concerns (What Would You Like Help With)
      GoRoute(
        path: '/onboarding/health-concerns',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 11,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/concerns',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 11,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 12: Food Restrictions & Allergies
      GoRoute(
        path: '/onboarding/food-restrictions',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 12,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/restrictions',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 12,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 13: Eating Routine
      GoRoute(
        path: '/onboarding/eating-routine',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 13,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 14: Daily Activity Level
      GoRoute(
        path: '/onboarding/daily-activity',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 14,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/activity',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 14,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 15: Sleep Patterns & Recovery
      GoRoute(
        path: '/onboarding/sleep-patterns',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 15,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/sleep',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 15,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 16: Knowledge Level (Fitness & Nutrition)
      GoRoute(
        path: '/onboarding/knowledge-level',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 16,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/onboarding/knowledge',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 16,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 17: Profile Completion (Your Journey Starts Here)
      GoRoute(
        path: '/onboarding/completion',
        builder: (context, state) => StitchScreenHostWidget(
          screenIndex: 17,
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),

      // Screen 18: Today — Evidence Hub Personalized Daily Plan
      GoRoute(
        path: '/today',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 18),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const StitchScreenHostWidget(screenIndex: 18),
      ),
    ],
  );
}

/// Reactive Riverpod Provider for GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  final storageService = ref.watch(onboardingStorageServiceProvider);
  final refreshNotifier = GoRouterRefreshStream(authService.authStateChanges);
  ref.onDispose(refreshNotifier.dispose);

  return createAppRouter(
    authService: authService,
    profileRepository: profileRepository,
    storageService: storageService,
    onboardingStateProvider: () => ref.read(onboardingJourneyProvider),
    refreshListenable: refreshNotifier,
  );
});

/// Default singleton appRouter instance for backward compatibility & tests
final appRouter = createAppRouter(
  refreshListenable: _buildAuthRefreshListenable(),
);
