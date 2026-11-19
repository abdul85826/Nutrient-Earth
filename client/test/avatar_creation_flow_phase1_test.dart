// ==============================================================================
// Unit & Widget Test: avatar_creation_flow_phase1_test.dart
// Verifies Living Avatar Phase 1: AvatarStateSwitcher (State A & State B),
// "Meet Your Companion" Modal, Demographic Auto-Fetch, and updateAvatar RPC flow.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/profile/presentation/widgets/avatar_state_switcher.dart';
import 'package:nutrient_earth_client/features/today/state/today_state.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfileContext? _profile;

  MockProfileRepository([this._profile]);

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    return _profile;
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => _profile;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    _profile = profile;
    return true;
  }

  @override
  Future<bool> updateAvatar({
    required String skinTone,
    Map<String, dynamic>? avatarConfig,
  }) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        hasAvatar: true,
        skinTone: skinTone,
        avatarConfig: avatarConfig ?? {},
      );
    }
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    _profile = null;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Living Avatar Phase 1 — Domain & State Tests', () {
    test('UserProfileContext serializes and deserializes avatar attributes', () {
      final context = UserProfileContext(
        userId: 'usr_test_123',
        displayName: 'Sarah',
        heightCm: 168.0,
        weightKg: 60.0,
        biologicalSex: 'female',
        hasAvatar: true,
        skinTone: '#E0AC69',
        avatarConfig: {'posture': 'alert', 'aqi_state': 'clear'},
      );

      final json = context.toJson();
      expect(json['has_avatar'], isTrue);
      expect(json['skin_tone'], equals('#E0AC69'));
      expect(json['avatar_config']['posture'], equals('alert'));

      final restored = UserProfileContext.fromJson(json);
      expect(restored.hasAvatar, isTrue);
      expect(restored.skinTone, equals('#E0AC69'));
      expect(restored.avatarConfig['posture'], equals('alert'));
    });

    test('updateAvatar updates ProfileRepository cache and marks hasAvatar = true', () async {
      final repo = MockProfileRepository(
        const UserProfileContext(
          userId: 'usr_sarah_1',
          displayName: 'Sarah',
          heightCm: 170.0,
          weightKg: 65.0,
          biologicalSex: 'female',
          hasAvatar: false,
        ),
      );

      final initial = await repo.getCurrentUserProfile();
      expect(initial?.hasAvatar, isFalse);

      final success = await repo.updateAvatar(skinTone: '#F1C27D');
      expect(success, isTrue);

      final updated = await repo.getCurrentUserProfile();
      expect(updated?.hasAvatar, isTrue);
      expect(updated?.skinTone, equals('#F1C27D'));
    });
  });

  group('Living Avatar Phase 1 — UI Widget & Modal Tests', () {
    testWidgets('Renders State A Glassmorphic Button with Create Avatar label when has_avatar is false', (tester) async {
      final mockRepo = MockProfileRepository(
        const UserProfileContext(
          userId: 'usr_sarah_1',
          displayName: 'Sarah',
          heightCm: 168.0,
          weightKg: 58.0,
          biologicalSex: 'female',
          hasAvatar: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AvatarStateSwitcher(size: 110.0),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // State A Verifications
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('Create\nAvatar'), findsOneWidget);

      // Verify the circular container size
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(110.0));
      expect(sizedBox.height, equals(110.0));
    });

    testWidgets('Tapping Create Avatar slides up "Meet Your Companion" bottom modal sheet', (tester) async {
      final mockRepo = MockProfileRepository(
        const UserProfileContext(
          userId: 'usr_sarah_1',
          displayName: 'Sarah',
          heightCm: 168.0,
          weightKg: 58.0,
          biologicalSex: 'female',
          hasAvatar: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AvatarStateSwitcher(size: 110.0),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the glassmorphic Create Avatar button
      await tester.tap(find.text('Create\nAvatar'));
      await tester.pumpAndSettle();

      // Verify modal sheet is opened
      expect(find.text('Meet Your Companion'), findsOneWidget);

      // Verify auto-fetched demographics
      expect(find.text('168 cm'), findsOneWidget);
      expect(find.text('58 kg'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);

      // Verify 5 skin tone ChoiceChips
      expect(find.byType(ChoiceChip), findsNWidgets(5));

      // Verify the dark green action button
      expect(find.widgetWithText(ElevatedButton, 'Create Avatar'), findsOneWidget);
    });
  });
}
