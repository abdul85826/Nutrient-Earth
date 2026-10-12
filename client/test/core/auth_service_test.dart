import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/auth/auth_service.dart';
import 'package:nutrient_earth/core/auth/auth_state.dart';

void main() {
  group('AuthService Tests', () {
    test('resolveRedirectUri constructs valid web URL with trailing slash', () {
      final webUri = AuthService.resolveRedirectUri(
        isWeb: true,
        origin: 'http://localhost:5656',
      );
      expect(webUri, equals('http://localhost:5656/'));

      final trailingUri = AuthService.resolveRedirectUri(
        isWeb: true,
        origin: 'https://nutrientearth.com/',
      );
      expect(trailingUri, equals('https://nutrientearth.com/'));
    });

    test(
      'resolveRedirectUri preserves native custom scheme for iOS and Android',
      () {
        final nativeUri = AuthService.resolveRedirectUri(isWeb: false);
        expect(nativeUri, equals('com.nutrientearth.app://login-callback'));
      },
    );

    test('guest sign in updates state to Authenticated with guest user', () {
      final authService = AuthService();
      addTearDown(authService.dispose);

      authService.signInAsGuest();

      expect(authService.state, isA<Authenticated>());
      final user = (authService.state as Authenticated).user;
      expect(user.isGuest, isTrue);
      expect(user.displayName, equals('Guest Explorer'));
    });

    test('signOut resets guest session to Unauthenticated', () async {
      final authService = AuthService();
      addTearDown(authService.dispose);

      authService.signInAsGuest();
      expect(authService.state, isA<Authenticated>());

      await authService.signOut();
      expect(authService.state, isA<Unauthenticated>());
    });
  });
}
