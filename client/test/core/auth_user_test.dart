import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/auth/auth_user.dart';

void main() {
  group('AuthUser Model Tests', () {
    test('guest user factory initializes sovereign guest correctly', () {
      final guest = AuthUser.guest();
      expect(guest.isGuest, isTrue);
      expect(guest.displayName, equals('Guest Explorer'));
      expect(guest.id, startsWith('guest_'));
    });

    test('toJson and fromJson preserves user properties', () {
      final user = AuthUser(
        id: 'user_123',
        email: 'researcher@nutrientearth.com',
        displayName: 'Dr. Jane Smith',
        isGuest: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      final restored = AuthUser.fromJson(json);

      expect(restored.id, equals(user.id));
      expect(restored.email, equals(user.email));
      expect(restored.displayName, equals(user.displayName));
      expect(restored.isGuest, equals(user.isGuest));
    });
  });
}
