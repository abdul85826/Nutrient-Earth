// ==============================================================================
// Nutrient Earth — Master Intelligence Architecture Tests
// Verifies:
// 1. Central Intelligence Orchestrator (8 Bounded Specialists + Twin Authorities)
// 2. Personal Health Decision Engine (Proactive, Contextual, Zero-Spam)
// 3. Medical Safety & Oncology Intelligence Guard (Nuanced, Safe, Non-Prescriptive)
// 4. Traditional Food & Living Intelligence Engine (Millets, Ayurveda, Longevity Science)
// 5. Provider-Independent Multimodal Gateway
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/memory/bitemporal_memory_models.dart';
import 'package:nutrient_earth_client/core/services/decision/personal_health_decision_engine.dart';
import 'package:nutrient_earth_client/core/services/food_science/food_hazards_and_cancer_service.dart';
import 'package:nutrient_earth_client/core/services/food_science/food_processing_engine.dart';
import 'package:nutrient_earth_client/core/services/food_science/utensil_safety_service.dart';
import 'package:nutrient_earth_client/core/services/habits/practical_habits_service.dart';
import 'package:nutrient_earth_client/core/services/medical_safety/medical_safety_guard_service.dart';
import 'package:nutrient_earth_client/core/services/memory/bitemporal_memory_service.dart';
import 'package:nutrient_earth_client/core/services/movement/movement_engine_service.dart';
import 'package:nutrient_earth_client/core/services/multimodal/provider_independent_multimodal_gateway.dart';
import 'package:nutrient_earth_client/core/services/nutrition/usda_food_data_central_provider.dart';
import 'package:nutrient_earth_client/core/services/orchestration/central_intelligence_orchestrator.dart';
import 'package:nutrient_earth_client/core/services/personal_state/personal_data_foundation_service.dart';
import 'package:nutrient_earth_client/core/services/research/universal_research_engine.dart';
import 'package:nutrient_earth_client/core/services/traditional/traditional_living_intelligence_service.dart';

void main() {
  group('Central Intelligence Orchestrator Tests', () {
    late DefaultCentralIntelligenceOrchestrator orchestrator;

    setUp(() {
      orchestrator = DefaultCentralIntelligenceOrchestrator(
        researchEngine: DefaultUniversalResearchEngine(supabase: null),
        foodEngine: DefaultFoodProcessingEngine(),
        utensilService: DefaultUtensilSafetyService(),
        hazardsService: DefaultFoodHazardsAndCancerService(),
        habitsService: DefaultPracticalHabitsService(),
        traditionalService: DefaultTraditionalLivingIntelligenceService(),
        medicalSafetyGuard: DefaultMedicalSafetyGuardService(),
        movementService: DefaultMovementEngineService(supabase: null),
        memoryService: SupabaseBitemporalMemoryService(supabase: null),
        personalDataFoundation: SupabasePersonalDataFoundationService(supabase: null),
        usdaProvider: UsdaFoodDataCentralProvider(),
      );
    });

    test('Plans queries by invoking ONLY the 1-2 relevant bounded specialists', () {
      // 1. Oncology query -> Medical Safety + Research
      final oncologyPlan = orchestrator.planQuery('What is the medicine for cancer?');
      expect(oncologyPlan.selectedSpecialists, contains(SpecialistCapability.medicalSafety));
      expect(oncologyPlan.selectedSpecialists, contains(SpecialistCapability.research));
      expect(oncologyPlan.isSafetyCritical, isTrue);

      // 2. Traditional Millets -> Traditional Living + Food Science
      final traditionalPlan = orchestrator.planQuery('How to prepare ragi mudde and what are its benefits?');
      expect(traditionalPlan.selectedSpecialists, contains(SpecialistCapability.traditionalLiving));
      expect(traditionalPlan.selectedSpecialists, contains(SpecialistCapability.foodScience));

      // 3. Cookware / Utensils -> Food Science + Nutrition
      final utensilPlan = orchestrator.planQuery('Is seasoned cast iron safe for tomato rasam?');
      expect(utensilPlan.selectedSpecialists, contains(SpecialistCapability.foodScience));
      expect(utensilPlan.selectedSpecialists, contains(SpecialistCapability.nutrition));

      // 4. Movement / Recovery -> MovementRecovery + Research
      final movementPlan = orchestrator.planQuery('How does soleus pushup clear postprandial glucose?');
      expect(movementPlan.selectedSpecialists, contains(SpecialistCapability.movementRecovery));
    });

    test('Executes oncology inquiries with clinically grounded guidance without prescribing', () async {
      final response = await orchestrator.executeQuery(query: 'What medicine is used for cancer?');

      expect(response.directAnswer, contains('Cancer is not a single disease'));
      expect(response.directAnswer, contains('Immunotherapy'));
      expect(response.directAnswer, contains('Targeted Therapies'));
      expect(response.actionableProtocols.isNotEmpty, isTrue);
      expect(response.actionableProtocols.any((q) => q.contains('biomarkers')), isTrue);
      expect(response.supportingCitations.any((c) => c.contains('NCCN')), isTrue);
      expect(response.clinicalTriageNotice?['safety_notice'], contains('Clinical Boundary'));
    });
  });

  group('Personal Health Decision Engine Tests', () {
    late DefaultPersonalHealthDecisionEngine decisionEngine;
    late SupabaseBitemporalMemoryService memoryService;
    const testUserId = 'usr_decision_engine_test';

    setUp(() {
      memoryService = SupabaseBitemporalMemoryService(supabase: null);
      decisionEngine = DefaultPersonalHealthDecisionEngine(
        memoryService: memoryService,
        movementService: DefaultMovementEngineService(supabase: null),
        personalDataFoundation: SupabasePersonalDataFoundationService(supabase: null),
      );
    });

    test('Generates proactive midday lunch guidance at 12:15 PM tailored to preferences', () async {
      // Record user preference for traditional home-cooked meals
      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.preference,
        factKey: 'preference.dietary',
        title: 'Dietary Preference',
        factValue: {'type': 'traditional_home_cooked'},
        validFrom: DateTime.utc(2024, 1, 1),
      );

      // Midday Lunch time: 12:15 PM
      final lunchTime = DateTime(2026, 11, 18, 12, 15);
      final guidance = await decisionEngine.evaluateProactiveGuidance(
        userId: testUserId,
        currentTimeOverride: lunchTime,
      );

      expect(guidance, isNotNull);
      expect(guidance!.categoryTag, contains('Personal Guidance • 12:15 PM'));
      expect(guidance.routineTitle, equals('Your lunch routine'));
      expect(guidance.routineBody, contains('millet'));
      expect(guidance.preparationInsightTitle, equals('A small preparation insight'));
      expect(guidance.preparationInsightBody, contains('fat-soluble carotenoids'));
      expect(guidance.afterMealMovementTitle, equals('After lunch movement'));
      expect(guidance.afterMealMovementBody, contains('walk or seated soleus'));
    });

    test('Zero-Spam Principle: Returns null and says nothing during quiet sleep hours', () async {
      final nightTime = DateTime(2026, 11, 18, 23, 30); // 11:30 PM
      final guidance = await decisionEngine.evaluateProactiveGuidance(
        userId: testUserId,
        currentTimeOverride: nightTime,
      );

      expect(guidance, isNull); // Says nothing during sleep
    });
  });

  group('Medical Safety & Oncology Guard Tests', () {
    late DefaultMedicalSafetyGuardService guardService;

    setUp(() {
      guardService = DefaultMedicalSafetyGuardService();
    });

    test('Triggers immediate emergency interruption for acute life-threatening symptoms', () {
      final triage = guardService.evaluateMedicalQuery(query: 'I have severe chest pain and cannot breathe');
      expect(triage.requiresEmergencyInterruption, isTrue);
      expect(triage.category, equals(MedicalQueryTriageCategory.emergencyLifeThreatening));
      expect(triage.structuredResponse, contains('EMERGENCY SAFETY TRIAGE'));
    });

    test('Answers cancer questions with clinical depth, standard of care, and oncologist questions', () {
      final triage = guardService.evaluateMedicalQuery(query: 'What is the treatment for lymphoma?');
      expect(triage.requiresEmergencyInterruption, isFalse);
      expect(triage.category, equals(MedicalQueryTriageCategory.oncologyTherapyOverview));
      expect(triage.questionsForClinician.length, greaterThanOrEqualTo(4));
      expect(triage.clinicalGuidelinesReferenced, contains('ASCO (American Society of Clinical Oncology) Clinical Practice Guidelines'));
    });
  });

  group('Traditional Living & Ayurvedic Science Tests', () {
    late DefaultTraditionalLivingIntelligenceService traditionalService;

    setUp(() {
      traditionalService = DefaultTraditionalLivingIntelligenceService();
    });

    test('Provides comprehensive millet profiles with regional names and clinical evidence', () {
      final ragi = traditionalService.getMilletByName('ragi');
      expect(ragi, isNotNull);
      expect(ragi!.commonName, contains('Finger Millet'));
      expect(ragi.regionalNames, contains('Kezhvaragu'));
      expect(ragi.nutritionalSignature, contains('344 mg calcium'));
      expect(ragi.optimalPreparationProtocol, contains('Sprouting'));
    });

    test('Evaluates traditional fermentation and indigenous gut suitability', () {
      final fermented = traditionalService.getFermentationSuitability();
      expect(fermented.length, greaterThanOrEqualTo(2));

      final dahi = fermented.firstWhere((f) => f.foodName.contains('Dahi'));
      expect(dahi.suitabilityForIndianGut, contains('traditional home-set dahi'));
      expect(dahi.practicalPreparationTip, contains('mitti handi'));
    });

    test('Rebuts ancient 100-year longevity myths with scientific demographic facts', () {
      final eval = traditionalService.evaluateHistoricalLongevityClaims();
      expect(eval['core_conclusion'].toString(), contains('unsupported by demographic and anthropological records'));
      expect(eval['anthropological_evidence'].toString(), contains('survival bias'));
    });
  });

  group('Provider-Independent Multimodal Gateway Tests', () {
    late DefaultMultimodalGateway gateway;

    setUp(() {
      gateway = DefaultMultimodalGateway();
    });

    test('Lists registered model capabilities across text, vision, speech, and document modalities', () {
      final models = gateway.getAvailableModels();
      expect(models.any((m) => m.providerId == 'gemini'), isTrue);
      expect(models.any((m) => m.providerId == 'groq'), isTrue);
      expect(models.any((m) => m.providerId == 'deepseek'), isTrue);
      expect(models.any((m) => m.isLocalPrivate), isTrue);
    });

    test('Processes vision meal scan with typed entities and confidence scoring', () async {
      const request = MultimodalInferenceRequest(
        query: 'What is on this plate?',
        modality: MultimodalModality.imageVision,
        mediaPathOrUrl: 'ragi_roti_plate.jpg',
      );

      final response = await gateway.processRequest(request);
      expect(response.modality, equals(MultimodalModality.imageVision));
      expect(response.confidenceScore, greaterThan(0.9));
      expect(response.detectedEntities.isNotEmpty, isTrue);
    });
  });
}
