// ==============================================================================
// Nutrient Earth — Personal State Model & Data Foundation Test Suite
// Verifies:
// 1. Observation Contract & Non-Elevation Constraint
// 2. Personal Baseline Minimum-Sample Rules & Robust Statistics
// 3. Deterministic State Change Detection & Artifact Filtering
// 4. Personal State Snapshot & Explicit Unknown Tracking
// 5. Personal Data Foundation Pipeline & Consent Verification Gate
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/personal_state/personal_baseline.dart';
import 'package:nutrient_earth_client/core/domain/personal_state/personal_observation.dart';
import 'package:nutrient_earth_client/core/domain/personal_state/personal_state_snapshot.dart';
import 'package:nutrient_earth_client/core/domain/personal_state/state_change_detection.dart';
import 'package:nutrient_earth_client/core/domain/personal_state/user_consent.dart';
import 'package:nutrient_earth_client/core/services/personal_state/personal_data_foundation_service.dart';
import 'package:nutrient_earth_client/core/services/personal_state/personal_state_engine.dart';

void main() {
  group('1. Canonical Personal Observation Contract', () {
    const testUserId = 'test-user-uuid-1234';

    test('Creates valid direct observation from authorized device', () {
      final now = DateTime.now().toUtc();
      final observedTime = now.subtract(const Duration(hours: 2));

      final obs = PersonalObservation.observed(
        userId: testUserId,
        observationType: 'sleep_duration',
        numericValue: 7.4,
        unit: 'hour',
        sourceProvider: ObservationSourceProvider.androidHealthConnect,
        deviceModel: 'Pixel Watch 2',
        externalRecordId: 'ext-sleep-rec-987',
        observedAt: observedTime,
        timezone: 'Asia/Kolkata',
        consentScope: ConsentScope.healthRead,
      );

      expect(obs.userId, equals(testUserId));
      expect(obs.observationType, equals('sleep_duration'));
      expect(obs.numericValue, equals(7.4));
      expect(obs.unit, equals('hour'));
      expect(obs.sourceProvider, equals(ObservationSourceProvider.androidHealthConnect));
      expect(obs.provenanceType, equals(ObservationProvenance.observed));
      expect(obs.isDirectObservation, isTrue);
      expect(obs.observedAt, equals(observedTime));
      expect(obs.recordedAt.isAfter(observedTime), isTrue);
      expect(obs.timezone, equals('Asia/Kolkata'));
    });

    test('Enforces Non-Elevation Rule: AI pipeline cannot produce observed record', () {
      expect(
        () => PersonalObservation(
          id: 'test-id',
          userId: testUserId,
          observationType: 'fatigue_level',
          numericValue: 8.0,
          sourceProvider: ObservationSourceProvider.aiPipeline,
          observedAt: DateTime.now().toUtc(),
          recordedAt: DateTime.now().toUtc(),
          provenanceType: ObservationProvenance.observed, // VIOLATION
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => PersonalObservation.observed(
          userId: testUserId,
          observationType: 'steps',
          sourceProvider: ObservationSourceProvider.aiPipeline, // VIOLATION
          observedAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Serializes to and from JSON preserving provenance and dual timestamps', () {
      final obs = PersonalObservation.observed(
        userId: testUserId,
        observationType: 'resting_heart_rate',
        numericValue: 62.0,
        unit: 'bpm',
        sourceProvider: ObservationSourceProvider.appleHealthKit,
        deviceModel: 'Apple Watch Series 9',
        observedAt: DateTime.utc(2026, 11, 17, 6, 0),
        timezone: 'America/New_York',
      );

      final json = obs.toJson();
      final reconstituted = PersonalObservation.fromJson(json);

      expect(reconstituted.userId, equals(obs.userId));
      expect(reconstituted.observationType, equals(obs.observationType));
      expect(reconstituted.numericValue, equals(62.0));
      expect(reconstituted.unit, equals('bpm'));
      expect(reconstituted.sourceProvider, equals(ObservationSourceProvider.appleHealthKit));
      expect(reconstituted.provenanceType, equals(ObservationProvenance.observed));
    });
  });

  group('2. Personal Baseline Engine', () {
    const testUserId = 'test-user-uuid-1234';
    final windowStart = DateTime.utc(2026, 11, 1);
    final windowEnd = DateTime.utc(2026, 11, 15);

    test('Rejects premature baseline when sample count < 5', () {
      final samples = [7200.0, 7500.0, 6800.0]; // Only 3 days

      final baseline = PersonalBaseline.compute(
        userId: testUserId,
        metricName: 'steps',
        values: samples,
        unit: 'count',
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(baseline.status, equals(BaselineStatus.insufficientData));
      expect(baseline.sampleCount, equals(3));
      expect(baseline.confidenceScore, equals(0.10));
    });

    test('Establishes provisional baseline when 5 <= sample count < 14', () {
      final samples = [
        6000.0, 6500.0, 7000.0, 7200.0, 6800.0, 7100.0, 6900.0
      ]; // 7 days

      final baseline = PersonalBaseline.compute(
        userId: testUserId,
        metricName: 'steps',
        values: samples,
        unit: 'count',
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(baseline.status, equals(BaselineStatus.provisional));
      expect(baseline.sampleCount, equals(7));
      expect(baseline.baselineValue, equals(6900.0)); // Median of sorted
      expect(baseline.confidenceScore, greaterThan(0.50));
      expect(baseline.confidenceScore, lessThan(0.90));
    });

    test('Establishes stable baseline when sample count >= 14', () {
      final samples = List.generate(14, (i) => 7000.0 + (i * 50)); // 14 days

      final baseline = PersonalBaseline.compute(
        userId: testUserId,
        metricName: 'steps',
        values: samples,
        unit: 'count',
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(baseline.status, equals(BaselineStatus.established));
      expect(baseline.sampleCount, equals(14));
      expect(baseline.confidenceScore, greaterThanOrEqualTo(0.90));
    });
  });

  group('3. Deterministic State Change Detection', () {
    const testUserId = 'test-user-uuid-1234';

    final baseline = PersonalBaseline(
      id: 'base-1',
      userId: testUserId,
      metricName: 'sleep_duration',
      baselineValue: 7.5,
      baselineMin: 6.8,
      baselineMax: 8.2,
      standardDeviation: 0.5,
      unit: 'hour',
      sampleCount: 14,
      windowDays: 14,
      windowStart: DateTime.utc(2026, 11, 1),
      windowEnd: DateTime.utc(2026, 11, 15),
      confidenceScore: 0.92,
      status: BaselineStatus.established,
      calculatedAt: DateTime.now().toUtc(),
    );

    test('Classifies observation within range as normal_variation', () {
      final detection = StateChangeDetection.evaluate(
        userId: testUserId,
        metricName: 'sleep_duration',
        observedValue: 7.2, // Within 6.8 - 8.2
        baseline: baseline,
      );

      expect(detection.classification, equals(ChangeClassification.normalVariation));
      expect(detection.direction, equals(ChangeDirection.unchanged));
      expect(detection.deviationPercent, equals(0.0));
    });

    test('Classifies significant drop as sustained_change', () {
      final detection = StateChangeDetection.evaluate(
        userId: testUserId,
        metricName: 'sleep_duration',
        observedValue: 5.2, // ~30.7% drop from 7.5
        baseline: baseline,
      );

      expect(detection.classification, equals(ChangeClassification.sustainedChange));
      expect(detection.direction, equals(ChangeDirection.decreased));
      expect(detection.deviationPercent, lessThan(-25.0));
    });

    test('Detects sensor artifact / extreme outlier as data_quality_issue', () {
      final detection = StateChangeDetection.evaluate(
        userId: testUserId,
        metricName: 'sleep_duration',
        observedValue: 18.0, // Implausible sleep duration (> 3.5 stdDev from 7.5)
        baseline: baseline,
      );

      expect(detection.classification, equals(ChangeClassification.dataQualityIssue));
      expect(detection.direction, equals(ChangeDirection.increased));
      expect(detection.explanation, contains('Potential device or sensor artifact'));
    });

    test('Honors insufficient_data when no baseline exists', () {
      final detection = StateChangeDetection.evaluate(
        userId: testUserId,
        metricName: 'resting_heart_rate',
        observedValue: 58.0,
        baseline: null,
      );

      expect(detection.classification, equals(ChangeClassification.insufficientData));
      expect(detection.explanation, contains('No personal baseline established yet'));
    });
  });

  group('4. Contextual Personal State Snapshot & Unknowns Tracking', () {
    const testUserId = 'test-user-uuid-1234';

    test('Explicitly tracks missing data as unknowns preventing hallucinations', () {
      final snapshot = PersonalStateSnapshot.synthesize(
        userId: testUserId,
        circadianPhase: 'morning',
        sleepHours: 7.6,
        // stepsCount and environmentalAqi are omitted
      );

      expect(snapshot.sleepHours, equals(7.6));
      expect(snapshot.stepsCount, isNull);
      expect(snapshot.environmentalAqi, isNull);

      // System must record unknowns explicitly
      expect(snapshot.unknowns, contains('daily_steps'));
      expect(snapshot.unknowns, contains('ambient_aqi'));
      expect(snapshot.unknowns, isNot(contains('sleep_duration')));
    });

    test('Calculates readiness and activity status from available observations', () {
      final snapshot = PersonalStateSnapshot.synthesize(
        userId: testUserId,
        circadianPhase: 'evening',
        sleepHours: 8.0,
        stepsCount: 11500,
        environmentalAqi: 42,
        weatherCondition: 'Clear',
        activeConstraints: ['busy_workday'],
        willingnessTier: WillingnessTier.high,
      );

      expect(snapshot.activityStatus, equals(ActivityStatus.intense));
      expect(snapshot.readinessScore, equals(1.0));
      expect(snapshot.activeConstraints, contains('busy_workday'));
      expect(snapshot.willingnessTier, equals(WillingnessTier.high));
      expect(snapshot.unknowns, isEmpty);
      expect(snapshot.confidenceScore, greaterThanOrEqualTo(0.90));
    });
  });

  group('5. Personal Data Foundation & State Engine Integration', () {
    const testUserId = 'test-user-uuid-1234';

    test('Ingests, normalizes, and checks consent correctly', () async {
      final foundation = SupabasePersonalDataFoundationService();
      final engine = SupabasePersonalStateEngine(dataFoundation: foundation);

      // Grant consent
      await foundation.grantConsent(
        userId: testUserId,
        scope: ConsentScope.healthRead,
      );

      final hasConsent = await foundation.checkConsent(
        userId: testUserId,
        scope: ConsentScope.healthRead,
      );
      expect(hasConsent, isTrue);

      // Ingest observation
      final obs = PersonalObservation.observed(
        userId: testUserId,
        observationType: 'steps',
        numericValue: 8432.7, // Should be normalized to 8433
        sourceProvider: ObservationSourceProvider.androidHealthConnect,
        observedAt: DateTime.now().toUtc(),
        consentScope: ConsentScope.healthRead,
      );

      final ingested = await foundation.ingestObservation(obs);
      expect(ingested, isNotNull);
      expect(ingested!.numericValue, equals(8433.0)); // Rounded

      // Evaluate change against empty baseline -> should report insufficientData
      final change = await engine.evaluateObservationChange(observation: ingested);
      expect(change.classification, equals(ChangeClassification.insufficientData));

      // Update state snapshot
      final snapshot = await engine.updateSnapshot(
        testUserId,
        stepsCount: 8433,
        circadianPhase: 'midday',
      );
      expect(snapshot.stepsCount, equals(8433));
      expect(snapshot.circadianPhase, equals('midday'));
    });
  });
}
