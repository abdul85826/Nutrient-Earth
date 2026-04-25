import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_navigation_shell.dart';
import '../../features/today/today_screen.dart';
import '../../features/body/body_screen.dart';
import '../../features/flow/flow_screen.dart';
import '../../features/me/me_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../providers/app_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  
  // Watch auth and onboarding state to trigger redirects
  // This ensures the router re-evaluates redirects when these states change
  ref.watch(authStateProvider);
  final userProfile = ref.watch(userProgressProvider);
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isLoggingIn = state.matchedLocation == '/auth';
      final isSplashing = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // 1. Splash Screen logic
      if (isSplashing) return null;

      // 2. Auth protection
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/auth';
      }

      // 3. Logged in logic
      if (isLoggingIn) {
        // Just logged in, check onboarding
        return userProfile.hasCompletedOnboarding ? '/' : '/onboarding';
      }

      // 4. Onboarding protection
      if (!userProfile.hasCompletedOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      // 5. Prevent returning to onboarding or auth if complete
      if (userProfile.hasCompletedOnboarding && (isOnboarding || isLoggingIn)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/body',
                builder: (context, state) => const BodyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/flow',
                builder: (context, state) => const FlowScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
