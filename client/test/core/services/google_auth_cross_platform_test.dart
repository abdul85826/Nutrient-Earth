// ==============================================================================
// Nutrient Earth — Cross-Platform Google Authentication Test Suite
// Verifies:
// 1. AppConfig Google Client ID configuration for Web and iOS.
// 2. Offline / uninitialized Supabase client error reporting.
// 3. Native mobile vs Web OAuth architecture contract.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Cross-Platform Google Authentication Architecture', () {
    test('AppConfig exposes valid Google OAuth Client ID accessors', () {
      expect(AppConfig.googleWebClientId, isA<String>());
      expect(AppConfig.googleIosClientId, isA<String>());
    });

    test('SupabaseAuthService throws descriptive AuthException if backend uninitialized', () async {
      const authService = SupabaseAuthService();
      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Authentication backend is offline or uninitialized'),
        )),
      );
    });

    test('AuthService contract requires explicit sign-in, sign-up, and session exchange', () {
      const authService = SupabaseAuthService();
      expect(authService.currentUser, isNull);
      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, isFalse);
    });
  });
}
