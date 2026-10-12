import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/auth/auth_service.dart';
import 'package:nutrient_earth/core/auth/auth_state.dart';
import 'package:nutrient_earth/core/auth/auth_user.dart';
import 'package:nutrient_earth/routing/app_router.dart';

class MockUnauthenticatedAuthService extends AuthService {
  MockUnauthenticatedAuthService() : super(supabaseClient: null) {
    state = const Unauthenticated();
  }
}

class MockAuthenticatedAuthService extends AuthService {
  MockAuthenticatedAuthService() : super(supabaseClient: null) {
    state = Authenticated(
      AuthUser(
        id: 'usr_verified_123',
        email: 'user@nutrientearth.com',
        displayName: 'Verified Explorer',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

void main() {
  group('AppRouter Navigation Guards & Session Restoration Tests', () {
    testWidgets(
      'Unauthenticated user is redirected to /login when attempting to access /ask',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWith(
              (ref) => MockUnauthenticatedAuthService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(routerProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          router.routeInformationProvider.value.uri.path,
          equals('/login'),
        );
      },
    );

    testWidgets('Authenticated user is routed to /ask', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith(
            (ref) => MockAuthenticatedAuthService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, equals('/ask'));
    });
  });
}
