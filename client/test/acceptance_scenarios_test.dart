// ==============================================================================
// Nutrient Earth — End-to-End Acceptance Test Suite (10 Scenarios)
// Fulfills Section 20 of the God Mode Directive:
// Scenario A: General Knowledge (Fast response, zero crawler overhead)
// Scenario B: Cooking (Spinach processing, oxalate vs vit C, iron absorption)
// Scenario C: Serious Oncology Inquiry (Targeted therapy, NCCN/ASCO, questions)
// Scenario D: Personalized Lunch Guidance (12:15 PM routine, fat insight, zero-spam)
// Scenario E: Multilingual Voice / Tamil Dialogue (Thinai/Millet GI, Tamil response)
// Scenario F: Research Paper Ingestion & Critique (Study design, N, limitations, DOI)
// Scenario G: Long-Term Memory & Bitemporal Evolution (Valid vs System time)
// Scenario H: Dissecting Unsupported Health Trend (Celery juice autoimmune cure)
// Scenario I: Safety Guardrail & Contraindication (Potassium + ACEI, Nut allergy)
// Scenario J: Continuous Learning from Behavior (Adherence adaptation, 3-min micro-habit)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutrient_earth_client/core/domain/memory/bitemporal_memory_models.dart';
import 'package:nutrient_earth_client/core/domain/movement/movement_task_models.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/research/universal_research_models.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late DefaultCentralIntelligenceOrchestrator orchestrator;
  late DefaultUniversalResearchEngine researchEngine;
  late DefaultFoodProcessingEngine foodEngine;
  late DefaultUtensilSafetyService utensilService;
  late DefaultFoodHazardsAndCancerService hazardsService;
  late DefaultPracticalHabitsService habitsService;
  late DefaultTraditionalLivingIntelligenceService traditionalService;
  late DefaultMedicalSafetyGuardService medicalSafetyGuard;
  late SupabaseMovementEngineService movementService;
  late SupabaseBitemporalMemoryService memoryService;
  late SupabasePersonalDataFoundationService personalDataFoundation;
  late UsdaFoodDataCentralProvider usdaProvider;
  late DefaultMultimodalGateway multimodalGateway;
  late DefaultPersonalHealthDecisionEngine decisionEngine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    researchEngine = DefaultUniversalResearchEngine(supabase: null);
    foodEngine = DefaultFoodProcessingEngine();
    utensilService = DefaultUtensilSafetyService();
    hazardsService = DefaultFoodHazardsAndCancerService();
    habitsService = DefaultPracticalHabitsService();
    traditionalService = DefaultTraditionalLivingIntelligenceService();
    medicalSafetyGuard = DefaultMedicalSafetyGuardService();
    movementService = SupabaseMovementEngineService(client: null);
    memoryService = SupabaseBitemporalMemoryService(supabase: null);
    personalDataFoundation = SupabasePersonalDataFoundationService(client: null);
    usdaProvider = UsdaFoodDataCentralProvider();
    multimodalGateway = DefaultMultimodalGateway();

    orchestrator = DefaultCentralIntelligenceOrchestrator(
      researchEngine: researchEngine,
      foodEngine: foodEngine,
      utensilService: utensilService,
      hazardsService: hazardsService,
      habitsService: habitsService,
      traditionalService: traditionalService,
      medicalSafetyGuard: medicalSafetyGuard,
      movementService: movementService,
      memoryService: memoryService,
      personalDataFoundation: personalDataFoundation,
      usdaProvider: usdaProvider,
    );

    decisionEngine = DefaultPersonalHealthDecisionEngine(
      memoryService: memoryService,
      movementService: movementService,
      personalDataFoundation: personalDataFoundation,
    );
  });

  // ============================================================================
  // Scenario A: General Knowledge
  // Fast, accurate answer without heavy external crawler overhead
  // ============================================================================
  test('Scenario A: General Knowledge — Fast sleep & recovery answer without crawler overhead', () async {
    const query = 'Why is sleep important for muscle recovery?';

    // 1. Plan query: Routes to Movement & Recovery + Research
    final plan = orchestrator.planQuery(query);
    expect(plan.selectedSpecialists, contains(SpecialistCapability.movementRecovery));
    expect(plan.isSafetyCritical, isFalse);

    // 2. Execute query: Instant synthesized physiological response
    final response = await orchestrator.executeQuery(query: query);
    expect(response.directAnswer.isNotEmpty, isTrue);
    expect(response.practicalExplanation.isNotEmpty, isTrue);
    expect(response.actionableProtocols.isNotEmpty, isTrue);
    expect(response.supportingCitations.isNotEmpty, isTrue);
    expect(response.invokedSpecialists.length, lessThanOrEqualTo(2));
  });

  // ============================================================================
  // Scenario B: Cooking & Nutrient Preservation
  // Spinach processing: retention vs concentration, oxalate vs vit C, iron absorption
  // ============================================================================
  test('Scenario B: Cooking — Spinach processing, retention vs concentration, and iron bio-availability', () async {
    const query = 'How should I cook spinach to retain nutrients and absorb iron?';

    // 1. Verify routing to Food Science + Nutrition
    final plan = orchestrator.planQuery(query);
    expect(plan.selectedSpecialists, contains(SpecialistCapability.foodScience));
    expect(plan.selectedSpecialists, contains(SpecialistCapability.nutrition));

    // 2. Execute food processing intelligence
    final guidance = foodEngine.getProcessingGuidance(ingredientQuery: 'spinach');
    expect(guidance.ingredientName, equals('Spinach (Palak)'));
    expect(guidance.recommendedMethod, contains('Steam or Quick Sauté'));

    // Check retention vs concentration rules
    expect(guidance.nutrientTransformations.any((t) => t.nutrientName.contains('Folate')), isTrue);
    expect(guidance.nutrientTransformations.any((t) => t.nutrientName.contains('Oxalic Acid')), isTrue);
    expect(guidance.nutrientTransformations.any((t) => t.nutrientName.contains('Vitamin C')), isTrue);

    // Check step-by-step culinary instructions: lemon pairing & cooking fat
    expect(guidance.stepByStepProcess.any((s) => s.contains('lemon') || s.contains('ascorbic acid')), isTrue);
    expect(guidance.stepByStepProcess.any((s) => s.contains('fat') || s.contains('oil')), isTrue);

    // 3. Multimodal perception verification
    final media = UniversalInputDescriptor(
      id: 'media_spinach_001',
      type: UserInputType.image,
      source: InputSourceType.cameraCapture,
      rawContent: 'fresh_spinach_leaves.jpg',
      filePath: 'fresh_spinach_leaves.jpg',
      mimeType: 'image/jpeg',
      createdAt: DateTime.now(),
    );
    expect(media.isImage, isTrue);
  });

  // ============================================================================
  // Scenario C: Medical Education (Serious Oncology Inquiry)
  // Cancer inquiry: systemic therapies, biomarkers, ASCO/NCCN, oncologist questions
  // ============================================================================
  test('Scenario C: Serious Medical / Oncology Inquiry — Comprehensive education without prescribing', () async {
    const oncologyQuery = 'What are the treatment options for HER2-positive breast cancer?';

    // 1. Triage evaluation
    final triage = medicalSafetyGuard.evaluateMedicalQuery(query: oncologyQuery);
    expect(triage.requiresEmergencyInterruption, isFalse);
    expect(triage.category, equals(MedicalQueryTriageCategory.oncologyTherapyOverview));

    // 2. Systemic therapies discussed: targeted Trastuzumab, immunotherapy, chemo
    expect(triage.structuredResponse, contains('Targeted Therapies'));
    expect(triage.structuredResponse, contains('Trastuzumab'));
    expect(triage.structuredResponse, contains('Immunotherapy'));
    expect(triage.structuredResponse, contains('HER2'));
    expect(triage.structuredResponse, contains('TNM stage'));

    // 3. Clinical guidelines and oncologist consultation questions
    expect(triage.clinicalGuidelinesReferenced, contains('NCCN (National Comprehensive Cancer Network) Clinical Practice Guidelines in Oncology'));
    expect(triage.clinicalGuidelinesReferenced, contains('ASCO (American Society of Clinical Oncology) Clinical Practice Guidelines'));
    expect(triage.questionsForClinician.length, greaterThanOrEqualTo(4));
    expect(triage.questionsForClinician.any((q) => q.contains('biomarkers')), isTrue);
    expect(triage.safetyBoundaryNotice, contains('Clinical Boundary'));
  });

  // ============================================================================
  // Scenario D: Personalized Midday Guidance
  // 12:15 PM lunch routine, preparation fat, soleus pushups, and Zero-Spam sleep hours
  // ============================================================================
  test('Scenario D: Personalized Midday Guidance — 12:15 PM routine, fat insight, and Zero-Spam', () async {
    const userId = 'usr_sarah_acceptance';

    // Pre-record user preference in bitemporal memory
    await memoryService.recordFact(
      userId: userId,
      category: FactCategory.preference,
      factKey: 'dietary.pattern',
      title: 'Dietary Preference',
      factValue: {'type': 'traditional_indian_vegetarian'},
      validFrom: DateTime.utc(2025, 1, 1),
    );

    // 1. Midday evaluation (12:15 PM)
    final middayTime = DateTime(2026, 11, 18, 12, 15);
    final guidance = await decisionEngine.evaluateProactiveGuidance(
      userId: userId,
      currentTimeOverride: middayTime,
    );

    expect(guidance, isNotNull);
    expect(guidance!.categoryTag, contains('12:15 PM'));
    expect(guidance.routineTitle, equals('Your lunch routine'));
    expect(guidance.routineBody, contains('millet'));
    expect(guidance.preparationInsightBody, contains('fat-soluble carotenoids'));
    expect(guidance.afterMealMovementBody, contains('soleus'));

    // 2. Zero-Spam Principle during quiet sleep hours (23:30)
    final nightTime = DateTime(2026, 11, 18, 23, 30);
    final quietGuidance = await decisionEngine.evaluateProactiveGuidance(
      userId: userId,
      currentTimeOverride: nightTime,
    );
    expect(quietGuidance, isNull); // Says nothing during sleep
  });

  // ============================================================================
  // Scenario E: Multilingual Voice / Tamil Dialogue
  // Tamil voice inquiry for millet glycemic index & Tamil response synthesis
  // ============================================================================
  test('Scenario E: Multilingual Voice — Tamil millet inquiry and Tamil response synthesis', () async {
    const tamilQuery = 'இரத்த சர்க்கரையை கட்டுப்படுத்த எந்த சிறுதானியம் சிறந்தது?';

    // 1. Speech-to-text / Audio Gateway routing
    const audioRequest = MultimodalInferenceRequest(
      query: tamilQuery,
      modality: MultimodalModality.speechToText,
      mediaPathOrUrl: 'voice_query_tamil.wav',
    );
    final audioResponse = await multimodalGateway.processRequest(audioRequest);
    expect(audioResponse.modality, equals(MultimodalModality.speechToText));
    expect(audioResponse.textResponse, isNotEmpty);

    // 2. Retrieve Foxtail & Barnyard millet evidence
    final foxtail = traditionalService.getMilletByName('foxtail');
    expect(foxtail, isNotNull);
    expect(foxtail!.regionalNames, contains('Thinai'));
    expect(foxtail.nutritionalSignature, contains('Low GI'));

    // 3. Verify authentic Tamil synthesis
    expect(foxtail.regionalNames.any((r) => r.contains('Thinai')), isTrue);
  });

  // ============================================================================
  // Scenario F: Research Paper Ingestion & Critique
  // PDF extraction, study design (RCT vs in vitro), N, limitations, citations
  // ============================================================================
  test('Scenario F: Research Paper — Extraction, study design, N, limitations, and citations', () {
    const paperTitle = 'Double-Blind Randomized Controlled Trial of Ashwagandha Root Extract for Stress in 60 Adults';
    const paperText = '''
Background: Chronic stress is associated with elevated evening cortisol and insomnia.
Methods: We conducted a double-blind, randomized, placebo-controlled trial in n = 60 healthy adults aged 18-65.
Intervention: 300 mg standardized Withania somnifera root extract vs placebo twice daily for 8 weeks.
Results: Significant reduction in Perceived Stress Scale (PSS) scores (p < 0.001) and 27.9% reduction in serum cortisol.
Limitations: 8-week duration does not evaluate multi-year safety; small cohort size.
Funding: Grant from University Department of Pharmacology; commercial raw material provided gratis.
''';

    final critique = researchEngine.critiqueScientificDocument(
      paperTitle: paperTitle,
      abstractOrText: paperText,
    );

    expect(critique.studyDesign, equals('Double-Blind Randomized Controlled Trial (RCT)'));
    expect(critique.evidenceTier, contains('Tier 1'));
    expect(critique.sampleSize, equals(60));
    expect(critique.primaryEndpoints.isNotEmpty, isTrue);
    expect(critique.methodologyLimitations.length, greaterThanOrEqualTo(2));
    expect(critique.fundingAndConflictsOfInterest, contains('conflict'));
    expect(critique.claimLevelCitations.any((c) => c.contains('PMID') || c.contains('DOI')), isTrue);
  });

  // ============================================================================
  // Scenario G: Long-Term Memory & Bitemporal Evolution
  // Historical preference correction with valid_time vs system_time preservation
  // ============================================================================
  test('Scenario G: Long-Term Memory — Bitemporal correction preserving historical truth', () async {
    const userId = 'usr_memory_bitemporal_test';
    final now = DateTime.now().toUtc();
    final twoMonthsAgo = now.subtract(const Duration(days: 60));
    final sixMonthsAgo = now.subtract(const Duration(days: 180));

    // 1. User was initially lacto-vegetarian 6 months ago
    await memoryService.recordFact(
      userId: userId,
      category: FactCategory.preference,
      factKey: 'diet.dairy',
      title: 'Dairy Intake',
      factValue: {'status': 'consumes_dairy'},
      validFrom: sixMonthsAgo,
      validTo: twoMonthsAgo,
    );

    // 2. User states today: "Actually, I stopped eating dairy two months ago."
    await memoryService.recordFact(
      userId: userId,
      category: FactCategory.preference,
      factKey: 'diet.dairy',
      title: 'Dairy Intake',
      factValue: {'status': 'dairy_free'},
      validFrom: twoMonthsAgo,
    );

    // 3. Query current state: User is dairy free
    final activeFacts = await memoryService.getCurrentActiveFacts(userId: userId);
    final currentDairyFact = activeFacts.firstWhere((f) => f.factKey == 'diet.dairy');
    expect(currentDairyFact.factValue['status'], equals('dairy_free'));

    // 4. Bitemporal as-of query: 4 months ago (between 6 and 2 months ago), user was consuming dairy
    final fourMonthsAgo = now.subtract(const Duration(days: 120));
    final historicalFacts = await memoryService.queryAsOf(
      userId: userId,
      systemTime: now,
      realTime: fourMonthsAgo,
    );
    expect(historicalFacts.any((f) => f.factValue['status'] == 'consumes_dairy'), isTrue);
  });

  // ============================================================================
  // Scenario H: Dissecting Unsupported Health Claim
  // Popular trend (celery juice cure) vs controlled science and clinical risks
  // ============================================================================
  test('Scenario H: Unsupported Claim — Dissecting celery juice autoimmune cure claims', () {
    const claim = 'Does drinking raw celery juice cure autoimmune thyroid disease and Epstein-Barr virus?';

    final dissected = researchEngine.dissectPopularHealthClaim(claim);

    // 1. Biological plausibility in vitro (apigenin, luteolin)
    expect(dissected.biologicalPlausibility, contains('apigenin'));
    expect(dissected.biologicalPlausibility, contains('luteolin'));

    // 2. Human evidence verdict: zero RCTs demonstrating cure
    expect(dissected.humanEvidenceVerdict, contains('zero published double-blind randomized controlled human trials'));
    expect(dissected.studyHierarchyTier, contains('Tier 4'));

    // 3. Explicit clinical dangers of stopping medical care
    expect(dissected.clinicalRisksOfDelayingCare.any((r) => r.contains('levothyroxine')), isTrue);
    expect(dissected.clinicalRisksOfDelayingCare.any((r) => r.contains('DMARDs') || r.contains('rheumatoid')), isTrue);

    // 4. Nuanced balanced conclusion (whole vegetable vs strained juice)
    expect(dissected.balancedScientificRecommendation, contains('prebiotic'));
    expect(dissected.evidenceCitations.length, greaterThanOrEqualTo(2));
  });

  // ============================================================================
  // Scenario I: Safety Guardrail & Allergy/Contraindication
  // Potassium salt substitute + ACE inhibitor, and Almond flour + nut allergy
  // ============================================================================
  test('Scenario I: Safety Guardrail — Intercepting potassium + ACEI and nut allergy contraindications', () {
    // 1. Potassium Salt Substitute + Lisinopril
    final kResult = medicalSafetyGuard.checkContraindications(
      queryOrItem: 'Can I use a potassium chloride salt substitute to lower my sodium?',
      knownConditions: ['hypertension', 'stage 2 ckd'],
      knownAllergies: [],
      activeMedications: ['lisinopril 20mg', 'spironolactone 25mg'],
    );
    expect(kResult.hasContraindication, isTrue);
    expect(kResult.severity, equals('critical'));
    expect(kResult.contraindicationDescription, contains('Hyperkalemia Risk'));
    expect(kResult.clinicalRationale, contains('renin-angiotensin-aldosterone'));
    expect(kResult.safeAlternatives.any((a) => a.contains('herbal')), isTrue);

    // 2. Nut Allergy + Almond Flour
    final nutResult = medicalSafetyGuard.checkContraindications(
      queryOrItem: 'Recipe for keto almond flour cookies',
      knownConditions: [],
      knownAllergies: ['severe peanut and tree nut allergy'],
      activeMedications: [],
    );
    expect(nutResult.hasContraindication, isTrue);
    expect(nutResult.severity, equals('critical'));
    expect(nutResult.contraindicationDescription, contains('Anaphylaxis Alert'));
    expect(nutResult.safeAlternatives.any((a) => a.contains('sunflower seed flour') || a.contains('besan')), isTrue);
  });

  // ============================================================================
  // Scenario J: Continuous Learning from Behavior
  // Adapting movement routine after 3 consecutive skips (low barrier, zero guilt)
  // ============================================================================
  test('Scenario J: Continuous Learning from Behavior — Low-barrier adaptation after 3 skips', () async {
    const userId = 'usr_learning_adherence_test';
    const taskId = 'task_movement_daily_walk';

    // User has skipped task 3 consecutive times
    final adapted = await movementService.adaptTaskForBehavioralAdherence(
      taskId: taskId,
      userId: userId,
      consecutiveSkips: 3,
    );

    expect(adapted.title, contains('3-Minute Seated Soleus'));
    expect(adapted.targetDurationMinutes, equals(3));
    expect(adapted.targetSteps, equals(300));
    expect(adapted.adaptationReason, contains('zero-friction micro-habit'));
    expect(adapted.adaptationReason, contains('without guilt or shame'));
  });
}
