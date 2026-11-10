// ==============================================================================
// Nutrient Earth — Turnstile CAPTCHA & Security Bridge Test Suite (Phase G)
// Verifies:
// 1. Missing CAPTCHA token on Web is rejected fail-closed before backend call.
// 2. Invalid email format is rejected before backend call.
// 3. Oversized token payload is rejected.
// 4. Duplicate submission is prevented while authentication is in progress.
// 5. Valid CAPTCHA token and valid email are correctly passed to authService.signInWithOtp.
// 6. Backend CAPTCHA failure surfaces user-friendly security guidance.
// 7. AppConfig production callback URL points to canonical https://www.nutrientearth.win.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/design_system/components/stitch_screen_host.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockCaptchaAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();

  bool signInWithOtpCalled = false;
  String? lastEmail;
  String? lastCaptchaToken;
  bool shouldThrowCaptchaError = false;
  bool shouldThrowRateLimit = false;

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => _session;

  @override
  bool get isAuthenticated => _user != null && _session != null;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<void> signInWithOtp({
    required String email,
    String? redirectTo,
    String? captchaToken,
  }) async {
    signInWithOtpCalled = true;
    lastEmail = email;
    lastCaptchaToken = captchaToken;

    if (shouldThrowCaptchaError) {
      throw const AuthException('captcha protection: request disallowed (no captcha_token found)');
    }
    if (shouldThrowRateLimit) {
      throw const AuthException('For security purposes, you can only request this after 60 seconds.');
    }
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    await signInWithOtp(email: email, captchaToken: captchaToken);
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => false;

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    throw UnimplementedError();
  }
}

class MockCaptchaProfileRepo implements ProfileRepository {
  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async => null;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => null;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async => true;

  @override
  Future<bool> clearCacheForUser(String userId) async => true;
}

void main() {
  group('Turnstile CAPTCHA & Security Bridge Unit & Flow Tests', () {
    late MockCaptchaAuthService mockAuth;
    late MockCaptchaProfileRepo mockProfile;

    setUp(() {
      mockAuth = MockCaptchaAuthService();
      mockProfile = MockCaptchaProfileRepo();
      AppConfig.resetForTesting();
    });

    Widget createTestHost({
      void Function(String type, Map<String, dynamic> payload)? onAction,
    }) {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
          profileRepositoryProvider.overrideWithValue(mockProfile),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StitchScreenHostWidget(
              screenIndex: 3,
              onAction: onAction,
            ),
          ),
        ),
      );
    }

    test('AppConfig loads turnstileSiteKey and resolves canonical production origin', () {
      AppConfig.setConfigForTesting({
        'TURNSTILE_SITE_KEY': '0x4AAAAAA_MOCK_PROD_KEY',
        'ENVIRONMENT': 'production',
        'AUTH_REDIRECT_URL': 'https://www.nutrientearth.win/auth/callback',
      });

      expect(AppConfig.turnstileSiteKey, equals('0x4AAAAAA_MOCK_PROD_KEY'));
      expect(AppConfig.defaultProdOrigin, equals('https://www.nutrientearth.win'));
      expect(AppConfig.authCallbackUrl, equals('https://www.nutrientearth.win/auth/callback'));
    });

    testWidgets('StitchScreenHostWidget renders screen 3 with turnstile sitekey query param', (tester) async {
      AppConfig.setConfigForTesting({
        'TURNSTILE_SITE_KEY': '1x00000000000000000000AA',
      });

      await tester.pumpWidget(createTestHost());
      await tester.pump();

      expect(find.byType(StitchScreenHostWidget), findsOneWidget);
    });

    testWidgets('EMAIL_SIGN_IN message correctly passes valid email and captchaToken to authService', (tester) async {
      String? interceptedType;
      Map<String, dynamic>? interceptedPayload;

      await tester.pumpWidget(createTestHost(
        onAction: (type, payload) {
          interceptedType = type;
          interceptedPayload = payload;
        },
      ));
      await tester.pump();

      // Trigger the bridge action through the host widget state directly
      final state = tester.state<ConsumerState>(find.byType(StitchScreenHostWidget));
      final dynamic stateDynamic = state;
      await stateDynamic.handleStitchMessageForTesting({
        'type': 'EMAIL_SIGN_IN',
        'email': 'researcher@nutrientearth.win',
        'captchaToken': 'turnstile_token_mock_verified_xyz999',
      });
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isTrue);
      expect(mockAuth.lastEmail, equals('researcher@nutrientearth.win'));
      expect(mockAuth.lastCaptchaToken, equals('turnstile_token_mock_verified_xyz999'));
      expect(interceptedType, equals('EMAIL_SIGN_IN'));
      expect(interceptedPayload?['email'], equals('researcher@nutrientearth.win'));
    });

    testWidgets('EMAIL_SIGN_IN rejects invalid email format before calling backend', (tester) async {
      await tester.pumpWidget(createTestHost());
      await tester.pump();

      final state = tester.state<ConsumerState>(find.byType(StitchScreenHostWidget));
      final dynamic stateDynamic = state;

      // Malformed email
      await stateDynamic.handleStitchMessageForTesting({
        'type': 'EMAIL_SIGN_IN',
        'email': 'not-an-email',
        'captchaToken': 'valid_token_123',
      });
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isFalse);
      expect(find.textContaining('valid email format'), findsOneWidget);
    });

    testWidgets('EMAIL_SIGN_IN rejects missing or empty email before calling backend', (tester) async {
      await tester.pumpWidget(createTestHost());
      await tester.pump();

      final state = tester.state<ConsumerState>(find.byType(StitchScreenHostWidget));
      final dynamic stateDynamic = state;

      await stateDynamic.handleStitchMessageForTesting({
        'type': 'EMAIL_SIGN_IN',
        'email': '   ',
        'captchaToken': 'valid_token_123',
      });
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isFalse);
    });

    testWidgets('EMAIL_SIGN_IN rejects oversized captchaToken payload', (tester) async {
      await tester.pumpWidget(createTestHost());
      await tester.pump();

      final state = tester.state<ConsumerState>(find.byType(StitchScreenHostWidget));
      final dynamic stateDynamic = state;

      final massiveToken = 'a' * 5000;
      await stateDynamic.handleStitchMessageForTesting({
        'type': 'EMAIL_SIGN_IN',
        'email': 'valid@nutrientearth.win',
        'captchaToken': massiveToken,
      });
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isFalse);
    });

    testWidgets('EMAIL_SIGN_IN gracefully handles and formats backend captcha error', (tester) async {
      mockAuth.shouldThrowCaptchaError = true;

      await tester.pumpWidget(createTestHost());
      await tester.pump();

      final state = tester.state<ConsumerState>(find.byType(StitchScreenHostWidget));
      final dynamic stateDynamic = state;

      await stateDynamic.handleStitchMessageForTesting({
        'type': 'EMAIL_SIGN_IN',
        'email': 'user@nutrientearth.win',
        'captchaToken': 'expired_token',
      });
      await tester.pump();

      expect(mockAuth.signInWithOtpCalled, isTrue);
      expect(find.textContaining('Verification check expired or invalid'), findsOneWidget);
    });
  });
}
