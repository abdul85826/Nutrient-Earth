import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_service.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../features/body/presentation/body_screen.dart';
import '../features/growth/presentation/growth_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/store/presentation/store_screen.dart';
import '../features/research/presentation/research_workspace_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/ask',
    redirect: (context, state) {
      final isAuth = authState is Authenticated;
      final path = state.uri.path;

      if (!isAuth) {
        return path == '/login' ? null : '/login';
      }

      // If authenticated user visits login, send directly to main application
      if (path == '/login') {
        return '/ask';
      }

      // Legacy /today route gracefully redirects to /ask
      if (path == '/today') {
        return '/ask';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/ask',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return ResearchWorkspaceScreen(initialQuery: query);
            },
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/growth',
            builder: (context, state) => const GrowthScreen(),
          ),
          GoRoute(
            path: '/body',
            builder: (context, state) => const BodyScreen(),
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
