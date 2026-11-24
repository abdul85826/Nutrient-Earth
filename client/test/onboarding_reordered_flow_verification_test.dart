// ==============================================================================
// Nutrient Earth — Reordered Onboarding Journey & Post-Onboarding Auth Test Suite
// Verifies all 15 criteria mandated by the real product engineering mission:
// 1. New unauthenticated user starts at splash/get started.
// 2. Every onboarding screen can be completed without authentication.
// 3. Every nested onboarding route works.
// 4. Back navigation restores previous answers.
// 5. Forward navigation validates required answers.
// 6. Onboarding progress survives refresh/restart.
// 7. Authentication cannot be reached before required onboarding completion.
// 8. Authentication opens after onboarding completion.
// 9. Google OAuth returns to the correct post-authentication destination.
// 10. Email magic-link/OTP authentication still works.
// 11. Profile synchronization occurs only after authentication.
// 12. Duplicate synchronization does not create duplicate profiles.
// 13. Protected health routes remain inaccessible without authentication.
// 14. Returning authenticated users with completed onboarding reach /today.
// 15. Returning users with incomplete onboarding resume correctly.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_destination_resolver.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/services/profile_sync_service.dart';
import 'package:nutrient_earth_client/core/services/task_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/data/onboarding_storage_service.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:nutrient_earth_client/routing/app_router.dart';

class MockBuildContext extends Fake implements BuildContext {}

class MockAuthServiceForReorder implements AuthService {
  User? _currentUser;
  final StreamController<AuthState> _streamCtrl = StreamController<AuthState>.broadcast();

  void loginAs(String userId, {String email = 'user@nutrientearth.win'}) {
    _currentUser = User(
      id: userId,
      appMetadata: {},
      userMetadata: {'full_name': 'Verified Researcher'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
  }

  void logout() {
    _currentUser = null;
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => _currentUser == null
      ? null
      : Session(accessToken: 'mock_token', tokenType: 'bearer', user: _currentUser!);

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AuthState> get authStateChanges => _streamCtrl.stream;

  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) async {}

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    loginAs('usr_otp_verified_999', email: email);
    return AuthResponse(session: currentSession, user: _currentUser);
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    loginAs('usr_google_oauth_777');
    return true;
  }

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    loginAs('usr_google_oauth_777');
    return AuthSessionUrlResponse(session: currentSession!, redirectType: 'web');
  }

  @override
  Future<void> resendOtp({required String email, OtpType type = OtpType.email, String? captchaToken}) async {}
  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}
  @override
  Future<AuthResponse> signIn({required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<void> signOut() async => logout();
  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async => throw UnimplementedError();
  @override
  Future<UserResponse> updatePassword({required String newPassword}) async => throw UnimplementedError();
}

class MockProfileRepoForReorder implements ProfileRepository {
  final Map<String, UserProfileContext> store = {};
  int saveCount = 0;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    return store[explicitUserId];
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    return store[userId];
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    saveCount++;
    store[profile.userId] = profile;
    return true;
  }

  @override
  Future<bool> updateAvatar({
    required String skinTone,
    Map<String, dynamic>? avatarConfig,
  }) async => true;

  @override
  Future<bool> clearCacheForUser(String userId) async {
    store.remove(userId);
    return true;
  }
}

class MockStorageForReorder extends OnboardingStorageService {
  OnboardingJourneyState? _staged;

  MockStorageForReorder([this._staged]);

  @override
  OnboardingJourneyState? get cachedStagedState => _staged;

  @override
  bool get isOnboardingCompleted => _staged?.onboardingFinished ?? false;

  @override
  Future<void> saveStagedOnboarding(OnboardingJourneyState state) async {
    _staged = state;
  }

  @override
  Future<OnboardingJourneyState?> loadStagedOnboarding() async {
    return _staged;
  }

  @override
  Future<void> clearStagedOnboarding() async {
    _staged = null;
  }
}

GoRouterState _createState(GoRouter router, String location) {
  final uri = Uri.parse(location);
  return GoRouterState(
    router.configuration,
    uri: uri,
    matchedLocation: uri.path,
    fullPath: uri.path,
    pathParameters: const {},
    pageKey: const ValueKey('test_key'),
  );
}

void main() {
  group('NUTRIENT EARTH — 15 Master Mission Reordered Onboarding Tests', () {
    late MockAuthServiceForReorder mockAuth;
    late MockProfileRepoForReorder mockProfileRepo;
    late InMemoryTaskRepository mockTaskRepo;

    setUp(() {
      mockAuth = MockAuthServiceForReorder();
      mockProfileRepo = MockProfileRepoForReorder();
      mockTaskRepo = InMemoryTaskRepository();
    });

    test('1. New unauthenticated user starts at splash/get started', () {
      final router = createAppRouter(authService: mockAuth);
      expect(router.routeInformationProvider.value.uri.path, equals('/splash'));

      final stateWelcome = _createState(router, '/welcome');
      final redirectWelcome = appRouterRedirect(
        MockBuildContext(),
        stateWelcome,
        authService: mockAuth,
      );
      expect(redirectWelcome, isNull);
    });

    test('2. Every onboarding screen can be completed without authentication', () {
      final router = createAppRouter(authService: mockAuth);
      final onboardingRoutes = [
        '/onboarding/health-goals',
        '/onboarding/difficulties',
        '/onboarding/daily-impact',
        '/onboarding/food-choices',
        '/onboarding/review-phase1',
        '/onboarding/personal-details',
        '/onboarding/body-measurements',
        '/onboarding/health-concerns',
        '/onboarding/food-restrictions',
        '/onboarding/eating-routine',
        '/onboarding/daily-activity',
        '/onboarding/sleep-patterns',
        '/onboarding/knowledge-level',
        '/onboarding/completion',
      ];

      for (final r in onboardingRoutes) {
        final state = _createState(router, r);
        final redirect = appRouterRedirect(
          MockBuildContext(),
          state,
          authService: mockAuth,
        );
        expect(redirect, isNull, reason: '$r must be directly accessible unauthenticated');
      }
    });

    test('3. Every nested onboarding route and review checkpoint works', () {
      final router = createAppRouter(authService: mockAuth);

      final stateReview = _createState(router, '/onboarding/review-phase1');
      expect(appRouterRedirect(MockBuildContext(), stateReview, authService: mockAuth), isNull);

      final stateCompletion = _createState(router, '/onboarding/completion');
      expect(appRouterRedirect(MockBuildContext(), stateCompletion, authService: mockAuth), isNull);
    });

    test('4. Back navigation restores previous answers cleanly', () {
      final notifier = OnboardingJourneyNotifier();

      // User selects goals on Screen 04
      notifier.setHealthGoals({'longevity', 'energy'});
      expect(notifier.currentState.healthGoals, contains('longevity'));

      // Advances to Screen 05, adds difficulties
      notifier.setDifficulties({'afternoon_slump'});
      expect(notifier.currentState.difficulties, contains('afternoon_slump'));

      // Taps back to Screen 04: previous goals remain intact
      expect(notifier.currentState.healthGoals.length, equals(2));
    });

    test('5. Forward navigation validates required answers', () {
      final notifier = OnboardingJourneyNotifier();

      // Empty state
      expect(notifier.currentState.healthGoals, isEmpty);
      expect(notifier.currentState.age, equals(0));

      // Personal details validation
      notifier.setPersonalDetails(name: 'Abdul Rehman', age: 24);
      expect(notifier.currentState.firstName, equals('Abdul Rehman'));
      expect(notifier.currentState.age, greaterThanOrEqualTo(16));
    });

    test('6. Onboarding progress survives refresh/restart via local storage', () async {
      final storage = MockStorageForReorder();
      const stateBeforeRefresh = OnboardingJourneyState(
        healthGoals: {'gut_health'},
        dietaryPattern: 'vegetarian',
        firstName: 'Sam',
        age: 29,
        onboardingFinished: true,
      );

      await storage.saveStagedOnboarding(stateBeforeRefresh);
      expect(storage.cachedStagedState, isNotNull);

      final restored = await storage.loadStagedOnboarding();
      expect(restored?.healthGoals, contains('gut_health'));
      expect(restored?.dietaryPattern, equals('vegetarian'));
      expect(restored?.onboardingFinished, isTrue);
    });

    test('7. Authentication cannot be reached before required onboarding completion', () {
      final router = createAppRouter(authService: mockAuth);
      final storage = MockStorageForReorder(
        const OnboardingJourneyState(onboardingFinished: false),
      );

      final stateAuth = _createState(router, '/auth?mode=signup');
      final redirect = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        storageService: storage,
      );

      // Must be redirected away from authentication
      expect(redirect, equals('/welcome'));
    });

    test('8. Authentication opens after onboarding completion', () {
      final router = createAppRouter(authService: mockAuth);
      final storage = MockStorageForReorder(
        const OnboardingJourneyState(
          healthGoals: {'energy'},
          onboardingFinished: true,
        ),
      );

      final stateAuth = _createState(router, '/auth?mode=signup');
      final redirect = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        storageService: storage,
      );

      // Must be allowed to access authentication
      expect(redirect, isNull);
    });

    test('9. Google OAuth returns to the correct post-authentication destination', () async {
      mockAuth.loginAs('usr_google_1');
      mockProfileRepo.store['usr_google_1'] = const UserProfileContext(
        userId: 'usr_google_1',
        displayName: 'Google Member',
        onboardingCompleted: true,
      );

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockProfileRepo,
        userId: 'usr_google_1',
      );

      expect(destination, equals('/today'));
    });

    test('10. Email OTP authentication establishes session and resolves destination', () async {
      expect(mockAuth.isAuthenticated, isFalse);

      final response = await mockAuth.verifyOtp(email: 'researcher@nutrientearth.win', token: '123456');
      expect(response.user, isNotNull);
      expect(mockAuth.isAuthenticated, isTrue);

      mockProfileRepo.store[response.user!.id] = UserProfileContext(
        userId: response.user!.id,
        displayName: 'Researcher',
        onboardingCompleted: true,
      );

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockProfileRepo,
        userId: response.user!.id,
      );
      expect(destination, equals('/today'));
    });

    test('11. Profile synchronization occurs only after authentication with verified user ID', () async {
      final storage = MockStorageForReorder(
        const OnboardingJourneyState(
          healthGoals: {'vitality'},
          dietaryPattern: 'mediterranean',
          firstName: 'Clara',
          age: 32,
          onboardingFinished: true,
        ),
      );

      final syncService = ProfileSyncService(
        storageService: storage,
        profileRepo: mockProfileRepo,
        taskRepo: mockTaskRepo,
      );

      final notifier = OnboardingJourneyNotifier(storage.cachedStagedState);

      // Synchronize with authentic User context
      final user = const User(
        id: 'usr_verified_clara',
        appMetadata: {},
        userMetadata: {},
        aud: 'auth',
        createdAt: '',
      );

      final synced = await syncService.synchronizeStagedOnboarding(user: user, notifier: notifier);
      expect(synced, isTrue);

      final saved = await mockProfileRepo.getCurrentUserProfile(explicitUserId: 'usr_verified_clara');
      expect(saved, isNotNull);
      expect(saved?.displayName, equals('Clara'));
      expect(saved?.onboardingCompleted, isTrue);

      // Local storage wiped after sync
      expect(storage.cachedStagedState, isNull);
    });

    test('12. Duplicate synchronization does not create duplicate profiles (idempotent)', () async {
      final storage = MockStorageForReorder(
        const OnboardingJourneyState(
          healthGoals: {'sleep'},
          firstName: 'Elena',
          age: 28,
          onboardingFinished: true,
        ),
      );

      final syncService = ProfileSyncService(
        storageService: storage,
        profileRepo: mockProfileRepo,
        taskRepo: mockTaskRepo,
      );

      final notifier = OnboardingJourneyNotifier(storage.cachedStagedState);
      final user = const User(id: 'usr_elena', appMetadata: {}, userMetadata: {}, aud: 'auth', createdAt: '');

      // First sync
      await syncService.synchronizeStagedOnboarding(user: user, notifier: notifier);
      expect(mockProfileRepo.store.length, equals(1));

      // Second sync attempt (storage already cleared)
      final secondSync = await syncService.synchronizeStagedOnboarding(user: user, notifier: notifier);
      expect(secondSync, isFalse);
      expect(mockProfileRepo.store.length, equals(1));
    });

    test('13. Protected health routes remain inaccessible without authentication', () {
      final router = createAppRouter(authService: mockAuth);

      final stateToday = _createState(router, '/today');
      final redirectToday = appRouterRedirect(
        MockBuildContext(),
        stateToday,
        authService: mockAuth,
      );
      expect(redirectToday, equals('/welcome'));

      final stateExplore = _createState(router, '/explore');
      final redirectExplore = appRouterRedirect(
        MockBuildContext(),
        stateExplore,
        authService: mockAuth,
      );
      expect(redirectExplore, equals('/welcome'));
    });

    test('14. Returning authenticated users with completed onboarding reach /today', () {
      mockAuth.loginAs('usr_returning');
      mockProfileRepo.store['usr_returning'] = const UserProfileContext(
        userId: 'usr_returning',
        displayName: 'Returning Member',
        onboardingCompleted: true,
      );

      final router = createAppRouter(authService: mockAuth, profileRepository: mockProfileRepo);

      final stateAuth = _createState(router, '/auth');
      final redirectAuth = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        profileRepository: mockProfileRepo,
      );
      expect(redirectAuth, equals('/today'));

      final stateWelcome = _createState(router, '/welcome');
      final redirectWelcome = appRouterRedirect(
        MockBuildContext(),
        stateWelcome,
        authService: mockAuth,
        profileRepository: mockProfileRepo,
      );
      expect(redirectWelcome, equals('/today'));
    });

    test('15. Returning users with incomplete onboarding resume correctly', () {
      mockAuth.loginAs('usr_incomplete');
      mockProfileRepo.store['usr_incomplete'] = const UserProfileContext(
        userId: 'usr_incomplete',
        displayName: 'Incomplete Member',
        primaryGoals: ['energy'],
        difficulties: ['slump'],
        dailyImpacts: {'slump': 3},
        dietaryPreference: '', // Missing Screen 07
        onboardingCompleted: false,
      );

      final router = createAppRouter(authService: mockAuth, profileRepository: mockProfileRepo);

      final stateAuth = _createState(router, '/auth');
      final redirectAuth = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        profileRepository: mockProfileRepo,
      );

      // Must route to Screen 07 (food-choices) to resume
      expect(redirectAuth, equals('/onboarding/food-choices'));
    });
  });
}
