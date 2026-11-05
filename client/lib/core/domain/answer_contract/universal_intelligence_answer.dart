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

/// Evidence classification tier based on empirical study rigor.
enum EvidenceClassification {
  wellSupported, // Replicated randomized controlled trials, systematic reviews, meta-analyses
  limitedEvidence, // Small preliminary clinical trials, in-vitro/animal studies
  mixedEvidence, // Divergent or contradictory clinical outcomes across studies
  notVerified; // Unverified anecdotal or social media claim without indexed scientific basis

  String get displayName {
    switch (this) {
      case EvidenceClassification.wellSupported:
        return 'Well Supported';
      case EvidenceClassification.limitedEvidence:
        return 'Limited Evidence';
      case EvidenceClassification.mixedEvidence:
        return 'Mixed Evidence';
      case EvidenceClassification.notVerified:
        return 'Not Verified';
    }
  }

  static EvidenceClassification fromString(String? val) {
    if (val == null) return EvidenceClassification.notVerified;
    final lower = val.toLowerCase();
    if (lower.contains('well') || lower.contains('strong')) return EvidenceClassification.wellSupported;
    if (lower.contains('limit') || lower.contains('preliminary')) return EvidenceClassification.limitedEvidence;
    if (lower.contains('mix') || lower.contains('inconclusive')) return EvidenceClassification.mixedEvidence;
    return EvidenceClassification.notVerified;
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
  final String contractVersion; // '2026.2'
  final String referenceId;
  final UserInputType detectedInputType;
  final String query;
  final String heroAnswer; // Rule 1: The answer is the hero
  final String recommendation; // Personalized guidance
  final String detailedExplanation;
  final GoalMatchIndicator goalMatch; // Rule 2: Small secondary element
  final EvidenceProvenanceContainer evidence; // Rules 3, 4, 5: Evidence watermark & inspection
  final List<String> practicalSteps;
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
    this.contractVersion = '2026.2',
    required this.referenceId,
    required this.detectedInputType,
    required this.query,
    required this.heroAnswer,
    required this.recommendation,
    required this.detailedExplanation,
    required this.goalMatch,
    required this.evidence,
    this.practicalSteps = const [],
    this.imageQuality,
    this.videoAnalysis,
    this.foodComposition,
    this.urlSourceDetails,
    required this.uncertaintyDisclaimer,
    this.providerUsed = 'Nutrient Earth Multimodal Engine',
    this.provenanceDossier,
    this.legacyEvidenceBadge,
    this.legacyGoalAlignment,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

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

    return UniversalIntelligenceAnswer(
      contractVersion: json['contractVersion'] as String? ?? '2026.2',
      referenceId: json['referenceId'] as String? ?? 'REF-2026-NE01',
      detectedInputType: detectedType,
      query: json['query'] as String? ?? '',
      heroAnswer: hero,
      recommendation: rec,
      detailedExplanation: detailed,
      goalMatch: goalMatch,
      evidence: evidenceContainer,
      practicalSteps: (json['practicalSteps'] as List<dynamic>?)?.map((p) => p.toString()).toList() ?? const [],
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
      providerUsed: json['providerUsed'] as String? ?? 'Nutrient Earth Multimodal Engine',
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
        'query': query,
        'heroAnswer': heroAnswer,
        'recommendation': recommendation,
        'detailedExplanation': detailedExplanation,
        'goalMatch': goalMatch.toJson(),
        'evidence': evidence.toJson(),
        'practicalSteps': practicalSteps,
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
