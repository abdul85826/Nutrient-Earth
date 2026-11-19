// ==============================================================================
// Nutrient Earth — 10-Year Bitemporal Personal Memory Engine Tests
// Verifies:
// 1. Dual temporal dimensions: valid time vs. transaction/system time
// 2. Non-destructive versioning and supersession
// 3. As-of and as-was Point-in-Time queries
// 4. Memory context prompt synthesis for LLM personal intelligence
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/memory/bitemporal_memory_models.dart';
import 'package:nutrient_earth_client/core/services/memory/bitemporal_memory_service.dart';

void main() {
  group('Bitemporal Memory Engine Tests', () {
    late SupabaseBitemporalMemoryService memoryService;
    const testUserId = 'usr_test_10yr_bitemporal';

    setUp(() {
      // Initialize service with local storage (no external Supabase network needed)
      memoryService = SupabaseBitemporalMemoryService(supabase: null);
    });

    test('Records a new bitemporal fact with initial version', () async {
      final validFrom = DateTime.utc(2024, 1, 1);

      final fact = await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.routine,
        factKey: 'exercise.primary_cadence',
        title: 'Morning Running',
        factValue: {'value': 'running', 'time_of_day': '06:30', 'frequency_per_week': 4},
        validFrom: validFrom,
        provenance: FactProvenance.userExplicit,
        changeReason: 'Initial routine setup during 2024 onboarding',
      );

      expect(fact.id, isNotEmpty);
      expect(fact.userId, equals(testUserId));
      expect(fact.category, equals(FactCategory.routine));
      expect(fact.factKey, equals('exercise.primary_cadence'));
      expect(fact.currentValue['value'], equals('running'));

      final activeFacts = await memoryService.getCurrentActiveFacts(userId: testUserId);
      expect(activeFacts.length, equals(1));
      expect(activeFacts.first.title, equals('Morning Running'));

      final history = await memoryService.getFactHistory(
        userId: testUserId,
        factKey: 'exercise.primary_cadence',
      );
      expect(history.length, equals(1));
      expect(history.first.versionNumber, equals(1));
      expect(history.first.supersededAt, isNull);
      expect(history.first.isCurrentlyActive, isTrue);
    });

    test('Updating a fact non-destructively supersedes prior version and preserves history', () async {
      // 1. Initial belief recorded in 2024: runs in the morning
      final t2024 = DateTime.utc(2024, 1, 1);
      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.routine,
        factKey: 'exercise.primary_cadence',
        title: 'Morning Running',
        factValue: {'value': 'running', 'time_of_day': '06:30'},
        validFrom: t2024,
      );

      // 2. In 2025, user updates routine to evening yoga
      final t2025 = DateTime.utc(2025, 6, 1);
      final updatedFact = await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.routine,
        factKey: 'exercise.primary_cadence',
        title: 'Evening Vinyasa Yoga',
        factValue: {'value': 'yoga', 'time_of_day': '18:30'},
        validFrom: t2025,
        changeReason: 'Shifted from running to low-impact evening yoga',
      );

      expect(updatedFact.title, equals('Evening Vinyasa Yoga'));
      expect(updatedFact.currentValue['value'], equals('yoga'));

      // Check current active facts: shows the newest active fact
      final activeFacts = await memoryService.getCurrentActiveFacts(userId: testUserId);
      expect(activeFacts.length, equals(1));
      expect(activeFacts.first.title, equals('Evening Vinyasa Yoga'));

      // Full history has both versions intact
      final history = await memoryService.getFactHistory(
        userId: testUserId,
        factKey: 'exercise.primary_cadence',
      );
      expect(history.length, equals(2));

      final v1 = history[0];
      final v2 = history[1];

      expect(v1.versionNumber, equals(1));
      expect(v1.factValue['value'], equals('running'));
      expect(v1.supersededAt, isNotNull); // Prior version was superseded
      expect(v1.isCurrentlyActive, isFalse);

      expect(v2.versionNumber, equals(2));
      expect(v2.factValue['value'], equals('yoga'));
      expect(v2.supersededAt, isNull); // New version is active
      expect(v2.isCurrentlyActive, isTrue);
      expect(v2.changeReason, equals('Shifted from running to low-impact evening yoga'));
    });

    test('Bitemporal Point-in-Time queries isolate reality vs. system belief', () async {
      final realStart2023 = DateTime.utc(2023, 1, 1);
      final realEnd2024 = DateTime.utc(2024, 12, 31);

      // Record a fact that was true in 2023-2024: Vegetarian diet
      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.preference,
        factKey: 'diet.pattern',
        title: 'Vegetarian Diet',
        factValue: {'diet': 'vegetarian'},
        validFrom: realStart2023,
        validTo: realEnd2024,
      );

      // Query reality in June 2023
      final mid2023 = DateTime.utc(2023, 6, 1);
      final factsIn2023 = await memoryService.queryAsOf(
        userId: testUserId,
        systemTime: DateTime.now().toUtc(),
        realTime: mid2023,
      );
      expect(factsIn2023.length, equals(1));
      expect(factsIn2023.first.factValue['diet'], equals('vegetarian'));

      // Query reality in 2025 (after validTo)
      final mid2025 = DateTime.utc(2025, 6, 1);
      final factsIn2025 = await memoryService.queryAsOf(
        userId: testUserId,
        systemTime: DateTime.now().toUtc(),
        realTime: mid2025,
      );
      expect(factsIn2025.isEmpty, isTrue); // Not valid in 2025
    });

    test('Synthesizes personal memory context for LLM agent prompt injection', () async {
      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.allergyAndIntolerance,
        factKey: 'allergy.peanuts',
        title: 'Peanut Anaphylaxis',
        factValue: {'summary': 'Severe anaphylactic reaction to peanuts and peanut oil'},
        validFrom: DateTime.utc(2020, 1, 1),
      );

      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.medicationAndSupplement,
        factKey: 'supplement.vitamin_d3',
        title: 'Vitamin D3 & K2',
        factValue: {'summary': '5000 IU Vitamin D3 + 100 mcg K2 daily with breakfast'},
        validFrom: DateTime.utc(2024, 1, 1),
      );

      final activeFacts = await memoryService.getCurrentActiveFacts(userId: testUserId);
      final promptContext = memoryService.synthesizeMemoryPromptContext(
        activeFacts: activeFacts,
      );

      expect(promptContext, contains('Verified Personal Health Memory & Long-Term Context'));
      expect(promptContext, contains('Allergy & Intolerance'));
      expect(promptContext, contains('Peanut Anaphylaxis'));
      expect(promptContext, contains('Medication & Supplement'));
      expect(promptContext, contains('Vitamin D3 & K2'));
    });
  });
}
