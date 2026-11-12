// ==============================================================================
// Nutrient Earth — Profile Synchronization Service
// Idempotently synchronizes unauthenticated onboarding answers to Supabase
// public.profiles and seeds goal-tailored tasks in public.user_daily_tasks.
// Enforces server-verified user identity, clinical safety constraints,
// and clean purging of local staging upon successful synchronization.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/onboarding/data/onboarding_storage_service.dart';
import '../../features/onboarding/state/onboarding_journey_state.dart';
import 'auth_service.dart';
import 'profile_repository.dart';
import 'task_repository.dart';

class ProfileSyncService {
  final OnboardingStorageService _storageService;
  final ProfileRepository _profileRepo;
  final TaskRepository _taskRepo;

  const ProfileSyncService({
    required OnboardingStorageService storageService,
    required ProfileRepository profileRepo,
    required TaskRepository taskRepo,
  })  : _storageService = storageService,
        _profileRepo = profileRepo,
        _taskRepo = taskRepo;

  /// Idempotently synchronizes staged onboarding state to the authenticated profile.
  /// Returns true if synchronization occurred, or false if no staged onboarding was present.
  Future<bool> synchronizeStagedOnboarding({
    required User user,
    required OnboardingJourneyNotifier notifier,
  }) async {
    try {
      // 1. Check in-memory state or load staged state from secure local storage
      var currentState = notifier.currentState;
      if (currentState.healthGoals.isEmpty) {
        final staged = await _storageService.loadStagedOnboarding();
        if (staged != null && staged.healthGoals.isNotEmpty) {
          notifier.hydrate(staged);
          currentState = staged;
        }
      }

      // If no onboarding data was collected (e.g. standard returning login), skip sync
      if (currentState.healthGoals.isEmpty && currentState.difficulties.isEmpty) {
        debugPrint('[ProfileSyncService] No staged onboarding answers found for user ${user.id}. Skipping sync.');
        return false;
      }

      debugPrint('[ProfileSyncService] Synchronizing staged onboarding for user ${user.id}...');

      // 2. Perform atomic profile persistence with verified server user id
      final success = await notifier.saveAndComplete(
        auth: _FixedUserAuthService(user),
        profileRepo: _profileRepo,
        taskRepo: _taskRepo,
      );

      if (success) {
        // 3. Securely wipe local staging storage and reset notifier state upon successful account synchronization
        await _storageService.clearStagedOnboarding();
        notifier.reset();
        debugPrint('[ProfileSyncService] Staged onboarding successfully synchronized and local buffer purged.');
        return true;
      } else {
        debugPrint('[ProfileSyncService] Failed to synchronize profile: ${notifier.currentState.saveError}');
        return false;
      }
    } catch (e) {
      debugPrint('[ProfileSyncService] Synchronization error: $e');
      return false;
    }
  }
}

/// Helper adapter ensuring saveAndComplete uses the verified authenticated User
class _FixedUserAuthService implements AuthService {
  final User _user;
  const _FixedUserAuthService(this._user);

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => null;

  @override
  bool get isAuthenticated => true;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) => throw UnimplementedError();

  @override
  Future<void> resendOtp({required String email, OtpType type = OtpType.email, String? captchaToken}) => throw UnimplementedError();

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) => throw UnimplementedError();

  @override
  Future<AuthResponse> signIn({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) => throw UnimplementedError();

  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) => throw UnimplementedError();

  @override
  Future<UserResponse> updatePassword({required String newPassword}) => throw UnimplementedError();

  @override
  Future<AuthResponse> verifyOtp({required String email, required String token, OtpType type = OtpType.email, String? captchaToken}) => throw UnimplementedError();
}

final profileSyncServiceProvider = Provider<ProfileSyncService>((ref) {
  return ProfileSyncService(
    storageService: ref.watch(onboardingStorageServiceProvider),
    profileRepo: ref.watch(profileRepositoryProvider),
    taskRepo: ref.watch(taskRepositoryProvider),
  );
});

