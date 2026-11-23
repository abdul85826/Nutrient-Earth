// ==============================================================================
// Nutrient Earth — Response Relevance Gate
// Production architectural gatekeeper ensuring strict intent-response coherence,
// citation integrity, disclaimer necessity, and zero hallucinated evidence badges.
// ==============================================================================

import '../../domain/answer_contract/universal_intelligence_answer.dart';
import '../../domain/evidence/scientific_evidence_contract.dart';
import '../../domain/orchestration/universal_intelligence_router.dart';
import '../../domain/personalization/goal_alignment_evaluator.dart';

class ResponseRelevanceGate {
  ResponseRelevanceGate._();

  /// Validates and sanitizes any candidate answer before returning it to the presentation layer.
  static UniversalIntelligenceAnswer validateAndSanitize({
    required String query,
    required IntentRoutingDecision routing,
    required UniversalIntelligenceAnswer rawAnswer,
  }) {
    UniversalIntelligenceAnswer sanitized = rawAnswer;

    // 1. Social & Conversational Dialogues (Strict zero-RAG, zero-citation, zero-disclaimer policy)
    if (routing.intent.isConversational) {
      final textContent = rawAnswer.heroAnswer.isNotEmpty
          ? (rawAnswer.detailedExplanation.isNotEmpty
              ? '${rawAnswer.heroAnswer}\n\n${rawAnswer.detailedExplanation}'
              : rawAnswer.heroAnswer)
          : rawAnswer.detailedExplanation;

      final convBlocks = <ResponseContentBlock>[
        TextBlock(content: textContent, calloutType: TextCalloutType.leadSummary),
        const InteractiveSuggestionsBlock(
          promptChips: [
            'Is cast iron safe for acidic food?',
            'What is dietary fiber?',
            'How much protein do I need?',
            'Evaluate non-stick cookware',
          ],
        ),
      ];

      return rawAnswer.copyWith(
        responseType: UniversalResponseType.conversation,
        depthStrategy: AnswerDepthStrategy.minimal,
        blocks: convBlocks,
        evidence: const EvidenceProvenanceContainer.empty(),
        practicalSteps: const [],
        uncertaintyDisclaimer: '',
        legacyEvidenceBadge: null,
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.neutral,
          matchLabel: 'Conversational Dialogue',
          rationale: 'General conversational dialogue does not require goal alignment scoring.',
        ),
      );
    }

    // 2. Emergency Medical Triage
    if (routing.isSafetyCritical || routing.intent == UniversalIntent.safetyCriticalEmergency) {
      final emergencyDisclaimer = rawAnswer.uncertaintyDisclaimer.isNotEmpty
          ? rawAnswer.uncertaintyDisclaimer
          : 'Nutrient Earth does not diagnose or manage acute emergency medical events. Seek immediate emergency medical care.';

      final triageBlocks = <ResponseContentBlock>[
        SafetyNoticeBlock(
          severity: SafetySeverity.criticalEmergency,
          title: 'EMERGENCY MEDICAL TRIAGE',
          message: rawAnswer.heroAnswer,
          emergencyActions: rawAnswer.practicalSteps,
        ),
        TextBlock(content: rawAnswer.detailedExplanation),
      ];

      return rawAnswer.copyWith(
        responseType: UniversalResponseType.safetyResponse,
        depthStrategy: AnswerDepthStrategy.concise,
        blocks: triageBlocks,
        legacyEvidenceBadge: 'CLINICAL SAFETY BOUNDARY',
        uncertaintyDisclaimer: emergencyDisclaimer,
      );
    }

    // 3. General Knowledge & Health Education Concept Queries
    if (routing.intent == UniversalIntent.generalKnowledge ||
        routing.intent == UniversalIntent.healthEducation) {
      final sanitizedType = UniversalResponseType.explanation;

      // If user did not ask for research citations, do not inject arbitrary study citations
      final shouldKeepCitations = routing.requiresEvidenceCitations &&
          rawAnswer.evidence.citations.isNotEmpty &&
          _isCitationRelevant(query, rawAnswer.evidence.citations);

      final sanitizedEvidence = shouldKeepCitations
          ? rawAnswer.evidence
          : const EvidenceProvenanceContainer.empty();

      // Ensure blocks match concept explanation
      List<ResponseContentBlock> blocks = rawAnswer.blocks;
      if (blocks.isEmpty) {
        blocks = [
          TextBlock(content: rawAnswer.heroAnswer, calloutType: TextCalloutType.leadSummary),
          if (rawAnswer.detailedExplanation.isNotEmpty)
            TextBlock(content: rawAnswer.detailedExplanation),
        ];
      } else {
        // Strip any unrequested citation or disclaimer blocks
        if (!shouldKeepCitations) {
          blocks = blocks.where((b) => b is! EvidenceCardBlock).toList();
        }
      }

      return rawAnswer.copyWith(
        responseType: sanitizedType,
        depthStrategy: AnswerDepthStrategy.concise,
        blocks: blocks,
        evidence: sanitizedEvidence,
        legacyEvidenceBadge: shouldKeepCitations ? rawAnswer.legacyEvidenceBadge : null,
        uncertaintyDisclaimer: routing.requiresMedicalDisclaimer ? rawAnswer.uncertaintyDisclaimer : '',
      );
    }

    // 4. Symptom & Physiological Inquiries ("why am I tired", "bloating", etc.)
    if (routing.intent == UniversalIntent.symptomInquiry) {
      final disclaimer = rawAnswer.uncertaintyDisclaimer.isNotEmpty
          ? rawAnswer.uncertaintyDisclaimer
          : 'Nutrient Earth explores nutritional and physiological factors for educational guidance; it does not replace individualized clinical diagnosis.';

      final shouldKeepCitations = routing.requiresEvidenceCitations &&
          rawAnswer.evidence.citations.isNotEmpty &&
          _isCitationRelevant(query, rawAnswer.evidence.citations);

      List<ResponseContentBlock> blocks = rawAnswer.blocks;
      if (blocks.isEmpty) {
        blocks = [
          TextBlock(content: rawAnswer.heroAnswer, calloutType: TextCalloutType.leadSummary),
          if (rawAnswer.detailedExplanation.isNotEmpty)
            TextBlock(content: rawAnswer.detailedExplanation),
          if (rawAnswer.practicalSteps.isNotEmpty)
            ActionPlanBlock(
              title: 'Recommended Lifestyle Considerations',
              steps: rawAnswer.practicalSteps.map((s) => ActionStepItem(title: s)).toList(),
            ),
          SafetyNoticeBlock(
            severity: SafetySeverity.medicalDisclaimer,
            title: 'Clinical Guidance Boundary',
            message: disclaimer,
          ),
        ];
      }

      return rawAnswer.copyWith(
        responseType: UniversalResponseType.personalHealthInsight,
        depthStrategy: AnswerDepthStrategy.standard,
        blocks: blocks,
        evidence: shouldKeepCitations ? rawAnswer.evidence : const EvidenceProvenanceContainer.empty(),
        legacyEvidenceBadge: shouldKeepCitations ? rawAnswer.legacyEvidenceBadge : null,
        uncertaintyDisclaimer: disclaimer,
      );
    }

    // 5. Product & Utensil Safety Inquiries
    if (routing.intent == UniversalIntent.productSafetyResearch) {
      final isUtensil = routing.primaryCategory == IntelligenceCategory.utensilAndCookwareSafety;
      final badge = rawAnswer.evidence.hasVerifiedSources && rawAnswer.evidence.citations.isNotEmpty
          ? (isUtensil ? 'COOKWARE TOXICOLOGY & SAFETY AUDIT' : 'VERIFIED PRODUCT DATABASE')
          : null;

      List<ResponseContentBlock> blocks = rawAnswer.blocks;
      if (blocks.isEmpty) {
        blocks = [
          ProductAuditBlock(
            productName: rawAnswer.heroAnswer,
            brand: 'Kitchen Material Safety',
            safetyProfile: rawAnswer.recommendation,
            recommendation: rawAnswer.recommendation,
          ),
          if (rawAnswer.detailedExplanation.isNotEmpty)
            TextBlock(content: rawAnswer.detailedExplanation),
          if (rawAnswer.practicalSteps.isNotEmpty)
            ActionPlanBlock(
              title: 'Best Culinary Practices',
              steps: rawAnswer.practicalSteps.map((s) => ActionStepItem(title: s)).toList(),
            ),
          if (rawAnswer.evidence.hasVerifiedSources && rawAnswer.evidence.citations.isNotEmpty)
            EvidenceCardBlock(
              watermarkLabel: badge ?? 'Food Contact Materials Toxicology',
              citations: rawAnswer.evidence.citations,
              hasVerifiedSources: true,
            ),
        ];
      }

      return rawAnswer.copyWith(
        responseType: isUtensil ? UniversalResponseType.nutritionKnowledge : UniversalResponseType.productAnalysis,
        depthStrategy: AnswerDepthStrategy.standard,
        blocks: blocks,
        legacyEvidenceBadge: badge,
      );
    }

    // 6. Generic Verification: Never claim "VERIFIED SOURCES AVAILABLE" if 0 genuine citations
    if (!rawAnswer.evidence.hasVerifiedSources || rawAnswer.evidence.citations.isEmpty) {
      sanitized = rawAnswer.copyWith(
        evidence: rawAnswer.evidence.copyWith(
          hasVerifiedSources: false,
          watermarkLabel: 'No verified scientific sources',
          citations: const [],
        ),
        legacyEvidenceBadge: null,
      );
    }

    // Ensure blocks are populated if empty
    if (sanitized.blocks.isEmpty) {
      final blocks = <ResponseContentBlock>[
        TextBlock(content: sanitized.heroAnswer, calloutType: TextCalloutType.leadSummary),
        if (sanitized.detailedExplanation.isNotEmpty)
          TextBlock(content: sanitized.detailedExplanation),
        if (sanitized.practicalSteps.isNotEmpty)
          ActionPlanBlock(
            title: 'Actionable Steps',
            steps: sanitized.practicalSteps.map((s) => ActionStepItem(title: s)).toList(),
          ),
        if (sanitized.evidence.hasVerifiedSources && sanitized.evidence.citations.isNotEmpty)
          EvidenceCardBlock(
            watermarkLabel: sanitized.legacyEvidenceBadge ?? 'Verified Scientific Evidence',
            citations: sanitized.evidence.citations,
            hasVerifiedSources: true,
          ),
      ];
      sanitized = sanitized.copyWith(blocks: blocks);
    }

    return sanitized;
  }

  /// Checks whether attached citations actually correlate with the user inquiry topic
  static bool _isCitationRelevant(String query, List<ScientificSource> citations) {
    if (citations.isEmpty) return false;
    final lower = query.toLowerCase();
    final queryTokens = lower
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(' ')
        .where((t) => t.length > 3 && !_stopWords.contains(t))
        .toList();

    if (queryTokens.isEmpty) return true;

    for (final cit in citations) {
      final citText = '${cit.title} ${cit.authorsOrJournal}'.toLowerCase();
      for (final token in queryTokens) {
        if (citText.contains(token)) return true;
      }
    }
    return false;
  }

  static const Set<String> _stopWords = {
    'what', 'when', 'where', 'which', 'who', 'whom', 'this', 'that', 'these',
    'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have',
    'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the',
    'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at',
    'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through',
    'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down',
    'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once',
  };
}
