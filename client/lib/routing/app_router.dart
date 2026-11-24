// ==============================================================================
// Nutrient Earth — App Router (GoRouter)
// Production router connecting all 18 authentic Stitch screens via StitchScreenHostWidget.
// ==============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/supabase_config.dart';
import '../core/design_system/components/stitch_screen_host.dart';
import '../core/services/auth_destination_resolver.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_repository.dart';
import '../features/auth/presentation/auth_callback_screen.dart';
import '../features/chat/presentation/intelligence_workspace_screen.dart';
import '../features/onboarding/data/onboarding_storage_service.dart';
import '../features/onboarding/state/onboarding_journey_state.dart';
import '../features/profile/presentation/profile_screen.dart';

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
  final effectiveAuth = authService ?? (SupabaseConfig.isInitialized ? const SupabaseAuthService() : null);
  final effectiveProfile = profileRepository ?? (SupabaseConfig.isInitialized ? const SupabaseProfileRepository() : null);
  final effectiveStorage = storageService ?? const OnboardingStorageService();

  // When backend is not initialized (e.g. offline testing, mocking, or unit tests without auth), allow direct navigation
  if (effectiveAuth == null) {
    return null;
  }

  // Visual inspection and automated headless audit support
  if (state.uri.queryParameters['preview'] == 'true') {
    return null;
  }

  final isAuthenticated = effectiveAuth.isAuthenticated;
  final path = state.uri.path;

  // 1. Always allow OAuth callback processing
  if (path == '/auth/callback') {
    return null;
  }

  // 2. Intercept OAuth or Magic Link redirect landing with code, error, or hash tokens anywhere
  final hasCode = state.uri.queryParameters.containsKey('code') ||
      (kIsWeb && Uri.base.queryParameters.containsKey('code'));
  final hasError = state.uri.queryParameters.containsKey('error') ||
      (kIsWeb && Uri.base.queryParameters.containsKey('error'));
  final hasHashToken = kIsWeb &&
      (Uri.base.fragment.contains('access_token') ||
          Uri.base.fragment.contains('type=magiclink') ||
          Uri.base.fragment.contains('type=recovery') ||
          Uri.base.fragment.contains('type=signup') ||
          Uri.base.fragment.contains('error='));

  if (path != '/auth/callback' && (hasCode || hasError || hasHashToken)) {
    final query = state.uri.query.isNotEmpty
        ? state.uri.query
        : (kIsWeb ? Uri.base.query : '');
    return '/auth/callback${query.isNotEmpty ? '?$query' : ''}';
  }

  // Helper: Determine whether the user has completed all onboarding questions
  bool hasCompletedOnboardingFlow() {
    if (onboardingStateProvider != null) {
      final s = onboardingStateProvider();
      if (s.onboardingFinished) return true;
    }
    if (effectiveStorage.isOnboardingCompleted) {
      return true;
    }
    return false;
  }

  // 3. Protected Route Rules:
  // Today Hub, Explore, Multimodal processing & answer routes strictly require an authenticated session
  const protectedRoutes = {
    '/today',
    '/processing-view',
    '/answer-experience',
    '/explore',
    '/research',
  };
  final isProtected = protectedRoutes.contains(path) || path.startsWith('/today/');

  if (!isAuthenticated && isProtected) {
    if (hasCompletedOnboardingFlow()) {
      final returnTo = Uri.encodeComponent(state.uri.toString());
      return '/auth?mode=signup&returnTo=$returnTo';
    }
    return '/welcome';
  }

  // 4. Authentication Route Rules for Unauthenticated Users:
  // Authentication (/auth) cannot be reached before required onboarding completion,
  // except for returning users signing into an existing account (mode=signin).
  if (!isAuthenticated && path == '/auth') {
    final mode = state.uri.queryParameters['mode'] ?? 'signup';
    if (mode == 'signin') {
      // Returning user logging in: allowed
      return null;
    }
    // New registration or default access: requires completed onboarding
    if (!hasCompletedOnboardingFlow()) {
      return '/welcome';
    }
    return null;
  }

  // 5. Authenticated Users Route Enforcement:
  if (isAuthenticated) {
    final currentUser = effectiveAuth.currentUser;
    final cachedProfile = currentUser != null ? effectiveProfile?.getCachedProfileSync(currentUser.id) : null;
    final onboardingCompleted = cachedProfile?.onboardingCompleted ?? false;

    // Authenticated user attempting to access /today without completed profile is routed to their first incomplete step
    if (path == '/today' && cachedProfile != null && !onboardingCompleted) {
      return AuthDestinationResolver.resolveFirstIncompleteStep(cachedProfile);
    }

    // Authenticated users navigating to /auth or /welcome are automatically redirected forward
    if (path == '/auth' || path == '/welcome' || path == '/onboarding/completion') {
      final returnTo = state.uri.queryParameters['returnTo'];
      if (returnTo != null && returnTo.isNotEmpty) {
        final decoded = Uri.decodeComponent(returnTo);
        if (!decoded.startsWith('/auth') && !decoded.startsWith('/welcome') && !decoded.startsWith('/onboarding/completion')) {
          return decoded;
        }
      }
      return onboardingCompleted
          ? '/today'
          : AuthDestinationResolver.resolveFirstIncompleteStep(cachedProfile);
    }

    // Generic /onboarding alias for authenticated users
    if (path == '/onboarding') {
      return onboardingCompleted
          ? '/today'
          : AuthDestinationResolver.resolveFirstIncompleteStep(cachedProfile);
    }
  }

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
        builder: (context, state) => AuthCallbackScreen(
          code: state.uri.queryParameters['code'],
          error: state.uri.queryParameters['error'],
          errorDescription: state.uri.queryParameters['error_description'],
          returnTo: state.uri.queryParameters['returnTo'],
        ),
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
        builder: (context, state) => const ProfileScreen(),
      ),

      // Intelligence Workspace & Continuous Dialogue Hub
      GoRoute(
        path: '/workspace',
        builder: (context, state) => const IntelligenceWorkspaceScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const IntelligenceWorkspaceScreen(),
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
