// ==============================================================================
// Nutrient Earth — AI Answer Generation Engine Foundation Test Suite
// Rigorous offline verification of structured answer contracts, goal-aware
// personalization, nutrition calculation engine, citation validation, and orchestration.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/structured_research_answer.dart';
import 'package:nutrient_earth_client/core/domain/evidence/citation_validator.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_contract.dart';
import 'package:nutrient_earth_client/core/domain/nutrition/nutrition_computation_engine.dart';
import 'package:nutrient_earth_client/core/domain/nutrition/nutrition_models.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/research_intent.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/research_orchestration_pipeline.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/research_persistence_service.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  group('Workstream A: Structured Answer Contract & Backward Compatibility', () {
    test('StructuredResearchAnswer serializes and deserializes accurately with version 2026.1', () {
      final answer = StructuredResearchAnswer(
        contractVersion: '2026.1',
        query: 'Magnesium bisglycinate bioavailability',
        referenceId: 'REF-2026-TEST',
        domainCategory: 'Biochemical Pharmacology',
        quickAnswer: 'Chelated magnesium glycinate has superior intestinal bioavailability.',
        detailedExplanation: 'Amino acid chelates utilize PepT1 peptide pathways.',
        effectivenessAssessment: EffectivenessAssessment.stronglySupported,
        evidenceBadge: 'SYSTEMATIC REVIEW & RCT EVIDENCE • GRADE A',
        sources: const [
          ScientificSource(
            title: 'Bioavailability of US magnesium preparations',
            authorsOrJournal: 'Magnesium Research',
            year: '2001',
            evidenceGrade: 'Clinical Pharmacokinetics',
            pmid: '11794633',
            verificationStatus: EvidenceVerificationStatus.peerReviewedArchive,
          ),
        ],
        practicalRecommendations: const ['Take 200mg 30 minutes before sleep'],
        safetyInformation: const SafetyInformation(
          tolerableUpperIntakeLevel: '350 mg/day',
          generalMedicalDisclaimer: 'Educational guidance only.',
        ),
        generatedAt: DateTime(2026, 10, 27),
      );

      final json = answer.toJson();
      expect(json['contractVersion'], equals('2026.1'));
      expect(json['quickAnswer'], contains('superior intestinal bioavailability'));
      // Verify legacy UI backward compatibility fields exist
      expect(json['answerSummary'], contains('PepT1'));
      expect(json['citations'], isNotEmpty);
      expect(json['practicalSteps'], contains('Take 200mg 30 minutes before sleep'));

      final restored = StructuredResearchAnswer.fromJson(json);
      expect(restored.contractVersion, equals('2026.1'));
      expect(restored.quickAnswer, equals(answer.quickAnswer));
      expect(restored.sources.first.pmid, equals('11794633'));
    });

    test('ResearchAnswer converts smoothly fromStructuredAnswer preserving legacy UI getters', () {
      final structured = StructuredResearchAnswer(
        query: 'Optimal protein per meal',
        referenceId: 'REF-2026-MPS',
        quickAnswer: 'Target 0.31-0.40 g/kg protein per meal for MPS.',
        detailedExplanation: 'Stimulates mTORC1 via intracellular leucine threshold.',
        sources: const [
          ScientificSource(
            title: 'Muscle protein synthesis kinetics',
            authorsOrJournal: 'AJCN',
            year: '2024',
            evidenceGrade: 'Meta-Analysis',
            pmid: '24299726',
          ),
        ],
        practicalRecommendations: const ['Consume 30-35g protein with fiber'],
        safetyInformation: const SafetyInformation(
          generalMedicalDisclaimer: 'Consult renal specialist if indicated.',
        ),
        generatedAt: DateTime.now(),
      );

      final legacyAnswer = ResearchAnswer.fromStructuredAnswer(structured);

      expect(legacyAnswer.query, equals('Optimal protein per meal'));
      expect(legacyAnswer.answerSummary, contains('mTORC1'));
      expect(legacyAnswer.citations.length, equals(1));
      expect(legacyAnswer.citations.first.pmid, equals('24299726'));
      expect(legacyAnswer.practicalSteps.first, contains('30-35g protein'));
      expect(legacyAnswer.structuredAnswer, isNotNull);
    });
  });

  group('Workstream B: Goal-Aware Personalization & Evaluation Rules', () {
    const userProfile = UserProfileContext(
      userId: 'test-user-101',
      displayName: 'Alex Rivers',
      age: 32,
      biologicalSex: 'female',
      primaryGoals: ['Deep Sleep Optimization', 'Muscle Recovery'],
      activityLevel: 'high',
      dietaryPreference: 'vegan',
      budgetConstraint: 'moderate',
      willingnessToChange: 'high',
      knownConditions: ['Chronic kidney sensitivity'],
      activeSupplements: ['Zinc picolinate', 'Vitamin B12'],
    );

    test('Evaluates positive goal alignment when inquiry matches primary goal', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'Magnesium glycinate for deep sleep and recovery',
        userProfile: userProfile,
      );

      expect(result.status, equals(GoalAlignmentStatus.aligned));
      expect(result.matchedGoals, contains('Deep Sleep Optimization'));
      expect(result.matchedGoals, contains('Muscle Recovery'));
      expect(result.alignmentRationale, contains('Deep Sleep Optimization'));
    });

    test('Detects dietary preference conflict (vegan vs animal collagen/whey)', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'Hydrolyzed bovine collagen and whey protein peptides',
        userProfile: userProfile,
      );

      expect(result.status, equals(GoalAlignmentStatus.misaligned));
      expect(result.contraindicationsOrWarnings, isNotEmpty);
      expect(result.contraindicationsOrWarnings.first, contains('vegan'));
    });

    test('Flags known clinical condition precautions (renal sensitivity vs protein load)', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'High-dose protein shake with potassium salts',
        userProfile: userProfile,
      );

      expect(result.contraindicationsOrWarnings, isNotEmpty);
      expect(
        result.contraindicationsOrWarnings.any((w) => w.contains('renal')),
        isTrue,
      );
    });

    test('Flags duplicate active supplementation to avoid exceeding UL', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'Zinc bisglycinate 50mg daily immunity protocol',
        userProfile: userProfile,
      );

      expect(
        result.contraindicationsOrWarnings.any((w) => w.contains('Zinc picolinate')),
        isTrue,
      );
    });

    test('Returns insufficientInformation when user profile is null or empty without hallucination', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'Magnesium for sleep',
        userProfile: null,
      );

      expect(result.status, equals(GoalAlignmentStatus.insufficientInformation));
      expect(result.missingContextNotes, isNotNull);
      expect(result.matchedGoals, isEmpty);
    });
  });

  group('Workstream D: Scientific Evidence & Citation Validation', () {
    test('Validates legitimate scientific publication with valid numeric PMID', () {
      const source = ScientificSource(
        title: 'Bioavailability of magnesium',
        authorsOrJournal: 'Magnesium Research',
        year: '2001',
        evidenceGrade: 'Pharmacokinetics',
        pmid: '11794633',
        verificationStatus: EvidenceVerificationStatus.liveVerified,
      );

      final result = CitationValidator.validateSource(source);
      expect(result.isValid, isTrue);
      expect(result.validationErrors, isEmpty);
    });

    test('Rejects malformed non-numeric PMID', () {
      const malformedSource = ScientificSource(
        title: 'Unverified paper',
        authorsOrJournal: 'Random Blog',
        year: '2024',
        evidenceGrade: 'Anecdotal',
        pmid: 'PMID-XYZ-1234', // Invalid format
      );

      final result = CitationValidator.validateSource(malformedSource);
      expect(result.isValid, isFalse);
      expect(result.validationErrors.any((e) => e.contains('Malformed PubMed ID')), isTrue);
    });

    test('Validates correct DOI format and rejects invalid prefix', () {
      expect(CitationValidator.isValidDoi('10.1016/j.nutres.2024.01.002'), isTrue);
      expect(CitationValidator.isValidDoi('http://doi.org/10.1016'), isFalse);
      expect(CitationValidator.isValidDoi('11.9999/invalid'), isFalse);
    });

    test('Enforces PMID or DOI requirement when marked liveVerified', () {
      const liveWithoutId = ScientificSource(
        title: 'Alleged live study',
        authorsOrJournal: 'Journal of Testing',
        year: '2025',
        evidenceGrade: 'RCT',
        verificationStatus: EvidenceVerificationStatus.liveVerified,
      );

      final result = CitationValidator.validateSource(liveWithoutId);
      expect(result.isValid, isFalse);
      expect(result.validationErrors.any((e) => e.contains('requires a verifiable PMID or DOI')), isTrue);
    });
  });

  group('Workstream E: Deterministic Nutrition Computation Engine', () {
    test('Calculates Atwater general factor energy distribution accurately', () {
      // 30g protein * 4 = 120 kcal
      // 40g total carbs - 10g fiber = 30g net carbs * 4 = 120 kcal
      // 10g fat * 9 = 90 kcal
      // Total = 330 kcal
      const macros = MacronutrientProfile(
        proteinGrams: 30.0,
        totalCarbsGrams: 40.0,
        dietaryFiberGrams: 10.0,
        totalFatGrams: 10.0,
      );

      final breakdown = NutritionComputationEngine.calculateEnergyBreakdown(macros);

      expect(breakdown.proteinKcal, equals(120.0));
      expect(breakdown.carbohydrateKcal, equals(120.0));
      expect(breakdown.fatKcal, equals(90.0));
      expect(breakdown.totalCalculatedKcal, equals(330.0));
      expect(breakdown.proteinRatio, closeTo(120 / 330, 0.001));
      expect(breakdown.carbohydrateRatio, closeTo(120 / 330, 0.001));
      expect(breakdown.fatRatio, closeTo(90 / 330, 0.001));
    });

    test('Ensures net carbohydrates cannot be negative if data has reporting discrepancies', () {
      const oddMacros = MacronutrientProfile(
        proteinGrams: 10.0,
        totalCarbsGrams: 5.0,
        dietaryFiberGrams: 8.0, // Erroneously higher than total carbs
        totalFatGrams: 2.0,
      );

      expect(oddMacros.netCarbsGrams, equals(0.0));
    });

    test('Performs deterministic mass and energy unit conversions', () {
      expect(
        NutritionComputationEngine.convertUnit(
          value: 2.5,
          from: NutrientUnit.gram,
          to: NutrientUnit.milligram,
        ),
        equals(2500.0),
      );

      expect(
        NutritionComputationEngine.convertUnit(
          value: 500.0,
          from: NutrientUnit.microgram,
          to: NutrientUnit.milligram,
        ),
        equals(0.5),
      );

      expect(
        NutritionComputationEngine.convertUnit(
          value: 100.0,
          from: NutrientUnit.kcal,
          to: NutrientUnit.kj,
        ),
        closeTo(418.4, 0.01),
      );
    });

    test('Scales nutrition profile to target gram weight while preserving missing nutrients list', () {
      final baseProfile = NutritionAnalysisProfile(
        foodItemName: 'Sample Whey & Oats Bowl',
        servingSize: const ServingSize(amount: 1.0, unitName: 'bowl', gramWeight: 100.0),
        caloriesKcal: 200.0,
        macronutrients: const MacronutrientProfile(
          proteinGrams: 20.0,
          totalCarbsGrams: 25.0,
          dietaryFiberGrams: 5.0,
          totalFatGrams: 4.0,
        ),
        micronutrients: const [
          MicronutrientMeasurement(
            nutrientName: 'Calcium',
            amount: 150.0,
            unit: NutrientUnit.milligram,
          ),
        ],
        missingOrUnreportedNutrients: const ['Iodine', 'Molybdenum'],
        provenance: NutritionDataProvenance(
          sourceDatabase: 'USDA FDC',
          citationOrStandard: 'Standard Laboratory Method',
          verifiedAt: DateTime.now(),
        ),
      );

      final scaled = NutritionComputationEngine.scaleToGramWeight(baseProfile, 200.0);

      expect(scaled.caloriesKcal, equals(400.0));
      expect(scaled.macronutrients.proteinGrams, equals(40.0));
      expect(scaled.macronutrients.netCarbsGrams, equals(40.0)); // (50 - 10)
      expect(scaled.micronutrients.first.amount, equals(300.0));
      // Missing nutrients must be preserved explicitly rather than assumed zero
      expect(scaled.missingOrUnreportedNutrients, contains('Iodine'));
      expect(scaled.missingOrUnreportedNutrients, contains('Molybdenum'));
    });
  });

  group('Workstream C: Research Orchestration Pipeline', () {
    test('Classifies research intents correctly', () {
      expect(
        ResearchIntentClassifier.classify('What are the calories and protein in 100g lentils?'),
        equals(ResearchIntent.nutrientAnalysis),
      );
      expect(
        ResearchIntentClassifier.classify('Morning light exposure and circadian melatonin onset'),
        equals(ResearchIntent.circadianDiurnal),
      );
      expect(
        ResearchIntentClassifier.classify('Magnesium bisglycinate bioavailability vs oxide'),
        equals(ResearchIntent.supplementEvaluation),
      );
      expect(
        ResearchIntentClassifier.classify('Creatine monohydrate dosage timing and kidney safety'),
        equals(ResearchIntent.supplementEvaluation),
      );
      expect(
        ResearchIntentClassifier.classify('Randomized controlled trial evidence on fasting autophagy'),
        equals(ResearchIntent.scientificLiterature),
      );
    });

    test('Orchestrates full 10-stage inquiry pipeline for sleep research', () async {
      final pipeline = ResearchOrchestrationPipeline();
      const profile = UserProfileContext(
        userId: 'u1',
        displayName: 'Test User',
        age: 30,
        biologicalSex: 'male',
        primaryGoals: ['Deep Sleep Optimization'],
        activityLevel: 'moderate',
        dietaryPreference: 'omnivorous',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
      );

      final result = await pipeline.execute(
        query: 'Magnesium glycinate for sleep quality',
        userProfile: profile,
      );

      expect(result.isSuccess, isTrue);
      expect(result.detectedIntent, equals(ResearchIntent.circadianDiurnal));
      expect(result.stagesExecuted.length, equals(9)); // Non-nutrient skips nutrition stage; includes BlockchainProvenanceAnchoring
      expect(result.stagesExecuted, contains('BlockchainProvenanceAnchoring'));
      expect(result.answer.sources, isNotEmpty);
      expect(result.answer.claims, isNotEmpty);
      expect(result.answer.claims.first.supportStatus, equals(ClaimSupportStatus.supported));
      expect(result.answer.goalAlignment?.status, equals(GoalAlignmentStatus.aligned));
      expect(result.answer.healthBenefits, isNotEmpty);
      expect(result.answer.provenanceDossier, isNotNull);
      expect(result.answer.provenanceDossier!.merkleProof.verify(), isTrue);
    });

    test('Orchestrates nutrient inquiry and builds detailed nutrition profile', () async {
      final pipeline = ResearchOrchestrationPipeline();

      final result = await pipeline.execute(
        query: 'High protein recovery meal plate calories and macros',
      );

      expect(result.isSuccess, isTrue);
      expect(result.detectedIntent, equals(ResearchIntent.nutrientAnalysis));
      expect(result.stagesExecuted, contains('NutritionComputation'));
      expect(result.stagesExecuted, contains('BlockchainProvenanceAnchoring'));
      expect(result.stagesExecuted.length, equals(10)); // Full 10 stages
      expect(result.answer.nutritionAnalysis, isNotNull);
      expect(result.answer.nutritionAnalysis!.caloriesKcal, equals(440.0));
      expect(result.answer.nutritionAnalysis!.macronutrients.proteinGrams, equals(36.0));
      expect(result.answer.provenanceDossier, isNotNull);
    });
  });

  group('Workstream G: Persistence Fallback Safety', () {
    test('ResearchPersistenceService handles offline / unauthenticated states gracefully without exceptions', () async {
      final service = ResearchPersistenceService.instance;

      // When unauthenticated, getOrCreateConversation safely returns null
      final convId = await service.getOrCreateConversation(title: 'Test Inquiry');
      expect(convId, isNull);

      final answer = await ResearchPipelineService.processInquiry(query: 'Sleep and magnesium');
      final success = await service.persistInquiryAndAnswer(
        conversationId: 'mock-conv-id',
        query: 'Sleep and magnesium',
        answer: answer,
      );
      expect(success, isFalse); // Handled safely without throwing

      final history = await service.loadRecentConversations();
      expect(history, isEmpty);
    });
  });

  group('Workstream H: Targeted Remediation Regression Tests (P0 & P1)', () {
    test('Supplement matching: Vitamin D3 does NOT trigger duplicate warning for Vitamin C', () {
      const profile = UserProfileContext(
        userId: 'u-supp-1',
        displayName: 'Test User',
        age: 32,
        biologicalSex: 'female',
        primaryGoals: ['Immune Support'],
        activityLevel: 'moderate',
        dietaryPreference: 'omnivorous',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        activeSupplements: ['Vitamin D3', 'Omega-3'],
      );

      final result = GoalAlignmentEvaluator.evaluate(
        query: 'What are the proven benefits of vitamin C for immune defense?',
        userProfile: profile,
      );

      // Must NOT contain duplicate warning for Vitamin D3
      final duplicateWarnings = result.contraindicationsOrWarnings
          .where((w) => w.contains('already report taking "Vitamin D3"'))
          .toList();
      expect(duplicateWarnings, isEmpty,
          reason: 'Vitamin D3 must not trigger duplicate warning when inquiry is about Vitamin C');
    });

    test('Supplement matching: Vitamin D3 accurately triggers duplicate warning for Vitamin D inquiries', () {
      const profile = UserProfileContext(
        userId: 'u-supp-2',
        displayName: 'Test User',
        age: 32,
        biologicalSex: 'female',
        primaryGoals: ['Bone Health'],
        activityLevel: 'moderate',
        dietaryPreference: 'omnivorous',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        activeSupplements: ['Vitamin D3'],
      );

      final result = GoalAlignmentEvaluator.evaluate(
        query: 'Should I take 5000 IU of vitamin D daily?',
        userProfile: profile,
      );

      expect(
        result.contraindicationsOrWarnings.any((w) => w.contains('already report taking "Vitamin D3"')),
        isTrue,
        reason: 'Vitamin D inquiry should match active Vitamin D3 supplement',
      );
    });

    test('Supplement matching: Distinguishes distinct B vitamins (B12 vs B6)', () {
      expect(GoalAlignmentEvaluator.isDuplicateSupplement('Vitamin B12', 'what is the best form of vitamin b6?'), isFalse);
      expect(GoalAlignmentEvaluator.isDuplicateSupplement('Vitamin B12', 'should I supplement methylcobalamin vitamin b12?'), isTrue);
    });

    test('Supplement matching: Elemental mineral matching catches compound salts without brand noise', () {
      // User takes "Doctor's Best Magnesium Glycinate"
      const supp = 'Doctor\'s Best Magnesium Glycinate';

      // Asking about magnesium citrate must match (same elemental mineral)
      expect(GoalAlignmentEvaluator.isDuplicateSupplement(supp, 'what are the side effects of magnesium citrate?'), isTrue);

      // Asking about doctors or best products must NOT match
      expect(GoalAlignmentEvaluator.isDuplicateSupplement(supp, 'should I ask my doctor for the best multivitamin?'), isFalse);
    });

    test('Supplement matching: Zinc salt forms match each other but do not match unrelated compounds', () {
      expect(GoalAlignmentEvaluator.isDuplicateSupplement('Zinc Picolinate', 'is zinc carnosine effective for gut lining?'), isTrue);
      expect(GoalAlignmentEvaluator.isDuplicateSupplement('Zinc Picolinate', 'what is the dosage for iron bisglycinate?'), isFalse);
      expect(GoalAlignmentEvaluator.isDuplicateSupplement('Melatonin', 'how does creatine monohydrate increase ATP?'), isFalse);
    });

    test('Mock identity elimination: Missing profile never activates Sarah Jenkins or fictional context', () {
      final result = GoalAlignmentEvaluator.evaluate(
        query: 'What is the optimal magnesium protocol for deep sleep?',
        userProfile: null, // Unauthenticated or missing profile
      );

      expect(result.status, equals(GoalAlignmentStatus.insufficientInformation));
      expect(result.alignmentRationale, contains('Personalized goal suitability requires an active user profile'));
      expect(result.missingContextNotes, contains('configure your health goals and dietary preferences in your profile'));
      expect(result.matchedGoals, isEmpty);
      // Zero fabricated Sarah Jenkins goals or active supplements
      expect(result.contraindicationsOrWarnings, isEmpty);
    });

    test('Non-manufactured metrics: Pipeline produces zero fabricated percentages or unsupported multipliers', () async {
      final pipeline = ResearchOrchestrationPipeline();

      final result = await pipeline.execute(
        query: 'What is the best magnesium for sleep?',
      );

      expect(result.isSuccess, isTrue);
      final answer = result.answer;

      // Evidence badge must be qualitative, NEVER manufactured numerical percentage
      expect(RegExp(r'\d+%\s*confidence', caseSensitive: false).hasMatch(answer.evidenceBadge), isFalse,
          reason: 'evidenceBadge must not contain fabricated confidence percentages like "96% CONFIDENCE"');
      expect(answer.evidenceBadge, equals('RCT REVIEW • GRADE A (SYSTEMATIC EVIDENCE)'));

      // Comparison multiplier must be null unless backed by verified pharmacokinetic data
      expect(answer.comparisonIndex, isNull,
          reason: 'comparisonIndex must be null rather than an arbitrary 4.2x or 3.5x multiplier');
    });

    test('Health privacy classification: Server and client guards reject sensitive health indicators', () {
      // Biomarkers + personal possessives
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('my fasting blood glucose was 142 mg/dL'), isTrue);
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('my latest lab results showed elevated triglycerides'), isTrue);
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('my blood pressure was 155/95 this morning'), isTrue);

      // Prescription pharmaceuticals
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('can I take berberine if I am on metformin?'), isTrue);
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('does magnesium interact with lisinopril?'), isTrue);
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('should I stop taking ozempic before fasting?'), isTrue);

      // Generalized non-confidential scientific queries are allowed
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('Mechanism of action of berberine on AMPK activation in muscle cells'), isFalse);
      expect(SensitiveDataRoutingGuard.containsPersonalHealthSignals('Randomized controlled trials on magnesium glycinate and sleep efficiency'), isFalse);
    });
  });
}
