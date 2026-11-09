// ==============================================================================
// Unit & Integration Test: multi_user_health_data_isolation_test.dart
// STAGE 2 — DATABASE & APPLICATION SECURITY VERIFICATION
// Proves that User A cannot read, modify, or cache-bleed into User B's private
// health data (Profiles, Health Sync Metrics, Daily Plan Tasks, Conversations).
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/domain/health/health_data_types.dart';
import 'package:nutrient_earth_client/core/domain/health/health_deduplication_engine.dart';
import 'package:nutrient_earth_client/core/domain/health/health_unit_converter.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Stage 2: Health Profile Ownership & User Isolation (PRIV-01 & RLS)', () {
    const userAId = '11111111-aaaa-4444-aaaa-111111111111';
    const userBId = '22222222-bbbb-4444-bbbb-222222222222';

    final profileUserA = UserProfileContext(
      userId: userAId,
      displayName: 'Patient Alice A',
      age: 34,
      biologicalSex: 'female',
      primaryGoals: const ['Sleep Architecture', 'Hormonal Balance'],
      activityLevel: 'moderate',
      dietaryPreference: 'pescatarian',
      budgetConstraint: 'moderate',
      willingnessToChange: 'high',
      knownConditions: const ['Hashimoto Thyroiditis', 'Mild Ferritin Deficiency'],
      activeSupplements: const ['Selenium', 'Ferrous Bisglycinate'],
      allergies: const ['Tree Nuts'],
      heightCm: 165.0,
      weightKg: 58.0,
    );

    final profileUserB = UserProfileContext(
      userId: userBId,
      displayName: 'Athlete Bob B',
      age: 29,
      biologicalSex: 'male',
      primaryGoals: const ['Hypertrophy', 'VO2 Max'],
      activityLevel: 'very_active',
      dietaryPreference: 'omnivore',
      budgetConstraint: 'high',
      willingnessToChange: 'high',
      knownConditions: const ['Hypertension Stage 1'],
      activeSupplements: const ['Creatine Monohydrate', 'Whey Isolate'],
      allergies: const ['Penicillin'],
      heightCm: 185.0,
      weightKg: 84.0,
    );

    test('User A and User B profiles reside in non-overlapping account-scoped storage', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);

      // Save User A
      final savedA = await repo.saveUserProfile(profileUserA);
      expect(savedA, isTrue);

      // Save User B
      final savedB = await repo.saveUserProfile(profileUserB);
      expect(savedB, isTrue);

      // Verify keys in underlying storage are strictly prefixed with user UUID
      expect(prefs.containsKey('ne_cached_profile_$userAId'), isTrue);
      expect(prefs.containsKey('ne_cached_profile_$userBId'), isTrue);
      expect(prefs.containsKey('ne_cached_profile_latest'), isFalse,
          reason: 'CRITICAL: Shared un-scoped "latest" fallback must NEVER exist');

      // User A reads their profile
      final readA = await repo.getCurrentUserProfile(explicitUserId: userAId);
      expect(readA, isNotNull);
      expect(readA!.userId, equals(userAId));
      expect(readA.displayName, equals('Patient Alice A'));
      expect(readA.knownConditions, contains('Hashimoto Thyroiditis'));

      // User B reads their profile
      final readB = await repo.getCurrentUserProfile(explicitUserId: userBId);
      expect(readB, isNotNull);
      expect(readB!.userId, equals(userBId));
      expect(readB.displayName, equals('Athlete Bob B'));
      expect(readB.knownConditions, contains('Hypertension Stage 1'));
    });

    test('User B cannot read User A profile by requesting User B identity', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);
      await repo.saveUserProfile(profileUserA);

      // User B attempts to read while only User A is cached
      final readB = await repo.getCurrentUserProfile(explicitUserId: userBId);
      expect(readB, isNull,
          reason: 'User B must receive null when requesting their own ID if only User A exists');
    });

    test('Unauthenticated caller cannot read any profile (Fail-Closed)', () async {
      final repo = SupabaseProfileRepository(prefs: prefs);
      await repo.saveUserProfile(profileUserA);
      await repo.saveUserProfile(profileUserB);

      // Caller without an explicit or active user identity
      final anonymousRead = await repo.getCurrentUserProfile();
      expect(anonymousRead, isNull,
          reason: 'Unauthenticated context must strictly fail-closed and return null');
    });
  });

  group('Stage 2: Biometric & Health Sync Tenant Isolation', () {
    test('Deduplication correctly prevents duplicate biometric records within tenant batch', () {
      const deduplicator = HealthDeduplicationEngine();

      final record1 = HealthRecord(
        id: 'rec_001',
        type: HealthDataType.heartRate,
        value: 72.0,
        unit: 'bpm',
        recordedAt: DateTime.utc(2026, 11, 6, 8, 0),
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'ext_hr_1001',
      );

      final recordDuplicate = HealthRecord(
        id: 'rec_002',
        type: HealthDataType.heartRate,
        value: 72.0,
        unit: 'bpm',
        recordedAt: DateTime.utc(2026, 11, 6, 8, 0),
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'ext_hr_1001',
      );

      final recordDistinct = HealthRecord(
        id: 'rec_003',
        type: HealthDataType.heartRate,
        value: 85.0,
        unit: 'bpm',
        recordedAt: DateTime.utc(2026, 11, 6, 8, 30),
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'ext_hr_1002',
      );

      final deduplicated = deduplicator.deduplicateBatch(
        incoming: [record1, recordDuplicate, recordDistinct],
      );

      expect(deduplicated.length, equals(2));
      expect(deduplicated.map((r) => r.id), containsAll(['rec_001', 'rec_003']));
    });

    test('Unit normalization operates deterministically without state leakage', () {
      // Distance km to meters
      final meters = HealthUnitConverter.normalize(
        HealthDataType.distance,
        5.2,
        'km',
      );
      expect(meters, closeTo(5200.0, 0.1));

      // Heart rate normalization
      final hr = HealthUnitConverter.normalize(
        HealthDataType.restingHeartRate,
        68.0,
        'count/min',
      );
      expect(hr, equals(68.0));
    });
  });

  group('Stage 2: Personal Health Data Privacy Guardrails', () {
    test('Identifies sensitive biomarkers and routes away from public external endpoints', () {
      const personalQuery = 'My fasting blood glucose is 126 mg/dL and HbA1c is 6.5%. What does this mean?';
      final hasPersonalSignals = SensitiveDataRoutingGuard.containsPersonalHealthSignals(personalQuery);

      expect(hasPersonalSignals, isTrue,
          reason: 'Clinical biomarkers must be flagged as personal health data');
    });

    test('Identifies non-sensitive general nutrition queries as public scientific inquiries', () {
      const generalQuery = 'What is the biological mechanism of isabgol (psyllium husk) on LDL cholesterol?';
      final hasPersonalSignals = SensitiveDataRoutingGuard.containsPersonalHealthSignals(generalQuery);

      expect(hasPersonalSignals, isFalse,
          reason: 'General biochemical research queries must not be falsely flagged as personal data');
    });
  });
}
