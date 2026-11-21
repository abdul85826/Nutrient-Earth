// ==============================================================================
// Nutrient Earth — Canonical Claim & Evidence Domain Models
// Full Clean Architecture representation of the Scientific Evidence Universe:
// 1. Evidence Tiers (Human RCTs, Observational, Mechanistic, Animal, In-Vitro)
// 2. Methodological Quality Appraisal (RoB 2, ROBINS-I, AMSTAR 2, SYRCLE)
// 3. GRADE Certainty Assessments (High, Moderate, Low, Very Low)
// 4. Canonical Scientific Claims with Population, Exposure, Mechanism & Outcomes
// 5. 11-Part Editorial Direct-Answer Publication Structure
// 6. Publishing Gate State Machine
// ==============================================================================

/// Hierarchical Evidence Classification Tiers
enum EvidenceTier {
  humanSystematicReview('Human Systematic Review & Meta-Analysis', 1, true),
  humanRandomizedTrial('Human Randomized Controlled Trial', 2, true),
  humanObservationalCohort('Human Prospective / Observational Cohort', 3, true),
  clinicalPracticeGuideline('Clinical Practice Guideline / Consensus', 4, true),
  preclinicalAnimalModel('Preclinical In-Vivo Animal Experiment', 5, false),
  inVitroCellularAssay('In-Vitro Cellular / Molecular Culture Assay', 6, false),
  computationalMechanisticModel('In-Silico / Computational Molecular Model', 7, false),
  traditionalEmpiricalTreatise('Traditional Empirical Treatise (AYUSH / Classical)', 8, false);

  final String displayName;
  final int hierarchyRank;
  final bool isDirectHumanEvidence;

  const EvidenceTier(this.displayName, this.hierarchyRank, this.isDirectHumanEvidence);
}

/// Publishing Gate Workflow States
enum PublishingState {
  discovered,
  sourceVerified,
  extracted,
  evidenceAssessed,
  claimVerified,
  safetyReviewed,
  approved,
  published,
  // Exception and terminal states
  rejected,
  withheld,
  needsHumanReview,
  superseded,
  corrected,
  retracted,
  archived;

  String get label => name.toUpperCase();

  bool get isLivePublished => this == PublishingState.published;
  bool get isUnderReview =>
      this == PublishingState.needsHumanReview ||
      this == PublishingState.discovered ||
      this == PublishingState.sourceVerified ||
      this == PublishingState.extracted ||
      this == PublishingState.evidenceAssessed ||
      this == PublishingState.claimVerified ||
      this == PublishingState.safetyReviewed;
  bool get isBlocked =>
      this == PublishingState.rejected ||
      this == PublishingState.withheld ||
      this == PublishingState.retracted;
}

/// Methodological Appraisal Tool Identifier
enum MethodologicalTool {
  rob2('RoB 2 (Randomized Controlled Trials)'),
  robinsI('ROBINS-I (Non-Randomized Observational Studies)'),
  amstar2('AMSTAR 2 (Systematic Reviews & Meta-Analyses)'),
  robis('ROBIS (Systematic Reviews in Healthcare)'),
  quadas2('QUADAS-2 (Diagnostic Accuracy Studies)'),
  syrcle('SYRCLE (Animal Preclinical Experimental Studies)'),
  grade('GRADE (Outcome-Specific Body of Evidence Certainty)');

  final String description;
  const MethodologicalTool(this.description);
}

/// Overall Risk of Bias Judgement
enum RiskOfBiasLevel {
  lowRisk,
  someConcerns,
  highRisk,
  criticalRisk,
  unclear;

  String get displayName {
    switch (this) {
      case RiskOfBiasLevel.lowRisk:
        return 'Low Risk of Bias';
      case RiskOfBiasLevel.someConcerns:
        return 'Some Concerns / Moderate Risk';
      case RiskOfBiasLevel.highRisk:
        return 'High Risk of Bias';
      case RiskOfBiasLevel.criticalRisk:
        return 'Critical Risk of Bias';
      case RiskOfBiasLevel.unclear:
        return 'Unclear / Incomplete Reporting';
    }
  }
}

/// GRADE Final Certainty Grade
enum GradeCertainty {
  high('High Certainty — Further research unlikely to change confidence'),
  moderate('Moderate Certainty — Further research likely to have important impact'),
  low('Low Certainty — Further research very likely to have important impact'),
  veryLow('Very Low Certainty — Any estimate of effect is very uncertain');

  final String description;
  const GradeCertainty(this.description);
}

/// Study Appraisal Record holding domain-specific bias evaluations
class StudyAppraisalRecord {
  final String publicationId;
  final MethodologicalTool toolUsed;
  final RiskOfBiasLevel overallRisk;
  final Map<String, String> domainJudgements;
  final String assessmentNotes;
  final String assessedBy;
  final DateTime assessedAt;

  const StudyAppraisalRecord({
    required this.publicationId,
    required this.toolUsed,
    required this.overallRisk,
    this.domainJudgements = const {},
    required this.assessmentNotes,
    this.assessedBy = 'nutrient_earth_verifier_v2',
    required this.assessedAt,
  });

  Map<String, dynamic> toJson() => {
        'publication_id': publicationId,
        'tool_used': toolUsed.name,
        'overall_risk': overallRisk.name,
        'domain_judgements': domainJudgements,
        'assessment_notes': assessmentNotes,
        'assessed_by': assessedBy,
        'assessed_at': assessedAt.toIso8601String(),
      };
}

/// Outcome-Specific GRADE Evidence Assessment
class GradeAssessmentRecord {
  final String outcomeName;
  final int studyCount;
  final int? totalParticipants;
  final List<String> studyDesignsIncluded;
  // Downgrade Domains (-2 to 0)
  final int riskOfBiasDowngrade;
  final int inconsistencyDowngrade;
  final int indirectnessDowngrade;
  final int imprecisionDowngrade;
  final int publicationBiasDowngrade;
  // Upgrade Domains (0 to +2)
  final int largeEffectUpgrade;
  final int doseResponseUpgrade;
  final int residualConfoundingUpgrade;
  final GradeCertainty finalCertainty;
  final String justificationSummary;

  const GradeAssessmentRecord({
    required this.outcomeName,
    required this.studyCount,
    this.totalParticipants,
    this.studyDesignsIncluded = const [],
    this.riskOfBiasDowngrade = 0,
    this.inconsistencyDowngrade = 0,
    this.indirectnessDowngrade = 0,
    this.imprecisionDowngrade = 0,
    this.publicationBiasDowngrade = 0,
    this.largeEffectUpgrade = 0,
    this.doseResponseUpgrade = 0,
    this.residualConfoundingUpgrade = 0,
    required this.finalCertainty,
    required this.justificationSummary,
  });

  int get netScoreOffset =>
      riskOfBiasDowngrade +
      inconsistencyDowngrade +
      indirectnessDowngrade +
      imprecisionDowngrade +
      publicationBiasDowngrade +
      largeEffectUpgrade +
      doseResponseUpgrade +
      residualConfoundingUpgrade;
}

/// Structured Effect Estimate & Statistical Confidence
class EffectEstimate {
  final String measureType; // 'Relative Risk (RR)', 'Odds Ratio (OR)', 'Mean Difference (MD)', 'Hazard Ratio (HR)'
  final double pointEstimate;
  final double? ciLower;
  final double? ciUpper;
  final double? pValue;
  final bool isStatisticallySignificant;
  final bool isClinicallyMeaningful;
  final String clinicalTakeaway;

  const EffectEstimate({
    required this.measureType,
    required this.pointEstimate,
    this.ciLower,
    this.ciUpper,
    this.pValue,
    required this.isStatisticallySignificant,
    required this.isClinicallyMeaningful,
    required this.clinicalTakeaway,
  });

  String get formattedCI => (ciLower != null && ciUpper != null)
      ? '95% CI [$ciLower, $ciUpper]'
      : 'CI Not Reported';
}

/// Structured Population Profile
class TargetPopulation {
  final String description;
  final int? sampleSize;
  final String ageRange;
  final String sexDistribution;
  final String healthStatus; // 'Healthy Adults', 'Type 2 Diabetes', 'Endurance Athletes', 'In-Vitro Cell Line'
  final bool isGeneralizableToGeneralPublic;

  const TargetPopulation({
    required this.description,
    this.sampleSize,
    this.ageRange = 'Adults (18-65)',
    this.sexDistribution = 'Mixed',
    this.healthStatus = 'Healthy Adults',
    this.isGeneralizableToGeneralPublic = true,
  });
}

/// Structured Exposure / Intervention Specification
class ExposureSpecification {
  final String agentOrIntervention;
  final String? doseAmount;
  final String? frequency;
  final String? duration;
  final String routeOfAdministration; // 'Oral', 'Inhalation', 'Dermal', 'In-Vitro Culture Media'
  final String? vehicleOrDeliveryMatrix;

  const ExposureSpecification({
    required this.agentOrIntervention,
    this.doseAmount,
    this.frequency,
    this.duration,
    this.routeOfAdministration = 'Oral',
    this.vehicleOrDeliveryMatrix,
  });
}

/// The Master Canonical Scientific Claim Record
class CanonicalClaim {
  final String id;
  final String claimUid; // e.g. 'CLM-2026-NUTR-0012'
  final String domainId; // e.g. 'domain_01_nutrition'
  final String exactStatement;
  final EvidenceTier evidenceTier;
  final bool isHumanEvidence;
  final bool isPreclinicalOnly;
  final TargetPopulation population;
  final ExposureSpecification exposure;
  final String biologicalMechanism;
  final String healthOutcome;
  final EffectEstimate? effectEstimate;
  final StudyAppraisalRecord? appraisal;
  final GradeAssessmentRecord? gradeAssessment;
  final List<String> supportingPublicationDois;
  final List<String> contradictoryPublicationDois;
  final String? contradictionNotes;
  final String studyLimitations;
  final PublishingState publishingStatus;
  final int version;
  final String reviewedBy;
  final DateTime reviewedAt;
  final bool requiresHumanSignoff;
  final String? humanReviewNotes;

  // Cancer & DNA specific safety audits
  final Map<String, dynamic>? cancerHazardAudit;
  final Map<String, dynamic>? dnaDamageVsOutcomeAudit;

  const CanonicalClaim({
    required this.id,
    required this.claimUid,
    required this.domainId,
    required this.exactStatement,
    required this.evidenceTier,
    required this.isHumanEvidence,
    this.isPreclinicalOnly = false,
    required this.population,
    required this.exposure,
    required this.biologicalMechanism,
    required this.healthOutcome,
    this.effectEstimate,
    this.appraisal,
    this.gradeAssessment,
    this.supportingPublicationDois = const [],
    this.contradictoryPublicationDois = const [],
    this.contradictionNotes,
    required this.studyLimitations,
    this.publishingStatus = PublishingState.approved,
    this.version = 1,
    this.reviewedBy = 'autonomous_integrity_verifier',
    required this.reviewedAt,
    this.requiresHumanSignoff = false,
    this.humanReviewNotes,
    this.cancerHazardAudit,
    this.dnaDamageVsOutcomeAudit,
  });

  bool get hasContradiction => contradictoryPublicationDois.isNotEmpty;
  bool get isApprovedForPublishing =>
      publishingStatus == PublishingState.approved ||
      publishingStatus == PublishingState.published;
}

/// The 11-Part Editorial Direct-Answer Structure (Section 7)
class EditorialArticle11Part {
  final String id;
  final String claimId;
  final String domainId;
  final String title;

  // 1. Direct answer
  final String part01DirectAnswer;
  // 2. What research actually found
  final String part02WhatResearchFound;
  // 3. Who was studied
  final String part03WhoWasStudied;
  // 4. What exposure or intervention was examined
  final String part04ExposureOrIntervention;
  // 5. What the result means
  final String part05WhatResultMeans;
  // 6. What the result does not prove
  final String part06WhatResultDoesNotProve;
  // 7. Practical actions supported by evidence
  final List<String> part07PracticalActions;
  // 8. Evidence certainty
  final String part08EvidenceCertainty;
  // 9. Important limitations
  final String part09ImportantLimitations;
  // 10. Original scientific sources
  final List<Map<String, String>> part10OriginalSources;
  // 11. Last verified date
  final DateTime part11LastVerifiedDate;

  final PublishingState publishingStatus;
  final int version;
  final bool wasUpdatedSinceRelease;
  final String? updateChangeLog;

  const EditorialArticle11Part({
    required this.id,
    required this.claimId,
    required this.domainId,
    required this.title,
    required this.part01DirectAnswer,
    required this.part02WhatResearchFound,
    required this.part03WhoWasStudied,
    required this.part04ExposureOrIntervention,
    required this.part05WhatResultMeans,
    required this.part06WhatResultDoesNotProve,
    required this.part07PracticalActions,
    required this.part08EvidenceCertainty,
    required this.part09ImportantLimitations,
    required this.part10OriginalSources,
    required this.part11LastVerifiedDate,
    this.publishingStatus = PublishingState.published,
    this.version = 1,
    this.wasUpdatedSinceRelease = false,
    this.updateChangeLog,
  });
}
