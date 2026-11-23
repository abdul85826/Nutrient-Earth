// ==============================================================================
// Nutrient Earth — Verified Intelligence Runtime Master Hardening Test Suite
// Verification Suite for Master Engineering Hardening Addendum (Schema v2026.3)
//
// Tests:
// 1. Advanced Request Understanding & Multi-Part Decomposition (Parts B & E)
// 2. Scientific Contradiction Engine & Study-Family Deduplication (Part D)
// 3. Operational Failure Classifier & Safe Recovery Engine (Parts C, N, P)
// 4. Deterministic Calculation Superiority (Parts B & C)
// 5. Response & Polymorphic Streaming Safety (Part J)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/answer_contract/response_content_block.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_contract.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/adaptive_execution_planner.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_intelligence_router.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/claims/claim_verification_engine.dart';
import 'package:nutrient_earth_client/core/services/deterministic/deterministic_calculation_service.dart';
import 'package:nutrient_earth_client/core/services/evidence/scientific_contradiction_engine.dart';
import 'package:nutrient_earth_client/core/services/orchestration/operational_failure_classifier.dart';
import 'package:nutrient_earth_client/core/services/search/query_decomposition_service.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/dynamic_block_renderers.dart';

void main() {
  group('Part B & E: Advanced Request Understanding & Query Decomposition', () {
    test('1. Decomposes multi-question inquiries with multiple question marks', () {
      const query = 'What is creatine? How much should I take? Does it cause hair loss?';
      final decomp = QueryDecompositionService.decompose(query: query);

      expect(decomp.isCompound, isTrue);
      expect(decomp.coordinationType, equals(CoordinationType.independent));
      expect(decomp.subQuestions.length, greaterThanOrEqualTo(3));
      expect(decomp.primaryEntity, equals('creatine'));
      expect(decomp.subQuestions.first.queryText, contains('creatine'));
    });

    test('2. Decomposes conjoined multi-intent inquiries (benefits, dosage, safety)', () {
      const query = 'magnesium sleep benefits, optimal dosage, and interaction with l-theanine';
      final decomp = QueryDecompositionService.decompose(query: query);

      expect(decomp.isCompound, isTrue);
      expect(decomp.subQuestions.length, greaterThanOrEqualTo(2));
      expect(decomp.primaryEntity, equals('magnesium'));
      expect(decomp.subQuestions.any((sq) => sq.focus.contains('benefit')), isTrue);
      expect(decomp.subQuestions.any((sq) => sq.focus.contains('dosage')), isTrue);
    });

    test('3. Detects material ambiguity on solitary keywords and generates structured clarification', () {
      const query = 'mercury';
      final decomp = QueryDecompositionService.decompose(query: query);

      expect(decomp.ambiguity, equals(AmbiguityClassification.material));
      expect(decomp.clarificationOptions.isNotEmpty, isTrue);
      expect(decomp.clarificationOptions.any((opt) => opt.optionId == 'opt-dosage'), isTrue);
      expect(decomp.clarificationOptions.any((opt) => opt.optionId == 'opt-safety'), isTrue);
    });

    test('4. Resolves anaphoric follow-up pronouns in sub-questions using context', () {
      final decomp = QueryDecompositionService.decompose(
        query: 'how much should I take?',
        priorReferencedEntity: 'ashwagandha',
      );

      expect(decomp.subQuestions.first.queryText, contains('ashwagandha'));
    });
  });

  group('Part D: Scientific Data Integrity, Contradiction Engine & Deduplication', () {
    test('1. Deduplicates multiple publications originating from the same trial (NCT ID)', () {
      final rawCitations = [
        const ScientificSource(
          title: 'Primary cardiovascular outcomes in the trial (NCT01169259)',
          authorsOrJournal: 'NEJM',
          year: '2020',
          evidenceGrade: 'RCT',
          sampleSize: 12000,
        ),
        const ScientificSource(
          title: 'Secondary cognitive sub-study analysis (NCT01169259)',
          authorsOrJournal: 'JAMA',
          year: '2022',
          evidenceGrade: 'Subgroup Analysis',
          sampleSize: 4500,
        ),
        const ScientificSource(
          title: 'Independent replication trial (NCT02999999)',
          authorsOrJournal: 'Lancet',
          year: '2023',
          evidenceGrade: 'RCT',
          sampleSize: 8000,
        ),
      ];

      final families = ScientificContradictionEngine.deduplicateStudyFamilies(rawCitations);

      // 3 citations, but only 2 unique trial families
      expect(families.length, equals(2));
      final multiPubFamily = families.firstWhere((f) => f.primaryTrialIdentifier == 'NCT01169259');
      expect(multiPubFamily.isMultiPublication, isTrue);
      expect(multiPubFamily.memberCitations.length, equals(2));
    });

    test('2. Deduplicates multiple publications from the same epidemiological cohort', () {
      final rawCitations = [
        const ScientificSource(
          title: 'Dietary sodium patterns in NHANES 2017-2018',
          authorsOrJournal: 'Am J Clin Nutr',
          year: '2021',
          evidenceGrade: 'Cohort',
        ),
        const ScientificSource(
          title: 'Potassium and hypertension risk in NHANES 2017-2018',
          authorsOrJournal: 'Hypertension',
          year: '2022',
          evidenceGrade: 'Cohort',
        ),
      ];

      final families = ScientificContradictionEngine.deduplicateStudyFamilies(rawCitations);
      expect(families.length, equals(1));
      expect(families.first.primaryTrialIdentifier, contains('NHANES'));
      expect(families.first.isMultiPublication, isTrue);
    });

    test('3. Reconciles apparent contradictions through confounder identification', () {
      final citations = [
        const ScientificSource(
          title: 'Vitamin D supplementation reduces respiratory infections in deficient subjects',
          authorsOrJournal: 'BMJ',
          year: '2017',
          evidenceGrade: 'Meta-Analysis',
          pmid: '28202713',
        ),
        const ScientificSource(
          title: 'High-dose bolus vitamin D fails to reduce cardiovascular events in replete adults',
          authorsOrJournal: 'JAMA',
          year: '2019',
          evidenceGrade: 'RCT',
          pmid: '31479137',
        ),
      ];

      final claims = [
        const ScientificClaim(
          claimText: 'Vitamin D supplementation reduces acute infection risk.',
          supportStatus: ClaimSupportStatus.supported,
          physiologicalMechanism: 'Cathelicidin synthesis',
        ),
        const ScientificClaim(
          claimText: 'Routine high-dose Vitamin D confers cardioprotection in unselected populations.',
          supportStatus: ClaimSupportStatus.contradicted,
          physiologicalMechanism: 'Vascular calcification risk with excessive bolus',
        ),
      ];

      final report = ScientificContradictionEngine.analyzeEvidence(
        topic: 'Vitamin D clinical efficacy',
        citations: citations,
        claims: claims,
      );

      expect(report.hasDiscordantOutcomes, isTrue);
      expect(report.consensusState, equals(ScientificConsensusState.contextDependent));
      expect(report.identifiedConfounders, contains(ConfounderDimension.baselineStatus));
      expect(report.explanatoryMechanisms.first, contains('Baseline Nutritional Repletion'));
    });
  });

  group('Part C, N, P: Operational Failure Classifier & Failure States', () {
    test('1. Classifies HTTP 429 into ERR_RATE_LIMITED with deterministic recovery', () {
      final report = OperationalFailureClassifier.classify(statusCode: 429);

      expect(report.failureCode, equals('ERR_RATE_LIMITED'));
      expect(report.failureType, equals(OperationalFailureType.rateLimited));
      expect(report.isTransient, isTrue);
      expect(report.suggestedAction, equals(OperationalRecoveryAction.fallbackToDeterministicEngine));
    });

    test('2. Classifies 401/403 into ERR_AUTH_INVALID requiring reauthentication', () {
      final report = OperationalFailureClassifier.classify(statusCode: 401);

      expect(report.failureCode, equals('ERR_AUTH_INVALID'));
      expect(report.failureType, equals(OperationalFailureType.authInvalid));
      expect(report.isTransient, isFalse);
      expect(report.suggestedAction, equals(OperationalRecoveryAction.reauthenticate));
    });

    test('3. Classifies network socket failures into ERR_NETWORK_DISRUPTED', () {
      final report = OperationalFailureClassifier.classify(error: 'SocketException: OS Error: connection refused');

      expect(report.failureCode, equals('ERR_NETWORK_DISRUPTED'));
      expect(report.failureType, equals(OperationalFailureType.networkDisrupted));
      expect(report.isTransient, isTrue);
      expect(report.suggestedAction, equals(OperationalRecoveryAction.retryWithBackoff));
    });

    test('4. Classifies publication gate interception into ERR_VERIFICATION_FAILED', () {
      final report = OperationalFailureClassifier.classify(error: 'Verification failed: unsupported claims detected');

      expect(report.failureCode, equals('ERR_VERIFICATION_FAILED'));
      expect(report.failureType, equals(OperationalFailureType.verificationFailed));
      expect(report.suggestedAction, equals(OperationalRecoveryAction.abstainAndNotifyUser));
    });

    test('5. Classifies medical emergency triggers into ERR_SAFE_ABSTENTION', () {
      final report = OperationalFailureClassifier.classify(error: 'Safe abstention: acute emergency clinical symptoms');

      expect(report.failureCode, equals('ERR_SAFE_ABSTENTION'));
      expect(report.failureType, equals(OperationalFailureType.safeAbstention));
      expect(report.suggestedAction, equals(OperationalRecoveryAction.abstainAndNotifyUser));
    });
  });

  group('Part B & C: Deterministic Calculation Engine Integration', () {
    test('1. BMR & TDEE calculated with exact mathematical precision', () {
      final result = DeterministicCalculationService.calculateBmrAndTdee(
        weightKg: 75.0,
        heightCm: 180.0,
        ageYears: 30,
        isMale: true,
        activityLevel: ActivityLevel.moderatelyActive,
      );

      // Mifflin-St Jeor male: 10*75 + 6.25*180 - 5*30 + 5 = 750 + 1125 - 150 + 5 = 1730 kcal
      expect(result.bmrKcal, equals(1730.0));
      // TDEE: 1730 * 1.55 = 2681.5 kcal
      expect(result.tdeeKcal, equals(2681.5));
    });

    test('2. Natural language calculation parser dispatches instantly', () {
      final parsed = DeterministicCalculationService.tryParseAndCalculate('calculate bmr 75kg 180cm 30 male');

      expect(parsed, isNotNull);
      expect(parsed!['calculationType'], equals('BMR_TDEE'));
      expect(parsed['displayText'], contains('1730 kcal/day'));
    });

    test('3. Exact unit conversions executed without LLM approximation', () {
      final conv = DeterministicCalculationService.convertVitaminDIuToMcg(2000.0);
      expect(conv.outputValue, equals(50.0));

      final temp = DeterministicCalculationService.convertTemperatureFtoC(212.0);
      expect(temp.outputValue, equals(100.0));
    });
  });

  group('Part J: Dynamic Block Rendering & Forward Compatibility', () {
    testWidgets('1. Forward-compatible fallback renders cleanly for unknown block types', (tester) async {
      final dummyBlock = _CustomExperimentalBlock(blockType: 'aiKnowledgeGraphVisualizer');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicBlockRenderer(block: dummyBlock),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('aiKnowledgeGraphVisualizer'), findsOneWidget);
    });

    test('2. Claim Verification Engine intercepts unverified cancer claims', () {
      final verified = ClaimVerificationEngine.evaluateForPublication(
        rawDirectAnswer: 'Taking high dose vitamin C cures cancer 100% and completely replaces insulin.',
        rawExplanation: '',
        candidateCitations: [],
      );

      expect(verified.isApprovedForPublication, isFalse);
      expect(verified.sanitizedDirectAnswer.toUpperCase(), contains('CLINICAL SAFETY NOTICE'));
      expect(verified.sanitizedDirectAnswer, isNot(contains('cures cancer 100%')));
    });
  });
}

class _CustomExperimentalBlock extends ResponseContentBlock {
  const _CustomExperimentalBlock({required super.blockType});

  @override
  Map<String, dynamic> toJson() => {'blockType': blockType};
}
