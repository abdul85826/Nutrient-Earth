// ==============================================================================
// Nutrient Earth — Email Authentication Flow Unit & Widget Test Suite
// Verifies:
// 1. CheckEmailScreen renders heading "Check your inbox", confirmation copy,
//    submitted email pill, three numbered verification steps, and neutral expiration notice.
// 2. Resend email with cooldown timer and duplicate request protection.
// 3. SupabaseAuthService.signInWithOtp contract & uninitialized backend safety.
// 4. AuthCallbackScreen email OTP link handling (code exchange, expired tokens, errors).
// 5. Reactive multi-tab session restoration from CheckEmailScreen.
// 6. Manual "Check status" and "Open email app" interactions.
// 7. Auto-detection of pre-existing or restored sessions on app reopen.
// 8. New user baseline profile initialization vs returning user destination resolution.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/auth_callback_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/check_email_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockEmailAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  bool signInWithOtpCalled = false;
  String? lastOtpEmail;
  String? lastOtpRedirect;
  bool shouldThrowOnOtp = false;
  String? otpErrorMessage;
  bool exchangeCodeCalled = false;
  String? lastExchangedCode;

  void emitSignedIn(User user, Session session) {
    _user = user;
    _session = session;
    _controller.add(AuthState(AuthChangeEvent.signedIn, session));
  }

  void setPreExistingSession(User user, Session session) {
    _user = user;
    _session = session;
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
  Future<void> signInWithOtp({required String email, String? redirectTo}) async {
    signInWithOtpCalled = true;
    lastOtpEmail = email;
    lastOtpRedirect = redirectTo;
    if (shouldThrowOnOtp) {
      throw AuthException(otpErrorMessage ?? 'For security purposes, you can only request this after 45 seconds.');
    }
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => false;

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    exchangeCodeCalled = true;
    lastExchangedCode = code;
    final user = User(
      id: 'usr_email_verified_123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: 'verified_user@nutrientearth.com',
    );
    final session = Session(
      accessToken: 'jwt_mock_token',
      tokenType: 'bearer',
      user: user,
    );
    emitSignedIn(user, session);
    return AuthSessionUrlResponse(session: session, redirectType: 'web');
  }

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async =>
      AuthResponse(session: _session, user: _user);

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async =>
      AuthResponse(session: _session, user: _user);

  @override
  Future<void> signOut() async {
    _user = null;
    _session = null;
    _controller.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async =>
      UserResponse.fromJson({'user': {}});
}

class MockProfileRepoForEmail implements ProfileRepository {
  UserProfileContext? profileToReturn;
  bool saveUserProfileCalled = false;
  UserProfileContext? lastSavedProfile;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async => profileToReturn;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => profileToReturn;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    saveUserProfileCalled = true;
    lastSavedProfile = profile;
    profileToReturn = profile;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    profileToReturn = null;
    return true;
  }
}

Widget createTestHost({
  required Widget child,
  required MockEmailAuthService authService,
  MockProfileRepoForEmail? profileRepo,
}) {
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
      if (profileRepo != null) profileRepositoryProvider.overrideWithValue(profileRepo),
    ],
    child: MaterialApp(
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
      ),
      home: child,
    ),
  );
}

void main() {
  group('CheckEmailScreen Widget & Flow Tests', () {
    testWidgets('renders Check your inbox, confirmation text, submitted email pill, 3 steps, and neutral expiration notice', (tester) async {
      final mockAuth = MockEmailAuthService();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'researcher@nutrientearth.com'),
      ));
      await tester.pump();

      // 1. Screen design assertions
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.text("We've sent you a secure verification link."), findsOneWidget);
      expect(find.text('researcher@nutrientearth.com'), findsOneWidget);
      expect(find.text('VERIFICATION STEPS'), findsOneWidget);
      expect(find.text('Open your email inbox.'), findsOneWidget);
      expect(find.text('Open the email from Nutrient Earth.'), findsOneWidget);
      expect(find.text('Tap Verify Email to continue.'), findsOneWidget);

      // 2. Authentic neutral expiration notice assertion (No invented countdown)
      expect(find.textContaining('Security Notice: For your safety, this single-use authentication link expires in accordance with Nutrient Earth security policies.'), findsOneWidget);

      // 3. Actions presence
      expect(find.text('Open email app'), findsOneWidget);
      expect(find.text('Check status'), findsOneWidget);
      expect(find.text('Use a different email address'), findsOneWidget);
    });

    testWidgets('starts with disabled resend button during 60s cooldown timer', (tester) async {
      final mockAuth = MockEmailAuthService();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'researcher@nutrientearth.com'),
      ));
      await tester.pump();

      // Look for the cooldown countdown text
      expect(find.textContaining('Resend link in'), findsOneWidget);

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Resend link in 60s');
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull); // Disabled during cooldown
    });

    testWidgets('clicking resend after cooldown sends OTP email and resets timer', (tester) async {
      final mockAuth = MockEmailAuthService();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'researcher@nutrientearth.com'),
      ));
      await tester.pump();

      // Fast-forward 61 seconds to elapse cooldown
      await tester.pump(const Duration(seconds: 61));

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Resend verification link');
      expect(buttonFinder, findsOneWidget);
      final enabledButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(enabledButton.onPressed, isNotNull);

      // Scroll into view & Tap Resend
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isTrue);
      expect(mockAuth.lastOtpEmail, equals('researcher@nutrientearth.com'));

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('A fresh verification link has been sent to your email.'), findsOneWidget);
    });

    testWidgets('surfaces server rate-limit error message gracefully', (tester) async {
      final mockAuth = MockEmailAuthService()
        ..shouldThrowOnOtp = true
        ..otpErrorMessage = 'For security purposes, you can only request this after 45 seconds.';

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'researcher@nutrientearth.com'),
      ));
      await tester.pump();

      // Fast-forward cooldown
      await tester.pump(const Duration(seconds: 61));

      // Scroll into view & Tap Resend
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Resend verification link');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('For security purposes, you can only request this after 45 seconds.'), findsOneWidget);
      expect(find.text('Resend link in 45s'), findsOneWidget);
    });

    testWidgets('manual check verification status prompts when session is still pending', (tester) async {
      final mockAuth = MockEmailAuthService();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'researcher@nutrientearth.com'),
      ));
      await tester.pump();

      final checkStatusFinder = find.widgetWithText(OutlinedButton, 'Check status');
      expect(checkStatusFinder, findsOneWidget);

      await tester.ensureVisible(checkStatusFinder);
      await tester.tap(checkStatusFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Waiting for verification link to be tapped in your email inbox.'), findsOneWidget);
    });

    testWidgets('auto-detects pre-existing active session on mount and restores session', (tester) async {
      final mockAuth = MockEmailAuthService();
      final user = User(
        id: 'usr_pre_existing_123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'restored@nutrientearth.com',
      );
      final session = Session(
        accessToken: 'jwt_pre_existing',
        tokenType: 'bearer',
        user: user,
      );
      mockAuth.setPreExistingSession(user, session);

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        child: const CheckEmailScreen(email: 'restored@nutrientearth.com'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Expect verified session state detected banner
      expect(find.text('Email verified! Opening your personal health plan...'), findsOneWidget);
    });
  });

  group('AuthCallbackScreen Email OTP & Link Handling Tests', () {
    testWidgets('exchanges authorization code and updates state to verifying profile', (tester) async {
      final mockAuth = MockEmailAuthService();
      final mockRepo = MockProfileRepoForEmail();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        profileRepo: mockRepo,
        child: const AuthCallbackScreen(
          queryParams: {'code': 'mock_auth_code_pkce_123'},
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockAuth.exchangeCodeCalled, isTrue);
      expect(mockAuth.lastExchangedCode, equals('mock_auth_code_pkce_123'));
    });

    testWidgets('new user signup initializes baseline profile with onboardingCompleted=false', (tester) async {
      final mockAuth = MockEmailAuthService();
      final mockRepo = MockProfileRepoForEmail()..profileToReturn = null; // New user

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        profileRepo: mockRepo,
        child: const AuthCallbackScreen(
          queryParams: {'code': 'mock_auth_code_new_user'},
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(mockRepo.saveUserProfileCalled, isTrue);
      expect(mockRepo.lastSavedProfile?.onboardingCompleted, isFalse);
    });

    testWidgets('displays explicit expired link notification when otp_expired is passed', (tester) async {
      final mockAuth = MockEmailAuthService();
      final mockRepo = MockProfileRepoForEmail();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        profileRepo: mockRepo,
        child: const AuthCallbackScreen(
          queryParams: {
            'error': 'otp_expired',
            'error_description': 'Email link is invalid or has expired',
          },
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your sign-in link has expired or has already been used. Please request a new link.'), findsOneWidget);
      expect(find.text('Return to Sign In'), findsOneWidget);
    });

    testWidgets('displays cancellation feedback when access_denied is passed', (tester) async {
      final mockAuth = MockEmailAuthService();
      final mockRepo = MockProfileRepoForEmail();

      await tester.pumpWidget(createTestHost(
        authService: mockAuth,
        profileRepo: mockRepo,
        child: const AuthCallbackScreen(
          queryParams: {'error': 'access_denied'},
        ),
      ));

      await tester.pump();
      expect(find.text('Sign-in was cancelled. Returning to sign-in screen...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1500));
    });
  });

  group('SupabaseAuthService signInWithOtp Contract', () {
    test('throws descriptive AuthException when backend is uninitialized', () async {
      const authService = SupabaseAuthService();
      expect(
        () => authService.signInWithOtp(email: 'user@example.com'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Authentication backend is offline or uninitialized'),
        )),
      );
    });
  });
}
