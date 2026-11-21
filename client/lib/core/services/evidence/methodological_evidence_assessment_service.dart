// ==============================================================================
// Nutrient Earth — Methodological Evidence Assessment Engine
// Implements recognized clinical epidemiology appraisal standards:
// 1. RoB 2 (Risk of Bias 2 for Randomized Controlled Trials)
// 2. ROBINS-I (Non-Randomized Observational Cohort Studies)
// 3. AMSTAR 2 (Systematic Reviews & Meta-Analyses)
// 4. SYRCLE (Preclinical Animal In-Vivo Experimental Studies)
// 5. GRADE (Outcome-Specific Body of Evidence Certainty)
//
// Rule: Keeps individual study appraisal strictly separate from body of evidence certainty.
// Never assigns universal credibility scores using arbitrary AI numbers.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evidence/canonical_claim_models.dart';

class MethodologicalEvidenceAssessmentService {
  const MethodologicalEvidenceAssessmentService();

  /// RoB 2 Assessment for Randomized Controlled Trials (Cochrane Standard)
  StudyAppraisalRecord assessRctRoB2({
    required String publicationId,
    required String randomizationProcess, // 'low', 'some_concerns', 'high'
    required String deviationsFromIntervention,
    required String missingOutcomeData,
    required String measurementOfOutcome,
    required String selectionOfReportedResult,
    required String justificationNotes,
    String assessedBy = 'nutrient_earth_methodologist',
  }) {
    final judgements = {
      'D1_randomization_process': randomizationProcess,
      'D2_deviations_intended_intervention': deviationsFromIntervention,
      'D3_missing_outcome_data': missingOutcomeData,
      'D4_measurement_of_outcome': measurementOfOutcome,
      'D5_selection_reported_result': selectionOfReportedResult,
    };

    // RoB 2 Algorithmic Overall Judgement
    RiskOfBiasLevel overall;
    final values = judgements.values.toList();
    if (values.any((v) => v.toLowerCase() == 'high')) {
      overall = RiskOfBiasLevel.highRisk;
    } else if (values.any((v) => v.toLowerCase() == 'some_concerns')) {
      overall = RiskOfBiasLevel.someConcerns;
    } else {
      overall = RiskOfBiasLevel.lowRisk;
    }

    return StudyAppraisalRecord(
      publicationId: publicationId,
      toolUsed: MethodologicalTool.rob2,
      overallRisk: overall,
      domainJudgements: judgements,
      assessmentNotes: justificationNotes,
      assessedBy: assessedBy,
      assessedAt: DateTime.now().toUtc(),
    );
  }

  /// ROBINS-I Assessment for Non-Randomized Observational Studies
  StudyAppraisalRecord assessObservationalRobinsI({
    required String publicationId,
    required String confounding, // 'low', 'moderate', 'serious', 'critical'
    required String participantSelection,
    required String interventionClassification,
    required String deviationsFromIntervention,
    required String missingData,
    required String outcomeMeasurement,
    required String selectionOfReportedResult,
    required String justificationNotes,
    String assessedBy = 'nutrient_earth_methodologist',
  }) {
    final judgements = {
      'D1_confounding': confounding,
      'D2_selection_participants': participantSelection,
      'D3_classification_interventions': interventionClassification,
      'D4_deviations_interventions': deviationsFromIntervention,
      'D5_missing_data': missingData,
      'D6_measurement_outcomes': outcomeMeasurement,
      'D7_selection_reported_results': selectionOfReportedResult,
    };

    RiskOfBiasLevel overall;
    final values = judgements.values.map((v) => v.toLowerCase()).toList();
    if (values.contains('critical')) {
      overall = RiskOfBiasLevel.criticalRisk;
    } else if (values.contains('serious')) {
      overall = RiskOfBiasLevel.highRisk;
    } else if (values.contains('moderate')) {
      overall = RiskOfBiasLevel.someConcerns;
    } else {
      overall = RiskOfBiasLevel.lowRisk;
    }

    return StudyAppraisalRecord(
      publicationId: publicationId,
      toolUsed: MethodologicalTool.robinsI,
      overallRisk: overall,
      domainJudgements: judgements,
      assessmentNotes: justificationNotes,
      assessedBy: assessedBy,
      assessedAt: DateTime.now().toUtc(),
    );
  }

  /// AMSTAR 2 Assessment for Systematic Reviews & Meta-Analyses
  StudyAppraisalRecord assessSystematicReviewAmstar2({
    required String publicationId,
    required bool priorProtocolRegistered, // Critical 1
    required bool comprehensiveLiteratureSearch, // Critical 2
    required bool justificationOfExcludedStudies, // Critical 3
    required bool riskOfBiasAssessedInIndividualStudies, // Critical 4
    required bool appropriateMetaAnalyticMethods, // Critical 5
    required bool riskOfBiasConsideredInInterpretation, // Critical 6
    required bool publicationBiasAssessed, // Critical 7
    required String justificationNotes,
    String assessedBy = 'nutrient_earth_methodologist',
  }) {
    int criticalFailures = 0;
    if (!priorProtocolRegistered) criticalFailures++;
    if (!comprehensiveLiteratureSearch) criticalFailures++;
    if (!justificationOfExcludedStudies) criticalFailures++;
    if (!riskOfBiasAssessedInIndividualStudies) criticalFailures++;
    if (!appropriateMetaAnalyticMethods) criticalFailures++;
    if (!riskOfBiasConsideredInInterpretation) criticalFailures++;
    if (!publicationBiasAssessed) criticalFailures++;

    RiskOfBiasLevel overall;
    if (criticalFailures == 0) {
      overall = RiskOfBiasLevel.lowRisk; // High confidence review
    } else if (criticalFailures == 1) {
      overall = RiskOfBiasLevel.someConcerns; // Moderate confidence review
    } else {
      overall = RiskOfBiasLevel.highRisk; // Low or critically low confidence
    }

    final judgements = {
      'prior_protocol_registered': priorProtocolRegistered ? 'yes' : 'no',
      'comprehensive_literature_search': comprehensiveLiteratureSearch ? 'yes' : 'no',
      'justification_excluded_studies': justificationOfExcludedStudies ? 'yes' : 'no',
      'rob_individual_studies_assessed': riskOfBiasAssessedInIndividualStudies ? 'yes' : 'no',
      'meta_analytic_methods_appropriate': appropriateMetaAnalyticMethods ? 'yes' : 'no',
      'rob_considered_in_interpretation': riskOfBiasConsideredInInterpretation ? 'yes' : 'no',
      'publication_bias_assessed': publicationBiasAssessed ? 'yes' : 'no',
      'critical_domain_deficits': criticalFailures.toString(),
    };

    return StudyAppraisalRecord(
      publicationId: publicationId,
      toolUsed: MethodologicalTool.amstar2,
      overallRisk: overall,
      domainJudgements: judgements,
      assessmentNotes: justificationNotes,
      assessedBy: assessedBy,
      assessedAt: DateTime.now().toUtc(),
    );
  }

  /// SYRCLE Assessment for Preclinical Animal In-Vivo Studies
  StudyAppraisalRecord assessAnimalPreclinicalSyrcle({
    required String publicationId,
    required bool sequenceGenerationRandom,
    required bool baselineCharacteristicsBalanced,
    required bool allocationConcealmentAdequate,
    required bool randomHousingUsed,
    required bool blindedInterventions,
    required bool randomOutcomeAssessment,
    required bool blindedOutcomeAssessor,
    required bool incompleteOutcomeDataAddressed,
    required bool selectiveOutcomeReportingFree,
    required String justificationNotes,
    String assessedBy = 'nutrient_earth_methodologist',
  }) {
    int unmetDomains = 0;
    if (!sequenceGenerationRandom) unmetDomains++;
    if (!baselineCharacteristicsBalanced) unmetDomains++;
    if (!allocationConcealmentAdequate) unmetDomains++;
    if (!randomHousingUsed) unmetDomains++;
    if (!blindedInterventions) unmetDomains++;
    if (!randomOutcomeAssessment) unmetDomains++;
    if (!blindedOutcomeAssessor) unmetDomains++;
    if (!incompleteOutcomeDataAddressed) unmetDomains++;
    if (!selectiveOutcomeReportingFree) unmetDomains++;

    RiskOfBiasLevel overall;
    if (unmetDomains <= 2) {
      overall = RiskOfBiasLevel.lowRisk;
    } else if (unmetDomains <= 5) {
      overall = RiskOfBiasLevel.someConcerns;
    } else {
      overall = RiskOfBiasLevel.highRisk;
    }

    final judgements = {
      'sequence_generation': sequenceGenerationRandom ? 'low' : 'high',
      'allocation_concealment': allocationConcealmentAdequate ? 'low' : 'high',
      'random_housing': randomHousingUsed ? 'low' : 'high',
      'blinded_outcome_assessment': blindedOutcomeAssessor ? 'low' : 'high',
      'unmet_syrcle_domains': unmetDomains.toString(),
    };

    return StudyAppraisalRecord(
      publicationId: publicationId,
      toolUsed: MethodologicalTool.syrcle,
      overallRisk: overall,
      domainJudgements: judgements,
      assessmentNotes: justificationNotes,
      assessedBy: assessedBy,
      assessedAt: DateTime.now().toUtc(),
    );
  }

  /// GRADE Outcome-Specific Certainty Assessment
  GradeAssessmentRecord assessGradeCertainty({
    required String outcomeName,
    required int studyCount,
    int? totalParticipants,
    required List<EvidenceTier> studyDesigns,
    // 5 Downgrade Domains (0, -1, or -2)
    int riskOfBiasDowngrade = 0,
    int inconsistencyDowngrade = 0,
    int indirectnessDowngrade = 0,
    int imprecisionDowngrade = 0,
    int publicationBiasDowngrade = 0,
    // 3 Upgrade Domains (0, +1, or +2)
    int largeEffectUpgrade = 0,
    int doseResponseUpgrade = 0,
    int residualConfoundingUpgrade = 0,
    required String justificationSummary,
  }) {
    // 1. Initial GRADE Starting Score:
    // RCTs start at High (Score 4)
    // Observational studies start at Low (Score 2)
    // In-vitro / animal starts at Very Low (Score 1)
    int score = 4;
    final hasRct = studyDesigns.contains(EvidenceTier.humanRandomizedTrial) ||
        studyDesigns.contains(EvidenceTier.humanSystematicReview);
    final isObservationalOnly = !hasRct &&
        studyDesigns.contains(EvidenceTier.humanObservationalCohort);
    final isPreclinicalOnly = !hasRct && !isObservationalOnly;

    if (isPreclinicalOnly) {
      score = 1; // Preclinical cannot achieve High or Moderate GRADE for human outcomes
    } else if (isObservationalOnly) {
      score = 2; // Observational baseline is Low
    } else {
      score = 4; // RCT baseline is High
    }

    // 2. Apply Downgrades
    score += riskOfBiasDowngrade.clamp(-2, 0);
    score += inconsistencyDowngrade.clamp(-2, 0);
    score += indirectnessDowngrade.clamp(-2, 0);
    score += imprecisionDowngrade.clamp(-2, 0);
    score += publicationBiasDowngrade.clamp(-2, 0);

    // 3. Apply Upgrades (Observational studies only)
    if (isObservationalOnly) {
      score += largeEffectUpgrade.clamp(0, 2);
      score += doseResponseUpgrade.clamp(0, 1);
      score += residualConfoundingUpgrade.clamp(0, 1);
    }

    // Clamp score between 1 and 4
    final finalScore = score.clamp(1, 4);

    GradeCertainty certainty;
    switch (finalScore) {
      case 4:
        certainty = GradeCertainty.high;
        break;
      case 3:
        certainty = GradeCertainty.moderate;
        break;
      case 2:
        certainty = GradeCertainty.low;
        break;
      case 1:
      default:
        certainty = GradeCertainty.veryLow;
        break;
    }

    return GradeAssessmentRecord(
      outcomeName: outcomeName,
      studyCount: studyCount,
      totalParticipants: totalParticipants,
      studyDesignsIncluded: studyDesigns.map((d) => d.displayName).toList(),
      riskOfBiasDowngrade: riskOfBiasDowngrade,
      inconsistencyDowngrade: inconsistencyDowngrade,
      indirectnessDowngrade: indirectnessDowngrade,
      imprecisionDowngrade: imprecisionDowngrade,
      publicationBiasDowngrade: publicationBiasDowngrade,
      largeEffectUpgrade: largeEffectUpgrade,
      doseResponseUpgrade: doseResponseUpgrade,
      residualConfoundingUpgrade: residualConfoundingUpgrade,
      finalCertainty: certainty,
      justificationSummary: justificationSummary,
    );
  }
}

final methodologicalEvidenceAssessmentServiceProvider = Provider<MethodologicalEvidenceAssessmentService>((ref) {
  return const MethodologicalEvidenceAssessmentService();
});
