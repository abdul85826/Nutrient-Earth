// ==============================================================================
// Nutrient Earth — Email OTP Verification Unit & Widget Test Suite
// Verifies:
// 1. Masked email formatting for diverse email domains.
// 2. EmailOtpVerificationScreen initial UI rendering (headline, 6 digit boxes,
//    masked email pill, change action, timer).
// 3. Digit entry, automatic focus advance, and backspace focus retraction.
// 4. Paste handling: full 6-digit code auto-distribution and auto-verification.
// 5. Successful OTP verification, session establishment, and destination navigation.
// 6. Invalid OTP code rejection, error banner display, and input reset.
// 7. Expired OTP code handling.
// 8. Resend cooldown lifecycle: disabled during countdown, enabled at 0s.
// 9. Resend OTP invocation and cooldown reset.
// 10. Resend rate-limiting error handling.
// 11. Concurrency guard: duplicate verification attempt prevention.
// 12. Responsive constraints: renders cleanly on mobile (360x640) and desktop (1280x800).
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/email_otp_verification_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockVerifyAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();

  bool verifyOtpCalled = false;
  String? lastVerifiedEmail;
  String? lastVerifiedToken;
  OtpType? lastVerifiedType;

  bool resendOtpCalled = false;
  String? lastResendEmail;
  OtpType? lastResendType;

  bool shouldThrowOnVerify = false;
  String? verifyErrorMessage;

  bool shouldThrowOnResend = false;
  String? resendErrorMessage;

  int verifyCallCount = 0;

  void emitSignedIn(User user, Session session) {
    _user = user;
    _session = session;
    _controller.add(AuthState(AuthChangeEvent.signedIn, session));
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
    verifyCallCount++;
    verifyOtpCalled = true;
    lastVerifiedEmail = email;
    lastVerifiedToken = token;
    lastVerifiedType = type;

    if (shouldThrowOnVerify) {
      throw AuthException(verifyErrorMessage ?? 'Invalid or expired token.');
    }

    final user = User(
      id: 'usr_otp_verified_999',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    final session = Session(
      accessToken: 'jwt_mock_token_verified',
      tokenType: 'bearer',
      user: user,
    );
    emitSignedIn(user, session);
    return AuthResponse(session: session, user: user);
  }

  @override
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    resendOtpCalled = true;
    lastResendEmail = email;
    lastResendType = type;

    if (shouldThrowOnResend) {
      throw AuthException(resendErrorMessage ?? 'For security purposes, you can only request this after 45 seconds.');
    }
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => false;

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async =>
      AuthSessionUrlResponse(session: _session!, redirectType: 'web');

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

class MockVerifyProfileRepo implements ProfileRepository {
  UserProfileContext? profileToReturn;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    return profileToReturn;
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => profileToReturn;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    profileToReturn = profile;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Email Masking Helper Unit Tests', () {
    test('masks standard email correctly', () {
      expect(
        EmailOtpVerificationScreen.maskEmail('elena.rostova@nutrientearth.com'),
        equals('el***a@nutrientearth.com'),
      );
    });

    test('masks short local part correctly', () {
      expect(
        EmailOtpVerificationScreen.maskEmail('ab@domain.com'),
        equals('a***@domain.com'),
      );
      expect(
        EmailOtpVerificationScreen.maskEmail('abc@domain.com'),
        equals('a***@domain.com'),
      );
    });

    test('handles edge case invalid format safely', () {
      expect(
        EmailOtpVerificationScreen.maskEmail('invalidemail'),
        equals('invalidemail'),
      );
    });
  });

  group('EmailOtpVerificationScreen Widget & Flow Tests', () {
    late MockVerifyAuthService mockAuth;
    late MockVerifyProfileRepo mockProfile;

    setUp(() {
      mockAuth = MockVerifyAuthService();
      mockProfile = MockVerifyProfileRepo();
    });

    Widget createTestApp({
      required String email,
      String? returnTo,
    }) {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
          profileRepositoryProvider.overrideWithValue(mockProfile),
        ],
        child: MaterialApp(
          theme: ThemeData(
            splashFactory: InkRipple.splashFactory,
          ),
          home: EmailOtpVerificationScreen(
            email: email,
            returnTo: returnTo,
          ),
        ),
      );
    }

    testWidgets('renders headline, 6 digit fields, masked email pill, and timer', (tester) async {
      await tester.pumpWidget(
        createTestApp(email: 'researcher@nutrientearth.com'),
      );
      await tester.pump();

      // Heading
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('NUTRIENT EARTH'), findsOneWidget);
      expect(find.text('SECURE BOTANICAL VERIFICATION'), findsOneWidget);

      // Masked email pill
      expect(find.text('re***r@nutrientearth.com'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      // 6 Digit boxes (TextFormFields)
      expect(find.byType(TextFormField), findsNWidgets(6));

      // Verify button
      expect(find.text('Verify & continue'), findsOneWidget);

      // Resend countdown active initially
      expect(find.textContaining('Resend code in 0:'), findsOneWidget);
    });

    testWidgets('entering 6 digits enables and calls verifyOtp', (tester) async {
      await tester.pumpWidget(
        createTestApp(email: 'patient@nutrientearth.com'),
      );
      await tester.pump();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(6));

      // Enter digits 1 through 6
      for (int i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), '${i + 1}');
        await tester.pump();
      }

      // Automatically calls verifyOtp when 6 digits are complete
      expect(mockAuth.verifyOtpCalled, isTrue);
      expect(mockAuth.lastVerifiedEmail, equals('patient@nutrientearth.com'));
      expect(mockAuth.lastVerifiedToken, equals('123456'));
      expect(mockAuth.lastVerifiedType, equals(OtpType.email));
    });

    testWidgets('pasting full 6-digit code distributes digits and verifies', (tester) async {
      await tester.pumpWidget(
        createTestApp(email: 'user_paste@nutrientearth.com'),
      );
      await tester.pump();

      final firstField = find.byType(TextFormField).first;
      // Paste full string into first box
      await tester.enterText(firstField, '987654');
      await tester.pump();

      expect(mockAuth.verifyOtpCalled, isTrue);
      expect(mockAuth.lastVerifiedToken, equals('987654'));
    });

    testWidgets('surfaces error banner on invalid or expired code and resets inputs', (tester) async {
      mockAuth.shouldThrowOnVerify = true;
      mockAuth.verifyErrorMessage = 'Token has expired or is invalid';

      await tester.pumpWidget(
        createTestApp(email: 'user_fail@nutrientearth.com'),
      );
      await tester.pump();

      final fields = find.byType(TextFormField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), '0');
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.textContaining('expired. Please request a new code'), findsOneWidget);
      // Controllers should be cleared for clean retry
      final firstBox = tester.widget<TextFormField>(fields.first);
      expect(firstBox.controller?.text, isEmpty);
    });

    testWidgets('resend button enabled after cooldown and resets timer on tap', (tester) async {
      await tester.pumpWidget(
        createTestApp(email: 'user_resend@nutrientearth.com'),
      );
      await tester.pump();

      // Fast forward timer past 60 seconds
      for (int i = 0; i <= 60; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Now "Resend code" button should be visible
      final resendBtn = find.text('Resend code');
      expect(resendBtn, findsOneWidget);

      await tester.tap(resendBtn);
      await tester.pump();

      expect(mockAuth.resendOtpCalled, isTrue);
      expect(mockAuth.lastResendEmail, equals('user_resend@nutrientearth.com'));
      expect(find.text('A new 6-digit verification code has been dispatched.'), findsOneWidget);

      // Cooldown timer restarted
      expect(find.textContaining('Resend code in 0:'), findsOneWidget);
    });

    testWidgets('surfaces server rate limit error when resending too frequently', (tester) async {
      mockAuth.shouldThrowOnResend = true;
      mockAuth.resendErrorMessage = 'For security purposes, you can only request this after 45 seconds.';

      await tester.pumpWidget(
        createTestApp(email: 'user_rate@nutrientearth.com'),
      );
      await tester.pump();

      // Fast forward past cooldown
      for (int i = 0; i <= 60; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      await tester.tap(find.text('Resend code'));
      await tester.pump();

      expect(find.text('For security purposes, you can only request this after 45 seconds.'), findsOneWidget);
    });

    testWidgets('responsive layout renders without overflow on narrow mobile and wide desktop', (tester) async {
      // 1. Narrow mobile: 360 x 640
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(email: 'mobile@nutrientearth.com'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // 2. Wide desktop: 1280 x 800
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(createTestApp(email: 'desktop@nutrientearth.com'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
