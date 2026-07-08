import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_navigation_shell.dart';
import '../../features/today/today_screen.dart';
import '../../features/body/body_screen.dart';
import '../../features/me/me_screen.dart';
import '../../features/explore/insights_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/flow/flow_screen.dart';
import '../bootstrap/app_bootstrap.dart';
import '../providers/biological_profile_provider.dart';
import '../../features/debug/developer_playground_screen.dart';
import '../../features/alpha/alpha_welcome_screen.dart';
import '../../features/alpha/feedback_hub_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../../features/legal/terms_of_service_screen.dart';

import '../lifecycle/app_lifecycle_notifier.dart';

/// State notifier that listens to the BootstrapManager AND Supabase Auth changes AND Profile changes
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    BootstrapManager().stateNotifier.addListener(_handleChange);
    // Listen to healthIdentityProvider so route updates when onboarding is completed
    _ref.listen(healthIdentityProvider, (prev, next) {
      _handleChange();
    });
    // Listen to appLifecycleProvider so route updates when lifecycle state changes
    _ref.listen(appLifecycleProvider, (prev, next) {
      _handleChange();
    });
  }

  void _handleChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    BootstrapManager().stateNotifier.removeListener(_handleChange);
    super.dispose();
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

/// Navigation is now strictly tied to local offline readiness.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final bootstrapState = BootstrapManager().state;

      final isAtSplash = state.matchedLocation == '/splash';
      final isAtAuth = state.matchedLocation == '/auth';
      final isAtOnboarding = state.matchedLocation.startsWith('/onboarding');
      final isAtLoginCallback = state.matchedLocation == '/login-callback';

      // 1. App is Booting
      if (bootstrapState != BootstrapState.complete && bootstrapState != BootstrapState.error) {
        if (isAtSplash) return null;
        return '/splash';
      }

      // 2. Fatal Bootstrap Error
      if (bootstrapState == BootstrapState.error) {
        return '/splash';
      }

      // 3. Complete Phase (Guest or Cloud)
      if (bootstrapState == BootstrapState.complete) {
        final lifecycle = ref.read(appLifecycleProvider);
        final isLoggedIn = lifecycle.isLoggedIn;

        if (!isLoggedIn) {
          if (isAtAuth || isAtLoginCallback) return null;
          return '/auth';
        } else {
          // Check if onboarding completed
          final healthId = ref.read(healthIdentityProvider);
          final onboardingComplete = (healthId != null && healthId.isComplete) || lifecycle.isProfileComplete;

          if (!onboardingComplete) {
            if (!lifecycle.isAlphaConsented && state.matchedLocation != '/alpha-welcome' && !state.matchedLocation.startsWith('/legal')) {
              return '/alpha-welcome';
            }
            if (state.matchedLocation == '/alpha-welcome' || state.matchedLocation.startsWith('/legal')) return null;
            if (isAtOnboarding) return null;
            return '/onboarding';
          } else {
            if (isAtAuth || isAtSplash || isAtOnboarding || isAtLoginCallback || state.matchedLocation == '/alpha-welcome') {
              return '/';
            }
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(path: 'identity', builder: (context, state) => const OnboardingScreen(step: 0)),
          GoRoute(path: 'lifestyle', builder: (context, state) => const OnboardingScreen(step: 1)),
          GoRoute(path: 'food', builder: (context, state) => const OnboardingScreen(step: 2)),
          GoRoute(path: 'risk', builder: (context, state) => const OnboardingScreen(step: 3)),
        ],
      ),
      GoRoute(
        path: '/dev/playground',
        builder: (context, state) => const DeveloperPlaygroundScreen(),
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) => const FlowScreen(),
      ),

      GoRoute(
        path: '/alpha-welcome',
        builder: (context, state) => const AlphaWelcomeScreen(),
      ),
      GoRoute(
        path: '/feedback-hub',
        builder: (context, state) => const FeedbackHubScreen(),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const TodayScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/body', builder: (context, state) => const BodyPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/explore', builder: (context, state) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/me', builder: (context, state) => const MeScreen())]),
        ],
      ),
    ],
  );
});
