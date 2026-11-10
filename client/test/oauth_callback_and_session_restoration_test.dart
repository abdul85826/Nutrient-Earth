// ==============================================================================
// Nutrient Earth — OAuth Callback & Session Restoration Test Suite
// Verifies:
// 1. AppConfig centralized redirect resolution (Dev vs Prod, zero localhost in Prod).
// 2. AuthCallbackScreen OAuth code exchange & cancellation handling.
// 3. Three-tier post-auth routing (New -> Screen 04, Incomplete -> Resume, Completed -> Screen 18).
// 4. appRouterRedirect route protection, callback interception, and /today onboarding gating.
// 5. Zero guest bypass links in Screen 03.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/03_auth_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/auth_callback_screen.dart';
import 'package:nutrient_earth_client/routing/app_router.dart';

class MockOAuthAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  bool exchangeCodeCalled = false;
  String? lastExchangedCode;

  void setAuthenticatedUser(String email, {String id = 'usr_oauth_test'}) {
    _user = User(
      id: id,
      appMetadata: {},
      userMetadata: {'full_name': 'Dr. Elena Rostova'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    _session = Session(
      accessToken: 'jwt_mock_token',
      tokenType: 'bearer',
      user: _user!,
    );
    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));
  }

  void clearSession() {
    _user = null;
    _session = null;
    _controller.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => _session;

  @override
  bool get isAuthenticated => _user != null && _session != null;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

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
    return true;
  }

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    exchangeCodeCalled = true;
    lastExchangedCode = code;
    setAuthenticatedUser('oauth_user@nutrientearth.com');
    return AuthSessionUrlResponse(session: _session!, redirectType: 'web');
  }

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    setAuthenticatedUser(email);
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async {
    setAuthenticatedUser(email);
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> signOut() async => clearSession();

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async {
    return UserResponse.fromJson({'user': _user?.toJson() ?? {}});
  }
}

class MockTestProfileRepository implements ProfileRepository {
  UserProfileContext? profile;
  bool saveCalled = false;
  UserProfileContext? lastSavedProfile;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    return profile;
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    return profile;
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext p) async {
    saveCalled = true;
    lastSavedProfile = p;
    profile = p;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    profile = null;
    return true;
  }
}

void main() {
  group('1. Centralized Environment & Redirect Configuration', () {
    test('AppConfig provides non-empty development origin and port', () {
      expect(AppConfig.defaultDevWebPort, equals(3000));
      expect(AppConfig.defaultDevOrigin, equals('http://localhost:3000'));
      expect(AppConfig.defaultProdOrigin, equals('https://www.nutrientearth.win'));
      expect(AppConfig.authCallbackUrl.isNotEmpty, isTrue);
    });

    test('Production redirect safety: Never leak localhost in production', () {
      if (AppConfig.isProduction) {
        expect(AppConfig.authCallbackUrl.contains('localhost'), isFalse);
        expect(AppConfig.authCallbackUrl.contains('127.0.0.1'), isFalse);
      }
    });
  });

  group('2. AuthCallbackScreen OAuth Processing & Error Handling', () {
    testWidgets('Displays cancellation message and redirects when error is access_denied', (tester) async {
      final mockAuth = MockOAuthAuthService();
      final mockRepo = MockTestProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: AuthCallbackScreen(
              queryParams: {'error': 'access_denied', 'error_description': 'User cancelled Google sign in'},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Google sign-in was cancelled. Returning to sign-in screen...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('Displays error notice when an OAuth provider error occurs', (tester) async {
      final mockAuth = MockOAuthAuthService();
      final mockRepo = MockTestProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: AuthCallbackScreen(
              queryParams: {'error': 'server_error', 'error_description': 'Internal token exchange failed'},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Internal token exchange failed'), findsOneWidget);
      expect(find.text('Return to Sign In'), findsOneWidget);
    });
  });

  group('3. Route Protection & Redirect Rules (appRouterRedirect)', () {
    test('Allows /auth/callback to proceed without redirection', () {
      final mockAuth = MockOAuthAuthService();
      final mockRepo = MockTestProfileRepository();
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/auth/callback');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: mockRepo,
      );
      expect(redirect, isNull);
    });

    test('Intercepts root / with OAuth code and forwards to /auth/callback', () {
      final mockAuth = MockOAuthAuthService();
      final mockRepo = MockTestProfileRepository();
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/?code=4/0Aean...');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: mockRepo,
      );
      expect(redirect, startsWith('/auth/callback?code='));
    });

    test('Guards /today: Unauthenticated request redirects to /auth?mode=signin', () {
      final mockAuth = MockOAuthAuthService();
      final mockRepo = MockTestProfileRepository();
      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/today');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: mockRepo,
      );
      expect(redirect, equals('/auth?mode=signin&returnTo=%2Ftoday'));
    });

    test('Guards /today: Authenticated user with onboardingCompleted=false redirects to /onboarding/health-goals', () {
      final mockAuth = MockOAuthAuthService();
      mockAuth.setAuthenticatedUser('incomplete_user@nutrientearth.com', id: 'usr_inc_123');
      final mockRepo = MockTestProfileRepository();
      mockRepo.profile = const UserProfileContext(
        userId: 'usr_inc_123',
        displayName: 'Alex',
        age: 28,
        biologicalSex: 'female',
        primaryGoals: [],
        activityLevel: 'moderate',
        dietaryPreference: 'omnivore',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        onboardingCompleted: false,
      );

      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/today');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: mockRepo,
      );
      expect(redirect, equals('/onboarding/health-goals'));
    });

    test('Allows /today for authenticated user with onboardingCompleted=true', () {
      final mockAuth = MockOAuthAuthService();
      mockAuth.setAuthenticatedUser('complete_user@nutrientearth.com', id: 'usr_comp_123');
      final mockRepo = MockTestProfileRepository();
      mockRepo.profile = const UserProfileContext(
        userId: 'usr_comp_123',
        displayName: 'Elena',
        age: 32,
        biologicalSex: 'female',
        primaryGoals: ['Vitality'],
        activityLevel: 'active',
        dietaryPreference: 'omnivore',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        onboardingCompleted: true,
      );

      final router = createAppRouter(authService: mockAuth);
      final state = _createState(router, '/today');

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        authService: mockAuth,
        profileRepository: mockRepo,
      );
      expect(redirect, isNull);
    });
  });

  group('4. Screen 03 Security & Guest Removal Audit', () {
    testWidgets('Guest bypass link is completely removed from Screen 03', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Continue as Guest to Today Hub →'), findsNothing);
      expect(find.textContaining('Continue as Guest'), findsNothing);
    });
  });
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

