// ==============================================================================
// Nutrient Earth — Universal Multimodal Intelligence Answer Contract (Schema v2026.2)
// Clean Architecture representation of evidence-grounded, goal-aligned answers.
// Conforms to the 5 visual presentation rules:
// 1. The answer is the hero.
// 2. The goal-match indicator is a small secondary element.
// 3. Evidence is represented by a subtle symbol or watermark.
// 4. The evidence symbol appears ONLY when actual supporting sources exist.
// 5. Clicking it opens the exact inspectable evidence (claims, DOIs, limitations).
// ==============================================================================

import '../blockchain/evidence_integrity_service.dart';
import '../evidence/scientific_evidence_contract.dart';
import '../input_gateway/universal_input_descriptor.dart';
import '../nutrition/nutrition_models.dart';
import '../personalization/goal_alignment_evaluator.dart';
import 'response_content_block.dart';

export 'response_content_block.dart';

export '../evidence/scientific_evidence_contract.dart' show EvidenceClassification;

/// Explicit architectural response types adapting UI and processing to intent.
enum UniversalResponseType {
  conversation,
  explanation,
  nutritionKnowledge,
  nutritionCalculation,
  researchSynthesis,
  productAnalysis,
  ingredientAnalysis,
  imageAnalysis,
  documentAnalysis,
  comparison,
  personalizedGuidance,
  actionPlan,
  personalHealthInsight,
  clarification,
  safetyResponse,
  codeSolution,
  error;

  String get displayName {
    switch (this) {
      case UniversalResponseType.conversation:
        return 'Conversation';
      case UniversalResponseType.explanation:
        return 'Explanation';
      case UniversalResponseType.codeSolution:
        return 'Code & Computation';
      case UniversalResponseType.nutritionKnowledge:
        return 'Nutrition Knowledge';
      case UniversalResponseType.nutritionCalculation:
        return 'Nutrition Calculation';
      case UniversalResponseType.researchSynthesis:
        return 'Research Synthesis';
      case UniversalResponseType.productAnalysis:
        return 'Product Analysis';
      case UniversalResponseType.ingredientAnalysis:
        return 'Ingredient Analysis';
      case UniversalResponseType.imageAnalysis:
        return 'Image Analysis';
      case UniversalResponseType.documentAnalysis:
        return 'Document Analysis';
      case UniversalResponseType.comparison:
        return 'Evidence Comparison';
      case UniversalResponseType.personalizedGuidance:
        return 'Personalized Guidance';
      case UniversalResponseType.actionPlan:
        return 'Action Plan';
      case UniversalResponseType.personalHealthInsight:
        return 'Health Insight';
      case UniversalResponseType.clarification:
        return 'Clarification';
      case UniversalResponseType.safetyResponse:
        return 'Safety Notice';
      case UniversalResponseType.error:
        return 'Notice';
    }
  }

  static UniversalResponseType fromString(String? raw) {
    if (raw == null) return UniversalResponseType.researchSynthesis;
    final lower = raw.toLowerCase().trim();
    for (final t in UniversalResponseType.values) {
      if (t.name.toLowerCase() == lower) return t;
    }
    return UniversalResponseType.researchSynthesis;
  }
}

/// Image quality diagnostic assessment for visual inquiries.
class ImageQualityAssessment {
  final double blurScore; // 0.0 (crisp) to 1.0 (severely blurry)
  final double exposureScore; // 0.0 (underexposed) to 1.0 (overexposed)
  final bool textLegible;
  final bool subjectIdentified;
  final bool isSuitableForTask;
  final String diagnosticNotes;

  const ImageQualityAssessment({
    this.blurScore = 0.0,
    this.exposureScore = 0.5,
    this.textLegible = true,
    this.subjectIdentified = true,
    this.isSuitableForTask = true,
    required this.diagnosticNotes,
  });

  factory ImageQualityAssessment.fromJson(Map<String, dynamic> json) {
    return ImageQualityAssessment(
      blurScore: (json['blurScore'] as num?)?.toDouble() ?? 0.0,
      exposureScore: (json['exposureScore'] as num?)?.toDouble() ?? 0.5,
      textLegible: json['textLegible'] as bool? ?? true,
      subjectIdentified: json['subjectIdentified'] as bool? ?? true,
      isSuitableForTask: json['isSuitableForTask'] as bool? ?? true,
      diagnosticNotes: json['diagnosticNotes'] as String? ?? 'Visual assessment complete',
    );
  }

  Map<String, dynamic> toJson() => {
        'blurScore': blurScore,
        'exposureScore': exposureScore,
        'textLegible': textLegible,
        'subjectIdentified': subjectIdentified,
        'isSuitableForTask': isSuitableForTask,
        'diagnosticNotes': diagnosticNotes,
      };
}

/// Video-specific transcript and claim analysis artifact.
class VideoUnderstandingArtifact {
  final int durationSeconds;
  final String detectedLanguage;
  final String transcript;
  final String? translatedEnglishTranscript;
  final List<VideoTimestampedClaim> speakerClaims;
  final String? socialPlatform;
  final bool isSocialUrlIngestion;
  final String captionAvailability;

  const VideoUnderstandingArtifact({
    this.durationSeconds = 0,
    required this.detectedLanguage,
    required this.transcript,
    this.translatedEnglishTranscript,
    this.speakerClaims = const [],
    this.socialPlatform,
    this.isSocialUrlIngestion = false,
    this.captionAvailability = 'accessible',
  });

  /// Compatibility aliases
  List<VideoTimestampedClaim> get claims => speakerClaims;
  String get fullTranscript => transcript;

  factory VideoUnderstandingArtifact.fromJson(Map<String, dynamic> json) {
    return VideoUnderstandingArtifact(
      detectedLanguage: json['detectedLanguage'] as String? ?? 'en',
      transcript: json['transcript'] as String? ?? '',
      translatedEnglishTranscript: json['translatedEnglishTranscript'] as String?,
      speakerClaims: (json['speakerClaims'] as List<dynamic>?)
              ?.map((c) => VideoTimestampedClaim.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      socialPlatform: json['socialPlatform'] as String?,
      isSocialUrlIngestion: json['isSocialUrlIngestion'] as bool? ?? false,
      captionAvailability: json['captionAvailability'] as String? ?? 'accessible',
    );
  }

  Map<String, dynamic> toJson() => {
        'detectedLanguage': detectedLanguage,
        'transcript': transcript,
        'translatedEnglishTranscript': translatedEnglishTranscript,
        'speakerClaims': speakerClaims.map((c) => c.toJson()).toList(),
        'socialPlatform': socialPlatform,
        'isSocialUrlIngestion': isSocialUrlIngestion,
        'captionAvailability': captionAvailability,
      };
}

/// An individual claim made by a video speaker tied to a specific timestamp.
class VideoTimestampedClaim {
  final String timestamp;
  final String speakerStatement;
  final String scientificStatus; // 'supported', 'contradicted', 'unverified'
  final String scientificFinding;

  const VideoTimestampedClaim({
    required this.timestamp,
    required this.speakerStatement,
    required this.scientificStatus,
    required this.scientificFinding,
  });

  factory VideoTimestampedClaim.fromJson(Map<String, dynamic> json) {
    return VideoTimestampedClaim(
      timestamp: json['timestamp'] as String? ?? '0:00',
      speakerStatement: json['speakerStatement'] as String? ?? '',
      scientificStatus: json['scientificStatus'] as String? ?? 'unverified',
      scientificFinding: json['scientificFinding'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'speakerStatement': speakerStatement,
        'scientificStatus': scientificStatus,
        'scientificFinding': scientificFinding,
      };
}

/// Secondary Goal Match element (Rule 2).
class GoalMatchIndicator {
  final int? matchPercentage; // e.g. 84, or null if insufficient context
  final GoalAlignmentStatus status;
  final String matchLabel; // e.g. '84% Goal match' or 'Not enough information'
  final String rationale;
  final List<String> positiveFactors;
  final List<String> riskFactors;
  final String? missingContextNotes;

  const GoalMatchIndicator({
    this.matchPercentage,
    required this.status,
    required this.matchLabel,
    required this.rationale,
    this.positiveFactors = const [],
    this.riskFactors = const [],
    this.missingContextNotes,
  });

  bool get hasSufficientContext => matchPercentage != null && status != GoalAlignmentStatus.insufficientInformation;

  factory GoalMatchIndicator.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String?;
    final status = _parseStatus(statusStr);
    final pct = (json['matchPercentage'] as num?)?.toInt();

    return GoalMatchIndicator(
      matchPercentage: pct,
      status: status,
      matchLabel: json['matchLabel'] as String? ??
          (pct != null ? '$pct% Goal match' : 'Not enough information to assess'),
      rationale: json['rationale'] as String? ?? '',
      positiveFactors: (json['positiveFactors'] as List<dynamic>?)?.map((f) => f.toString()).toList() ?? const [],
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.map((r) => r.toString()).toList() ?? const [],
      missingContextNotes: json['missingContextNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchPercentage': matchPercentage,
        'status': status.name,
        'matchLabel': matchLabel,
        'rationale': rationale,
        'positiveFactors': positiveFactors,
        'riskFactors': riskFactors,
        'missingContextNotes': missingContextNotes,
      };

  static GoalAlignmentStatus _parseStatus(String? raw) {
    if (raw == null) return GoalAlignmentStatus.insufficientInformation;
    for (final s in GoalAlignmentStatus.values) {
      if (s.name.toLowerCase() == raw.toLowerCase()) return s;
    }
    return GoalAlignmentStatus.insufficientInformation;
  }
}

/// Verified Evidence Provenance element (Rules 3, 4, 5).
class EvidenceProvenanceContainer {
  final bool hasVerifiedSources; // Rule 4: true ONLY if actual verified sources exist
  final EvidenceClassification classification;
  final String watermarkLabel; // e.g. 'Verified sources available'
  final List<ScientificSource> citations;
  final List<ScientificClaim> claims;
  final String? limitationsNotes;

  const EvidenceProvenanceContainer({
    required this.hasVerifiedSources,
    required this.classification,
    required this.watermarkLabel,
    this.citations = const [],
    this.claims = const [],
    this.limitationsNotes,
  });

  /// Factory for casual conversations, pleasantries, or general definitions without verified research sources
  const EvidenceProvenanceContainer.empty()
      : hasVerifiedSources = false,
        classification = EvidenceClassification.notVerified,
        watermarkLabel = '',
        citations = const [],
        claims = const [],
        limitationsNotes = null;

  EvidenceProvenanceContainer copyWith({
    bool? hasVerifiedSources,
    EvidenceClassification? classification,
    String? watermarkLabel,
    List<ScientificSource>? citations,
    List<ScientificClaim>? claims,
    String? limitationsNotes,
  }) {
    return EvidenceProvenanceContainer(
      hasVerifiedSources: hasVerifiedSources ?? this.hasVerifiedSources,
      classification: classification ?? this.classification,
      watermarkLabel: watermarkLabel ?? this.watermarkLabel,
      citations: citations ?? this.citations,
      claims: claims ?? this.claims,
      limitationsNotes: limitationsNotes ?? this.limitationsNotes,
    );
  }

  factory EvidenceProvenanceContainer.fromJson(Map<String, dynamic> json) {
    final citationsList = (json['citations'] as List<dynamic>?)
            ?.map((c) => ScientificSource.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [];

    final hasSources = (json['hasVerifiedSources'] as bool? ?? false) && citationsList.isNotEmpty;

    return EvidenceProvenanceContainer(
      hasVerifiedSources: hasSources,
      classification: EvidenceClassification.fromString(json['classification'] as String?),
      watermarkLabel: json['watermarkLabel'] as String? ??
          (hasSources ? 'Verified sources available' : 'No verified scientific sources'),
      citations: citationsList,
      claims: (json['claims'] as List<dynamic>?)
              ?.map((c) => ScientificClaim.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      limitationsNotes: json['limitationsNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'hasVerifiedSources': hasVerifiedSources,
        'classification': classification.name,
        'watermarkLabel': watermarkLabel,
        'citations': citations.map((c) => c.toJson()).toList(),
        'claims': claims.map((c) => c.toJson()).toList(),
        'limitationsNotes': limitationsNotes,
      };
}

/// Master Unified Answer Contract (Schema v2026.2).
class UniversalIntelligenceAnswer {
  final String contractVersion; // '2026.3'
  final String referenceId;
  final UserInputType detectedInputType;
  final UniversalResponseType responseType;
  final AnswerDepthStrategy depthStrategy;
  final List<ResponseContentBlock> blocks;
  final String query;
  final String heroAnswer; // Rule 1: The answer is the hero
  final String recommendation; // Personalized guidance
  final String detailedExplanation;
  final GoalMatchIndicator goalMatch; // Rule 2: Small secondary element
  final EvidenceProvenanceContainer evidence; // Rules 3, 4, 5: Evidence watermark & inspection
  final List<String> practicalSteps;
  final List<String> clarificationOptions;
  final ImageQualityAssessment? imageQuality;
  final VideoUnderstandingArtifact? videoAnalysis;
  final NutritionAnalysisProfile? foodComposition;
  final String? urlSourceDetails;
  final String uncertaintyDisclaimer;
  final String providerUsed;
  final ResearchProvenanceDossier? provenanceDossier;
  final String? legacyEvidenceBadge;
  final GoalAssessmentResult? legacyGoalAlignment;
  final DateTime generatedAt;

  UniversalIntelligenceAnswer({
    this.contractVersion = '2026.3',
    required this.referenceId,
    required this.detectedInputType,
    this.responseType = UniversalResponseType.researchSynthesis,
    this.depthStrategy = AnswerDepthStrategy.standard,
    this.blocks = const [],
    required this.query,
    required this.heroAnswer,
    required this.recommendation,
    required this.detailedExplanation,
    required this.goalMatch,
    required this.evidence,
    this.practicalSteps = const [],
    this.clarificationOptions = const [],
    this.imageQuality,
    this.videoAnalysis,
    this.foodComposition,
    this.urlSourceDetails,
    required this.uncertaintyDisclaimer,
    this.providerUsed = 'Nutrient Earth Verified Evidence Base',
    this.provenanceDossier,
    this.legacyEvidenceBadge,
    this.legacyGoalAlignment,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  bool get hasBlocks => blocks.isNotEmpty;
  bool get isConversational => responseType == UniversalResponseType.conversation;
  List<T> getBlocksOfType<T extends ResponseContentBlock>() => blocks.whereType<T>().toList();
  TextBlock? get firstTextBlock => blocks.whereType<TextBlock>().firstOrNull;
  ComparisonTableBlock? get tableBlock => blocks.whereType<ComparisonTableBlock>().firstOrNull;
  CodeBlock? get codeBlock => blocks.whereType<CodeBlock>().firstOrNull;
  ActionPlanBlock? get actionPlanBlock => blocks.whereType<ActionPlanBlock>().firstOrNull;
  MetricCalculationBlock? get metricBlock => blocks.whereType<MetricCalculationBlock>().firstOrNull;
  EvidenceCardBlock? get evidenceBlock => blocks.whereType<EvidenceCardBlock>().firstOrNull;
  ProductAuditBlock? get productBlock => blocks.whereType<ProductAuditBlock>().firstOrNull;
  SafetyNoticeBlock? get safetyBlock => blocks.whereType<SafetyNoticeBlock>().firstOrNull;
  InteractiveSuggestionsBlock? get suggestionsBlock => blocks.whereType<InteractiveSuggestionsBlock>().firstOrNull;

  UniversalIntelligenceAnswer copyWith({
    String? contractVersion,
    String? referenceId,
    UserInputType? detectedInputType,
    UniversalResponseType? responseType,
    AnswerDepthStrategy? depthStrategy,
    List<ResponseContentBlock>? blocks,
    String? query,
    String? heroAnswer,
    String? recommendation,
    String? detailedExplanation,
    GoalMatchIndicator? goalMatch,
    EvidenceProvenanceContainer? evidence,
    List<String>? practicalSteps,
    List<String>? clarificationOptions,
    ImageQualityAssessment? imageQuality,
    VideoUnderstandingArtifact? videoAnalysis,
    NutritionAnalysisProfile? foodComposition,
    String? urlSourceDetails,
    String? uncertaintyDisclaimer,
    String? providerUsed,
    ResearchProvenanceDossier? provenanceDossier,
    String? legacyEvidenceBadge,
    GoalAssessmentResult? legacyGoalAlignment,
    DateTime? generatedAt,
  }) {
    return UniversalIntelligenceAnswer(
      contractVersion: contractVersion ?? this.contractVersion,
      referenceId: referenceId ?? this.referenceId,
      detectedInputType: detectedInputType ?? this.detectedInputType,
      responseType: responseType ?? this.responseType,
      depthStrategy: depthStrategy ?? this.depthStrategy,
      blocks: blocks ?? this.blocks,
      query: query ?? this.query,
      heroAnswer: heroAnswer ?? this.heroAnswer,
      recommendation: recommendation ?? this.recommendation,
      detailedExplanation: detailedExplanation ?? this.detailedExplanation,
      goalMatch: goalMatch ?? this.goalMatch,
      evidence: evidence ?? this.evidence,
      practicalSteps: practicalSteps ?? this.practicalSteps,
      clarificationOptions: clarificationOptions ?? this.clarificationOptions,
      imageQuality: imageQuality ?? this.imageQuality,
      videoAnalysis: videoAnalysis ?? this.videoAnalysis,
      foodComposition: foodComposition ?? this.foodComposition,
      urlSourceDetails: urlSourceDetails ?? this.urlSourceDetails,
      uncertaintyDisclaimer: uncertaintyDisclaimer ?? this.uncertaintyDisclaimer,
      providerUsed: providerUsed ?? this.providerUsed,
      provenanceDossier: provenanceDossier ?? this.provenanceDossier,
      legacyEvidenceBadge: legacyEvidenceBadge ?? this.legacyEvidenceBadge,
      legacyGoalAlignment: legacyGoalAlignment ?? this.legacyGoalAlignment,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// True ONLY when verified evidence exists (Rule 4).
  bool get showEvidenceWatermark => evidence.hasVerifiedSources;

  factory UniversalIntelligenceAnswer.fromJson(Map<String, dynamic> json) {
    final inputTypeStr = json['detectedInputType'] as String? ?? 'text';
    final detectedType = _parseInputType(inputTypeStr);

    final hero = json['heroAnswer'] as String? ?? json['quickAnswer'] as String? ?? json['answerSummary'] as String? ?? '';
    final detailed = json['detailedExplanation'] as String? ?? json['answerSummary'] as String? ?? '';
    final rec = json['recommendation'] as String? ??
        (json['practicalSteps'] is List && (json['practicalSteps'] as List).isNotEmpty
            ? (json['practicalSteps'] as List).first.toString()
            : 'Consider your stated wellness preferences before taking action.');

    final citations = (json['citations'] as List<dynamic>? ?? json['sources'] as List<dynamic>?)
            ?.map((c) => ScientificSource.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [];

    final hasSources = citations.isNotEmpty;

    final goalMatch = json['goalMatch'] != null
        ? GoalMatchIndicator.fromJson(json['goalMatch'] as Map<String, dynamic>)
        : GoalMatchIndicator(
            status: GoalAlignmentStatus.insufficientInformation,
            matchLabel: 'Not enough information to assess',
            rationale: 'Personalized goal match requires an active user profile with declared goals.',
          );

    final evidenceContainer = json['evidence'] != null
        ? EvidenceProvenanceContainer.fromJson(json['evidence'] as Map<String, dynamic>)
        : EvidenceProvenanceContainer(
            hasVerifiedSources: hasSources,
            classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: citations,
            claims: (json['claims'] as List<dynamic>?)
                    ?.map((c) => ScientificClaim.fromJson(c as Map<String, dynamic>))
                    .toList() ??
                const [],
          );

    final depthStrategy = AnswerDepthStrategy.fromString(json['depthStrategy'] as String?);
    final blocksList = (json['blocks'] as List<dynamic>?)
            ?.map((b) => ResponseContentBlock.fromJson(b as Map<String, dynamic>))
            .toList() ??
        const [];

    return UniversalIntelligenceAnswer(
      contractVersion: json['contractVersion'] as String? ?? '2026.3',
      referenceId: json['referenceId'] as String? ?? 'REF-2026-NE01',
      detectedInputType: detectedType,
      responseType: UniversalResponseType.fromString(json['responseType'] as String?),
      depthStrategy: depthStrategy,
      blocks: blocksList,
      query: json['query'] as String? ?? '',
      heroAnswer: hero,
      recommendation: rec,
      detailedExplanation: detailed,
      goalMatch: goalMatch,
      evidence: evidenceContainer,
      practicalSteps: (json['practicalSteps'] as List<dynamic>?)?.map((p) => p.toString()).toList() ?? const [],
      clarificationOptions: (json['clarificationOptions'] as List<dynamic>?)?.map((o) => o.toString()).toList() ?? const [],
      imageQuality: json['imageQuality'] != null
          ? ImageQualityAssessment.fromJson(json['imageQuality'] as Map<String, dynamic>)
          : null,
      videoAnalysis: json['videoAnalysis'] != null
          ? VideoUnderstandingArtifact.fromJson(json['videoAnalysis'] as Map<String, dynamic>)
          : null,
      foodComposition: json['foodComposition'] != null
          ? NutritionAnalysisProfile.fromJson(json['foodComposition'] as Map<String, dynamic>)
          : null,
      urlSourceDetails: json['urlSourceDetails'] as String?,
      uncertaintyDisclaimer: json['uncertaintyDisclaimer'] as String? ??
          'Nutrient Earth provides nutritional and health research syntheses for educational guidance; it does not replace individualized clinical care.',
      providerUsed: json['providerUsed'] as String? ?? 'Nutrient Earth Verified Evidence Base',
      provenanceDossier: json['provenanceDossier'] != null
          ? ResearchProvenanceDossier.fromJson(json['provenanceDossier'] as Map<String, dynamic>)
          : null,
      legacyEvidenceBadge: json['legacyEvidenceBadge'] as String? ?? json['evidenceBadge'] as String?,
      legacyGoalAlignment: json['goalAlignment'] != null
          ? GoalAssessmentResult.fromJson(json['goalAlignment'] as Map<String, dynamic>)
          : null,
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'contractVersion': contractVersion,
        'referenceId': referenceId,
        'detectedInputType': detectedInputType.name,
        'responseType': responseType.name,
        'depthStrategy': depthStrategy.name,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'query': query,
        'heroAnswer': heroAnswer,
        'recommendation': recommendation,
        'detailedExplanation': detailedExplanation,
        'goalMatch': goalMatch.toJson(),
        'evidence': evidence.toJson(),
        'practicalSteps': practicalSteps,
        'clarificationOptions': clarificationOptions,
        'imageQuality': imageQuality?.toJson(),
        'videoAnalysis': videoAnalysis?.toJson(),
        'foodComposition': foodComposition?.toJson(),
        'urlSourceDetails': urlSourceDetails,
        'uncertaintyDisclaimer': uncertaintyDisclaimer,
        'providerUsed': providerUsed,
        'provenanceDossier': provenanceDossier?.toJson(),
        'legacyEvidenceBadge': legacyEvidenceBadge,
        'goalAlignment': legacyGoalAlignment?.toJson(),
        'generatedAt': generatedAt.toIso8601String(),
        // Backward compatibility getters
        'answerSummary': detailedExplanation.isNotEmpty ? detailedExplanation : heroAnswer,
        'citations': evidence.citations.map((c) => c.toJson()).toList(),
        'evidenceBadge': legacyEvidenceBadge ?? (evidence.hasVerifiedSources ? 'VERIFIED SOURCES AVAILABLE' : 'NO VERIFIED SOURCES'),
      };

  static UserInputType _parseInputType(String raw) {
    final lower = raw.toLowerCase();
    for (final t in UserInputType.values) {
      if (t.name.toLowerCase() == lower) return t;
    }
    return UserInputType.text;
  }
}
