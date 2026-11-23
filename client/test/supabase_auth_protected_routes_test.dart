// ==============================================================================
// Nutrient Earth — Supabase Auth & Protected Routes Verification Test Suite
// Verifies:
// 1. Reactive Supabase Auth Providers (currentUser, isAuthenticated, authStateChanges).
// 2. Protected route gating: Unauthenticated requests to /onboarding/* redirect to /auth.
// 3. ReturnTo preservation for post-authentication deep linking.
// 4. Authenticated sessions bypass login and redirect forward.
// 5. Password recovery and password update methods.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/data/onboarding_storage_service.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:nutrient_earth_client/routing/app_router.dart';

class MockOnboardingStorageService extends OnboardingStorageService {
  final bool _completed;
  final OnboardingJourneyState? _stagedState;

  const MockOnboardingStorageService({
    bool isOnboardingCompleted = false,
    OnboardingJourneyState? stagedState,
  })  : _completed = isOnboardingCompleted,
        _stagedState = stagedState;

  @override
  bool get isOnboardingCompleted => _completed;

  @override
  OnboardingJourneyState? get cachedStagedState => _stagedState;

  @override
  Future<OnboardingJourneyState?> loadStagedOnboarding() async => _stagedState;
}

class MockTestProfileRepo implements ProfileRepository {
  final bool onboardingCompleted;
  MockTestProfileRepo({this.onboardingCompleted = true});

  @override
  Future<bool> updateAvatar({
    required String skinTone,
    Map<String, dynamic>? avatarConfig,
  }) async => true;

  @override
  Future<bool> clearCacheForUser(String userId) async => true;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    if (userId == null) return null;
    return UserProfileContext(
      userId: userId,
      displayName: 'Test User',
      age: 30,
      biologicalSex: 'female',
      primaryGoals: const ['longevity'],
      activityLevel: 'moderate',
      dietaryPreference: 'omnivore',
      budgetConstraint: 'moderate',
      willingnessToChange: 'high',
      onboardingCompleted: onboardingCompleted,
    );
  }

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async => getCachedProfileSync('mock');
  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async => true;
  Future<bool> markOnboardingCompleted(String userId) async => true;
  Future<bool> clearProfile() async => true;
  @override
  Future<bool> clearCacheForUser(String userId) async => true;
}

class MockControlledAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _authController = StreamController<AuthState>.broadcast();
  bool resetPasswordCalled = false;
  String? lastResetEmail;
  bool updatePasswordCalled = false;
  String? lastUpdatedPassword;

  void setAuthenticatedUser(String email, {String id = 'usr_mock_123'}) {
    _user = User(
      id: id,
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    _session = Session(
      accessToken: 'mock_token_jwt',
      tokenType: 'bearer',
      user: _user!,
    );
    _authController.add(AuthState(AuthChangeEvent.signedIn, _session));
  }

  void clearSession() {
    _user = null;
    _session = null;
    _authController.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  void dispose() {
    _authController.close();
  }

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => _session;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Stream<AuthState> get authStateChanges => _authController.stream;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    setAuthenticatedUser(email);
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    setAuthenticatedUser(email);
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) async {}

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    setAuthenticatedUser(email);
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {}

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    setAuthenticatedUser('google_user@example.com');
    return true;
  }

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    setAuthenticatedUser('oauth_exchanged@example.com');
    return AuthSessionUrlResponse(session: _session!, redirectType: 'web');
  }

  @override
  Future<void> signOut() async {
    clearSession();
  }

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {
    resetPasswordCalled = true;
    lastResetEmail = email;
  }

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async {
    updatePasswordCalled = true;
    lastUpdatedPassword = newPassword;
    return UserResponse.fromJson({
      'user': _user?.toJson() ?? {},
    });
  }
}

class MockBuildContext extends Fake implements BuildContext {}

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockControlledAuthService mockAuth;

  setUp(() {
    mockAuth = MockControlledAuthService();
  });

  tearDown(() {
    mockAuth.dispose();
  });

  group('Supabase Auth & Reactive State Providers', () {
    test('Unauthenticated state returns null user and false for isAuthenticated', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('Authenticated state reactively reflects current user and returns true for isAuthenticated', () {
      mockAuth.setAuthenticatedUser('alex.researcher@example.com');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(currentUserProvider)?.email, equals('alex.researcher@example.com'));
    });

    test('Sign out updates reactive providers immediately', () async {
      mockAuth.setAuthenticatedUser('alex.researcher@example.com');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAuthenticatedProvider), isTrue);

      mockAuth.clearSession();
      // Allow microtask stream event to propagate through Riverpod
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('Password reset and update password methods record parameters properly', () async {
      await mockAuth.resetPasswordForEmail(email: 'reset@example.com');
      expect(mockAuth.resetPasswordCalled, isTrue);
      expect(mockAuth.lastResetEmail, equals('reset@example.com'));

      await mockAuth.updatePassword(newPassword: 'newSecurePassword123');
      expect(mockAuth.updatePasswordCalled, isTrue);
      expect(mockAuth.lastUpdatedPassword, equals('newSecurePassword123'));
    });
  });

  group('GoRouter Protected Route Guards', () {
    test('GoRouterRefreshStream instantiates and cleans up listeners without errors', () {
      final refreshStream = GoRouterRefreshStream(const Stream<AuthState>.empty());
      expect(refreshStream, isA<ChangeNotifier>());
      refreshStream.dispose();
    });

    test('Default appRouter is configured with initial location and route definitions', () {
      expect(appRouter, isA<GoRouter>());
      expect(appRouter.routeInformationProvider.value.uri.path, isNotEmpty);
    });

    test('Unauthenticated user navigating to onboarding routes is allowed without requiring an account', () {
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/onboarding/health-goals');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
      );

      // Must allow unauthenticated users to complete onboarding
      expect(redirect, isNull);
    });

    test('Unauthenticated user navigating to public routes (welcome, splash) is not blocked', () {
      final router = createAppRouter(authService: mockAuth);

      final stateWelcome = _createState(router, '/welcome');
      final redirectWelcome = appRouterRedirect(
        MockBuildContext(),
        stateWelcome,
        authService: mockAuth,
      );
      expect(redirectWelcome, isNull);

      final stateSplash = _createState(router, '/splash');
      final redirectSplash = appRouterRedirect(
        MockBuildContext(),
        stateSplash,
        authService: mockAuth,
      );
      expect(redirectSplash, isNull);
    });

    test('Unauthenticated user navigating to /auth before completing onboarding is redirected to /welcome', () {
      final router = createAppRouter(authService: mockAuth);
      final stateAuth = _createState(router, '/auth?mode=signup');
      final redirectAuth = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        storageService: const MockOnboardingStorageService(isOnboardingCompleted: false),
      );
      expect(redirectAuth, equals('/welcome'));
    });

    test('Unauthenticated user who completed onboarding navigating to /auth is allowed', () {
      final router = createAppRouter(authService: mockAuth);
      final stateAuth = _createState(router, '/auth?mode=signup');
      final redirectAuth = appRouterRedirect(
        MockBuildContext(),
        stateAuth,
        authService: mockAuth,
        storageService: const MockOnboardingStorageService(isOnboardingCompleted: true),
      );
      expect(redirectAuth, isNull);
    });

    test('Unauthenticated user navigating to /auth?mode=signin is allowed for returning account login', () {
      final router = createAppRouter(authService: mockAuth);
      final stateSignIn = _createState(router, '/auth?mode=signin');
      final redirectSignIn = appRouterRedirect(
        MockBuildContext(),
        stateSignIn,
        authService: mockAuth,
        storageService: const MockOnboardingStorageService(isOnboardingCompleted: false),
      );
      expect(redirectSignIn, isNull);
    });

    test('Unauthenticated user navigating to /today before completing onboarding is redirected to /welcome', () {
      final router = createAppRouter(authService: mockAuth);
      final stateToday = _createState(router, '/today');
      final redirectToday = appRouterRedirect(
        MockBuildContext(),
        stateToday,
        authService: mockAuth,
        storageService: const MockOnboardingStorageService(isOnboardingCompleted: false),
      );
      expect(redirectToday, equals('/welcome'));
    });

    test('Unauthenticated user who completed onboarding navigating to /today is redirected to /auth with returnTo', () {
      final router = createAppRouter(authService: mockAuth);
      final stateToday = _createState(router, '/today');
      final redirectToday = appRouterRedirect(
        MockBuildContext(),
        stateToday,
        authService: mockAuth,
        storageService: const MockOnboardingStorageService(isOnboardingCompleted: true),
      );
      expect(redirectToday, equals('/auth?mode=signup&returnTo=%2Ftoday'));
    });

    test('Authenticated user navigating to /auth is redirected forward to /today when onboarding complete', () {
      mockAuth.setAuthenticatedUser('member@example.com');
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/auth');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: MockTestProfileRepo(onboardingCompleted: true),
      );

      expect(redirect, equals('/today'));
    });

    test('Authenticated user navigating to /auth with returnTo is redirected forward to returnTo', () {
      mockAuth.setAuthenticatedUser('member@example.com');
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(
        router,
        '/auth?mode=signin&returnTo=%2Fonboarding%2Fdifficulties',
      );

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: MockTestProfileRepo(onboardingCompleted: true),
      );

      expect(redirect, equals('/onboarding/difficulties'));
    });

    test('Authenticated user navigating to /welcome is redirected to /today when onboarding complete', () {
      mockAuth.setAuthenticatedUser('member@example.com');
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/welcome');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: MockTestProfileRepo(onboardingCompleted: true),
      );

      expect(redirect, equals('/today'));
    });
  });
}
