// ==============================================================================
// Nutrient Earth — Adaptive Reasoning & Execution Planner
// Universal Request Understanding & Dynamic Execution Planning (Schema v2026.3)
//
// Dynamically plans execution based on:
// - Request intent & expected outcome
// - Multi-turn conversation continuity & anaphora resolution
// - Adaptive effort & depth strategy (minimal, concise, standard, detailed, comprehensive)
// - Conditional RAG necessity
// - Bounded resource constraints (token budgets, timeouts)
// ==============================================================================

import '../answer_contract/response_content_block.dart';
import '../input_gateway/universal_input_descriptor.dart';
import '../personalization/user_profile_context.dart';
import 'universal_intelligence_router.dart';

/// Nature of user request interaction
enum RequestType {
  conversation,
  question,
  command,
  investigation,
  task,
  followUp;
}

/// Dynamic Subject Domain Classification
enum SubjectDomain {
  lifestyleAndCircadian,
  nutritionAndDiet,
  foodChemistryAndCooking,
  cookwareAndMaterialSafety,
  scientificResearch,
  medicineAndPharmacology,
  traditionalAndAncestral,
  exerciseAndBiomechanics,
  environmentalHealth,
  softwareAndCode,
  calculationAndMath,
  generalKnowledge,
  unfamiliar;

  String get displayName {
    switch (this) {
      case SubjectDomain.lifestyleAndCircadian:
        return 'Lifestyle & Circadian Biology';
      case SubjectDomain.nutritionAndDiet:
        return 'Nutrition & Dietary Science';
      case SubjectDomain.foodChemistryAndCooking:
        return 'Food Chemistry & Culinary Physics';
      case SubjectDomain.cookwareAndMaterialSafety:
        return 'Cookware & Material Toxicology';
      case SubjectDomain.scientificResearch:
        return 'Scientific Research & Clinical Appraisal';
      case SubjectDomain.medicineAndPharmacology:
        return 'Medicine & Clinical Pharmacology';
      case SubjectDomain.traditionalAndAncestral:
        return 'Traditional & Ancestral Living';
      case SubjectDomain.exerciseAndBiomechanics:
        return 'Movement & Exercise Physiology';
      case SubjectDomain.environmentalHealth:
        return 'Environmental Toxins & Exposure';
      case SubjectDomain.softwareAndCode:
        return 'Software Engineering & Computation';
      case SubjectDomain.calculationAndMath:
        return 'Quantitative & Metabolic Calculations';
      case SubjectDomain.generalKnowledge:
        return 'General Educational Knowledge';
      case SubjectDomain.unfamiliar:
        return 'Open Domain Inquiry';
    }
  }
}

/// Semantic understanding synthesized from raw query and multi-turn context
class UniversalSemanticUnderstanding {
  final String rawQuery;
  final String resolvedQuery;
  final RequestType requestType;
  final SubjectDomain subjectDomain;
  final UniversalIntent intent;
  final AnswerDepthStrategy depthStrategy;
  final bool requiresExternalResearch;
  final bool requiresInternalKnowledge;
  final bool requiresCalculations;
  final bool requiresCodeGeneration;
  final bool requiresComparisonTable;
  final bool requiresPersonalContext;
  final bool isMultiPart;
  final bool isFollowUp;
  final String? referencedEntity;
  final double complexityScore; // 0.0 (trivial) to 1.0 (highly complex)

  const UniversalSemanticUnderstanding({
    required this.rawQuery,
    required this.resolvedQuery,
    required this.requestType,
    required this.subjectDomain,
    required this.intent,
    required this.depthStrategy,
    this.requiresExternalResearch = false,
    this.requiresInternalKnowledge = false,
    this.requiresCalculations = false,
    this.requiresCodeGeneration = false,
    this.requiresComparisonTable = false,
    this.requiresPersonalContext = false,
    this.isMultiPart = false,
    this.isFollowUp = false,
    this.referencedEntity,
    this.complexityScore = 0.5,
  });
}

/// Concrete Execution Plan holding bounded resources and intended block outputs
class ExecutionPlan {
  final String planId;
  final UniversalSemanticUnderstanding understanding;
  final AnswerDepthStrategy depthStrategy;
  final RagRetrievalDecision ragDecision;
  final List<String> requiredSpecialists;
  final List<String> intendedBlockTypes;
  final int tokenBudget;
  final int timeoutMs;
  final bool canExecuteDirectly;

  const ExecutionPlan({
    required this.planId,
    required this.understanding,
    required this.depthStrategy,
    required this.ragDecision,
    this.requiredSpecialists = const [],
    this.intendedBlockTypes = const [],
    this.tokenBudget = 800,
    this.timeoutMs = 5000,
    this.canExecuteDirectly = true,
  });
}

class AdaptiveExecutionPlanner {
  AdaptiveExecutionPlanner._();

  static final RegExp _greetingRegex = RegExp(
    r'^(hi+|hey+|hello+|howdy|hola|greetings|good\s+(morning|afternoon|evening)|hi\s+there|hey\s+there|sup|yo)[!.,\s]*$',
    caseSensitive: false,
  );

  static final List<String> _casualPhrases = [
    'how are you', 'how are you doing', 'who are you', 'what is nutrient earth',
    'what can you do', 'tell me about yourself', 'thank you', 'thanks', 'thanks a lot',
    'nice to meet you', 'who made you', 'what is your name', 'help me', 'good job',
  ];

  static final List<String> _codeKeywords = [
    'code', 'function', 'python', 'javascript', 'typescript', 'dart', 'api',
    'algorithm', 'regex', 'sql', 'script', 'programming', 'bug', 'compile',
  ];

  static final List<String> _comparisonKeywords = [
    'compare', 'difference between', 'versus', ' vs ', 'vs.', 'better than',
    'pros and cons', 'advantages and disadvantages',
  ];

  static final List<String> _calculationKeywords = [
    'calculate', 'how much', 'formula', 'ratio', 'estimate my', 'protein intake',
    'calories', 'bmr', 'tdee', 'intake target', 'percentage',
  ];

  static final List<String> _scientificKeywords = [
    'study', 'studies', 'clinical trial', 'rct', 'meta-analysis', 'pubmed',
    'doi', 'evidence', 'peer-reviewed', 'mechanism', 'pathway', 'microplastics',
    'cellular', 'biochemistry', 'autophagy', 'mitochondria',
  ];

  static final List<String> _cookwareKeywords = [
    'cast iron', 'cookware', 'pan', 'pot', 'stainless steel', 'teflon', 'ptfe',
    'copper', 'brass', 'clay pot', 'aluminium', 'aluminum', 'non-stick', 'leach',
  ];

  static final List<String> _symptomKeywords = [
    'tired', 'fatigue', 'bloated', 'bloating', 'brain fog', 'insomnia', 'headache',
    'exhausted', 'cramp', 'indigestion', 'why am i tired',
  ];

  /// Analyzes query, multimodal input, and session history to produce a semantic understanding
  static UniversalSemanticUnderstanding understandRequest({
    required String query,
    UserInputType? inputType,
    String? priorTurnQuery,
    String? priorReferencedEntity,
    UserProfileContext? userProfile,
  }) {
    final lower = query.toLowerCase().trim();
    String resolvedQuery = query.trim();
    bool isFollowUp = false;
    String? referencedEntity = priorReferencedEntity;

    // 1. Multi-turn Anaphora & Context Continuity Resolution
    // Handles follow-ups: "why?", "explain more", "compare them", "what about this?", "how do I use it?"
    if (priorTurnQuery != null && priorTurnQuery.isNotEmpty) {
      final isShortFollowUp = lower == 'why?' ||
          lower == 'why' ||
          lower == 'explain more' ||
          lower == 'tell me more' ||
          lower == 'compare them' ||
          lower == 'what about this?' ||
          lower == 'how do i use it?' ||
          lower == 'is it safe?' ||
          (lower.length < 25 && (lower.startsWith('why ') || lower.startsWith('how ') || lower.startsWith('what about ')));

      if (isShortFollowUp) {
        isFollowUp = true;
        if (referencedEntity != null && referencedEntity.isNotEmpty) {
          resolvedQuery = '$query (in reference to $referencedEntity)';
        } else {
          resolvedQuery = '$query (context: $priorTurnQuery)';
        }
      }
    }

    // 2. Determine Request Type
    RequestType reqType = RequestType.question;
    if (_greetingRegex.hasMatch(lower) || _casualPhrases.any((p) => lower == p || lower.startsWith('$p '))) {
      reqType = RequestType.conversation;
    } else if (lower.startsWith('compare ') || lower.contains(' vs ') || lower.contains(' versus ')) {
      reqType = RequestType.investigation;
    } else if (lower.startsWith('calculate ') || lower.startsWith('create a ') || lower.startsWith('write a ')) {
      reqType = RequestType.task;
    } else if (isFollowUp) {
      reqType = RequestType.followUp;
    }

    // 3. Determine Subject Domain & Specialized Needs
    SubjectDomain domain = SubjectDomain.generalKnowledge;
    bool reqResearch = false;
    bool reqInternal = true;
    bool reqCalc = false;
    bool reqCode = false;
    bool reqTable = false;
    bool reqPersonal = false;

    if (_codeKeywords.any((kw) => lower.contains(kw))) {
      domain = SubjectDomain.softwareAndCode;
      reqCode = true;
    } else if (_cookwareKeywords.any((kw) => lower.contains(kw))) {
      domain = SubjectDomain.cookwareAndMaterialSafety;
      reqResearch = true;
      if (lower.contains('cast iron')) referencedEntity = 'cast iron';
      if (lower.contains('teflon') || lower.contains('non-stick')) referencedEntity = 'non-stick Teflon';
      if (lower.contains('stainless')) referencedEntity = 'stainless steel';
    } else if (_comparisonKeywords.any((kw) => lower.contains(kw))) {
      reqTable = true;
      domain = SubjectDomain.scientificResearch;
    } else if (_calculationKeywords.any((kw) => lower.contains(kw))) {
      domain = SubjectDomain.calculationAndMath;
      reqCalc = true;
      reqPersonal = lower.contains('my ') || lower.contains('for me');
    } else if (_symptomKeywords.any((kw) => lower.contains(kw))) {
      domain = SubjectDomain.medicineAndPharmacology;
      reqResearch = false; // Initial symptom guidance is educational & non-diagnostic
    } else if (_scientificKeywords.any((kw) => lower.contains(kw))) {
      domain = SubjectDomain.scientificResearch;
      reqResearch = true;
    } else if (reqType == RequestType.conversation) {
      domain = SubjectDomain.lifestyleAndCircadian;
      reqInternal = false;
      reqResearch = false;
    }

    // 4. Adaptive Depth Strategy Evaluation
    AnswerDepthStrategy depth;
    double complexity = 0.5;

    // Explicit user requests for length
    if (lower.contains('in detail') || lower.contains('deep dive') || lower.contains('comprehensive') || lower.contains('explain thoroughly')) {
      depth = AnswerDepthStrategy.comprehensive;
      complexity = 0.9;
    } else if (lower.contains('short answer') || lower.contains('in one sentence') || lower.contains('briefly') || lower.contains('tldr')) {
      depth = AnswerDepthStrategy.concise;
      complexity = 0.3;
    } else if (reqType == RequestType.conversation) {
      depth = AnswerDepthStrategy.minimal;
      complexity = 0.1;
    } else if (reqCode || reqTable || domain == SubjectDomain.scientificResearch) {
      depth = AnswerDepthStrategy.detailed;
      complexity = 0.8;
    } else if (lower.startsWith('what is ') || lower.startsWith('define ')) {
      depth = AnswerDepthStrategy.concise;
      complexity = 0.35;
    } else {
      depth = AnswerDepthStrategy.standard;
      complexity = 0.5;
    }

    // Map to canonical intent
    final baseDecision = UniversalIntelligenceRouter.classify(resolvedQuery, inputType: inputType);

    return UniversalSemanticUnderstanding(
      rawQuery: query,
      resolvedQuery: resolvedQuery,
      requestType: reqType,
      subjectDomain: domain,
      intent: baseDecision.intent,
      depthStrategy: depth,
      requiresExternalResearch: reqResearch,
      requiresInternalKnowledge: reqInternal,
      requiresCalculations: reqCalc,
      requiresCodeGeneration: reqCode,
      requiresComparisonTable: reqTable,
      requiresPersonalContext: reqPersonal,
      isMultiPart: lower.contains(' and ') && lower.contains('?'),
      isFollowUp: isFollowUp,
      referencedEntity: referencedEntity,
      complexityScore: complexity,
    );
  }

  /// Synthesizes a bounded ExecutionPlan from semantic understanding
  static ExecutionPlan createPlan({
    required String query,
    UserInputType? inputType,
    String? priorTurnQuery,
    String? priorReferencedEntity,
    UserProfileContext? userProfile,
  }) {
    final understanding = understandRequest(
      query: query,
      inputType: inputType,
      priorTurnQuery: priorTurnQuery,
      priorReferencedEntity: priorReferencedEntity,
      userProfile: userProfile,
    );

    // 1. Determine RAG retrieval decision
    RagRetrievalDecision rag;
    if (understanding.intent.isConversational || understanding.requiresCodeGeneration) {
      rag = RagRetrievalDecision.none;
    } else if (understanding.requiresExternalResearch) {
      rag = RagRetrievalDecision.scientificEvidenceFetch;
    } else if (understanding.subjectDomain == SubjectDomain.cookwareAndMaterialSafety) {
      rag = RagRetrievalDecision.productDatabaseLookup;
    } else if (understanding.requiresPersonalContext) {
      rag = RagRetrievalDecision.personalContextOnly;
    } else {
      rag = RagRetrievalDecision.internalKnowledgeBase;
    }

    // 2. Determine Intended Dynamic Block Types
    final intendedBlocks = <String>['text'];

    if (understanding.intent.isConversational) {
      intendedBlocks.add('interactiveSuggestions');
    } else {
      if (understanding.requiresComparisonTable) {
        intendedBlocks.add('table');
      }
      if (understanding.requiresCodeGeneration) {
        intendedBlocks.add('code');
      }
      if (understanding.requiresCalculations) {
        intendedBlocks.add('metricCalculation');
        intendedBlocks.add('actionPlan');
      }
      if (understanding.subjectDomain == SubjectDomain.cookwareAndMaterialSafety) {
        intendedBlocks.add('productAudit');
        intendedBlocks.add('actionPlan');
      }
      if (understanding.intent == UniversalIntent.scientificResearch ||
          understanding.intent == UniversalIntent.evidenceComparison) {
        intendedBlocks.add('evidenceCard');
        intendedBlocks.add('actionPlan');
      }
      if (understanding.intent == UniversalIntent.symptomInquiry) {
        intendedBlocks.add('actionPlan');
        intendedBlocks.add('safetyNotice');
      }
      if (understanding.intent == UniversalIntent.safetyCriticalEmergency) {
        intendedBlocks.clear();
        intendedBlocks.add('safetyNotice');
        intendedBlocks.add('text');
      }
    }

    // 3. Determine Bounded Token Budget & Timeout
    int tokens = 600;
    int timeout = 4000;

    switch (understanding.depthStrategy) {
      case AnswerDepthStrategy.minimal:
        tokens = 150;
        timeout = 2000;
        break;
      case AnswerDepthStrategy.concise:
        tokens = 350;
        timeout = 3000;
        break;
      case AnswerDepthStrategy.standard:
        tokens = 800;
        timeout = 5000;
        break;
      case AnswerDepthStrategy.detailed:
        tokens = 1600;
        timeout = 9000;
        break;
      case AnswerDepthStrategy.comprehensive:
        tokens = 3200;
        timeout = 15000;
        break;
    }

    final specialists = <String>[];
    if (understanding.requiresCodeGeneration) specialists.add('software_engineer');
    if (understanding.requiresCalculations) specialists.add('metabolic_calculator');
    if (understanding.requiresExternalResearch) specialists.add('scientific_researcher');

    return ExecutionPlan(
      planId: 'PLAN-${DateTime.now().millisecondsSinceEpoch}',
      understanding: understanding,
      depthStrategy: understanding.depthStrategy,
      ragDecision: rag,
      requiredSpecialists: specialists,
      intendedBlockTypes: intendedBlocks,
      tokenBudget: tokens,
      timeoutMs: timeout,
      canExecuteDirectly: !understanding.requiresExternalResearch,
    );
  }
}
