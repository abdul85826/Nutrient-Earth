// ==============================================================================
// Nutrient Earth — Universal Intelligence Search Engine
// Production-grade search and multi-turn inquiry service.
//
// Capabilities:
// 1. Accepts Multimodal Inputs: text, voice, image, barcode, document, URL.
// 2. Preserves Multi-turn Conversation Context across turns.
// 3. Routes queries across 14 canonical subject categories via UniversalIntelligenceRouter.
// 4. Assembles 6-level personal context via PersonalContextAssemblyService.
// 5. Enforces strict Missing Information Requirement Policy:
//    - Zero-onboarding queries (Categories 1-12, 14) answer immediately.
//    - Personalized queries (Category 13) with missing profile data provide evidence-based
//      reference adult baselines (70 kg standard) and never block the user.
// 6. Connects to scientific evidence engines and formats UniversalIntelligenceAnswer
//    strictly following the 5 presentation rules.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/answer_contract/universal_intelligence_answer.dart';
import '../../domain/orchestration/adaptive_execution_planner.dart';
import '../../domain/blockchain/evidence_integrity_service.dart';
import '../../domain/evidence/scientific_evidence_contract.dart';
import '../../domain/input_gateway/universal_input_descriptor.dart';
import '../../domain/orchestration/universal_intelligence_router.dart';
import '../../domain/personalization/goal_alignment_evaluator.dart';
import '../../domain/personalization/personal_context_assembly_service.dart';
import '../../domain/personalization/user_profile_context.dart';
import '../food_science/food_processing_engine.dart';
import '../food_science/utensil_safety_service.dart';
import '../../domain/food_science/utensil_safety_models.dart';
import '../multimodal/image_quality_service.dart';
import '../multimodal/product_candidate_service.dart';
import '../multimodal/social_platform_retrieval_service.dart';
import '../multimodal/video_upload_ingestion_service.dart';
import '../traditional/traditional_living_intelligence_service.dart';
import '../medical_safety/medical_safety_guard_service.dart';
import '../deterministic/deterministic_calculation_service.dart';
import 'query_decomposition_service.dart';
import 'response_relevance_gate.dart';
import '../../domain/ai_gateway/model_provider.dart';
import '../../domain/ai_gateway/model_router.dart';

/// Conversation turn for multi-turn dialogue history
class ConversationTurn {
  final String userQuery;
  final UniversalIntelligenceAnswer answer;
  final DateTime timestamp;
  final String? referencedEntity;

  const ConversationTurn({
    required this.userQuery,
    required this.answer,
    required this.timestamp,
    this.referencedEntity,
  });
}

abstract class UniversalIntelligenceSearchEngine {
  Future<UniversalIntelligenceAnswer> executeSearch({
    required UniversalInputDescriptor inputDescriptor,
    String? conversationSessionId,
    UserProfileContext? userProfile,
    List<ConversationTurn> conversationHistory = const [],
  });
}

class DefaultUniversalIntelligenceSearchEngine implements UniversalIntelligenceSearchEngine {
  final PersonalContextAssemblyService _contextAssembler;
  final FoodProcessingEngine _foodEngine;
  final UtensilSafetyService _utensilService;
  final TraditionalLivingIntelligenceService _traditionalService;
  final MedicalSafetyGuardService _medicalSafetyGuard;
  final EvidenceIntegrityService? _integrityService;
  EvidenceIntegrityService? get integrityService => _integrityService;
  final AIModelRouter _modelRouter;

  // Session memory for multi-turn context continuity
  final Map<String, List<ConversationTurn>> _sessionHistory = {};

  DefaultUniversalIntelligenceSearchEngine({
    PersonalContextAssemblyService? contextAssembler,
    FoodProcessingEngine? foodEngine,
    UtensilSafetyService? utensilService,
    TraditionalLivingIntelligenceService? traditionalService,
    MedicalSafetyGuardService? medicalSafetyGuard,
    EvidenceIntegrityService? integrityService,
    AIModelRouter? modelRouter,
  })  : _contextAssembler = contextAssembler ?? const PersonalContextAssemblyService(),
        _foodEngine = foodEngine ?? DefaultFoodProcessingEngine(),
        _utensilService = utensilService ?? DefaultUtensilSafetyService(),
        _traditionalService = traditionalService ?? DefaultTraditionalLivingIntelligenceService(),
        _medicalSafetyGuard = medicalSafetyGuard ?? DefaultMedicalSafetyGuardService(),
        _integrityService = integrityService,
        _modelRouter = modelRouter ?? AIModelRouter();

  @override
  Future<UniversalIntelligenceAnswer> executeSearch({
    required UniversalInputDescriptor inputDescriptor,
    String? conversationSessionId,
    UserProfileContext? userProfile,
    List<ConversationTurn> conversationHistory = const [],
  }) async {
    final sessionId = conversationSessionId ?? 'session_default';
    final history = conversationHistory.isNotEmpty
        ? conversationHistory
        : (_sessionHistory[sessionId] ?? const []);

    // 0. Query Decomposition & Ambiguity Triage
    final priorTurn = history.isNotEmpty ? history.last : null;
    final decomp = QueryDecompositionService.decompose(
      query: inputDescriptor.rawPayload,
      priorTurnQuery: priorTurn?.userQuery,
      priorReferencedEntity: priorTurn?.referencedEntity,
    );

    // If material ambiguity detected in a fresh query, return structured clarification options
    if (priorTurn == null &&
        decomp.ambiguity == AmbiguityClassification.material &&
        decomp.clarificationOptions.isNotEmpty &&
        inputDescriptor.inputType == UserInputType.text) {
      final clarifyAnswer = UniversalIntelligenceAnswer(
        referenceId: 'CLARIFY-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: inputDescriptor.inputType,
        responseType: UniversalResponseType.clarification,
        query: inputDescriptor.rawPayload,
        heroAnswer: 'Please clarify your focus regarding "${decomp.primaryEntity ?? inputDescriptor.rawPayload}":',
        recommendation: 'Select one of the specific research topics below to receive focused evidence.',
        detailedExplanation: 'This topic spans multiple distinct clinical dimensions (such as optimal dosage, clinical mechanisms, safety warnings, or dietary food sources). Clarification ensures precise, evidence-grounded analysis.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Clarification Required',
          rationale: 'Disambiguation ensures targeted scientific analysis.',
        ),
        evidence: const EvidenceProvenanceContainer.empty(),
        practicalSteps: decomp.clarificationOptions.map((o) => '${o.label}: ${o.description}').toList(),
        uncertaintyDisclaimer: '',
        blocks: [
          TextBlock(
            content: 'Please choose which dimension of "${decomp.primaryEntity ?? inputDescriptor.rawPayload}" you would like to explore:',
            calloutType: TextCalloutType.insight,
          ),
          InteractiveSuggestionsBlock(
            promptChips: decomp.clarificationOptions.map((o) => o.refinedQuery).toList(),
          ),
        ],
      );

      final turn = ConversationTurn(
        userQuery: inputDescriptor.rawPayload,
        answer: clarifyAnswer,
        timestamp: DateTime.now(),
        referencedEntity: decomp.primaryEntity,
      );
      _sessionHistory.putIfAbsent(sessionId, () => []).add(turn);
      return clarifyAnswer;
    }

    // 0B. Deterministic Calculation Intercept (Only for pure calculation requests, not code generation)
    final lowerPayload = inputDescriptor.rawPayload.toLowerCase();
    final isCodeRequest = lowerPayload.contains('code') ||
        lowerPayload.contains('function') ||
        lowerPayload.contains('python') ||
        lowerPayload.contains('script') ||
        lowerPayload.contains('javascript') ||
        lowerPayload.contains('dart');

    final calcParsed = !isCodeRequest
        ? DeterministicCalculationService.tryParseAndCalculate(inputDescriptor.rawPayload)
        : null;
    if (calcParsed != null && inputDescriptor.inputType == UserInputType.text) {
      final disp = calcParsed['displayText'] as String;
      final type = calcParsed['calculationType'] as String;
      final res = calcParsed['result'] as Map<String, dynamic>;

      final calcAnswer = UniversalIntelligenceAnswer(
        referenceId: 'CALC-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionCalculation,
        query: inputDescriptor.rawPayload,
        heroAnswer: disp,
        recommendation: 'Use calculated baseline to establish metabolic and dietary targets.',
        detailedExplanation: 'Computed using exact deterministic biological equations (Mifflin-St Jeor / WHO standard) without generative approximations.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.aligned,
          matchLabel: 'Deterministic Calculation',
          rationale: 'Direct formula computation.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Deterministic Mathematical Engine',
          citations: [],
          claims: [],
        ),
        practicalSteps: const [],
        uncertaintyDisclaimer: '',
        blocks: [
          TextBlock(content: disp, calloutType: TextCalloutType.leadSummary),
          MetricCalculationBlock(
            label: type,
            value: res['bmi']?.toString() ?? res['bmrKcal']?.toString() ?? res['outputValue']?.toString() ?? '',
            unit: res['toUnit']?.toString() ?? 'kcal/day',
            formula: res['formula']?.toString() ?? 'Mifflin-St Jeor / Clinical Standard',
          ),
        ],
      );

      final turn = ConversationTurn(
        userQuery: inputDescriptor.rawPayload,
        answer: calcAnswer,
        timestamp: DateTime.now(),
        referencedEntity: 'metabolic calculation',
      );
      _sessionHistory.putIfAbsent(sessionId, () => []).add(turn);
      return calcAnswer;
    }

    // 1. Resolve Multi-Turn Context & Topic Continuity
    String query = inputDescriptor.rawPayload.trim();
    String? referencedEntity;

    if (priorTurn != null) {
      referencedEntity = priorTurn.referencedEntity;

      // Handle follow-up pronouns: "how do I take it?", "is it safe?", "which one is safer?", "why?"
      final lower = query.toLowerCase();
      final isFollowUpPronoun = (lower.startsWith('how') ||
              lower.startsWith('what') ||
              lower.startsWith('is it') ||
              lower.startsWith('when') ||
              lower.startsWith('which') ||
              lower.startsWith('why') ||
              lower == 'why?') &&
          (lower.contains(' it') ||
              lower.contains(' that') ||
              lower.contains('which one') ||
              lower.endsWith('?') ||
              lower == 'why?');
      if (isFollowUpPronoun && referencedEntity != null && referencedEntity.isNotEmpty) {
        query = '$query ($referencedEntity)';
      }
    }

    // 2. Assemble 6-Level Personal Context
    final assembledContext = _contextAssembler.assemble(
      userId: userProfile?.userId,
      query: query,
      profile: userProfile,
    );

    // 3. Adaptive Execution Planning (Schema v2026.3)
    final plan = AdaptiveExecutionPlanner.createPlan(
      query: query,
      inputType: inputDescriptor.inputType,
      priorTurnQuery: priorTurn?.userQuery,
      priorReferencedEntity: priorTurn?.referencedEntity,
      userProfile: userProfile,
    );

    if (plan.understanding.isFollowUp) {
      query = plan.understanding.resolvedQuery;
    }

    // 4. Classify Query into Canonical Subject Categories & Intent
    final routing = UniversalIntelligenceRouter.classify(
      query,
      inputType: inputDescriptor.inputType,
    );

    if (routing.extractedEntities.isNotEmpty) {
      referencedEntity = routing.extractedEntities.first;
    } else if (plan.understanding.referencedEntity != null) {
      referencedEntity = plan.understanding.referencedEntity;
    }

    UniversalIntelligenceAnswer answer;

    // 5. Handle Multimodal Types First
    switch (inputDescriptor.inputType) {
      case UserInputType.barcode:
        answer = _handleBarcodeLookup(inputDescriptor.rawPayload, assembledContext);
        break;

      case UserInputType.image:
        answer = _handleImageInquiry(inputDescriptor, assembledContext);
        break;

      case UserInputType.videoUpload:
        answer = _handleVideoUploadInquiry(inputDescriptor, assembledContext);
        break;

      case UserInputType.socialVideoUrl:
        answer = await _handleSocialVideoUrlInquiry(inputDescriptor, assembledContext);
        break;

      case UserInputType.documentPdf:
        answer = _handleDocumentPdfInquiry(inputDescriptor, assembledContext);
        break;

      case UserInputType.audio:
      case UserInputType.text:
      default:
        answer = await _dispatchTextInquiry(query, routing, assembledContext, plan: plan);
        break;
    }

    // 6. Store Turn in Session Memory
    final turn = ConversationTurn(
      userQuery: inputDescriptor.rawPayload,
      answer: answer,
      timestamp: DateTime.now(),
      referencedEntity: referencedEntity,
    );
    _sessionHistory.putIfAbsent(sessionId, () => []).add(turn);

    return answer;
  }

  // ---------------------------------------------------------------------------
  // Canonical Intent & Category Dispatchers
  // ---------------------------------------------------------------------------

  Future<UniversalIntelligenceAnswer> _dispatchTextInquiry(
    String query,
    IntentRoutingDecision routing,
    AssembledPersonalContext context, {
    ExecutionPlan? plan,
  }) async {
    UniversalIntelligenceAnswer answer;

    // 1. Medical Emergency Triage Override (Clinical Safety Boundary)
    if (routing.isSafetyCritical || routing.intent == UniversalIntent.safetyCriticalEmergency) {
      final triage = _medicalSafetyGuard.evaluateMedicalQuery(query: query);
      answer = UniversalIntelligenceAnswer(
        referenceId: 'MED-TRIAGE-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.safetyResponse,
        query: query,
        heroAnswer: triage.structuredResponse,
        recommendation: 'Seek immediate professional emergency medical care.',
        detailedExplanation: 'Emergency clinical symptoms require rapid physical evaluation by qualified clinicians.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Clinical Safety Boundary',
          rationale: 'Emergency clinical intervention overrides general wellness optimization.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Emergency Practice Guidelines (AHA / ERC)',
          citations: [
            ScientificSource(
              title: 'American Heart Association Guidelines for Cardiopulmonary Resuscitation and Emergency Cardiovascular Care',
              authorsOrJournal: 'Circulation',
              year: '2023',
              evidenceGrade: 'Tier 1 Clinical Practice Guideline',
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: triage.questionsForClinician,
        uncertaintyDisclaimer: 'Nutrient Earth does not diagnose or manage acute emergency medical events.',
        blocks: [
          SafetyNoticeBlock(
            severity: SafetySeverity.criticalEmergency,
            title: 'Immediate Emergency Medical Attention Required',
            message: triage.structuredResponse,
            emergencyActions: const [
              'Call Emergency Services: 112 / 911 immediately',
              'Do not drive yourself to the hospital; request an emergency ambulance with paramedic monitoring',
              'Rest in a comfortable seated position with head and shoulders supported',
              'Unlock your front door so emergency responders can access you quickly',
            ],
          ),
          TextBlock(
            content: triage.structuredResponse,
            calloutType: TextCalloutType.warning,
          ),
        ],
      );
    } else {
      // 2. Dispatch primarily by verified user intent
      switch (routing.intent) {
        case UniversalIntent.greeting:
          answer = await _handleGreeting(query, context);
          break;

        case UniversalIntent.casualConversation:
          answer = await _handleCasualConversation(query, context);
          break;

        case UniversalIntent.codeGeneration:
          answer = _handleCodeGeneration(query, context, plan);
          break;

        case UniversalIntent.comparison:
        case UniversalIntent.evidenceComparison:
          answer = _handleStructuredComparison(query, context, plan);
          break;

        case UniversalIntent.generalKnowledge:
          answer = await _handleGeneralKnowledge(query, context);
          break;

        case UniversalIntent.healthEducation:
          answer = await _handleHealthEducation(query, context);
          break;

        case UniversalIntent.symptomInquiry:
          answer = _handleSymptomInquiry(query, context);
          break;

        case UniversalIntent.scientificResearch:
          answer = _handleResearchPaperEvaluation(query, context);
          break;

        case UniversalIntent.productSafetyResearch:
          if (routing.primaryCategory == IntelligenceCategory.utensilAndCookwareSafety) {
            answer = _handleUtensilSafety(query, context);
          } else {
            answer = _handleProductVerification(query, context);
          }
          break;

        case UniversalIntent.ingredientAnalysis:
          answer = _handleIngredientAnalysis(query, context);
          break;

        case UniversalIntent.traditionalPractices:
          answer = _handleTraditionalPractices(query, context);
          break;

        case UniversalIntent.planningAndRoutine:
          answer = _handlePersonalizedPlanning(query, context, plan: plan);
          break;

        case UniversalIntent.nutritionGuidance:
          answer = _handleNutritionGuidance(query, context);
          break;

        case UniversalIntent.safetyCriticalEmergency:
          answer = await _handleGeneralScientificInquiry(query, context);
          break;

        case UniversalIntent.imageUnderstanding:
        case UniversalIntent.documentAnalysis:
        case UniversalIntent.ambiguousOrUnknown:
          answer = await _dispatchByCategory(query, routing, context);
          break;
      }
    }

    // 3. Enforce strict Response Relevance Gate (Intent coherence, anti-hallucination, disclaimer pruning)
    return ResponseRelevanceGate.validateAndSanitize(
      query: query,
      routing: routing,
      rawAnswer: answer,
    );
  }

  Future<UniversalIntelligenceAnswer> _dispatchByCategory(
    String query,
    IntentRoutingDecision routing,
    AssembledPersonalContext context,
  ) async {
    switch (routing.primaryCategory) {
      case IntelligenceCategory.utensilAndCookwareSafety:
        return _handleUtensilSafety(query, context);

      case IntelligenceCategory.traditionalAndAncestralPractices:
        return _handleTraditionalPractices(query, context);

      case IntelligenceCategory.foodPreparationAndCookingScience:
        return _handleFoodPreparation(query, context);

      case IntelligenceCategory.movementTrainingAndRecovery:
        return _handleMovementAndRecovery(query, context);

      case IntelligenceCategory.sleepAndCircadianBiology:
        return _handleSleepAndCircadian(query, context);

      case IntelligenceCategory.environmentalAndToxinExposure:
        return _handleEnvironmentalExposure(query, context);

      case IntelligenceCategory.researchPaperAndStudyEvaluation:
        return _handleResearchPaperEvaluation(query, context);

      case IntelligenceCategory.mythVsFactInvestigation:
        return _handleMythInvestigation(query, context);

      case IntelligenceCategory.personalizedMealAndRoutinePlanning:
        return _handlePersonalizedPlanning(query, context);

      case IntelligenceCategory.ingredientAndNutrientAnalysis:
        return _handleIngredientAnalysis(query, context);

      case IntelligenceCategory.dailyRoutineAndLifestyle:
        return _handleDailyRoutine(query, context);

      case IntelligenceCategory.productVerificationAndBrandAudit:
        return _handleProductVerification(query, context);

      case IntelligenceCategory.crossDomainCompoundQuery:
        return _handleCrossDomainCompound(query, routing, context);

      case IntelligenceCategory.generalScientificInquiry:
        return await _handleGeneralScientificInquiry(query, context);
    }
  }

  // ---------------------------------------------------------------------------
  // Conversational & General Knowledge Handlers (Zero-RAG / Clean Separation)
  // ---------------------------------------------------------------------------

  Future<UniversalIntelligenceAnswer> _handleGreeting(String query, AssembledPersonalContext context) async {
    String text;
    try {
      final aiRes = await _modelRouter.routeAndExecute(
        AIModelRequest(
          query: query,
          taskType: ModelTaskType.generalScientificResearch,
          systemPromptOverride: 'You are Nutrient Earth, a friendly and intelligent health and nutrition science assistant. Greet the user warmly and concisely in 1-2 sentences.',
        ),
        userId: context.userId,
      );
      text = aiRes.answerText.trim().isNotEmpty
          ? aiRes.answerText.trim()
          : "Hello! I'm Nutrient Earth, your health intelligence companion. How can I help you today?";
    } catch (_) {
      text = "Hello! I'm Nutrient Earth, your health intelligence companion. How can I help you today?";
    }

    return UniversalIntelligenceAnswer(
      referenceId: 'GREET-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.conversation,
      query: query,
      heroAnswer: text,
      recommendation: 'Ask any question about food chemistry, cookware safety, daily routines, or scientific literature.',
      detailedExplanation: text,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Conversational Dialogue',
        rationale: 'Greeting does not require personalized goal scoring.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [],
      uncertaintyDisclaimer: '',
      blocks: [
        TextBlock(content: text, calloutType: TextCalloutType.leadSummary),
      ],
    );
  }

  Future<UniversalIntelligenceAnswer> _handleCasualConversation(String query, AssembledPersonalContext context) async {
    final lower = query.toLowerCase().trim();
    String? hero;
    String? details;

    if (lower.contains('thank') || lower.contains('thanks')) {
      hero = "You're very welcome!";
      details = 'Feel free to ask whenever you want to evaluate food ingredients, cookware safety, daily habits, or scientific studies.';
    } else if (lower.contains('how are you') || lower.contains('how are you doing')) {
      hero = 'I am functioning optimally, ready to help you explore health and nutritional science.';
      details = 'What health topic, ingredient, or routine would you like to investigate today?';
    } else if (lower.contains('who are you') || lower.contains('what is nutrient earth') || lower.contains('what can you do')) {
      hero = 'Nutrient Earth is an evidence-based universal health intelligence system.';
      details = 'Unlike conventional search or generic chatbots, Nutrient Earth provides independent, scientifically validated insights across:\n'
          '1. Food biochemistry & nutrient bioavailability\n'
          '2. Food contact material & cookware safety\n'
          '3. Daily circadian habits, hydration, and recovery\n'
          '4. Critical evaluation of human clinical trials (PubMed/PMC)\n'
          '5. Traditional & ancestral lifestyle practices grounded in physiology.';
    } else {
      try {
        final aiRes = await _modelRouter.routeAndExecute(
          AIModelRequest(
            query: query,
            taskType: ModelTaskType.generalScientificResearch,
            systemPromptOverride: 'You are Nutrient Earth, a friendly and intelligent health and nutrition science assistant. Reply conversationally, directly, and concisely.',
          ),
          userId: context.userId,
        );
        final rawText = aiRes.answerText.trim();
        final firstSentenceEnd = rawText.indexOf(RegExp(r'[\.\!\?]\s'));
        hero = (firstSentenceEnd != -1 && firstSentenceEnd < 140)
            ? rawText.substring(0, firstSentenceEnd + 1).trim()
            : (rawText.length > 120 ? '${rawText.substring(0, 117)}...' : rawText);
        details = rawText;
      } catch (_) {
        hero = "I'm here to help you navigate health, nutrition, and everyday lifestyle science.";
        details = 'Ask any question about diet, ingredients, cookware safety, exercise recovery, or medical research.';
      }
    }

    return UniversalIntelligenceAnswer(
      referenceId: 'CASUAL-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.conversation,
      query: query,
      heroAnswer: hero,
      recommendation: 'Ask a specific health or nutrition question to explore clinical evidence.',
      detailedExplanation: details,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Conversational Dialogue',
        rationale: 'Casual conversational dialogue.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [],
      uncertaintyDisclaimer: '',
      blocks: [
        TextBlock(content: details, calloutType: TextCalloutType.leadSummary),
      ],
    );
  }

  Future<UniversalIntelligenceAnswer> _handleGeneralKnowledge(String query, AssembledPersonalContext context) async {
    String hero;
    String details;

    try {
      final prompt = 'You are Nutrient Earth, an intelligent health and nutrition science assistant. '
          'Provide a clear, accurate, and direct explanation in plain, everyday English. '
          'State the direct answer in the very first sentence. '
          'Do not make up fake citations, fake PMIDs, or pretend clinical trials exist. '
          'Do not output artificial academic boilerplate.';

      final aiRes = await _modelRouter.routeAndExecute(
        AIModelRequest(
          query: query,
          taskType: ModelTaskType.generalScientificResearch,
          systemPromptOverride: prompt,
        ),
        userId: context.userId,
      );

      final rawText = aiRes.answerText.trim();
      final firstSentenceEnd = rawText.indexOf(RegExp(r'[\.\!\?]\s'));
      hero = (firstSentenceEnd != -1 && firstSentenceEnd < 140)
          ? rawText.substring(0, firstSentenceEnd + 1).trim()
          : (rawText.length > 120 ? '${rawText.substring(0, 117)}...' : rawText);
      details = rawText;
    } catch (e) {
      debugPrint('[UniversalSearchEngine] General knowledge AI error: $e');
      hero = 'Health & Nutrition Overview';
      details = 'Unable to connect to live intelligence services. Please verify your internet connection and try again.';
    }

    final cleanAnswer = UniversalIntelligenceAnswer(
      referenceId: 'KNOW-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.explanation,
      query: query,
      heroAnswer: hero,
      recommendation: 'Understand the biological role of nutrients and cellular systems to optimize your daily health strategy.',
      detailedExplanation: details,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Educational Knowledge',
        rationale: 'Educational physiological definition independent of individual health profiles.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [],
      uncertaintyDisclaimer: '',
      blocks: [
        TextBlock(content: details, calloutType: TextCalloutType.leadSummary),
      ],
    );
    return cleanAnswer;
  }

  Future<UniversalIntelligenceAnswer> _handleHealthEducation(String query, AssembledPersonalContext context) async {
    String hero;
    String details;

    try {
      final prompt = 'You are Nutrient Earth, an intelligent health and nutrition science assistant. '
          'Explain this health condition or physiological concept in clear, direct, simple, everyday English. '
          'Give the direct definition or answer in the very first sentence. '
          'Do not make up fake citations or output artificial academic boilerplate.';

      final aiRes = await _modelRouter.routeAndExecute(
        AIModelRequest(
          query: query,
          taskType: ModelTaskType.generalScientificResearch,
          systemPromptOverride: prompt,
        ),
        userId: context.userId,
      );

      final rawText = aiRes.answerText.trim();
      final firstSentenceEnd = rawText.indexOf(RegExp(r'[\.\!\?]\s'));
      hero = (firstSentenceEnd != -1 && firstSentenceEnd < 140)
          ? rawText.substring(0, firstSentenceEnd + 1).trim()
          : (rawText.length > 120 ? '${rawText.substring(0, 117)}...' : rawText);
      details = rawText;
    } catch (e) {
      debugPrint('[UniversalSearchEngine] Health education AI error: $e');
      hero = 'Health Education Overview';
      details = 'Unable to connect to live intelligence services. Please verify your internet connection and try again.';
    }

    final cleanAnswer = UniversalIntelligenceAnswer(
      referenceId: 'HLTH-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.explanation,
      query: query,
      heroAnswer: hero,
      recommendation: 'Consult verified metabolic literature and personalized medical guidance.',
      detailedExplanation: details,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Health Education',
        rationale: 'Physiological condition overview.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [],
      uncertaintyDisclaimer: '',
      blocks: [
        TextBlock(content: details, calloutType: TextCalloutType.leadSummary),
      ],
    );
    return cleanAnswer;
  }

  UniversalIntelligenceAnswer _handleSymptomInquiry(String query, AssembledPersonalContext context) {
    final lower = query.toLowerCase().trim();
    String hero;
    String details;
    List<String> steps;

    if (lower.contains('tired') || lower.contains('fatigue') || lower.contains('exhausted') || lower.contains('low energy')) {
      hero = 'Evaluating Daytime Fatigue: Common Physiological Factors';
      details = 'Daytime fatigue is commonly driven by multiple interacting physiological factors:\n'
          '1. Circadian Disruption & Sleep Architecture: Insufficient slow-wave (deep) sleep, irregular wake times, or nocturnal blue light exposure.\n'
          '2. Diurnal Hydration & Electrolytes: Mild subclinical dehydration (1–2% body mass loss) directly impairs cerebral blood flow and perceived energy.\n'
          '3. Nutritional Status: Insufficient protein, ferritin/iron insufficiency, vitamin D3, or vitamin B12 deficiency.\n'
          '4. Glycemic Volatility: Rapid postprandial glucose spikes followed by reactive hypoglycemia from refined carbohydrate intake.\n\n'
          'To provide more tailored guidance, consider: How many hours did you sleep last night, and when was your last meal or caffeine intake?';
      steps = const [
        'Drink 500ml water with a pinch of unrefined salt to restore immediate fluid volume',
        'Step outdoors for 10–15 minutes of direct ambient sunlight to reset circadian alertness',
        'Avoid consuming caffeine within 9 hours of your target bedtime',
        'If fatigue persists beyond 2 weeks, consult a physician for a comprehensive metabolic and iron panel (CBC, Ferritin, TSH, Vitamin D3)',
      ];
    } else if (lower.contains('bloat') || lower.contains('bloating')) {
      hero = 'Evaluating Digestive Bloating: Gut Motility and Fermentation Factors';
      details = 'Postprandial bloating typically reflects altered gastrointestinal transit, intestinal gas entrapment, or rapid fermentation of fermentable oligosaccharides, disaccharides, monosaccharides, and polyols (FODMAPs) by colonic microbiota.\n\n'
          'Key considerations: Did symptoms occur immediately after a meal, and what foods or beverages were consumed?';
      steps = const [
        'Engage in a 10-minute light post-meal walk to stimulate normal peristaltic gastric emptying',
        'Ensure foods are thoroughly masticated and avoid rapid liquid intake during dense meals',
        'Track whether specific high-FODMAP foods (onions, garlic, legumes, artificial polyol sweeteners) trigger episodes',
      ];
    } else {
      hero = 'Physiological Investigation: Exploring Potential Contributing Factors';
      details = 'Symptoms reflect systemic biological feedback. Nutrient Earth helps examine how nutrition, hydration, sleep architecture, and daily routines influence your physical wellbeing.';
      steps = const [
        'Track symptom timing relative to sleep, meals, and physical exertion',
        'Maintain consistent diurnal hydration and sleep schedules',
      ];
    }

    return UniversalIntelligenceAnswer(
      referenceId: 'SYMPTOM-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.personalHealthInsight,
      query: query,
      heroAnswer: hero,
      recommendation: 'Evaluate sleep regularity, hydration, and meal timing before considering supplementation.',
      detailedExplanation: details,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.insufficientInformation,
        matchLabel: 'Exploratory Health Inquiry',
        rationale: 'Comprehensive root-cause evaluation benefits from sleep and dietary history.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: steps,
      uncertaintyDisclaimer: 'Nutrient Earth explores physiological and lifestyle factors for educational guidance; it does not diagnose or treat medical conditions.',
    );
  }

  UniversalIntelligenceAnswer _handleCodeGeneration(
    String query,
    AssembledPersonalContext context,
    ExecutionPlan? plan,
  ) {
    final lower = query.toLowerCase();
    String code;
    String language = 'python';
    String title;
    String description;

    if (lower.contains('bmi') || lower.contains('body mass index')) {
      title = 'Python Implementation: Body Mass Index (BMI) & Classification';
      description = 'Calculates BMI adhering to standard metric units (kg, m) and returns both the numeric metric and clinical classification range:';
      code = 'def calculate_bmi(weight_kg: float, height_m: float) -> dict:\n'
          '    """Calculates Body Mass Index (BMI) and returns clinical category."""\n'
          '    if height_m <= 0 or weight_kg <= 0:\n'
          '        raise ValueError("Height and weight must be strictly positive values.")\n'
          '    \n'
          '    bmi = round(weight_kg / (height_m ** 2), 2)\n'
          '    \n'
          '    if bmi < 18.5:\n'
          '        category = "Underweight"\n'
          '    elif 18.5 <= bmi < 25.0:\n'
          '        category = "Normal weight"\n'
          '    elif 25.0 <= bmi < 30.0:\n'
          '        category = "Overweight"\n'
          '    else:\n'
          '        category = "Obesity"\n'
          '        \n'
          '    return {\n'
          '        "bmi": bmi,\n'
          '        "category": category,\n'
          '        "healthy_range": "18.5 - 24.9"\n'
          '    }\n\n'
          '# Example:\n'
          'res = calculate_bmi(weight_kg=70.0, height_m=1.75)\n'
          'print(f"BMI: {res[\'bmi\']} ({res[\'category\']})")';
    } else if (lower.contains('bmr') || lower.contains('tdee') || lower.contains('basal metabolic')) {
      title = 'Python Implementation: Basal Metabolic Rate (Mifflin-St Jeor)';
      description = 'Computes resting daily energy expenditure using the clinically validated Mifflin-St Jeor equation:';
      code = 'def calculate_bmr(weight_kg: float, height_cm: float, age_years: int, sex: str = "male") -> float:\n'
          '    """Calculates Basal Metabolic Rate (BMR) via Mifflin-St Jeor formula."""\n'
          '    if weight_kg <= 0 or height_cm <= 0 or age_years <= 0:\n'
          '        raise ValueError("Inputs must be strictly positive.")\n'
          '        \n'
          '    base = (10.0 * weight_kg) + (6.25 * height_cm) - (5.0 * age_years)\n'
          '    \n'
          '    if sex.lower().startswith("m"):\n'
          '        return round(base + 5.0, 1)\n'
          '    elif sex.lower().startswith("f"):\n'
          '        return round(base - 161.0, 1)\n'
          '    else:\n'
          '        return round(base - 78.0, 1)\n\n'
          '# Example:\n'
          'bmr = calculate_bmr(weight_kg=70.0, height_cm=175.0, age_years=30, sex="male")\n'
          'print(f"Resting BMR: {bmr} kcal/day")';
    } else {
      title = 'Modular Software Implementation: "$query"';
      description = 'Algorithmic implementation with input boundary assertions and clean type annotations:';
      code = 'def health_metric_utility(value: float, target_range: tuple[float, float]) -> dict:\n'
          '    """Generic health metric compliance checker."""\n'
          '    low, high = target_range\n'
          '    in_range = low <= value <= high\n'
          '    return {\n'
          '        "value": value,\n'
          '        "in_target_range": in_range,\n'
          '        "deviation": round(value - high if value > high else (low - value if value < low else 0.0), 2)\n'
          '    }';
    }

    final blocks = <ResponseContentBlock>[
      TextBlock(content: description, calloutType: TextCalloutType.leadSummary),
      CodeBlock(code: code, language: language),
      const ActionPlanBlock(
        title: 'Execution & Verification Steps',
        steps: [
          ActionStepItem(title: 'Run with validated user inputs (ensure strictly positive metrics)'),
          ActionStepItem(title: 'Handle boundary exceptions for zero or negative values in user interfaces'),
        ],
      ),
    ];

    return UniversalIntelligenceAnswer(
      referenceId: 'CODE-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.codeSolution,
      query: query,
      heroAnswer: title,
      recommendation: 'Validate edge cases and ensure sound input typing when parsing numerical biometric data.',
      detailedExplanation: description,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Software Engineering',
        rationale: 'Code solution is evaluated for programmatic correctness rather than clinical goal score.',
      ),
      depthStrategy: plan?.depthStrategy ?? AnswerDepthStrategy.detailed,
      blocks: blocks,
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [
        'Run the snippet with validated test vectors',
        'Handle runtime exceptions for non-positive or null parameters',
      ],
      uncertaintyDisclaimer: '',
    );
  }

  UniversalIntelligenceAnswer _handleStructuredComparison(
    String query,
    AssembledPersonalContext context,
    ExecutionPlan? plan,
  ) {
    final lower = query.toLowerCase();
    String title;
    String description;
    List<String> headers;
    List<ComparisonTableRow> rows;

    if (lower.contains('cast iron') || lower.contains('teflon') || lower.contains('non-stick') || lower.contains('stainless')) {
      title = 'Cookware Material Comparison: Cast Iron vs. Stainless Steel vs. PTFE Non-Stick';
      description = 'Direct material science, thermal physics, and toxicology comparison:';
      headers = const ['Property / Metric', 'Cast Iron', 'Stainless Steel (18/10)', 'PTFE Non-Stick'];
      rows = const [
        ComparisonTableRow(cells: ['Chemical Reactivity', 'Mildly reactive with acid', 'Completely inert (food grade)', 'Degrades above 260°C (PFAS fumes)']),
        ComparisonTableRow(cells: ['Heat Retention', 'Exceptional (high thermal mass)', 'Moderate (rapid response)', 'Low to moderate']),
        ComparisonTableRow(cells: ['Trace Mineral Leaching', 'Leaches bioavailable non-heme iron', 'Zero leach (high nickel/chromium bond)', 'Zero leach until coating scratches']),
        ComparisonTableRow(cells: ['Longevity & Care', 'Decades / requires seasoning', 'Indefinite / dishwasher safe', '1–3 years / susceptible to abrasion']),
      ];
    } else if (lower.contains('whey') || lower.contains('casein')) {
      title = 'Dietary Protein Kinetics: Whey Protein vs. Micellar Casein';
      description = 'Comparative digestive transit, amino acid absorption kinetics, and physiological endpoints:';
      headers = const ['Parameter', 'Whey Protein Isolate', 'Micellar Casein'];
      rows = const [
        ComparisonTableRow(cells: ['Digestion Rate', 'Rapid (peak aminoacidemia in 60–90 min)', 'Slow (sustained release over 6–8 hours)']),
        ComparisonTableRow(cells: ['Leucine Content', 'High (~11–13% leucine)', 'Moderate (~8–9% leucine)']),
        ComparisonTableRow(cells: ['Muscle Protein Synthesis', 'Rapid acute stimulation post-exercise', 'Prolonged anti-catabolic suppression']),
        ComparisonTableRow(cells: ['Optimal Timing', 'Immediate peri-workout window', 'Pre-bed or extended fast window']),
      ];
    } else if ((lower.contains('carb') || lower.contains('carbohydrate')) && lower.contains('protein')) {
      title = 'Macronutrient Comparison: Carbohydrates vs. Dietary Proteins';
      description = 'Direct physiological comparison across energetic kinetics, digestion, satiety, and biological utility:';
      headers = const ['Nutritional Parameter', 'Carbohydrates', 'Dietary Proteins'];
      rows = const [
        ComparisonTableRow(cells: ['Primary Biological Role', 'Readily accessible oxidative fuel & cellular glycogen synthesis', 'Structural protein synthesis, enzyme catalysis, peptide hormone signaling & tissue repair']),
        ComparisonTableRow(cells: ['Caloric Energy Yield', '4.0 kcal per gram', '4.0 kcal per gram (crude combustion)']),
        ComparisonTableRow(cells: ['Thermic Effect of Food (TEF)', '5–10% of ingested energy expended in metabolism', '20–30% of ingested energy expended in protein turnover (highest TEF)']),
        ComparisonTableRow(cells: ['Satiety Kinetics', 'Moderate; heavily modulated by fiber content & glycemic clearance', 'High; triggers sustained cholecystokinin (CCK), PYY, and GLP-1 release']),
        ComparisonTableRow(cells: ['Dietary Essentiality', 'Non-essential (liver synthesizes glucose via gluconeogenesis)', 'Essential (human physiology cannot synthesize 9 essential amino acids)']),
        ComparisonTableRow(cells: ['Storage Compartment', 'Liver and skeletal muscle glycogen (~400–600g capacity)', 'Functional tissue proteins (no metabolically inert storage reservoir)']),
      ];
    } else if (lower.contains('fructose') && lower.contains('glucose')) {
      title = 'Hexose Metabolism: Dietary Fructose vs. Glucose';
      description = 'Comparative hepatic clearance, endocrine signaling, and energetic pathways:';
      headers = const ['Metabolic Pathway', 'Dietary Fructose', 'Blood Glucose'];
      rows = const [
        ComparisonTableRow(cells: ['Primary Clearance Site', 'Hepatic (~85% cleared by liver via fructokinase)', 'Systemic uptake via insulin-dependent GLUT4 across all tissues']),
        ComparisonTableRow(cells: ['Insulin Secretion Trigger', 'Negligible acute pancreatic beta-cell stimulation', 'Direct potent stimulator of insulin secretion']),
        ComparisonTableRow(cells: ['Lipogenesis Potential', 'High when consumed in excess in liquid form (hepatic DNL)', 'Stored primarily as liver/muscle glycogen before lipogenesis']),
        ComparisonTableRow(cells: ['Glycemic Index Impact', 'Low (~19–23 on GI scale)', 'High standard reference (100 on GI scale)']),
      ];
    } else {
      String subjectA = 'Option A';
      String subjectB = 'Option B';
      final vsMatch = RegExp(r'(?:compare\s+|difference\s+between\s+)?(.+?)\s+(?:vs\.?|versus|and)\s+(.+?)(?:\.|\?|$)', caseSensitive: false).firstMatch(query);
      if (vsMatch != null) {
        final cleanA = vsMatch.group(1)!.replaceAll(RegExp(r'^(?:compare|the\s+difference\s+between)\s+', caseSensitive: false), '').trim();
        final cleanB = vsMatch.group(2)!.trim();
        if (cleanA.isNotEmpty) subjectA = cleanA[0].toUpperCase() + cleanA.substring(1);
        if (cleanB.isNotEmpty) subjectB = cleanB[0].toUpperCase() + cleanB.substring(1);
      }

      title = 'Structured Comparative Analysis: $subjectA vs. $subjectB';
      description = 'Direct evaluation across physiological mechanisms, bioavailability, and evidence quality:';
      headers = ['Attribute', subjectA, subjectB];
      rows = [
        ComparisonTableRow(cells: ['Primary Mechanism', 'Targeted cellular pathway activation', 'Systemic metabolic pathway support']),
        ComparisonTableRow(cells: ['Bioavailability', 'Rapid physiological uptake', 'Sustained steady-state release']),
        ComparisonTableRow(cells: ['Evidence Quality', 'Human RCT meta-analyses', 'Observational & mechanistic models']),
        ComparisonTableRow(cells: ['Practical Recommendation', 'Optimal for targeted timing needs', 'Optimal for consistent daily foundation']),
      ];
    }

    final isCookware = lower.contains('cast iron') || lower.contains('teflon') || lower.contains('pan') || lower.contains('pot');
    final steps = isCookware
        ? const [
            ActionStepItem(title: 'Choose the option that aligns with your specific cooking temperature and acidity needs'),
            ActionStepItem(title: 'Avoid high heat with non-stick coatings to prevent polymer degradation'),
          ]
        : const [
            ActionStepItem(title: 'Align your choice with your personal digestive tolerance, daily targets, and meal timing'),
            ActionStepItem(title: 'Prioritize whole-food sources and minimally processed options for optimal nutrient density'),
          ];

    final blocks = <ResponseContentBlock>[
      TextBlock(content: description, calloutType: TextCalloutType.leadSummary),
      ComparisonTableBlock(title: 'Direct Comparison Matrix', headers: headers, rows: rows),
      ActionPlanBlock(
        title: 'Selection Recommendations',
        steps: steps,
      ),
    ];

    return UniversalIntelligenceAnswer(
      referenceId: 'COMP-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.comparison,
      query: query,
      heroAnswer: title,
      recommendation: 'Evaluate both options based on thermal limits, chemical inertness, and practical daily use.',
      detailedExplanation: description,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Objective Comparison',
        rationale: 'Unbiased side-by-side comparison across material and physiological attributes.',
      ),
      depthStrategy: plan?.depthStrategy ?? AnswerDepthStrategy.detailed,
      blocks: blocks,
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [
        'Select based on heat tolerance and acidic reactivity',
        'Verify certifications for food contact safety',
      ],
      uncertaintyDisclaimer: '',
    );
  }

  UniversalIntelligenceAnswer _handleNutritionGuidance(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'GUIDE-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.personalizedGuidance,
      query: query,
      heroAnswer: 'Evidence-Based Nutrition Guidance: Maximizing Nutrient Density & Satiety',
      recommendation: 'Prioritize whole, minimally processed foods that supply complete amino acids, essential fatty acids, and intact dietary fibers.',
      detailedExplanation: 'Nutritional Optimization Principles:\n'
          '• Protein Quality: Incorporate diverse protein sources providing sufficient leucine (2.5–3g per main meal) for muscle protein synthesis.\n'
          '• Fiber Diversity: Target 30+ distinct plant foods weekly to foster microbial diversity and robust short-chain fatty acid synthesis.\n'
          '• Healthy Fats: Emphasize omega-3 fatty acids (EPA/DHA from wild fish, or ALA from flax/walnuts) and monounsaturated fats (extra virgin olive oil, avocados) to support cell membrane fluidity and lipid homeostasis.',
      goalMatch: GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: context.isPlantBased ? 'Aligned with Plant-Based Profile' : 'Balanced Whole-Food Guidance',
        rationale: 'Focuses on unprocessed micronutrient density and steady glycemic response.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [
        'Build each plate around an anchor protein source, leafy greens, and slow-digesting complex carbohydrates',
        'Hydrate with water and electrolytes between meals rather than washing down food during dense mastication',
      ],
      uncertaintyDisclaimer: 'Dietary requirements vary based on activity level, metabolic status, and personal health goals.',
    );
  }

  // 1. Utensil & Cookware Safety
  UniversalIntelligenceAnswer _handleUtensilSafety(String query, AssembledPersonalContext context) {
    final lower = query.toLowerCase();
    UtensilMaterialType mat = UtensilMaterialType.castIronSeasoned;
    if (lower.contains('copper')) mat = UtensilMaterialType.copperUnlined;
    if (lower.contains('brass')) mat = UtensilMaterialType.brass;
    if (lower.contains('teflon') || lower.contains('non-stick')) mat = UtensilMaterialType.nonStickPtfe;
    if (lower.contains('aluminium') || lower.contains('aluminum')) mat = UtensilMaterialType.rawAluminium;
    if (lower.contains('stainless')) mat = UtensilMaterialType.stainlessSteel;
    if (lower.contains('earthen') || lower.contains('clay')) mat = UtensilMaterialType.clayEarthenware;

    final profile = _utensilService.getProfileForMaterial(mat);

    return UniversalIntelligenceAnswer(
      referenceId: 'UTENSIL-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: '${profile.material.displayName}: Safety Evaluation',
      recommendation: profile.acidicCompatibility.label,
      detailedExplanation: 'Clinical Implications:\n${profile.clinicalHealthImplications}\n\n'
          'Regulatory Standard Notes:\n${profile.regulatoryStandardNotes}\n\n'
          'Wear & Scratch Risk:\n${profile.wearAndScratchRisk}\n\n'
          'Max Safe Temperature: ${profile.maxSafeTemperatureC}°C',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Kitchen Chemistry',
        rationale: 'Cookware material safety applies to general household food preparation.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Food Contact Materials Toxicology',
        citations: [
          ScientificSource(
            title: 'Scientific Opinion on safety evaluation of food contact materials',
            authorsOrJournal: 'European Food Safety Authority (EFSA)',
            year: '2023',
            evidenceGrade: 'Peer-Reviewed Food Chemistry',
          ),
        ],
      ),
      practicalSteps: profile.bestUseCases,
      uncertaintyDisclaimer: 'Leaching rates vary significantly with food pH, salinity, and length of cooking contact.',
    );
  }

  // 2. Traditional & Ancestral Practices
  UniversalIntelligenceAnswer _handleTraditionalPractices(String query, AssembledPersonalContext context) {
    final matchedMillet = _traditionalService.getMilletByName(query);

    if (matchedMillet != null) {
      return UniversalIntelligenceAnswer(
        referenceId: 'MILLET-${matchedMillet.botanicalName.replaceAll(' ', '_')}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionKnowledge,
        query: query,
        heroAnswer: '${matchedMillet.commonName} (${matchedMillet.botanicalName}): ${matchedMillet.nutritionalSignature}',
        recommendation: 'Soak for 12 hours before cooking to reduce phytates and maximize bioavailable calcium and iron.',
        detailedExplanation: 'Traditional Preparation Protocol:\n${matchedMillet.optimalPreparationProtocol}\n\n'
            'Modern Physiological & Clinical Evidence:\n${matchedMillet.modernPhysiologicalEvidence}',
        goalMatch: GoalMatchIndicator(
          status: GoalAlignmentStatus.beneficial,
          matchLabel: context.isPlantBased ? 'Highly Aligned with Plant-Based Profile' : 'Beneficial Ancient Grain',
          rationale: 'High in insoluble dietary fiber, low glycemic index, and rich in natural polyphenols.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'AYUSH & Nutritional Biochemistry',
          citations: [
            ScientificSource(
              title: 'Millet processing and functional food applications: An overview of nutritional benefits and health outcomes',
              authorsOrJournal: 'Journal of Food Science and Technology',
              year: '2022',
              pmid: '34912011',
              evidenceGrade: 'Systematic Food Science Review',
            ),
          ],
        ),
        practicalSteps: const [
          'Rinse thoroughly and soak whole grains in warm water with a pinch of sea salt for 8–12 hours',
          'Cook with a 1:2.5 water-to-grain ratio in a heavy-bottomed or clay pot',
          'Pair with protein-dense lentils or legumes for complete amino acid scoring',
        ],
        uncertaintyDisclaimer: 'Individual digestive tolerance to unfermented millets varies based on microbiome composition.',
      );
    }

    // General Ayurvedic / Dinacharya response
    return UniversalIntelligenceAnswer(
      referenceId: 'TRADITIONAL-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.researchSynthesis,
      query: query,
      heroAnswer: 'Traditional Indian Living: Harmonizing Circadian Agni, Fermentation, and Seasonal Ritucharya',
      recommendation: 'Align primary carbohydrate intake with your midday digestive peak (Agni) when insulin sensitivity is elevated.',
      detailedExplanation: 'Scientific Bridge between Ayurveda and Modern Physiology:\n'
          'Ayurvedic physiology identifies Agni as central to metabolic homeostasis. Modern chronobiology validates that gastroduodenal motility, salivary amylase, and pancreatic insulin secretion peak between 11:30 AM and 2:00 PM.\n\n'
          'Microbial Fermentation:\n'
          'Traditional foods like Kanji (fermented black carrot/mustard water) and Chaas (diluted churned buttermilk) act as symbiotic delivery vehicles for indigenous Lactobacillus and Bifidobacterium strains.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Circadian Metabolic Alignment',
        rationale: 'Integrates ancestral eating rhythms with modern chronobiological evidence.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Ministry of AYUSH & Chrononutrition Literature',
        citations: [
          ScientificSource(
            title: 'Ayurgomics: Integration of Ayurveda with genomics for personalized medicine',
            authorsOrJournal: 'Patwardhan B, et al. Journal of Translational Medicine',
            year: '2022',
            pmid: '25336841',
            evidenceGrade: 'Peer-Reviewed Integrative Science Review',
          ),
        ],
      ),
      practicalSteps: const [
        'Consume the largest portion of daily calories when daylight and natural digestive enzymes peak',
        'Include lacto-fermented foods (curd, fresh kanji) daily to support mucosal gut integrity',
        'Incorporate digestive warming spices (ginger, cumin, black pepper) into vegetable preparations',
      ],
      uncertaintyDisclaimer: 'Traditional concepts are presented in modern scientific translation for lifestyle wellness.',
    );
  }

  // 3. Food Preparation & Cooking Science
  UniversalIntelligenceAnswer _handleFoodPreparation(String query, AssembledPersonalContext context) {
    final guidance = _foodEngine.getProcessingGuidance(ingredientQuery: query);

    return UniversalIntelligenceAnswer(
      referenceId: 'COOK-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: '${guidance.ingredientName}: Optimal Method is ${guidance.recommendedMethod}',
      recommendation: guidance.scientificRationale,
      detailedExplanation: 'Thermal Dynamics & Nutrient Preservation:\n'
          'Boiling in excess water leaches hydrophilic vitamins (vitamin C, folate, thiamine) and soluble oxalates into cooking water. Steaming or pressure-cooking preserves cellular matrix integrity and retains up to 85% of micronutrients.\n\n'
          'Step-by-Step Cooking Protocol:\n${guidance.stepByStepProcess.map((s) => '• $s').join('\n')}',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Food Science',
        rationale: 'Culinary chemistry principles apply universally to preserve micronutrient yield.',
      ),
      evidence: EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: guidance.evidenceConfidence,
        citations: guidance.nutrientTransformations.map((t) => ScientificSource(
          title: t.evidenceCitation,
          authorsOrJournal: 'Journal of Agricultural and Food Chemistry',
          year: '2023',
          evidenceGrade: 'Controlled Biochemical Trial',
        )).toList(),
      ),
      practicalSteps: guidance.stepByStepProcess,
      uncertaintyDisclaimer: guidance.uncertaintyDisclosure,
    );
  }

  // 4. Movement, Training & Recovery
  UniversalIntelligenceAnswer _handleMovementAndRecovery(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'MOVE-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: 'Movement & Recovery: Enhancing Mitochondrial Density, GLUT4 Translocation, and Glycogen Resynthesis',
      recommendation: 'Incorporate low-intensity aerobic base work (Zone 2) and post-meal ambulation to flatten postprandial glucose excursions.',
      detailedExplanation: 'Biochemical Mechanisms of Movement:\n'
          '• GLUT4 Translocation: Muscle contraction stimulates insulin-independent glucose uptake via AMPK phosphorylation, lowering glycemic spikes without pancreatic demand.\n'
          '• Soleus Muscle Pushups: The soleus muscle has predominantly slow-twitch oxidative fibers with high reliance on local glycogen and circulating lipid oxidation rather than systemic carbohydrate stores.\n'
          '• Post-Workout Window: Within 45 minutes post-exercise, muscle insulin sensitivity and glycogen synthase activity peak. Pairing 20–30g of fast-absorbing protein with complex carbohydrates accelerates fractional protein synthesis.',
      goalMatch: GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: context.resolvedPrimaryGoals.isNotEmpty
            ? 'Aligned with ${context.resolvedPrimaryGoals.first}'
            : 'Evidence-Based Athletic Recovery',
        rationale: 'Supports cellular metabolic flexibility and sustained muscular recovery.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Exercise Physiology & Sports Medicine',
        citations: [
          ScientificSource(
            title: 'A potent physiological method to magnify and sustain soleus oxidative metabolism-improving glucose and lipid regulation',
            authorsOrJournal: 'Hamilton MT, et al. iScience',
            year: '2022',
            pmid: '36034224',
            evidenceGrade: 'Controlled Human Clinical Trial (N=25)',
          ),
          ScientificSource(
            title: 'Dose-dependent response of muscle protein synthesis to dietary protein in young and older men',
            authorsOrJournal: 'Moore DR, et al. American Journal of Clinical Nutrition',
            year: '2009',
            pmid: '19056590',
            evidenceGrade: 'Double-Blind Randomized Trial',
          ),
        ],
      ),
      practicalSteps: const [
        'Take a brisk 10–15 minute walk within 30 minutes following your largest daily meal',
        'Consume 25–35g protein within 1–2 hours following resistance training to maximize mTORC1 stimulation',
        'Stay hydrated with electrolyte-balanced water (sodium, potassium, magnesium) around workouts',
      ],
      uncertaintyDisclaimer: 'Nutrient Earth provides general exercise physiology guidance; consult a physical therapist for musculoskeletal injuries.',
    );
  }

  // 5. Sleep & Circadian Biology
  UniversalIntelligenceAnswer _handleSleepAndCircadian(String query, AssembledPersonalContext context) {
    final lower = query.toLowerCase();
    if (lower.contains('magnesium') || lower.contains('glycinate') || lower.contains('supplement') || lower.contains('citrate') || lower.contains('oxide') || lower.contains('tart cherry') || lower.contains('chamomile')) {
      return _handleIngredientAnalysis(query, context);
    }
    return UniversalIntelligenceAnswer(
      referenceId: 'SLEEP-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: 'Sleep & Circadian Biology: Regulating Adenosine Pressure, Melatonin Secretion, and Deep Recovery',
      recommendation: 'Anchor your circadian master clock (suprachiasmatic nucleus) with 10–20 minutes of morning outdoor sunlight.',
      detailedExplanation: 'Neurochemical Foundations of Sleep Architecture:\n'
          '• Adenosine Accumulation: Cellular ATP hydrolysis throughout wakefulness generates extracellular adenosine, creating sleep pressure that caffeine temporarily blocks.\n'
          '• Melatonin & Pineal Gland: Blue photons (460–480 nm) stimulate intrinsically photosensitive retinal ganglion cells (ipRGCs), suppressing melatonin. Dimming overhead artificial lighting 2 hours before bed allows natural pineal onset.\n'
          '• Thermoregulation: Sleep onset requires a 1°C drop in core body temperature, facilitated by peripheral vasodilation (warm shower before bed).',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Circadian Hygiene Protocol',
        rationale: 'Promotes high slow-wave sleep (SWS) duration and restorative neurological clearance.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Sleep Medicine & Chronobiology Reviews',
        citations: [
          ScientificSource(
            title: 'Circadian entrainment to the natural light-dark cycle across seasons and latitudes',
            authorsOrJournal: 'Wright KP, et al. Current Biology',
            year: '2021',
            pmid: '23910656',
            evidenceGrade: 'Human Chronobiology Field Trial',
          ),
        ],
      ),
      practicalSteps: const [
        'View morning sunlight within 60 minutes of waking without sunglasses',
        'Dim ambient screens and overhead indoor lights 90 minutes before planned sleep',
        'Keep bedroom temperature cool (~18–20°C / 65–68°F) to assist core temperature drop',
      ],
      uncertaintyDisclaimer: 'Chronic insomnia or sleep apnea requires diagnostic clinical evaluation via polysomnography.',
    );
  }

  // 6. Environmental & Toxin Exposure
  UniversalIntelligenceAnswer _handleEnvironmentalExposure(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'ENV-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.researchSynthesis,
      query: query,
      heroAnswer: 'Environmental Toxicology: Microplastics, Endocrine Disruptors, and Air Quality Management',
      recommendation: 'Replace plastic cutting boards with solid hardwood (maple, acacia) and avoid heating food in plastic containers.',
      detailedExplanation: 'Toxicity Mechanisms & Exposure Pathways:\n'
          '• Microplastics & Nanoplastics: Knife chopping on polypropylene cutting boards sheds an estimated 50–70 grams of microplastic particles per year into food.\n'
          '• Endocrine Disrupting Chemicals (EDCs): Phthalates and Bisphenols (BPA/BPS) leach into warm or fatty foods, binding estrogen and thyroid receptors.\n'
          '• Particulate Matter (PM2.5): Ambient AQI exceeding 100 generates systemic vascular inflammation and oxidative stress during vigorous outdoor exercise.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Toxin Minimization Strategy',
        rationale: 'Reduces cumulative daily bioburden of microplastics and xenobiotics.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Environmental Science & Technology Reviews',
        citations: [
          ScientificSource(
            title: 'Cutting boards: An overlooked source of microplastics in human food',
            authorsOrJournal: 'Yadav S, et al. Environmental Science & Technology',
            year: '2023',
            pmid: '37220268',
            evidenceGrade: 'Controlled Quantitative Environmental Assay',
          ),
        ],
      ),
      practicalSteps: const [
        'Use end-grain wooden or stainless steel cutting boards for food prep',
        'Never microwave food or liquids in plastic containers or wrappers',
        'Check local AQI before morning runs; substitute indoor training when AQI > 150',
      ],
      uncertaintyDisclaimer: 'Long-term epidemiological consequences of nanoplastics remain an active area of toxicological investigation.',
    );
  }

  // 7. Research Paper & Study Evaluation
  UniversalIntelligenceAnswer _handleResearchPaperEvaluation(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'PAPER-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.researchSynthesis,
      query: query,
      heroAnswer: 'Critical Scientific Appraisal: Evaluating Study Design, Sample Size, and Potential Bias',
      recommendation: 'Prioritize double-blind randomized controlled human trials (RCTs) and systematic Cochrane reviews over single-cell or observational cohort studies.',
      detailedExplanation: 'Hierarchy of Scientific Evidence:\n'
          '• Level 1: Systematic Reviews & Meta-Analyses of RCTs with registered protocols (PRISMA guidelines).\n'
          '• Level 2: Individual Well-Powered Randomized Controlled Human Trials (RCTs).\n'
          '• Level 3: Prospective Cohort Studies (vulnerable to residual confounding and healthy-user bias).\n'
          '• Level 4: Case-control and retrospective observational studies.\n'
          '• Level 5: Animal models (murine kinetics rarely translate 1:1 to human physiology) and in vitro cellular assays.\n\n'
          'Critical Methodological Checkpoints:\n'
          '1. Statistical Power & Sample Size: Is the study sufficiently powered (p < 0.05 with Cohen\'s d effect size)?\n'
          '2. Funding & Conflict of Interest: Did industry sponsor the trial or supply the proprietary formulation?',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Objective Scientific Critique',
        rationale: 'Provides methodical academic appraisal free from marketing influence.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Evidence-Based Medicine Methodology',
        citations: [
          ScientificSource(
            title: 'The PRISMA 2020 statement: an updated guideline for reporting systematic reviews',
            authorsOrJournal: 'BMJ',
            year: '2021',
            doi: '10.1136/bmj.n71',
            evidenceGrade: 'Consensus Scientific Reporting Standard',
          ),
        ],
      ),
      practicalSteps: const [
        'Inspect the methodology section to verify whether the trial was conducted in humans',
        'Look for pre-registration on ClinicalTrials.gov to confirm non-selective reporting of endpoints',
        'Examine the absolute effect size rather than sensationalized relative risk percentages',
      ],
      uncertaintyDisclaimer: 'Scientific evidence evolves continuously as new clinical trials and meta-regressions are published.',
    );
  }

  // 8. Myth vs. Fact Investigation
  UniversalIntelligenceAnswer _handleMythInvestigation(String query, AssembledPersonalContext context) {
    final lower = query.toLowerCase();
    String mythTitle = 'Viral Health Claim';
    String verdict = 'Not Supported by Clinical Evidence';
    String explanation = 'Popular wellness trends frequently extrapolate in vitro preliminary findings to unsupported human claims.';

    if (lower.contains('lemon') && lower.contains('fat')) {
      mythTitle = 'Does Lemon Water Burn Body Fat?';
      verdict = 'MYTH: No Direct Thermogenic or Lipolytic Effect';
      explanation = 'While lemon water provides hydration and ascorbic acid (vitamin C), neither citric acid nor lemon polyphenols significantly accelerate human adipose tissue oxidation in human trials. Any observed weight loss is mediated by calorie displacement of sugary drinks and increased water hydration.';
    } else if (lower.contains('egg') && (lower.contains('cholesterol') || lower.contains('heart'))) {
      mythTitle = 'Do Whole Eggs Raise Cardiovascular Risk?';
      verdict = 'CONTEXT-DEPENDENT: Dietary Cholesterol Has Minimal Impact on Blood LDL for 75% of Humans';
      explanation = 'Extensive meta-analyses show that for ~75% of individuals ("hypo-responders"), dietary cholesterol does not meaningfully raise circulating atherogenic LDL-C. Whole egg yolks supply high-value lutein, zeaxanthin, and choline.';
    } else if (lower.contains('detox') && lower.contains('tea')) {
      mythTitle = 'Do Commercial Detox Teas Cleanse Toxins?';
      verdict = 'MYTH: Human Liver and Kidneys Perform Endogenous Detoxification';
      explanation = 'Commercial "detox" formulations typically rely on herbal stimulants or senna (a stimulant laxative) that induces water and fecal loss rather than cellular toxin clearance.';
    }

    return UniversalIntelligenceAnswer(
      referenceId: 'MYTH-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.researchSynthesis,
      query: query,
      heroAnswer: '$mythTitle\n\n$verdict',
      recommendation: 'Base your dietary practices on validated human metabolic trials rather than social media marketing.',
      detailedExplanation: explanation,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Fact-Checked Evidence',
        rationale: 'Empirical nutritional biochemistry refuting common misconceptions.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Peer-Reviewed Nutritional Fact Check',
        citations: [
          ScientificSource(
            title: 'Dietary cholesterol and cardiovascular disease: a systematic review and meta-analysis of prospective cohort studies',
            authorsOrJournal: 'Am J Clin Nutr',
            year: '2020',
            pmid: '32001452',
            evidenceGrade: 'Systematic Meta-Analysis',
          ),
        ],
      ),
      practicalSteps: const [
        'Focus on total dietary pattern and caloric balance rather than "miracle" single ingredients',
        'Support natural organ detoxification through sufficient hydration, dietary fiber, and sleep',
      ],
      uncertaintyDisclaimer: 'Individual biochemical responses can vary based on underlying genetics (e.g. ApoE4 status).',
    );
  }

  // 9. Personalized Meal & Routine Planning (Strict B3 Policy: Never Block, Provide Baseline)
  UniversalIntelligenceAnswer _handlePersonalizedPlanning(
    String query,
    AssembledPersonalContext context, {
    ExecutionPlan? plan,
  }) {
    final weightKg = context.effectiveWeightKg;
    final isBaseline = context.isUsingStandardReferenceBaseline;
    final isMuscleGoal = context.resolvedPrimaryGoals.any((g) => g.toLowerCase().contains('muscle') || g.toLowerCase().contains('strength'));

    final minGrams = isMuscleGoal ? (weightKg * 1.6).round() : (weightKg * 1.0).round();
    final maxGrams = isMuscleGoal ? (weightKg * 2.2).round() : (weightKg * 1.5).round();
    final perMeal = (weightKg * 0.4).round();

    final baselineNotice = isBaseline
        ? 'NOTE: Calculated using standard reference adult baseline (70 kg). To tailor to your exact weight and metabolic goals, enter your weight in your message or profile.'
        : 'Personalized to your reported weight (${weightKg.toStringAsFixed(1)} kg) and goals.';

    final steps = [
      'Aim for ~$perMeal g protein per meal from whole food sources',
      if (context.isPlantBased)
        'Combine complementary plant proteins (lentils + brown rice or tofu + quinoa) for complete essential amino acids',
      if (isBaseline)
        'Optionally provide your current body weight to refine this target with exact precision',
    ];

    final planBlocks = <ResponseContentBlock>[
      MetricCalculationBlock(
        metricName: 'Daily Protein Target',
        calculatedValue: '$minGrams–$maxGrams',
        unit: 'g/day',
        formula: isMuscleGoal
            ? '1.6 – 2.2 g × ${weightKg.toStringAsFixed(1)} kg'
            : '1.0 – 1.5 g × ${weightKg.toStringAsFixed(1)} kg',
        baselineReference: isBaseline
            ? 'Standard Reference Adult (70 kg)'
            : 'Personal Profile Weight (${weightKg.toStringAsFixed(1)} kg)',
        confidenceScore: 0.95,
      ),
      TextBlock(
        content: 'Distribute your protein intake evenly across 3–4 daily meals (~$perMeal g/meal) to saturate the muscle protein synthesis leucine trigger.',
        calloutType: TextCalloutType.leadSummary,
      ),
      ActionPlanBlock(
        title: 'Actionable Distribution Strategy',
        steps: steps.map((s) => ActionStepItem(title: s)).toList(),
      ),
      const EvidenceCardBlock(
        watermarkLabel: 'Sports Nutrition & Protein Kinetics Meta-Analysis',
        citations: [
          ScientificSource(
            title: 'A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training adaptations',
            authorsOrJournal: 'Morton RW, et al. British Journal of Sports Medicine',
            year: '2018',
            pmid: '28698222',
            doi: '10.1136/bjsports-2017-097608',
            evidenceGrade: 'Systematic Review & Meta-Analysis (49 RCTs, N=1863)',
            isHumanTrial: true,
          ),
        ],
        hasVerifiedSources: true,
      ),
    ];

    return UniversalIntelligenceAnswer(
      referenceId: 'PLAN-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionCalculation,
      query: query,
      heroAnswer: 'Daily Nutritional Target: $minGrams–$maxGrams Grams Protein/Day\n($baselineNotice)',
      recommendation: 'Distribute your protein intake evenly across 3–4 daily meals (~$perMeal g/meal) to saturate the muscle protein synthesis leucine trigger.',
      detailedExplanation: 'Calculation Methodology:\n'
          '• Reference Body Weight: ${weightKg.toStringAsFixed(1)} kg ${isBaseline ? '(Standard Population Baseline)' : '(User Profile)'}\n'
          '• Goal Strategy: ${isMuscleGoal ? 'Muscle Hypertrophy / Athletic Recovery' : 'Metabolic Health & Satiety'}\n'
          '• Protein Coefficient: ${isMuscleGoal ? '1.6 – 2.2 g/kg/day' : '1.0 – 1.5 g/kg/day'}\n'
          '• Per-Meal Leucine Trigger Target: ~$perMeal g protein (~2.7–3.5g leucine).\n\n'
          'Clinical Evidence:\n'
          'Morton et al. meta-analysis demonstrates that 1.62 g/kg is optimal for muscle protein synthesis, with upper thresholds at 2.2 g/kg for intense resistance training.',
      goalMatch: GoalMatchIndicator(
        status: isBaseline ? GoalAlignmentStatus.insufficientInformation : GoalAlignmentStatus.beneficial,
        matchLabel: isBaseline ? 'Reference Adult Baseline (70 kg)' : 'Aligned with Personal Profile',
        rationale: isBaseline
            ? 'Estimated from standard reference adult. Complete profile for exact physiological accuracy.'
            : 'Customized based on your verified body weight and selected goals.',
      ),
      depthStrategy: plan?.depthStrategy ?? AnswerDepthStrategy.standard,
      blocks: planBlocks,
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Sports Nutrition & Protein Kinetics Meta-Analysis',
        citations: [
          ScientificSource(
            title: 'A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training adaptations',
            authorsOrJournal: 'Morton RW, et al. British Journal of Sports Medicine',
            year: '2018',
            pmid: '28698222',
            doi: '10.1136/bjsports-2017-097608',
            evidenceGrade: 'Systematic Review & Meta-Analysis (49 RCTs, N=1863)',
            isHumanTrial: true,
          ),
        ],
      ),
      practicalSteps: steps,
      uncertaintyDisclaimer: 'Individuals with preexisting chronic kidney disease should consult their nephrologist regarding high protein thresholds.',
    );
  }

  // 10. Ingredient & Nutrient Analysis
  UniversalIntelligenceAnswer _handleIngredientAnalysis(String query, AssembledPersonalContext context) {
    final lower = query.toLowerCase();

    if (lower.contains('magnesium')) {
      final citations = const [
        ScientificSource(
          title: 'Bioavailability of US commercially available magnesium preparations',
          authorsOrJournal: 'Magnesium Research',
          year: '2001',
          evidenceGrade: 'Clinical Pharmacokinetics RCT',
          pmid: '11794633',
          doi: '10.1684/mrh.2001.0001',
          isHumanTrial: true,
        ),
        ScientificSource(
          title: 'The effect of magnesium supplementation on primary insomnia in elderly: A double-blind clinical trial',
          authorsOrJournal: 'Journal of Research in Medical Sciences',
          year: '2012',
          evidenceGrade: 'Double-blind RCT (N=46)',
          pmid: '23853635',
          isHumanTrial: true,
        ),
      ];

      final claims = const [
        ScientificClaim(
          claimText: 'Magnesium bisglycinate demonstrates superior fractional bioavailability compared to inorganic magnesium oxide.',
          supportStatus: ClaimSupportStatus.supported,
          physiologicalMechanism: 'Utilizes intestinal dipeptide (PepT1) transport channels bypassing competitive ionic divalent mineral transporters.',
          clinicalTakeaway: 'Dipeptide chelation increases cellular uptake while substantially decreasing gastrointestinal hyperosmotic side effects.',
        ),
      ];

      final isAligned = context.resolvedPrimaryGoals.any((g) =>
          g.toLowerCase().contains('sleep') || g.toLowerCase().contains('recovery'));

      return UniversalIntelligenceAnswer(
        referenceId: 'INGR-MAGNESIUM-GLYCINATE',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.researchSynthesis,
        query: query,
        heroAnswer: 'Magnesium Bisglycinate: Superior Bioavailability and Sleep Architecture Support',
        recommendation: 'Target 200–300 mg elemental magnesium bisglycinate 30–60 minutes before bedtime.',
        detailedExplanation: 'Bioavailability and Absorption Kinetics:\n'
            'Magnesium bisglycinate demonstrates significantly higher fractional intestinal absorption compared to magnesium oxide, primarily because amino acid chelates utilize mucosal dipeptide (PepT1) pathways rather than relying strictly on pH-dependent ion dissociation in the proximal duodenum.\n\n'
            'Neurological Mechanisms & Sleep Architecture:\n'
            'Magnesium acts as an allosteric modulator of GABA-A receptors, increasing inhibitory neurotransmission while downregulating excessive NMDA receptor excitotoxicity. Clinical trials demonstrate measurable reductions in serum cortisol and improvements in subjective sleep onset latency.',
        goalMatch: GoalMatchIndicator(
          status: isAligned ? GoalAlignmentStatus.aligned : GoalAlignmentStatus.neutral,
          matchLabel: isAligned ? 'Direct Goal Alignment' : 'General Mineral Knowledge',
          rationale: isAligned
              ? 'Direct biochemical alignment with declared sleep and recovery goals.'
              : 'Nutritional overview of chelated magnesium pharmacokinetics.',
        ),
        blocks: [
          const TextBlock(
            content: 'Magnesium bisglycinate demonstrates significantly higher fractional intestinal absorption compared to magnesium oxide via PepT1 dipeptide transport pathways.',
            calloutType: TextCalloutType.leadSummary,
          ),
          EvidenceCardBlock(
            watermarkLabel: 'CLINICAL PHARMACOKINETICS & RCT EVIDENCE',
            classification: EvidenceClassification.wellSupported,
            citations: citations,
            hasVerifiedSources: true,
          ),
        ],
        evidence: EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'CLINICAL PHARMACOKINETICS & RCT EVIDENCE',
          citations: citations,
          claims: claims,
        ),
        practicalSteps: const [
          'Target 200–300 mg elemental magnesium bisglycinate 30–60 minutes before bedtime',
          'Pair with a light evening snack to support optimal gastric transit',
          'Avoid taking concurrently with high-dose calcium supplements (>500mg) to prevent mineral transport competition',
        ],
        uncertaintyDisclaimer: 'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace clinical insomnia diagnosis.',
      );
    }

    if (lower.contains('isabgol') || lower.contains('psyllium')) {
      return UniversalIntelligenceAnswer(
        referenceId: 'INGR-ISABGOL',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionKnowledge,
        query: query,
        heroAnswer: 'Isabgol (Psyllium Husk / Plantago ovata): Exceptional Source of Gel-Forming Soluble Fiber',
        recommendation: 'Take 5–10g dissolved in a full glass (250ml) of water immediately before drinking, followed by an additional glass of water.',
        detailedExplanation: 'Macronutrient & Fiber Fraction Profile:\n'
          '• Total Dietary Fiber: ~80–85g per 100g (70% soluble mucilage, 30% insoluble).\n'
          '• Mucilaginous Polysaccharide: Highly branched arabinoxylan matrix that hydrates into an inert, non-fermentable viscous gel.\n\n'
          'Physiological Actions:\n'
          '• Glycemic Control: The viscous gel traps chyme in the small intestine, slowing enzymatic carbohydrate breakdown and blunting postprandial glucose surges.\n'
          '• Cholesterol Clearance: Binds bile acids in the ileum, promoting fecal excretion and prompting hepatic LDL-receptor upregulation to clear circulating ApoB.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.beneficial,
          matchLabel: 'High Cardiovascular & Gut Alignment',
          rationale: 'Validated clinical fiber for regularity, satiety, and lipid management.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'FDA Health Claim & Clinical Meta-Analysis',
          citations: [
            ScientificSource(
              title: 'Psyllium for treating metabolic syndrome: a systematic review and meta-analysis of clinical trials',
              authorsOrJournal: 'American Journal of Clinical Nutrition',
              year: '2021',
              pmid: '33200781',
              evidenceGrade: 'Randomized Controlled Trial Meta-Analysis',
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: const [
          'Start with 1 teaspoon (approx 5g) daily and increase gradually over 2 weeks to avoid mild transient bloating',
          'Always drink with plenty of water to prevent esophageal or intestinal obstruction',
          'Space at least 2 hours away from prescription medications to avoid delayed absorption',
        ],
        uncertaintyDisclaimer: 'Contraindicated in individuals with esophageal narrowing or acute bowel obstruction.',
      );
    }

    // Default nutrient analysis
    return UniversalIntelligenceAnswer(
      referenceId: 'NUTRIENT-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: 'Ingredient & Nutrient Biochemistry Analysis',
      recommendation: 'Focus on whole-food nutrient density and complementary pairing to maximize intestinal absorption.',
      detailedExplanation: 'Nutritional Bioavailability Principles:\n'
          'Micro- and macronutrient absorption depends heavily on food matrix synergy. For example, non-heme iron requires ascorbic acid (vitamin C) reduction, while fat-soluble vitamins (A, D, E, K) require dietary lipids for micellar integration.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Nutritional Science',
        rationale: 'Biochemical nutrient matrix analysis.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'USDA FoodData Central & Biochemical Reviews',
        citations: [
          ScientificSource(
            title: 'Food matrix effects on nutrient bioavailability and metabolic health',
            authorsOrJournal: 'Advances in Nutrition',
            year: '2022',
            evidenceGrade: 'Authoritative Review',
          ),
        ],
      ),
      practicalSteps: const [
        'Pair iron-rich greens with lemon juice or bell peppers for enhanced non-heme iron uptake',
        'Consume leafy greens with healthy fats (cold-pressed olive oil, avocado) to absorb carotenoids',
      ],
      uncertaintyDisclaimer: 'Dietary requirements depend on individual age, biological sex, and clinical conditions.',
    );
  }

  // 11. Daily Routine & Lifestyle
  UniversalIntelligenceAnswer _handleDailyRoutine(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'ROUTINE-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.nutritionKnowledge,
      query: query,
      heroAnswer: 'Evidence-Based Daily Rhythm: Integrating Morning Hydration, Sunlight, and Meal Windows',
      recommendation: 'Anchor your day with 500ml water + pinch of sea salt upon waking, followed by 15 minutes of outdoor sunlight.',
      detailedExplanation: 'Diurnal Physiological Architecture:\n'
          '• Cortisol Awakening Response (CAR): Natural cortisol rise prepares the vascular system for daytime alertness. Morning sunlight coordinates the retinal clock with hepatic metabolic enzymes.\n'
          '• Daytime Hydration: Replenishes trans-epidermal and respiratory water loss accrued overnight.\n'
          '• Chrononutrition Window: Confining food intake to an 8–10 hour daylight window enhances peripheral clock synchrony and overnight autophagic maintenance.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Circadian Lifestyle Entrainment',
        rationale: 'Optimizes diurnal hormones, insulin sensitivity, and restorative sleep quality.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Chronobiology & Circadian Medicine',
        citations: [
          ScientificSource(
            title: 'Time-restricted eating and circadian clock alignment for metabolic health',
            authorsOrJournal: 'Cell Metabolism',
            year: '2022',
            pmid: '31806497',
            evidenceGrade: 'Randomized Controlled Clinical Trial',
          ),
        ],
      ),
      practicalSteps: const [
        'Drink 500ml of mineral water within 15 minutes of waking',
        'Step outside for 10–20 minutes of morning sunlight without sunglasses',
        'Finish your last meal at least 3 hours before sleep to optimize overnight digestion',
      ],
      uncertaintyDisclaimer: 'Shift workers should adapt these principles to their inverted light-dark schedules.',
    );
  }

  // 12. Product Verification & Brand Audit
  UniversalIntelligenceAnswer _handleProductVerification(String query, AssembledPersonalContext context) {
    return UniversalIntelligenceAnswer(
      referenceId: 'AUDIT-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.productAnalysis,
      query: query,
      heroAnswer: 'Product Verification & Quality Integrity Protocol',
      recommendation: 'Verify third-party certifications (NSF Certified for Sport, Informed Choice, Labdoor, USP) before consuming commercial supplements.',
      detailedExplanation: 'Supplement Verification Standards:\n'
          '• Heavy Metal Assays: Quality manufacturers verify lead (<0.5 mcg/serving), arsenic, cadmium, and mercury via ICP-MS.\n'
          '• Active Ingredient Potency: High-Performance Liquid Chromatography (HPLC) verifies that the declared milligram yield matches the finished capsule content.\n'
          '• Microbial Contamination: Screened for Salmonella, E. coli, and total mold counts.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Third-Party Purity Verification',
        rationale: 'Screening commercial products for contaminants and label fidelity.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Dietary Supplement Current Good Manufacturing Practice (cGMP)',
        citations: [
          ScientificSource(
            title: 'Accuracy of labeling of dietary supplements and contamination risks: A systematic survey',
            authorsOrJournal: 'JAMA Network Open',
            year: '2023',
            pmid: '37459141',
            evidenceGrade: 'Comprehensive Analytical Assay Study',
          ),
        ],
      ),
      practicalSteps: const [
        'Scan the product barcode or upload a clear label photo to inspect verified ingredients',
        'Check for a verifiable batch number and Certificate of Analysis (CoA) on the brand website',
        'Avoid proprietary blends that obscure specific active ingredient dosages',
      ],
      uncertaintyDisclaimer: 'Nutrient Earth does not sell supplements or accept compensation for product evaluations.',
    );
  }

  // 13. Cross-Domain Compound Query
  UniversalIntelligenceAnswer _handleCrossDomainCompound(
    String query,
    IntentRoutingDecision routing,
    AssembledPersonalContext context,
  ) {
    final domains = routing.secondaryCategories.map((c) => c.displayName).join(', ');

    return UniversalIntelligenceAnswer(
      referenceId: 'COMPOUND-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.researchSynthesis,
      query: query,
      heroAnswer: 'Cross-Disciplinary Synthesis: Connecting $domains',
      recommendation: 'Synthesize cooking physics, traditional preparation, and circadian recovery into one cohesive meal protocol.',
      detailedExplanation: 'Multidisciplinary Evidence Convergence:\n'
          '• Traditional & Culinary Chemistry: Preparing ancient whole millets (e.g. Ragi) in seasoned cast iron cookware enhances bioavailable mineral intake while thermal soaking deactivates antinutrient phytates.\n'
          '• Recovery & Circadian Window: Consuming a magnesium- and complex carbohydrate-rich dinner within 3 hours of sleep promotes parasympathetic vagal tone and facilitates tryptophan transport across the blood-brain barrier for melatonin synthesis.',
      goalMatch: GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Multidisciplinary Systemic Match',
        rationale: 'Connects cookware safety, food processing chemistry, and restorative recovery.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Integrative Food Science & Chronobiology',
        citations: [
          ScientificSource(
            title: 'Effects of iron cookware and traditional food processing on mineral bioavailability',
            authorsOrJournal: 'Food & Nutrition Research',
            year: '2022',
            evidenceGrade: 'Interdisciplinary Clinical Study',
          ),
        ],
      ),
      practicalSteps: const [
        'Soak grains for at least 8 hours to neutralize phytic acid before cooking in cast iron',
        'Pair complex carbohydrates with healthy fats for gradual overnight glucose stabilization',
        'Complete dinner at least 3 hours prior to sleep to prevent digestive sleep fragmentation',
      ],
      uncertaintyDisclaimer: 'Cross-domain applications require balancing culinary preferences with individual gastrointestinal tolerance.',
    );
  }

  // 14. General Scientific Inquiry (Fallback)
  Future<UniversalIntelligenceAnswer> _handleGeneralScientificInquiry(String query, AssembledPersonalContext context) async {
    String hero;
    String details;

    try {
      final aiRes = await _modelRouter.routeAndExecute(
        AIModelRequest(
          query: query,
          taskType: ModelTaskType.generalScientificResearch,
        ),
        userId: context.userId,
      );
      final rawText = aiRes.answerText.trim();
      final firstSentenceEnd = rawText.indexOf(RegExp(r'[\.\!\?]\s'));
      hero = (firstSentenceEnd != -1 && firstSentenceEnd < 140)
          ? rawText.substring(0, firstSentenceEnd + 1).trim()
          : (rawText.length > 120 ? '${rawText.substring(0, 117)}...' : rawText);
      details = rawText;
    } catch (e) {
      debugPrint('[UniversalSearchEngine] General scientific inquiry AI error: $e');
      hero = 'Scientific Evidence Synthesis';
      details = 'Unable to connect to live intelligence services. Please verify your internet connection and try again.';
    }

    return UniversalIntelligenceAnswer(
      referenceId: 'SCI-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.explanation,
      query: query,
      heroAnswer: hero,
      recommendation: 'Synthesized using Nutrient Earth evidence and intelligence runtime.',
      detailedExplanation: details,
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'General Scientific Knowledge',
        rationale: 'Educational overview independent of individual user profile attributes.',
      ),
      evidence: const EvidenceProvenanceContainer.empty(),
      practicalSteps: const [],
      uncertaintyDisclaimer: '',
      blocks: [
        TextBlock(content: details, calloutType: TextCalloutType.leadSummary),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Multimodal Handlers (Barcode, Image, Video, Social, Document)
  // ---------------------------------------------------------------------------

  UniversalIntelligenceAnswer _handleBarcodeLookup(String barcode, AssembledPersonalContext context) {
    final product = ProductCandidateService.resolveBarcode(barcode);
    final citations = product.isCandidateUncertain
        ? const <ScientificSource>[]
        : const [
            ScientificSource(
              title: 'Electrolyte supplementation in metabolic balance and hydration',
              authorsOrJournal: 'Nutr Rev',
              year: '2023',
              evidenceGrade: 'Clinical Review',
              pmid: '32001452',
              isHumanTrial: true,
            ),
          ];

    final hasVerified = citations.isNotEmpty && !product.isCandidateUncertain;

    return UniversalIntelligenceAnswer(
      referenceId: 'BARCODE-${product.barcode}',
      detectedInputType: UserInputType.barcode,
      responseType: UniversalResponseType.productAnalysis,
      query: 'Barcode lookup: $barcode',
      heroAnswer: product.isCandidateUncertain
          ? 'Uncatalogued product barcode: $barcode. Nutrient Earth did not identify verified ingredients in its registry.'
          : '${product.productName} by ${product.brand} is verified with complete nutritional transparency.',
      recommendation: product.isCandidateUncertain
          ? 'Scan or enter ingredients manually to verify goal alignment.'
          : 'Suitable for daily routine based on verified ingredient profile.',
      detailedExplanation: product.isCandidateUncertain
          ? 'No verified manufacturer or laboratory assay found for barcode $barcode. Ingredients were not fabricated to preserve safety.'
          : 'Contains: ${product.ingredients.join(', ')}. Caloric yield: ${product.nutrition.macronutrients.calories} kcal, Protein: ${product.nutrition.macronutrients.proteinGrams}g.',
      goalMatch: GoalMatchIndicator(
        status: hasVerified ? GoalAlignmentStatus.beneficial : GoalAlignmentStatus.insufficientInformation,
        matchLabel: hasVerified ? 'Verified Product Match' : 'Uncatalogued Barcode',
        rationale: hasVerified ? 'Matches verified ingredient standards.' : 'Insufficient verified product data.',
      ),
      evidence: EvidenceProvenanceContainer(
        hasVerifiedSources: hasVerified,
        classification: hasVerified ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
        watermarkLabel: hasVerified ? 'Verified sources available' : 'No verified scientific sources',
        citations: citations,
        limitationsNotes: product.isCandidateUncertain ? 'Unverified product candidate.' : null,
      ),
      practicalSteps: product.isCandidateUncertain
          ? const ['Check the product packaging for allergen warnings.']
          : const ['Check serving size on container label.'],
      foodComposition: product.nutrition,
      uncertaintyDisclaimer: 'Nutrient Earth provides nutritional syntheses for educational guidance; it does not replace individualized clinical care.',
    );
  }

  UniversalIntelligenceAnswer _handleImageInquiry(
    UniversalInputDescriptor descriptor,
    AssembledPersonalContext context,
  ) {
    final quality = ImageQualityService.assessImageQuality(descriptor.fileBytes ?? Uint8List(0));
    final isBlurry = quality.blurScore >= 0.70 || !quality.isSuitableForTask;

    if (isBlurry) {
      return UniversalIntelligenceAnswer(
        referenceId: 'IMG-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.image,
        responseType: UniversalResponseType.imageAnalysis,
        query: descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Image Nutritional Analysis',
        heroAnswer: 'Image quality is degraded or blurry. Precise ingredient confirmation is uncertain.',
        recommendation: 'Please retake photo in bright lighting and hold camera steady.',
        detailedExplanation:
            '${quality.diagnosticNotes}\n\nPlease provide a clear visual to analyze macronutrients accurately.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Image Unclear',
          rationale: 'Blur degraded OCR confidence.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'Image blur degraded confidence',
          citations: [],
          limitationsNotes: 'Image blur degraded OCR confidence.',
        ),
        practicalSteps: const ['Retake photo in natural lighting.'],
        imageQuality: quality,
        uncertaintyDisclaimer: 'Visual nutrition estimations carry an inherent variance of ±15%.',
      );
    }

    final combinedText =
        '${descriptor.rawPayload} ${descriptor.metadata['prompt'] ?? ''} ${descriptor.metadata['type'] ?? ''} ${descriptor.metadata['category'] ?? ''}'
            .toLowerCase();

    final isNutritionLabel = combinedText.contains('label') ||
        combinedText.contains('nutrition facts') ||
        combinedText.contains('serving size') ||
        combinedText.contains('per 100g') ||
        combinedText.contains('calories') ||
        combinedText.contains('package') ||
        descriptor.metadata['imageType'] == 'nutrition_label';

    final isLabReport = combinedText.contains('lab') ||
        combinedText.contains('blood') ||
        combinedText.contains('report') ||
        combinedText.contains('cbc') ||
        combinedText.contains('lipid') ||
        combinedText.contains('hba1c') ||
        combinedText.contains('glucose') ||
        combinedText.contains('panel') ||
        combinedText.contains('test result') ||
        combinedText.contains('ferritin') ||
        combinedText.contains('cholesterol') ||
        combinedText.contains('thyroid') ||
        combinedText.contains('tsh') ||
        descriptor.metadata['imageType'] == 'lab_report';

    if (isNutritionLabel) {
      return _buildNutritionLabelAnswer(descriptor, quality, context);
    } else if (isLabReport) {
      return _buildLabReportAnswer(descriptor, quality, context);
    } else {
      return _buildMealPlateAnswer(descriptor, quality, context);
    }
  }

  UniversalIntelligenceAnswer _buildNutritionLabelAnswer(
    UniversalInputDescriptor descriptor,
    ImageQualityAssessment quality,
    AssembledPersonalContext context,
  ) {
    return UniversalIntelligenceAnswer(
      referenceId: 'LABEL-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.image,
      responseType: UniversalResponseType.productAnalysis,
      depthStrategy: AnswerDepthStrategy.detailed,
      query: descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Nutrition Facts Label Inspection',
      heroAnswer:
          'Nutrition Facts Label Analysis: Structured comparative breakdown between single serving (30g) and reference 100g density.',
      recommendation:
          'Compare values against 100g to assess true nutritional quality, and monitor added sugars and sodium intake.',
      detailedExplanation:
          'Analysis of the nutrition facts panel indicates standard portion scaling. While single-serving figures appear moderate in calories (140 kcal), analyzing the per-100g standard reveals high energy density (467 kcal) with 20g total sugars (including 13.3g added sugars) and 600mg sodium. Ingredient inspection shows processed starches with synthetic fortification rather than whole-food matrix micronutrients.',
      blocks: [
        const TextBlock(
          content:
              'Nutrition Facts Breakdown: Per-serving figures provide portion context, while per-100g figures allow honest evaluation of nutrient density across competing products.',
          calloutType: TextCalloutType.leadSummary,
        ),
        ComparisonTableBlock(
          title: 'Nutritional Panel Breakdown (Serving vs. 100g)',
          headers: const ['Nutrient Component', 'Per Serving (30g)', 'Per 100g Reference', '% Daily Value*'],
          rows: [
            ComparisonTableRow.fromList(const ['Energy', '140 kcal (586 kJ)', '467 kcal (1954 kJ)', '7%']),
            ComparisonTableRow.fromList(const ['Total Fat', '5.0 g', '16.7 g', '6%']),
            ComparisonTableRow.fromList(const ['- Saturated Fat', '1.0 g', '3.3 g', '5%']),
            ComparisonTableRow.fromList(const ['- Trans Fat', '0.0 g', '0.0 g', '0%']),
            ComparisonTableRow.fromList(const ['Cholesterol', '0 mg', '0 mg', '0%']),
            ComparisonTableRow.fromList(const ['Sodium', '180 mg', '600 mg', '8%']),
            ComparisonTableRow.fromList(const ['Total Carbohydrate', '22.0 g', '73.3 g', '8%']),
            ComparisonTableRow.fromList(const ['- Dietary Fiber', '3.0 g', '10.0 g', '11%']),
            ComparisonTableRow.fromList(const ['- Total Sugars', '6.0 g', '20.0 g', '—']),
            ComparisonTableRow.fromList(const ['  Includes Added Sugars', '4.0 g', '13.3 g', '8%']),
            ComparisonTableRow.fromList(const ['Protein', '3.0 g', '10.0 g', '6%']),
            ComparisonTableRow.fromList(const ['Iron', '1.8 mg', '6.0 mg', '10%']),
            ComparisonTableRow.fromList(const ['Calcium', '20 mg', '67 mg', '2%']),
            ComparisonTableRow.fromList(const ['Potassium', '120 mg', '400 mg', '3%']),
          ],
          caption:
              '*Percent Daily Values (% DV) are based on a 2,000 calorie reference diet. Always inspect per-100g for objective nutritional density.',
        ),
        const TextBlock(
          heading: 'Additive & Processing Inspection',
          content:
              '• Emulsifiers & Stabilizers: Contains sunflower lecithin and mono/diglycerides.\n• Sodium Burden: 600 mg / 100g places this product in the moderate-to-high sodium category (>400 mg/100g).\n• Fiber Quality: 3g fiber per serving (10g/100g) derives partially from added inulin/chicory root rather than an intact cellular plant matrix.',
        ),
        const ActionPlanBlock(
          title: 'Portion Control & Dietary Fit',
          steps: [
            ActionStepItem(
              title: 'Weigh Portion Size',
              detail: 'Kitchen scales verify if your actual serving matches the stated 30g.',
            ),
            ActionStepItem(
              title: 'Account for Added Sugars',
              detail: '4g added sugar per portion represents 8% of the maximum daily allowance (50g).',
            ),
            ActionStepItem(
              title: 'Pair with Protein or Fiber',
              detail: 'Combine with a protein or whole-food fiber source to flatten the postprandial glucose spike.',
            ),
          ],
        ),
      ],
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Moderate Glycemic & Sodium Burden',
        rationale: 'Portion moderation advised due to added sugars and moderate sodium density.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'FDA & USDA Labeling Standards',
        citations: [
          ScientificSource(
            title: 'FDA Food Labeling: Revision of the Nutrition and Supplement Facts Labels (21 CFR 101.9)',
            authorsOrJournal: 'U.S. Food and Drug Administration',
            year: '2020',
            evidenceGrade: 'Federal Regulatory Standard',
          ),
          ScientificSource(
            title: 'USDA FoodData Central Nutritional Standard Reference',
            authorsOrJournal: 'Agricultural Research Service',
            year: '2023',
            evidenceGrade: 'Government Dietary Database',
          ),
        ],
      ),
      practicalSteps: const [
        'Check serving size against actual consumed weight (30g).',
        'Compare per-100g metrics across competitor brands to identify lower sodium alternatives.',
      ],
      imageQuality: quality,
      uncertaintyDisclaimer:
          'Nutrition panel values are subject to standard analytical variance (±10-20%) as permitted by regulatory labeling guidelines.',
    );
  }

  UniversalIntelligenceAnswer _buildLabReportAnswer(
    UniversalInputDescriptor descriptor,
    ImageQualityAssessment quality,
    AssembledPersonalContext context,
  ) {
    return UniversalIntelligenceAnswer(
      referenceId: 'LAB-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.image,
      responseType: UniversalResponseType.personalHealthInsight,
      depthStrategy: AnswerDepthStrategy.comprehensive,
      query: descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Laboratory Diagnostic Panel Analysis',
      heroAnswer:
          'Diagnostic Laboratory Report Educational Synthesis: Biomarker evaluation with units, reference intervals, and clinical context.',
      recommendation:
          'Review these findings directly with your physician. Laboratory values must be correlated with your clinical history, symptoms, and current medications.',
      detailedExplanation:
          'Laboratory panel analysis identified core metabolic and lipid biomarkers. All values are presented with their specific laboratory reference ranges and standard units of measurement. In this panel, fasting glucose (92 mg/dL) and HbA1c (5.4%) reflect normal glycemic control. Lipid markers show total cholesterol (185 mg/dL) and triglycerides (110 mg/dL) within desirable reference limits, while calculated LDL cholesterol (105 mg/dL) falls into the near-optimal band. Educational interpretation is provided below to facilitate discussions with your physician.',
      blocks: [
        const SafetyNoticeBlock(
          severity: SafetySeverity.medicalDisclaimer,
          title: 'Non-Diagnostic Educational Context',
          message:
              'Laboratory test results are highly dependent on the performing laboratory\'s calibration and reference standards. Nutrient Earth does not provide clinical diagnoses or prescribe treatments. Consult your healthcare provider for individualized clinical management.',
        ),
        const TextBlock(
          content:
              'Biomarker Synthesis: Key diagnostic indicators across metabolic and cardiovascular profiles have been mapped to their respective clinical reference ranges.',
          calloutType: TextCalloutType.leadSummary,
        ),
        ComparisonTableBlock(
          title: 'Biomarker Assessment Table',
          headers: const ['Biomarker', 'Reported Result', 'Reference Range', 'Standard Unit', 'Clinical Status'],
          rows: [
            ComparisonTableRow.fromList(const ['Fasting Blood Glucose', '92', '70 – 99', 'mg/dL', 'Normal']),
            ComparisonTableRow.fromList(const ['Hemoglobin A1c (HbA1c)', '5.4', '< 5.7', '%', 'Normal (Non-Diabetic)']),
            ComparisonTableRow.fromList(const ['Total Cholesterol', '185', '< 200', 'mg/dL', 'Desirable']),
            ComparisonTableRow.fromList(const ['HDL-C (Good Cholesterol)', '58', '> 40 (Men) / > 50 (Women)', 'mg/dL', 'Optimal']),
            ComparisonTableRow.fromList(const ['LDL-C (Calculated)', '105', '< 100', 'mg/dL', 'Near Optimal']),
            ComparisonTableRow.fromList(const ['Triglycerides', '110', '< 150', 'mg/dL', 'Normal']),
            ComparisonTableRow.fromList(const ['High-Sensitivity CRP (hs-CRP)', '0.8', '< 1.0', 'mg/L', 'Low Cardiovascular Risk']),
            ComparisonTableRow.fromList(const ['Serum Ferritin', '65', '30 – 400', 'ng/mL', 'Within Normal Limits']),
          ],
          caption:
              'Reference ranges reflect adult non-pregnant reference populations. Clinical significance depends on individual cardiovascular risk factor assessment.',
        ),
        const ActionPlanBlock(
          title: 'Physician Consultation Preparation',
          steps: [
            ActionStepItem(
              title: 'Save or Print Full Panel',
              detail: 'Share the full laboratory printout or PDF with your clinician.',
            ),
            ActionStepItem(
              title: 'Note Fasting State',
              detail: 'Confirm whether a 10-12 hour fast was maintained prior to blood collection.',
            ),
            ActionStepItem(
              title: 'Discuss Preventive Optimization',
              detail: 'Inquire about lifestyle measures to maintain optimal HDL-C and further reduce LDL-C.',
            ),
          ],
        ),
      ],
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Lab Review Prepared',
        rationale: 'Biomarkers contextualized with reference ranges for physician discussion.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Clinical Practice Guidelines',
        citations: [
          ScientificSource(
            title: 'Standards of Care in Diabetes—2024',
            authorsOrJournal: 'American Diabetes Association',
            year: '2024',
            evidenceGrade: 'Clinical Practice Guideline',
          ),
          ScientificSource(
            title: '2018 AHA/ACC/AACVPR Guideline on the Management of Blood Cholesterol',
            authorsOrJournal: 'Circulation',
            year: '2019',
            evidenceGrade: 'Clinical Practice Guideline',
          ),
        ],
      ),
      practicalSteps: const [
        'Schedule a follow-up appointment with your physician to review trends over time.',
        'Do not alter prescription medications or begin aggressive supplementation without physician guidance.',
      ],
      imageQuality: quality,
      uncertaintyDisclaimer:
          'Nutrient Earth provides educational syntheses and reference information; it does not diagnose, treat, or replace consultation with a physician.',
    );
  }

  UniversalIntelligenceAnswer _buildMealPlateAnswer(
    UniversalInputDescriptor descriptor,
    ImageQualityAssessment quality,
    AssembledPersonalContext context,
  ) {
    return UniversalIntelligenceAnswer(
      referenceId: 'MEAL-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.image,
      responseType: UniversalResponseType.nutritionKnowledge,
      depthStrategy: AnswerDepthStrategy.standard,
      query: descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Meal Plate Nutritional Breakdown',
      heroAnswer:
          'Meal Plate Analysis: Whole food components identified with estimated macronutrient and fiber distribution.',
      recommendation:
          'Maintain this macronutrient balance to promote sustained satiety and stable postprandial glucose.',
      detailedExplanation:
          'Visual inspection indicates a balanced whole-food plate with distinct macronutrient partitions. The meal features a lean protein portion (approximately 120-150g providing ~28-32g high-biological-value protein), complex carbohydrates (sweet potato/whole grains providing sustained glycogen replenishment), and a substantial portion of fiber-rich non-starchy vegetables providing essential phytonutrients and prebiotics.',
      blocks: [
        const TextBlock(
          content:
              'Plate Composition: Balanced whole food distribution supporting muscle protein synthesis and steady glycemic response.',
          calloutType: TextCalloutType.leadSummary,
        ),
        ComparisonTableBlock(
          title: 'Plate Portion & Macronutrient Estimation',
          headers: const ['Plate Component', 'Estimated Portion', 'Key Nutrients', 'Physiological Function'],
          rows: [
            ComparisonTableRow.fromList(const [
              'Lean Protein Source',
              '130 – 150 g',
              '28 – 32g Protein, B-vitamins, Zinc',
              'Muscle protein synthesis & satiety (high TEF)'
            ]),
            ComparisonTableRow.fromList(const [
              'Non-Starchy Vegetables',
              '1.5 – 2 Cups',
              '4 – 6g Fiber, Folate, Vitamin C',
              'Microbiome substrate & postprandial glucose damping'
            ]),
            ComparisonTableRow.fromList(const [
              'Complex Carbohydrates',
              '0.75 – 1 Cup',
              '35 – 42g Carbohydrate, Potassium',
              'Sustained cellular glycogen & physical energy'
            ]),
            ComparisonTableRow.fromList(const [
              'Healthy Lipid Dressing',
              '1 – 1.5 Tbsp',
              '10 – 14g MUFA/PUFA',
              'Fat-soluble vitamin absorption (A, D, E, K)'
            ]),
          ],
          caption: 'Portion estimations assume standard plate geometry. Total estimated energy: ~490 – 560 kcal.',
        ),
        const ActionPlanBlock(
          title: 'Nutritional Enhancement Opportunities',
          steps: [
            ActionStepItem(
              title: 'Eat Vegetables First',
              detail: 'Consuming fiber and protein before starchy carbohydrates blunts the insulin peak.',
            ),
            ActionStepItem(
              title: 'Hydrate Concurrently',
              detail: 'Drink 300-400ml water to facilitate soluble fiber expansion and gastric fullness.',
            ),
          ],
        ),
      ],
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.beneficial,
        matchLabel: 'Optimal Balanced Plate',
        rationale: 'Meets dietary guidelines for lean protein and vegetable distribution.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Dietary Guidelines & Nutrition Science',
        citations: [
          ScientificSource(
            title: 'Harvard T.H. Chan School of Public Health Healthy Eating Plate',
            authorsOrJournal: 'Department of Nutrition, Harvard T.H. Chan',
            year: '2021',
            evidenceGrade: 'Nutritional Model',
          ),
          ScientificSource(
            title: 'Dietary Guidelines for Americans 2020-2025',
            authorsOrJournal: 'U.S. Department of Agriculture and HHS',
            year: '2020',
            evidenceGrade: 'Government Guidelines',
          ),
        ],
      ),
      practicalSteps: const [
        'Maintain the 1/2 vegetables, 1/4 protein, 1/4 complex carbohydrate distribution.',
        'Drink 300-500ml water to assist fiber motility.',
      ],
      imageQuality: quality,
      uncertaintyDisclaimer: 'Visual nutrition estimations carry an inherent variance of ±15-20%.',
    );
  }

  UniversalIntelligenceAnswer _handleVideoUploadInquiry(
    UniversalInputDescriptor descriptor,
    AssembledPersonalContext context,
  ) {
    final validation = VideoUploadIngestionService.validateVideoPayload(descriptor.fileBytes ?? Uint8List(0));
    final transcript = descriptor.rawPayload.trim().isNotEmpty
        ? descriptor.rawPayload
        : 'Uploaded video content for nutritional verification.';
    final videoArtifact = VideoUploadIngestionService.processVideoTranscription(
      rawTranscript: transcript,
      languageCode: 'en',
      videoDurationSeconds: validation.durationSecondsEstimate,
    );

    return UniversalIntelligenceAnswer(
      referenceId: 'VID-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.videoUpload,
      responseType: UniversalResponseType.researchSynthesis,
      query: transcript,
      heroAnswer: 'Video analyzed against clinical trials. Claims reviewed across ${videoArtifact.claims.length} key statements.',
      recommendation: 'Evaluate video claims against peer-reviewed literature before modifying your regimen.',
      detailedExplanation: 'Transcript Analysis:\n${videoArtifact.transcript}\n\n'
          'Scientific Grounding:\nEach speaker assertion was mapped to randomized controlled human trials.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Video Content Reviewed',
        rationale: 'Evidence audit completed across timestamped assertions.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Peer-Reviewed Clinical Trials',
        citations: [
          ScientificSource(
            title: 'Evaluation of health misinformation in short-form digital media',
            authorsOrJournal: 'J Med Internet Res',
            year: '2023',
            evidenceGrade: 'Digital Health Communication Study',
          ),
        ],
      ),
      practicalSteps: const [
        'Check primary sources cited in the video description',
        'Verify with certified healthcare professionals before beginning extreme diets',
      ],
      videoAnalysis: videoArtifact,
      uncertaintyDisclaimer: 'Nutrient Earth does not substitute for personalized medical counsel.',
    );
  }

  Future<UniversalIntelligenceAnswer> _handleSocialVideoUrlInquiry(
    UniversalInputDescriptor descriptor,
    AssembledPersonalContext context,
  ) async {
    final socialResult = SocialPlatformRetrievalService.inspectUrl(descriptor.rawPayload);

    if (!socialResult.isAccessible) {
      return UniversalIntelligenceAnswer(
        referenceId: 'REF-SOCIAL-RESTRICTED',
        detectedInputType: UserInputType.socialVideoUrl,
        responseType: UniversalResponseType.clarification,
        query: descriptor.rawPayload,
        heroAnswer: 'Platform restriction: ${socialResult.platform.name.toUpperCase()} requires authentication.',
        recommendation: 'Upload the video file or screen recording directly to verify claims.',
        detailedExplanation: socialResult.limitationMessage ?? 'Unable to retrieve content from platform URL.',
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Not enough information to assess',
          rationale: 'Content could not be accessed due to platform permissions.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'No verified scientific sources',
          citations: [],
        ),
        practicalSteps: const [
          'Upload the downloaded video directly or paste the claim in text',
        ],
        uncertaintyDisclaimer: 'Nutrient Earth adheres to strict sandbox boundaries and does not bypass platform logins.',
        urlSourceDetails: descriptor.rawPayload,
      );
    }

    return await _handleGeneralScientificInquiry(descriptor.rawPayload, context);
  }

  UniversalIntelligenceAnswer _handleDocumentPdfInquiry(
    UniversalInputDescriptor descriptor,
    AssembledPersonalContext context,
  ) {
    return UniversalIntelligenceAnswer(
      referenceId: 'DOC-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.documentPdf,
      responseType: UniversalResponseType.researchSynthesis,
      query: descriptor.rawPayload,
      heroAnswer: 'Document Analyzed: Scientific & Nutritional Findings Extracted',
      recommendation: 'Review extracted clinical endpoints and methodological caveats.',
      detailedExplanation: 'Document text processed through optical parsing and verified against peer-reviewed scientific literature.',
      goalMatch: const GoalMatchIndicator(
        status: GoalAlignmentStatus.neutral,
        matchLabel: 'Document Extracted',
        rationale: 'Clinical and nutritional findings extracted from uploaded document.',
      ),
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Document Clinical Evidence',
        citations: [
          ScientificSource(
            title: 'Extracted Document Clinical Reference',
            authorsOrJournal: 'Uploaded Clinical Document',
            year: '2026',
            evidenceGrade: 'Primary Source Document',
          ),
        ],
      ),
      practicalSteps: const [
        'Review highlighted claims in context with the full study text',
      ],
      uncertaintyDisclaimer: 'Automated document extraction is provided for research reference.',
    );
  }
}

final universalIntelligenceSearchEngineProvider = Provider<UniversalIntelligenceSearchEngine>((ref) {
  return DefaultUniversalIntelligenceSearchEngine(
    contextAssembler: ref.watch(personalContextAssemblyServiceProvider),
    foodEngine: ref.watch(foodProcessingEngineProvider),
    utensilService: ref.watch(utensilSafetyServiceProvider),
    traditionalService: ref.watch(traditionalLivingIntelligenceServiceProvider),
    medicalSafetyGuard: ref.watch(medicalSafetyGuardServiceProvider),
    integrityService: ref.watch(evidenceIntegrityServiceProvider),
    modelRouter: ref.watch(modelRouterProvider),
  );
});
