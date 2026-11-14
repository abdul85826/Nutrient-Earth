// ==============================================================================
// Nutrient Earth — App Router (GoRouter)
// Unified router providing clean routing to the canonical HomeScreen.
// ==============================================================================

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/supabase_config.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_repository.dart';
import '../features/home/presentation/home_screen.dart';
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
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
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
