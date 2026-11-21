// ==============================================================================
// Nutrient Earth — Human Evidence & Mechanism Separation Guard
// Mandatory Clinical Safety Requirement (Section 5)
//
// Strictly enforces evidence boundary rules:
// 1. Cellular mechanisms NEVER presented as proven human diseases.
// 2. Animal in-vivo results NEVER presented as demonstrated human clinical outcomes.
// 3. Epidemiological associations NEVER asserted as causal relationships.
// 4. Chemical hazard identification NEVER asserted as clinical harm without exposure dose.
// 5. Statistically significant trivial differences NEVER exaggerated as clinical benefits.
// 6. Cancer claims explicitly distinguish IARC hazard tiers, dose, and absolute risk.
// 7. DNA claims explicitly distinguish base damage from mutations and health outcomes.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evidence/canonical_claim_models.dart';

class SafetyVerificationViolation {
  final String ruleIdentifier;
  final String violationMessage;
  final String correctiveAction;

  const SafetyVerificationViolation({
    required this.ruleIdentifier,
    required this.violationMessage,
    required this.correctiveAction,
  });
}

class SafetyVerificationResult {
  final bool isSafe;
  final List<SafetyVerificationViolation> violations;
  final List<String> requiredDisclosures;

  const SafetyVerificationResult({
    required this.isSafe,
    this.violations = const [],
    this.requiredDisclosures = const [],
  });
}

class HumanEvidenceSeparationGuard {
  const HumanEvidenceSeparationGuard();

  /// Validates a candidate scientific statement against the 7 mandatory separation rules
  SafetyVerificationResult verifyClaimSafety({
    required String statement,
    required EvidenceTier evidenceTier,
    required TargetPopulation population,
    required ExposureSpecification exposure,
    EffectEstimate? effectEstimate,
    Map<String, dynamic>? cancerDetails,
    Map<String, dynamic>? dnaDetails,
  }) {
    final violations = <SafetyVerificationViolation>[];
    final disclosures = <String>[];
    final lower = statement.toLowerCase();

    // -------------------------------------------------------------------------
    // Rule 1: Cellular Mechanism vs Human Disease
    // -------------------------------------------------------------------------
    if (evidenceTier == EvidenceTier.inVitroCellularAssay ||
        evidenceTier == EvidenceTier.computationalMechanisticModel) {
      if (lower.contains('cures') ||
          lower.contains('prevents') ||
          lower.contains('causes disease') ||
          lower.contains('treats in humans') ||
          lower.contains('proven in human')) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_1_CELLULAR_MECHANISM_EXTRAPOLATION',
          violationMessage: 'In-vitro cellular or in-silico findings cannot be stated as proven clinical treatments or human disease cures.',
          correctiveAction: 'Rephrase to: "Demonstrated cellular biochemical activity in laboratory cell models; human clinical trials are required to establish in-vivo efficacy."',
        ));
      }
      disclosures.add('Laboratory finding observed in cell culture models; does not establish clinical outcomes in living humans.');
    }

    // -------------------------------------------------------------------------
    // Rule 2: Animal Model vs Demonstrated Human Outcome
    // -------------------------------------------------------------------------
    if (evidenceTier == EvidenceTier.preclinicalAnimalModel) {
      if (lower.contains('in humans') ||
          lower.contains('proves in people') ||
          lower.contains('human patients') ||
          lower.contains('clinical cure')) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_2_ANIMAL_EXTRAPOLATION',
          violationMessage: 'Preclinical animal trials (murine/rodent) cannot be described as human clinical trials or proven human outcomes.',
          correctiveAction: 'Specify exact animal model (e.g., "In murine rodent trials...") and clarify that mammalian metabolic rates differ from humans.',
        ));
      }
      disclosures.add('Observed in preclinical animal experiments. Human pharmacokinetic and clinical trials are needed before applying to human regimens.');
    }

    // -------------------------------------------------------------------------
    // Rule 3: Association vs Causation
    // -------------------------------------------------------------------------
    if (evidenceTier == EvidenceTier.humanObservationalCohort) {
      final assertsCausation = lower.contains('causes') ||
          lower.contains('leads directly to') ||
          lower.contains('proves that eating') ||
          lower.contains('eradicates');
      if (assertsCausation) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_3_ASSOCIATION_AS_CAUSATION',
          violationMessage: 'Prospective observational cohort studies establish statistical associations, not definitive clinical causality.',
          correctiveAction: 'Replace "causes" with "is associated with" or "correlates with higher incidence of".',
        ));
      }
      disclosures.add('Observational epidemiological finding. Demonstrates statistical correlation; residual confounding cannot be ruled out without randomized trials.');
    }

    // -------------------------------------------------------------------------
    // Rule 4: Hazard vs Clinical Harm Without Exposure Dose
    // -------------------------------------------------------------------------
    final mentionsChemicalToxicity = lower.contains('toxic') ||
        lower.contains('poisonous') ||
        lower.contains('deadly chemical') ||
        lower.contains('harmful toxin');

    if (mentionsChemicalToxicity && exposure.doseAmount == null) {
      violations.add(const SafetyVerificationViolation(
        ruleIdentifier: 'RULE_4_HAZARD_WITHOUT_DOSE',
        violationMessage: 'Chemical detection alone cannot be described as clinical toxicity without specifying exposure dose, route, and physiological threshold.',
        correctiveAction: 'State the exact detection level (e.g. parts per billion) and compare it against established regulatory safety thresholds (Tolerable Daily Intake / RfD).',
      ));
    }

    // -------------------------------------------------------------------------
    // Rule 5: Statistical Significance vs Clinical Meaningfulness
    // -------------------------------------------------------------------------
    if (effectEstimate != null && effectEstimate.isStatisticallySignificant) {
      if (!effectEstimate.isClinicallyMeaningful &&
          (lower.contains('massive benefit') || lower.contains('miracle') || lower.contains('huge improvement'))) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_5_TRIVIAL_STATISTICAL_SIGNIFICANCE',
          violationMessage: 'A statistically significant difference (p < 0.05) cannot be exaggerated as a major clinical benefit when the absolute effect size is clinically negligible.',
          correctiveAction: 'Report the absolute effect size and state that while statistically measurable, the clinical real-world difference is minor.',
        ));
      }
    }

    // -------------------------------------------------------------------------
    // Rule 6: Cancer-Specific Audits (Hazard Class vs Absolute Risk)
    // -------------------------------------------------------------------------
    final isCancerClaim = lower.contains('cancer') || lower.contains('tumor') || lower.contains('carcinogen');
    if (isCancerClaim) {
      if (cancerDetails == null || !cancerDetails.containsKey('hazard_class')) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_6_CANCER_HAZARD_UNSPECIFIED',
          violationMessage: 'Cancer-related claims must specify the IARC or NTP hazard classification (Group 1, 2A, 2B, or 3) and route of exposure.',
          correctiveAction: 'Include explicit hazard classification and specify whether carcinogenic evidence derives from human epidemiology or high-dose animal bioassays.',
        ));
      }
      disclosures.add('Cancer risk depends on cumulative exposure route, intensity, and duration. Hazard identification is not an absolute measure of personal risk.');
    }

    // -------------------------------------------------------------------------
    // Rule 7: DNA-Specific Audits (Damage vs Mutation vs Health Outcome)
    // -------------------------------------------------------------------------
    final isDnaClaim = lower.contains('dna') || lower.contains('telomere') || lower.contains('mutation');
    if (isDnaClaim) {
      if (lower.contains('damages dna and causes disease') &&
          (dnaDetails == null || !(dnaDetails['clinical_disease_proven'] as bool? ?? false))) {
        violations.add(const SafetyVerificationViolation(
          ruleIdentifier: 'RULE_7_DNA_DAMAGE_VS_DISEASE_OUTCOME',
          violationMessage: 'DNA base oxidation or repair activity cannot be stated as proven clinical disease without demonstrating mutational fixation and phenotypic outcome.',
          correctiveAction: 'Distinguish transient DNA base oxidation (e.g. 8-OHdG) and endogenous enzymatic DNA repair from permanent pathogenic mutations.',
        ));
      }
      disclosures.add('Endogenous DNA repair pathways (e.g. base excision repair) continuously resolve oxidative lesions; biochemical markers of damage do not equate to clinical disease.');
    }

    return SafetyVerificationResult(
      isSafe: violations.isEmpty,
      violations: violations,
      requiredDisclosures: disclosures,
    );
  }
}

final humanEvidenceSeparationGuardProvider = Provider<HumanEvidenceSeparationGuard>((ref) {
  return const HumanEvidenceSeparationGuard();
});
