import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_service.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/onboarding/domain/onboarding_state.dart';
import '../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/body/presentation/body_screen.dart';
import '../features/growth/presentation/growth_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/store/presentation/store_screen.dart';
import '../features/research/presentation/research_workspace_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authServiceProvider);
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/today',
    redirect: (context, state) {
      final isAuth = authState is Authenticated;
      final path = state.uri.path;

      if (!isAuth) {
        return path == '/login' ? null : '/login';
      }

      if (!onboardingState.hasCompletedOnboarding) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      if (path == '/login' || path == '/onboarding') {
        return '/today';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/body',
            builder: (context, state) => const BodyScreen(),
          ),
          GoRoute(
            path: '/growth',
            builder: (context, state) => const GrowthScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/store',
            builder: (context, state) => const StoreScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/research',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return ResearchWorkspaceScreen(initialQuery: query);
        },
      ),
    ],
  );
});
