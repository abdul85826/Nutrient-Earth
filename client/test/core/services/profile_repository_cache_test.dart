// ==============================================================================
// Unit & Regression Test: profile_repository_cache_test.dart
// Verifies account-scoped local cache isolation and zero cross-account leakage.
// ==============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('ProfileRepository Account-Scoped Cache Isolation (PRIV-01 Remediation)', () {
    final profileUserA = UserProfileContext(
      userId: 'usr_user_a_111',
      displayName: 'Alice User A',
      age: 32,
      biologicalSex: 'female',
      primaryGoals: const ['Sleep Optimization', 'Gut Health'],
      activityLevel: 'moderate',
      dietaryPreference: 'mediterranean',
      budgetConstraint: 'moderate',
      willingnessToChange: 'high',
      knownConditions: const ['Difficulty: Falling Asleep'],
      activeSupplements: const ['Magnesium Bisglycinate'],
      allergies: const ['Peanuts'],
      heightCm: 168.0,
      weightKg: 62.0,
      eatingRoutine: 'regular',
      sleepQuality: 'fair_variable',
      knowledgeLevel: 'intermediate',
    );

    final profileUserB = UserProfileContext(
      userId: 'usr_user_b_222',
      displayName: 'Bob User B',
      age: 45,
      biologicalSex: 'male',
      primaryGoals: const ['Cardiovascular Health', 'Endurance'],
      activityLevel: 'very_active',
      dietaryPreference: 'vegan',
      budgetConstraint: 'high',
      willingnessToChange: 'high',
      knownConditions: const ['Hypertension'],
      activeSupplements: const ['CoQ10', 'Omega-3'],
      allergies: const ['Shellfish'],
      heightCm: 182.0,
      weightKg: 78.0,
      eatingRoutine: 'intermittent_fasting',
      sleepQuality: 'good_consistent',
      knowledgeLevel: 'advanced',
    );

    test('Full 7-Step Lifecycle: User A -> Sign Out -> User B -> Sign Out -> User A', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      // Step 1: User A saves a profile
      final saveSuccess = await repo.saveUserProfile(profileUserA);
      expect(saveSuccess, isTrue, reason: 'User A profile must save to local cache');

      // Verify that the profile was cached under User A key and NOT under legacy 'latest'
      expect(prefs.containsKey('ne_cached_profile_usr_user_a_111'), isTrue);
      expect(prefs.containsKey('ne_cached_profile_latest'), isFalse,
          reason: 'Legacy shared latest key must NEVER be written');

      // User A reads their own profile
      final readUserA = await repo.getCurrentUserProfile(explicitUserId: 'usr_user_a_111');
      expect(readUserA, isNotNull);
      expect(readUserA!.userId, equals('usr_user_a_111'));
      expect(readUserA.displayName, equals('Alice User A'));
      expect(readUserA.primaryGoals, contains('Sleep Optimization'));

      // Step 2: User A signs out (no authenticated user context)
      final readSignedOut = await repo.getCurrentUserProfile();
      expect(readSignedOut, isNull,
          reason: 'Unauthenticated/signed-out caller must FAIL CLOSED and receive null');

      // Step 3: User B signs in (active user context is user_b)
      // Step 4: User B must NEVER receive User A profile
      final readUserBBeforeSave = await repo.getCurrentUserProfile(explicitUserId: 'usr_user_b_222');
      expect(readUserBBeforeSave, isNull,
          reason: 'User B must receive null before saving own profile; must NEVER see User A data');

      // User B saves their own profile
      final saveBSuccess = await repo.saveUserProfile(profileUserB);
      expect(saveBSuccess, isTrue);
      expect(prefs.containsKey('ne_cached_profile_usr_user_b_222'), isTrue);
      expect(prefs.containsKey('ne_cached_profile_latest'), isFalse);

      final readUserBAfterSave = await repo.getCurrentUserProfile(explicitUserId: 'usr_user_b_222');
      expect(readUserBAfterSave, isNotNull);
      expect(readUserBAfterSave!.userId, equals('usr_user_b_222'));
      expect(readUserBAfterSave.displayName, equals('Bob User B'));
      expect(readUserBAfterSave.dietaryPreference, equals('vegan'));

      // Step 5: User B signs out
      final readSignedOut2 = await repo.getCurrentUserProfile();
      expect(readSignedOut2, isNull);

      // Step 6: User A signs in again
      // Step 7: User A receives ONLY their own permitted cached profile
      final readUserARestored = await repo.getCurrentUserProfile(explicitUserId: 'usr_user_a_111');
      expect(readUserARestored, isNotNull);
      expect(readUserARestored!.userId, equals('usr_user_a_111'));
      expect(readUserARestored.displayName, equals('Alice User A'));
      expect(readUserARestored.dietaryPreference, equals('mediterranean'));
      expect(readUserARestored.primaryGoals, contains('Gut Health'));
      expect(readUserARestored.primaryGoals, isNot(contains('Cardiovascular Health')));
    });

    test('Corrupt or malformed JSON in cache fails closed (returns null)', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      // Seed corrupt data
      await prefs.setString('ne_cached_profile_usr_corrupt', '{this is not valid json');

      final result = await repo.getCurrentUserProfile(explicitUserId: 'usr_corrupt');
      expect(result, isNull, reason: 'Malformed JSON must fail closed safely');
    });

    test('Cache entry with mismatched user_id fails closed and invalidates entry', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      // Seed spoofed data: Key belongs to victim, but payload claims attacker ID
      final spoofedMap = profileUserA.toJson();
      spoofedMap['user_id'] = 'usr_attacker_999';
      await prefs.setString('ne_cached_profile_usr_victim', jsonEncode(spoofedMap));

      final result = await repo.getCurrentUserProfile(explicitUserId: 'usr_victim');
      expect(result, isNull, reason: 'User ID mismatch must be rejected');

      // Verify that the corrupt entry was removed
      expect(prefs.containsKey('ne_cached_profile_usr_victim'), isFalse,
          reason: 'Mismatched cache key must be invalidated and purged');
    });

    test('Legacy shared latest key is purged on read and write', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      // Seed legacy key from older versions
      await prefs.setString('ne_cached_profile_latest', jsonEncode(profileUserA.toJson()));
      expect(prefs.containsKey('ne_cached_profile_latest'), isTrue);

      // Reading a user profile must purge the legacy key
      await repo.getCurrentUserProfile(explicitUserId: 'usr_random');
      expect(prefs.containsKey('ne_cached_profile_latest'), isFalse,
          reason: 'Legacy key must be purged during read');

      // Seed again
      await prefs.setString('ne_cached_profile_latest', jsonEncode(profileUserA.toJson()));
      expect(prefs.containsKey('ne_cached_profile_latest'), isTrue);

      // Saving must also purge the legacy key
      await repo.saveUserProfile(profileUserB);
      expect(prefs.containsKey('ne_cached_profile_latest'), isFalse,
          reason: 'Legacy key must be purged during save');
    });

    test('clearCacheForUser safely removes only the targeted user cache', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      await repo.saveUserProfile(profileUserA);
      await repo.saveUserProfile(profileUserB);

      expect(prefs.containsKey('ne_cached_profile_usr_user_a_111'), isTrue);
      expect(prefs.containsKey('ne_cached_profile_usr_user_b_222'), isTrue);

      // Clear User A
      final cleared = await repo.clearCacheForUser('usr_user_a_111');
      expect(cleared, isTrue);

      expect(prefs.containsKey('ne_cached_profile_usr_user_a_111'), isFalse);
      expect(prefs.containsKey('ne_cached_profile_usr_user_b_222'), isTrue,
          reason: 'User B cache must remain untouched');
    });
  });
}

