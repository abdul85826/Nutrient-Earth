// ==============================================================================
// Nutrient Earth — Query Decomposition & Compound Intent Service (Schema v2026.3)
// Master Engineering Hardening: Parts B & E
//
// Decomposes compound, multi-part, and anaphoric inquiries into independent
// atomic sub-queries, resolves context continuity, and classifies ambiguity.
// ==============================================================================

import '../../domain/input_gateway/universal_input_descriptor.dart';
import '../../domain/orchestration/adaptive_execution_planner.dart';
import '../../domain/orchestration/universal_intelligence_router.dart';

/// Relationship between sub-questions in a compound inquiry
enum CoordinationType {
  single,       // Standard atomic inquiry
  independent,  // Distinct questions that can be analyzed in parallel
  sequential,   // Secondary question depends on primary question's outcome
  comparative,  // Explicit comparison between two or more subjects
}

/// Level of semantic ambiguity detected in query
enum AmbiguityClassification {
  none,      // Query is unambiguous and directly actionable
  minor,     // Slight ambiguity; proceed with primary interpretation and acknowledge
  material,  // Critical ambiguity; requires explicit clarification before definitive action
}

/// A focused sub-question extracted from a compound user inquiry
class SubQuestion {
  final String id;
  final String queryText;
  final String focus;
  final UniversalIntent intent;
  final SubjectDomain domain;
  final bool requiresResearch;
  final bool requiresCalculation;
  final List<String> targetEntities;

  const SubQuestion({
    required this.id,
    required this.queryText,
    required this.focus,
    required this.intent,
    required this.domain,
    this.requiresResearch = false,
    this.requiresCalculation = false,
    this.targetEntities = const [],
  });
}

/// Structured clarification option when ambiguity is material
class ClarificationOption {
  final String optionId;
  final String label;
  final String description;
  final String refinedQuery;

  const ClarificationOption({
    required this.optionId,
    required this.label,
    required this.description,
    required this.refinedQuery,
  });
}

/// Output of Query Decomposition
class DecompositionResult {
  final String originalQuery;
  final String normalizedQuery;
  final bool isCompound;
  final CoordinationType coordinationType;
  final List<SubQuestion> subQuestions;
  final AmbiguityClassification ambiguity;
  final List<ClarificationOption> clarificationOptions;
  final String? primaryEntity;

  const DecompositionResult({
    required this.originalQuery,
    required this.normalizedQuery,
    required this.isCompound,
    required this.coordinationType,
    required this.subQuestions,
    required this.ambiguity,
    this.clarificationOptions = const [],
    this.primaryEntity,
  });
}

class QueryDecompositionService {
  QueryDecompositionService._();

  static final RegExp _multiQuestionMarks = RegExp(r'\?+');
  static final RegExp _listDelimiter = RegExp(r'[,;]|\band\b', caseSensitive: false);

  /// Decomposes an incoming query into atomic sub-questions with context resolution
  static DecompositionResult decompose({
    required String query,
    String? priorTurnQuery,
    String? priorReferencedEntity,
  }) {
    final raw = query.trim();
    final lower = raw.toLowerCase();

    // 1. Ambiguity Triage
    final ambiguity = _assessAmbiguity(lower);
    final clarificationOptions = <ClarificationOption>[];

    if (ambiguity == AmbiguityClassification.material) {
      clarificationOptions.addAll(_generateClarificationOptions(lower));
    }

    // 2. Identify entity candidates
    final primaryEntity = _extractPrimaryEntity(lower, priorEntity: priorReferencedEntity);

    // 3. Multi-Question Split Check
    // A query with multiple question marks, e.g.: "What is creatine? How much to take? Any side effects?"
    if (raw.contains('?') && raw.indexOf('?') != raw.lastIndexOf('?')) {
      final segments = raw.split(_multiQuestionMarks)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length > 2)
          .toList();

      if (segments.length > 1) {
        final subs = <SubQuestion>[];
        for (int i = 0; i < segments.length; i++) {
          final seg = segments[i];
          final enriched = _enrichWithContext(seg, primaryEntity);
          subs.add(_buildSubQuestion(
            id: 'sq-${i + 1}',
            queryText: enriched,
            rawSegment: seg,
            entity: primaryEntity,
          ));
        }

        return DecompositionResult(
          originalQuery: raw,
          normalizedQuery: raw,
          isCompound: true,
          coordinationType: CoordinationType.independent,
          subQuestions: subs,
          ambiguity: ambiguity,
          clarificationOptions: clarificationOptions,
          primaryEntity: primaryEntity,
        );
      }
    }

    // 4. Conjunction Decomposition
    // Handles multi-part inquiries with "and" / "as well as" / "plus"
    // e.g.: "magnesium sleep benefits, optimal dosage, and interaction with l-theanine"
    final compoundSubParts = _detectConjoinedSubQuestions(raw, primaryEntity);
    if (compoundSubParts.length > 1) {
      return DecompositionResult(
        originalQuery: raw,
        normalizedQuery: raw,
        isCompound: true,
        coordinationType: CoordinationType.independent,
        subQuestions: compoundSubParts,
        ambiguity: ambiguity,
        clarificationOptions: clarificationOptions,
        primaryEntity: primaryEntity,
      );
    }

    // 5. Comparison Detection
    if (lower.startsWith('compare ') || lower.contains(' vs ') || lower.contains(' versus ') || lower.contains('difference between')) {
      final entities = _extractComparativeEntities(lower);
      final subs = <SubQuestion>[
        _buildSubQuestion(
          id: 'sq-comp-1',
          queryText: raw,
          rawSegment: raw,
          entity: entities.isNotEmpty ? entities.first : primaryEntity,
          forceIntent: UniversalIntent.evidenceComparison,
        ),
      ];

      return DecompositionResult(
        originalQuery: raw,
        normalizedQuery: raw,
        isCompound: false,
        coordinationType: CoordinationType.comparative,
        subQuestions: subs,
        ambiguity: ambiguity,
        clarificationOptions: clarificationOptions,
        primaryEntity: primaryEntity,
      );
    }

    // 6. Single Standard Query
    final enriched = _enrichWithContext(raw, primaryEntity);
    return DecompositionResult(
      originalQuery: raw,
      normalizedQuery: enriched,
      isCompound: false,
      coordinationType: CoordinationType.single,
      subQuestions: [
        _buildSubQuestion(
          id: 'sq-1',
          queryText: enriched,
          rawSegment: raw,
          entity: primaryEntity,
        ),
      ],
      ambiguity: ambiguity,
      clarificationOptions: clarificationOptions,
      primaryEntity: primaryEntity,
    );
  }

  /// Evaluates query ambiguity
  static AmbiguityClassification _assessAmbiguity(String query) {
    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    // Solitary highly ambiguous keywords
    const ambiguousSingleTokens = {
      'mercury', 'lead', 'iron', 'zinc', 'fasting', 'keto', 'magnesium', 'water',
      'protein', 'collagen', 'creatine', 'caffeine', 'ashwagandha', 'melatonin',
    };

    if (tokens.length == 1 && ambiguousSingleTokens.contains(tokens.first)) {
      return AmbiguityClassification.material;
    }

    if (tokens.length == 2 && (tokens.first == 'the' || tokens.first == 'about') && ambiguousSingleTokens.contains(tokens.last)) {
      return AmbiguityClassification.material;
    }

    if (query.startsWith('is it good') || query == 'safe?' || query == 'how to use') {
      return AmbiguityClassification.material;
    }

    if (tokens.length <= 3 && !query.contains('?') && !query.contains('how') && !query.contains('what')) {
      return AmbiguityClassification.minor;
    }

    return AmbiguityClassification.none;
  }

  /// Generates structured clarification options for ambiguous inquiries
  static List<ClarificationOption> _generateClarificationOptions(String query) {
    final token = query.replaceAll(RegExp(r'[^\w\s]'), '').trim();

    return [
      ClarificationOption(
        optionId: 'opt-dosage',
        label: 'Dosage & Protocols',
        description: 'Optimal evidence-based dosage, timing, and administration guidelines.',
        refinedQuery: 'What is the optimal evidence-based dosage and timing for $token?',
      ),
      ClarificationOption(
        optionId: 'opt-benefits',
        label: 'Clinical Benefits & Evidence',
        description: 'Human clinical trial outcomes, mechanisms, and physiological efficacy.',
        refinedQuery: 'What are the proven clinical health benefits and mechanisms of $token?',
      ),
      ClarificationOption(
        optionId: 'opt-safety',
        label: 'Safety & Contraindications',
        description: 'Upper intake limits, drug interactions, toxicology, and side effects.',
        refinedQuery: 'What are the known safety warnings, side effects, and drug interactions for $token?',
      ),
      ClarificationOption(
        optionId: 'opt-sources',
        label: 'Dietary & Bioavailable Sources',
        description: 'Whole-food sources, chemical forms, and absorption rates.',
        refinedQuery: 'What are the highest dietary food sources and most bioavailable forms of $token?',
      ),
    ];
  }

  /// Extracts primary entity from query or history
  static String? _extractPrimaryEntity(String lower, {String? priorEntity}) {
    const knownEntities = [
      'creatine', 'magnesium', 'vitamin d', 'omega-3', 'fish oil', 'zinc', 'ashwagandha',
      'l-theanine', 'curcumin', 'melatonin', 'cast iron', 'stainless steel', 'teflon',
      'glycine', 'collagen', 'electrolytes', 'potassium', 'coq10', 'berberine',
    ];

    for (final ent in knownEntities) {
      if (lower.contains(ent)) return ent;
    }

    return priorEntity;
  }

  /// Resolves pronouns and anaphoric expressions
  static String _enrichWithContext(String segment, String? entity) {
    if (entity == null || entity.isEmpty) return segment;
    final lower = segment.toLowerCase().trim();

    // If segment already names the entity, leave as-is
    if (lower.contains(entity)) return segment;

    // Check for pronoun or missing subject
    if (lower.contains('it') || lower.contains('this') || lower.contains('its') ||
        lower.startsWith('how much') || lower.startsWith('dosage') ||
        lower.startsWith('side effects') || lower.startsWith('benefits') ||
        lower.startsWith('is it safe') || lower.startsWith('why?')) {
      return '$segment ($entity)';
    }

    return segment;
  }

  /// Detects compound sub-questions joined by "and", commas, or multiple clauses
  static List<SubQuestion> _detectConjoinedSubQuestions(String raw, String? entity) {
    final lower = raw.toLowerCase();

    // Check for indicators of multi-topic inquiries
    final hasMultipleTopics = (lower.contains('benefits') && lower.contains('dosage')) ||
        (lower.contains('dosage') && lower.contains('interaction')) ||
        (lower.contains('benefits') && lower.contains('side effects')) ||
        (lower.contains('how to take') && lower.contains('when to take')) ||
        (lower.contains('pros') && lower.contains('cons'));

    if (!hasMultipleTopics) return [];

    final parts = <SubQuestion>[];
    int count = 1;

    if (lower.contains('benefit')) {
      parts.add(_buildSubQuestion(
        id: 'sq-${count++}',
        queryText: 'What are the clinical benefits and mechanisms of ${entity ?? 'this'}?',
        rawSegment: 'benefits',
        entity: entity,
        forceIntent: UniversalIntent.scientificResearch,
      ));
    }

    if (lower.contains('dosage') || lower.contains('how much') || lower.contains('how to take')) {
      parts.add(_buildSubQuestion(
        id: 'sq-${count++}',
        queryText: 'What is the optimal dosage and protocol for ${entity ?? 'this'}?',
        rawSegment: 'dosage protocol',
        entity: entity,
        forceIntent: UniversalIntent.scientificResearch,
      ));
    }

    if (lower.contains('interaction') || lower.contains('side effect') || lower.contains('safety')) {
      parts.add(_buildSubQuestion(
        id: 'sq-${count++}',
        queryText: 'What are the interactions, safety warnings, and contraindications for ${entity ?? 'this'}?',
        rawSegment: 'interactions and safety',
        entity: entity,
        forceIntent: UniversalIntent.symptomInquiry,
      ));
    }

    return parts;
  }

  /// Extracts entities being compared
  static List<String> _extractComparativeEntities(String lower) {
    final entities = <String>[];
    const candidateEntities = [
      'cast iron', 'stainless steel', 'teflon', 'non-stick', 'copper', 'ceramic',
      'magnesium glycinate', 'magnesium oxide', 'magnesium citrate', 'creatine monohydrate', 'creatine hcl',
      'whey', 'plant protein', 'butter', 'ghee', 'olive oil', 'seed oils',
    ];

    for (final cand in candidateEntities) {
      if (lower.contains(cand)) entities.add(cand);
    }
    return entities;
  }

  /// Helper to build a validated SubQuestion
  static SubQuestion _buildSubQuestion({
    required String id,
    required String queryText,
    required String rawSegment,
    String? entity,
    UniversalIntent? forceIntent,
  }) {
    final understanding = AdaptiveExecutionPlanner.understandRequest(query: queryText);

    return SubQuestion(
      id: id,
      queryText: queryText,
      focus: rawSegment,
      intent: forceIntent ?? understanding.intent,
      domain: understanding.subjectDomain,
      requiresResearch: understanding.requiresExternalResearch,
      requiresCalculation: understanding.requiresCalculations,
      targetEntities: entity != null ? [entity] : [],
    );
  }
}
