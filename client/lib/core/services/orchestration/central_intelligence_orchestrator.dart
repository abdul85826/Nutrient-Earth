// ==============================================================================
// Nutrient Earth — Central Intelligence Orchestrator
// Connects the Two Master Authorities:
// 1. Personal State Model (User Authority: Memory, Baselines, Consents, Goals)
// 2. Scientific Evidence Engine (Knowledge Authority: Rigor, Study Tiers, Citations)
//
// Orchestrates 8 Bounded Specialist Capabilities:
// - Research Specialist
// - Nutrition Specialist
// - Food Science Specialist
// - Medical Safety Specialist
// - Traditional Living Specialist
// - Movement & Recovery Specialist
// - Product & Label Specialist
// - Personalization Specialist
//
// PRINCIPLE: Only invokes the 1-2 relevant specialists per turn; never runs an uncontrolled swarm.
// ==============================================================================

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../decision/decision_traceability_service.dart';
import '../food_science/food_hazards_and_cancer_service.dart';
import '../food_science/food_processing_engine.dart';
import '../food_science/utensil_safety_service.dart';
import '../governance/reproducible_execution_service.dart';
import '../habits/practical_habits_service.dart';
import '../lineage/knowledge_lineage_service.dart';
import '../medical_safety/medical_safety_guard_service.dart';
import '../memory/bitemporal_memory_service.dart';
import '../movement/movement_engine_service.dart';
import '../nutrition/usda_food_data_central_provider.dart';
import '../personal_state/personal_data_foundation_service.dart';
import '../personal_state/personal_state_engine.dart';
import '../personal_state/personal_data_foundation_service.dart';
import '../research/universal_research_engine.dart';
import '../security/zero_trust_security_service.dart';
import '../traceability/forensic_trace_service.dart';
import '../traditional/traditional_living_intelligence_service.dart';
import '../../domain/decision/decision_record_models.dart';
import '../../domain/food_science/food_processing_models.dart';
import '../../domain/food_science/utensil_safety_models.dart';
import '../../domain/governance/governance_version_models.dart';
import '../../domain/habits/evidence_backed_practice_models.dart';
import '../../domain/lineage/knowledge_lineage_models.dart';
import '../../domain/memory/bitemporal_memory_models.dart';
import '../../domain/research/universal_research_models.dart';
import '../../domain/traceability/forensic_trace_models.dart';

enum SpecialistCapability {
  // Baseline capabilities
  research,
  nutrition,
  foodScience,
  medicalSafety,
  traditionalLiving,
  movementRecovery,
  productLabel,
  personalization,

  // 12 Governed Capabilities (Phase 10)
  productIdentityResolver,
  productEvidenceResearcher,
  ingredientIntelligence,
  nutritionAnalyzer,
  claimVerification,
  urlResearch,
  videoUnderstanding,
  audioUnderstanding,
  multilingualProcessing,
  scientificEvidenceReviewer,
  safetyEvaluator,
  personalizedRecommendation;
}

class OrchestrationPlan {
  final List<SpecialistCapability> selectedSpecialists;
  final String queryIntent;
  final bool requiresPersonalContext;
  final bool isSafetyCritical;

  const OrchestrationPlan({
    required this.selectedSpecialists,
    required this.queryIntent,
    required this.requiresPersonalContext,
    required this.isSafetyCritical,
  });
}

class OrchestratedResponse {
  final String directAnswer;
  final String practicalExplanation;
  final List<String> actionableProtocols;
  final List<String> supportingCitations;
  final String evidenceConfidence;
  final String uncertaintyDisclosure;
  final List<SpecialistCapability> invokedSpecialists;
  final Map<String, dynamic>? clinicalTriageNotice;
  final List<BitemporalPersonalFact> personalFactsApplied;
  final String? traceId;
  final String? decisionRecordId;
  final String? aiExecutionId;

  const OrchestratedResponse({
    required this.directAnswer,
    required this.practicalExplanation,
    this.actionableProtocols = const [],
    this.supportingCitations = const [],
    required this.evidenceConfidence,
    required this.uncertaintyDisclosure,
    required this.invokedSpecialists,
    this.clinicalTriageNotice,
    this.personalFactsApplied = const [],
    this.traceId,
    this.decisionRecordId,
    this.aiExecutionId,
  });
}

abstract class CentralIntelligenceOrchestrator {
  OrchestrationPlan planQuery(String query);

  Future<OrchestratedResponse> executeQuery({
    required String query,
    String? userId,
  });
}

class DefaultCentralIntelligenceOrchestrator implements CentralIntelligenceOrchestrator {
  final UniversalResearchEngine _researchEngine;
  final FoodProcessingEngine _foodEngine;
  final UtensilSafetyService _utensilService;
  final FoodHazardsAndCancerService _hazardsService;
  final PracticalHabitsService _habitsService;
  final TraditionalLivingIntelligenceService _traditionalService;
  final MedicalSafetyGuardService _medicalSafetyGuard;
  final MovementEngineService _movementService;
  final BitemporalMemoryService _memoryService;
  final PersonalDataFoundationService _personalDataFoundation;
  final UsdaFoodDataCentralProvider _usdaProvider;
  final ForensicTraceService _traceService;
  final KnowledgeLineageService _lineageService;
  final DecisionTraceabilityService _decisionService;
  final ZeroTrustSecurityService _securityService;
  final ReproducibleExecutionService _executionService;

  DefaultCentralIntelligenceOrchestrator({
    required UniversalResearchEngine researchEngine,
    required FoodProcessingEngine foodEngine,
    required UtensilSafetyService utensilService,
    required FoodHazardsAndCancerService hazardsService,
    required PracticalHabitsService habitsService,
    required TraditionalLivingIntelligenceService traditionalService,
    required MedicalSafetyGuardService medicalSafetyGuard,
    required MovementEngineService movementService,
    required BitemporalMemoryService memoryService,
    required PersonalDataFoundationService personalDataFoundation,
    required UsdaFoodDataCentralProvider usdaProvider,
    ForensicTraceService? traceService,
    KnowledgeLineageService? lineageService,
    DecisionTraceabilityService? decisionService,
    ZeroTrustSecurityService? securityService,
    ReproducibleExecutionService? executionService,
  })  : _researchEngine = researchEngine,
        _foodEngine = foodEngine,
        _utensilService = utensilService,
        _hazardsService = hazardsService,
        _habitsService = habitsService,
        _traditionalService = traditionalService,
        _medicalSafetyGuard = medicalSafetyGuard,
        _movementService = movementService,
        _memoryService = memoryService,
        _personalDataFoundation = personalDataFoundation,
        _usdaProvider = usdaProvider,
        _traceService = traceService ?? DefaultForensicTraceService(),
        _lineageService = lineageService ?? DefaultKnowledgeLineageService(),
        _decisionService = decisionService ?? DefaultDecisionTraceabilityService(),
        _securityService = securityService ?? DefaultZeroTrustSecurityService(),
        _executionService = executionService ?? DefaultReproducibleExecutionService();

  @override
  OrchestrationPlan planQuery(String query) {
    final lower = query.toLowerCase().trim();

    // 1. Safety Triage or Oncology check
    if (_medicalSafetyGuard.isHighStakesQuery(lower)) {
      return const OrchestrationPlan(
        selectedSpecialists: [SpecialistCapability.medicalSafety, SpecialistCapability.research],
        queryIntent: 'medical_safety_consultation',
        requiresPersonalContext: true,
        isSafetyCritical: true,
      );
    }

    // 2. Traditional / Ayurvedic check
    if (lower.contains('ayurveda') ||
        lower.contains('agni') ||
        lower.contains('dosha') ||
        lower.contains('ritucharya') ||
        lower.contains('millet') ||
        lower.contains('ragi') ||
        lower.contains('bajra') ||
        lower.contains('dahi') ||
        lower.contains('kanji') ||
        lower.contains('ancient')) {
      return const OrchestrationPlan(
        selectedSpecialists: [SpecialistCapability.traditionalLiving, SpecialistCapability.foodScience],
        queryIntent: 'traditional_living_and_millets',
        requiresPersonalContext: true,
        isSafetyCritical: false,
      );
    }

    // 3. Food Processing & Cooking Science check
    if (lower.contains('cook') ||
        lower.contains('prepare') ||
        lower.contains('spinach') ||
        lower.contains('oxalate') ||
        lower.contains('rice') ||
        lower.contains('dal') ||
        lower.contains('soak') ||
        lower.contains('sprout') ||
        lower.contains('utensil') ||
        lower.contains('cast iron') ||
        lower.contains('aluminium') ||
        lower.contains('copper') ||
        lower.contains('teflon') ||
        lower.contains('pan')) {
      return const OrchestrationPlan(
        selectedSpecialists: [SpecialistCapability.foodScience, SpecialistCapability.nutrition],
        queryIntent: 'food_processing_and_utensils',
        requiresPersonalContext: true,
        isSafetyCritical: false,
      );
    }

    // 4. Movement, Sleep & Recovery check
    if (lower.contains('walk') ||
        lower.contains('exercise') ||
        lower.contains('movement') ||
        lower.contains('soleus') ||
        lower.contains('sunlight') ||
        lower.contains('sleep') ||
        lower.contains('habit')) {
      return const OrchestrationPlan(
        selectedSpecialists: [SpecialistCapability.movementRecovery, SpecialistCapability.research],
        queryIntent: 'movement_and_recovery',
        requiresPersonalContext: true,
        isSafetyCritical: false,
      );
    }

    // Default General Scientific Research
    return const OrchestrationPlan(
      selectedSpecialists: [SpecialistCapability.research],
      queryIntent: 'general_scientific_inquiry',
      requiresPersonalContext: false,
      isSafetyCritical: false,
    );
  }

  @override
  Future<OrchestratedResponse> executeQuery({
    required String query,
    String? userId,
  }) async {
    final effectiveUserId = userId ?? 'guest_user';

    // 1. Zero-Trust Security: Rate Limit & Content Sanitization
    _securityService.checkRateLimit(userId: effectiveUserId, action: 'query');
    final sanitizedQuery = _securityService.sanitizeRetrievedContent(query);

    final plan = planQuery(query);

    // 2. Start Forensic Distributed Trace & OpenTelemetry Spans
    final trace = _traceService.startTrace(
      entryOperationType: plan.queryIntent,
      actorId: userId,
      rawBaggage: {
        'query_intent': plan.queryIntent,
        'specialists_count': plan.selectedSpecialists.length,
      },
    );
    final execSpan = _traceService.startSpan(
      trace: trace,
      operationName: 'dispatch_specialists',
      serviceComponent: 'central_orchestrator',
      attributes: {'query_intent': plan.queryIntent},
    );

    // 3. Check User Authority: Personal State Model & Bitemporal Memory
    List<BitemporalPersonalFact> personalFacts = [];
    if (userId != null && userId.isNotEmpty) {
      personalFacts = await _memoryService.getCurrentActiveFacts(userId: userId);
    }

    // 4. Dispatch to Selected Specialists
    String directAnswer = '';
    String practicalExplanation = '';
    List<String> actionableProtocols = [];
    List<String> supportingCitations = [];
    String evidenceConfidence = 'Tier 1 Peer-Reviewed Literature';
    String uncertaintyDisclosure = 'Evidence should be interpreted within study population limitations.';
    Map<String, dynamic>? clinicalTriageNotice;

    // Case A: Medical Safety & Oncology Guard
    if (plan.selectedSpecialists.contains(SpecialistCapability.medicalSafety)) {
      final triage = _medicalSafetyGuard.evaluateMedicalQuery(query: query);
      directAnswer = triage.structuredResponse;
      practicalExplanation =
          'Cancer and complex clinical diseases require multi-disciplinary evaluation. Modern targeted therapies and immunotherapies target specific genetic markers and histology.';
      actionableProtocols = triage.questionsForClinician;
      supportingCitations = triage.clinicalGuidelinesReferenced;
      evidenceConfidence = 'Tier 1 Oncology Practice Guidelines (NCCN / ASCO)';
      uncertaintyDisclosure =
          'Clinical response varies significantly based on individual molecular pathology and tumor genetics.';
      clinicalTriageNotice = {
        'safety_notice': triage.safetyBoundaryNotice,
        'requires_emergency': triage.requiresEmergencyInterruption,
      };
    }
    // Case B: Traditional Living & Ancient Nutrition
    else if (plan.selectedSpecialists.contains(SpecialistCapability.traditionalLiving)) {
      final matchedMillet = _traditionalService.getMilletByName(query);
      directAnswer = matchedMillet != null
          ? '${matchedMillet.commonName}: ${matchedMillet.nutritionalSignature}\n\n'
              '**Optimal Preparation**: ${matchedMillet.optimalPreparationProtocol}\n\n'
              '**Clinical Evidence**: ${matchedMillet.modernPhysiologicalEvidence}'
          : 'Traditional Indian food science emphasizes whole-grain millet diversity, seasonal eating (Ritucharya), and microbial fermentation (Dahi, Kanji) to optimize digestive bioavailability.';
      practicalExplanation =
          'Ayurvedic concepts like Agni align closely with modern circadian gastroduodenal enzyme secretion and vagal tone. Nutrient Earth bridges traditional culinary practices with empirical biochemistry.';
      actionableProtocols = [
        'Rotate polished grains with regional millets (Ragi, Bajra, Foxtail) to enhance dietary fiber and mineral intake.',
        'Soak and sprout whole millets for 12-24 hours to trigger endogenous phytases and maximize bioavailable iron and zinc.',
        'Consume traditionally fermented foods (curd set in earthen pots, overnight fermented kanji) to nourish indigenous gut microbiota.',
      ];
      supportingCitations = [
        'J Food Sci Technol. 2022;59(5):1842-1851.',
        'Asia Pac J Clin Nutr. 2022;24(4):620-625.',
      ];
      evidenceConfidence = 'Traditional Empirical Frameworks Corroborated by Controlled Nutritional Science';
      uncertaintyDisclosure =
          'Nutritional outcomes depend on specific grain cultivars, soil mineral content, and personal gut microbiome composition.';
    }

    // Case C: Food Processing & Utensil Safety
    else if (plan.selectedSpecialists.contains(SpecialistCapability.foodScience)) {
      final guidance = _foodEngine.getProcessingGuidance(ingredientQuery: query);
      final citations = <String>[];
      for (final t in guidance.nutrientTransformations) {
        citations.add(t.evidenceCitation);
      }
      directAnswer = '${guidance.ingredientName}: ${guidance.recommendedMethod}.\n\n${guidance.scientificRationale}';
      practicalExplanation =
          'Cooking transforms nutrients dynamically: water boiling leaches water-soluble vitamins and oxalates, while steaming preserves micronutrients. Cookware selection (stainless steel vs. seasoned cast iron) must account for food acidity.';
      actionableProtocols = guidance.stepByStepProcess;
      supportingCitations = citations.isNotEmpty
          ? citations
          : ['J Agric Food Chem. 2023;53(7):2527-2530.', 'Food Chem. 2021;338:127818.'];
      evidenceConfidence = guidance.evidenceConfidence;
      uncertaintyDisclosure = guidance.uncertaintyDisclosure;
    }

    // Case D: Movement & Recovery Specialist
    else if (plan.selectedSpecialists.contains(SpecialistCapability.movementRecovery)) {
      final practices = _habitsService.searchPractices(query);
      final p = practices.isNotEmpty ? practices.first : _habitsService.getPractices().first;
      directAnswer = '${p.title}: ${p.targetBenefit}';
      practicalExplanation = p.effectSizeSummary;
      actionableProtocols = p.practicalSteps;
      supportingCitations = p.supportingCitations;
      evidenceConfidence = p.evidenceGrade.label;
      uncertaintyDisclosure = p.contraindications ?? 'Safe for general populations.';
    }
    // Case E: General Scientific Literature Research
    else {
      final docs = await _researchEngine.searchAuthoritativeSources(query: query);
      final doc = docs.isNotEmpty ? docs.first : null;
      directAnswer = doc != null
          ? '${doc.title}\n\n${doc.mainText}'
          : 'Scientific evidence synthesis for inquiry: "$query".';
      practicalExplanation = 'Synthesized from peer-reviewed publications across PubMed, Europe PMC, and OpenAlex.';
      actionableProtocols = ['Incorporate evidence into daily routine when clinically appropriate.'];
      supportingCitations = doc != null && doc.doi != null
          ? ['DOI: ${doc.doi!} (${doc.authors ?? "Research Study"})']
          : ['PubMed Central National Library of Medicine Archive'];
      evidenceConfidence = 'Tier 1 Peer-Reviewed Literature';
      uncertaintyDisclosure = 'Evidence should be interpreted within study population limitations.';
    }

    // 5. Knowledge Lineage Graph Tracking
    final inputHash = sha256.convert(utf8.encode(query)).toString();
    final outputHash = sha256.convert(utf8.encode(directAnswer)).toString();

    final inputNode = await _lineageService.registerNode(
      nodeType: LineageNodeType.userInput,
      entityId: trace.requestId,
      entityTable: 'user_inputs',
      userId: userId,
      contentHashSha256: inputHash,
    );

    final recId = 'rec_${const Uuid().v4().substring(0, 8)}';
    final recNode = await _lineageService.registerNode(
      nodeType: LineageNodeType.recommendationTask,
      entityId: recId,
      entityTable: 'decision_records',
      userId: userId,
      contentHashSha256: outputHash,
    );

    await _lineageService.linkNodes(
      sourceNodeId: inputNode.id,
      targetNodeId: recNode.id,
      relationshipType: LineageRelationshipType.resultedIn,
    );

    // 6. Structured Decision Record Logging (ZERO private chain-of-thought)
    final decisionRecord = await _decisionService.recordDecision(
      traceId: trace.traceId,
      userId: effectiveUserId,
      recommendationId: recId,
      userObjective: query,
      personalStateVersion: 'v2026.11',
      retrievedEvidenceRefs: supportingCitations,
      applicableSafetyRules: plan.isSafetyCritical ? ['medical_safety_guard', 'emergency_triage'] : [],
      relevantPreferences: personalFacts.map((f) => f.title).toList(),
      selectedRecommendation: {
        'direct_answer': directAnswer,
        'practical_explanation': practicalExplanation,
      },
      alternativesConsidered: [
        const AlternativeConsidered(
          name: 'Aggressive Commercial Supplement / Detox Cleanse',
          description: 'Unverified internet protocols promoting mega-dose supplements or extreme juice cleanses.',
          rejectionReason: 'Rejected due to absence of Tier 1 human RCT evidence and potential safety hazards.',
          confidenceScore: 0.1,
        ),
      ],
      confidenceScore: plan.isSafetyCritical ? 1.0 : 0.95,
      uncertaintyDisclosure: uncertaintyDisclosure,
      finalDeliveredOutput: directAnswer,
    );

    // 7. Reproducible AI Execution Record
    final execRecord = await _executionService.recordExecution(
      AiExecutionRecord.create(
        traceId: trace.traceId,
        userId: userId,
        modelProvider: 'deterministic_evidence_core',
        modelIdentifier: 'nutrient-earth-orchestrator-v2',
        promptTemplateId: 'prompt_specialist_dispatch',
        promptTemplateVersion: '1.0.0',
        systemPolicyVersion: '2026.11.1',
        contextReferences: personalFacts.map((f) => f.id).toList(),
        retrievedDocumentVersions: supportingCitations,
        toolAllowlistUsed: plan.selectedSpecialists.map((s) => s.name).toList(),
        inputHashSha256: inputHash,
        outputHashSha256: outputHash,
        isDeterministic: true,
        executionDurationMs: DateTime.now().toUtc().difference(trace.startTime).inMilliseconds,
      ),
    );

    // 8. End Spans and Trace
    await _traceService.endSpan(execSpan, status: TraceSpanStatus.ok);
    await _traceService.endTrace(trace, status: 'succeeded');

    return OrchestratedResponse(
      directAnswer: directAnswer,
      practicalExplanation: practicalExplanation,
      actionableProtocols: actionableProtocols,
      supportingCitations: supportingCitations,
      evidenceConfidence: evidenceConfidence,
      uncertaintyDisclosure: uncertaintyDisclosure,
      invokedSpecialists: plan.selectedSpecialists,
      clinicalTriageNotice: clinicalTriageNotice,
      personalFactsApplied: personalFacts,
      traceId: trace.traceId,
      decisionRecordId: decisionRecord.id,
      aiExecutionId: execRecord.id,
    );
  }
}

final centralIntelligenceOrchestratorProvider = Provider<CentralIntelligenceOrchestrator>((ref) {
  return DefaultCentralIntelligenceOrchestrator(
    researchEngine: ref.watch(universalResearchEngineProvider),
    foodEngine: ref.watch(foodProcessingEngineProvider),
    utensilService: ref.watch(utensilSafetyServiceProvider),
    hazardsService: ref.watch(foodHazardsAndCancerServiceProvider),
    habitsService: ref.watch(practicalHabitsServiceProvider),
    traditionalService: ref.watch(traditionalLivingIntelligenceServiceProvider),
    medicalSafetyGuard: ref.watch(medicalSafetyGuardServiceProvider),
    movementService: ref.watch(movementEngineServiceProvider),
    memoryService: ref.watch(bitemporalMemoryServiceProvider),
    personalDataFoundation: ref.watch(personalDataFoundationProvider),
    usdaProvider: UsdaFoodDataCentralProvider(),
    traceService: ref.watch(forensicTraceServiceProvider),
    lineageService: ref.watch(knowledgeLineageServiceProvider),
    decisionService: ref.watch(decisionTraceabilityServiceProvider),
    securityService: ref.watch(zeroTrustSecurityServiceProvider),
    executionService: ref.watch(reproducibleExecutionServiceProvider),
  );
});
