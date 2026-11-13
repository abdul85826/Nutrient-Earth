// ==============================================================================
// Nutrient Earth — Startup Coordinator & State Machine
// Authoritative coordinator managing the complete application startup lifecycle:
// Initializing -> RestoringSession -> CheckingOnboarding -> ShowingWelcome /
// ShowingOnboarding / ShowingMainApplication / RecoverableError.
// Enforces single-source routing, offline tolerance, and idempotency.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/data/onboarding_storage_service.dart';
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import 'auth_destination_resolver.dart';
import 'auth_service.dart';
import 'profile_repository.dart';

enum StartupState {
  initializing,
  restoringSession,
  checkingOnboarding,
  showingWelcome,
  showingOnboarding,
  showingMainApplication,
  recoverableError,
}

class StartupStatus {
  final StartupState state;
  final String targetRoute;
  final String? errorMessage;
  final bool isReady;

  const StartupStatus({
    required this.state,
    required this.targetRoute,
    this.errorMessage,
    this.isReady = false,
  });

  StartupStatus copyWith({
    StartupState? state,
    String? targetRoute,
    String? errorMessage,
    bool? isReady,
  }) {
    return StartupStatus(
      state: state ?? this.state,
      targetRoute: targetRoute ?? this.targetRoute,
      errorMessage: errorMessage ?? this.errorMessage,
      isReady: isReady ?? this.isReady,
    );
  }

  @override
  String toString() =>
      'StartupStatus(state: $state, targetRoute: $targetRoute, isReady: $isReady, error: $errorMessage)';
}

class StartupCoordinator extends StateNotifier<StartupStatus> {
  final AuthService _authService;
  final ProfileRepository _profileRepository;
  final OnboardingStorageService _storageService;

  bool _hasNavigated = false;
  bool get hasNavigated => _hasNavigated;

  StartupCoordinator({
    required AuthService authService,
    required ProfileRepository profileRepository,
    required OnboardingStorageService storageService,
  })  : _authService = authService,
        _profileRepository = profileRepository,
        _storageService = storageService,
        super(const StartupStatus(
          state: StartupState.initializing,
          targetRoute: '/splash',
          isReady: false,
        ));

  /// Attempts to mark navigation as completed. Returns true if this is the first call,
  /// preventing duplicate transitions from repeated state notifications.
  bool markNavigated() {
    if (_hasNavigated) return false;
    _hasNavigated = true;
    return true;
  }

  /// Resets the navigation guard (e.g. on manual restart or sign out).
  void resetNavigation() {
    _hasNavigated = false;
  }

  /// Initiates the full startup resolution pipeline.
  Future<void> resolveStartupDestination() async {
    _hasNavigated = false;
    state = const StartupStatus(
      state: StartupState.initializing,
      targetRoute: '/splash',
      isReady: false,
    );

    try {
      // 1. Initializing core configurations if not yet completed
      if (!AppConfig.isInitialized) {
        try {
          await AppConfig.initialize();
        } catch (e) {
          debugPrint('[StartupCoordinator] AppConfig warning: $e');
        }
      }

      if (!SupabaseConfig.isInitialized && AppConfig.supabaseUrl.isNotEmpty) {
        try {
          await SupabaseConfig.initialize();
        } catch (e) {
          debugPrint('[StartupCoordinator] SupabaseConfig warning: $e');
        }
      }

      // 2. RestoringSession: evaluate authentic Supabase session
      state = state.copyWith(state: StartupState.restoringSession);
      final user = _authService.currentUser;
      final isAuthenticated = _authService.isAuthenticated && user != null;

      // 3. CheckingOnboarding: evaluate onboarding status based on auth state
      state = state.copyWith(state: StartupState.checkingOnboarding);

      if (!isAuthenticated) {
        // Unauthenticated visitor: inspect local staged onboarding progress
        final staged = await _storageService.loadStagedOnboarding();
        if (staged != null && staged.healthGoals.isNotEmpty) {
          // Incomplete guest onboarding resumption
          debugPrint('[StartupCoordinator] Resuming in-flight guest onboarding');
          state = const StartupStatus(
            state: StartupState.showingOnboarding,
            targetRoute: '/onboarding/health-goals',
            isReady: true,
          );
        } else {
          // Fresh installation: show welcome value proposition
          debugPrint('[StartupCoordinator] Fresh installation -> showing welcome');
          state = const StartupStatus(
            state: StartupState.showingWelcome,
            targetRoute: '/welcome',
            isReady: true,
          );
        }
        return;
      }

      // Authenticated User: retrieve verified profile context
      try {
        final profile = await _profileRepository.getCurrentUserProfile(explicitUserId: user.id);

        if (profile != null && profile.onboardingCompleted) {
          debugPrint('[StartupCoordinator] Verified completed profile -> /today');
          state = const StartupStatus(
            state: StartupState.showingMainApplication,
            targetRoute: '/today',
            isReady: true,
          );
          return;
        }

        if (profile == null) {
          // New authenticated account with no profile yet created
          debugPrint('[StartupCoordinator] New account -> /onboarding/health-goals');
          state = const StartupStatus(
            state: StartupState.showingOnboarding,
            targetRoute: '/onboarding/health-goals',
            isReady: true,
          );
          return;
        }

        // Incomplete profile: resolve the specific incomplete onboarding step
        final firstIncomplete = AuthDestinationResolver.resolveFirstIncompleteStep(profile);
        debugPrint('[StartupCoordinator] Incomplete account -> $firstIncomplete');
        state = StartupStatus(
          state: StartupState.showingOnboarding,
          targetRoute: firstIncomplete,
          isReady: true,
        );
      } catch (profileError) {
        debugPrint('[StartupCoordinator] Profile retrieval exception: $profileError');
        // Offline / network fallback: check account-isolated local cache
        final cached = _profileRepository.getCachedProfileSync(user.id);
        if (cached != null) {
          if (cached.onboardingCompleted) {
            state = const StartupStatus(
              state: StartupState.showingMainApplication,
              targetRoute: '/today',
              isReady: true,
            );
          } else {
            final nextStep = AuthDestinationResolver.resolveFirstIncompleteStep(cached);
            state = StartupStatus(
              state: StartupState.showingOnboarding,
              targetRoute: nextStep,
              isReady: true,
            );
          }
          return;
        }

        // Genuine failure without cached state: present recoverable error
        state = StartupStatus(
          state: StartupState.recoverableError,
          targetRoute: '/splash',
          errorMessage: 'Unable to connect to your profile. Please check your network connection and retry.',
          isReady: false,
        );
      }
    } catch (criticalError) {
      debugPrint('[StartupCoordinator] Critical startup error: $criticalError');
      state = StartupStatus(
        state: StartupState.recoverableError,
        targetRoute: '/splash',
        errorMessage: 'A startup error occurred. Tap below to retry.',
        isReady: false,
      );
    }
  }

  /// Retries resolution after a recoverable failure.
  void retry() {
    resolveStartupDestination();
  }
}

final startupCoordinatorProvider =
    StateNotifierProvider<StartupCoordinator, StartupStatus>((ref) {
  final authService = ref.watch(authServiceProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  final storageService = ref.watch(onboardingStorageServiceProvider);

  final coordinator = StartupCoordinator(
    authService: authService,
    profileRepository: profileRepository,
    storageService: storageService,
  );

  // Automatically begin resolution when first observed
  coordinator.resolveStartupDestination();

  return coordinator;
});
