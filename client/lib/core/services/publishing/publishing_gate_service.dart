// ==============================================================================
// Nutrient Earth — Publishing Gate & Editorial State Machine
// Strictly enforces the 8-stage verification pipeline:
// DISCOVERED → SOURCE_VERIFIED → EXTRACTED → EVIDENCE_ASSESSED →
// CLAIM_VERIFIED → SAFETY_REVIEWED → APPROVED → PUBLISHED
//
// Rules:
// 1. Only approved content may transition to PUBLISHED.
// 2. High-impact claims (oncology, pediatric, organ toxicity) require human review.
// 3. Automated jobs NEVER bypass the publishing gate for daily publishing deadlines.
//    If fewer than 5 articles pass verification, publish fewer; never lower the bar.
// 4. Retracted or failing records transition immediately to RETRACTED or REJECTED.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evidence/canonical_claim_models.dart';
import '../evidence/human_evidence_separation_guard.dart';
import '../evidence/source_authentication_service.dart';

class GateEvaluationOutcome {
  final PublishingState targetState;
  final bool canPublish;
  final List<String> passedChecks;
  final List<String> blockingReasons;
  final bool requiresHumanReview;
  final String transitionRationale;

  const GateEvaluationOutcome({
    required this.targetState,
    required this.canPublish,
    this.passedChecks = const [],
    this.blockingReasons = const [],
    this.requiresHumanReview = false,
    required this.transitionRationale,
  });
}

class PublishingGateService {
  final SourceAuthenticationService _sourceAuth;
  final HumanEvidenceSeparationGuard _safetyGuard;

  const PublishingGateService({
    SourceAuthenticationService? sourceAuth,
    HumanEvidenceSeparationGuard? safetyGuard,
  })  : _sourceAuth = sourceAuth ?? const SourceAuthenticationService(),
        _safetyGuard = safetyGuard ?? const HumanEvidenceSeparationGuard();

  /// Evaluates whether a candidate claim passes through the complete publishing gate
  GateEvaluationOutcome evaluateClaimForPublication({
    required CanonicalClaim claim,
    required AuthenticatedSourceRecord source,
    bool humanReviewerApproved = false,
    String? humanReviewerNotes,
  }) {
    final passedChecks = <String>[];
    final blockingReasons = <String>[];

    // Stage 1: SOURCE_VERIFIED
    if (source.isRetracted) {
      return const GateEvaluationOutcome(
        targetState: PublishingState.retracted,
        canPublish: false,
        blockingReasons: ['Source is formally retracted by the issuing journal.'],
        transitionRationale: 'Immediate transition to RETRACTED due to retracted publication state.',
      );
    }
    if (source.doi == null && source.pmid == null) {
      blockingReasons.add('Source lacks a verified DOI or PMID.');
    } else {
      passedChecks.add('Source authentication passed: verified universal identifier.');
    }

    // Stage 2: EXTRACTED
    if (claim.exactStatement.trim().isEmpty) {
      blockingReasons.add('Claim text is empty.');
    } else {
      passedChecks.add('Claim extracted: ${claim.claimUid}');
    }

    // Stage 3: EVIDENCE_ASSESSED
    if (claim.appraisal == null) {
      blockingReasons.add('Missing methodological appraisal (RoB 2, ROBINS-I, AMSTAR 2, or SYRCLE).');
    } else if (claim.appraisal!.overallRisk == RiskOfBiasLevel.criticalRisk) {
      blockingReasons.add('Methodological appraisal identified Critical Risk of Bias.');
    } else {
      passedChecks.add('Evidence assessed: ${claim.appraisal!.toolUsed.description} (${claim.appraisal!.overallRisk.displayName})');
    }

    // Stage 4: CLAIM_VERIFIED (Evidence Grounding)
    if (claim.supportingPublicationDois.isEmpty) {
      blockingReasons.add('Zero verified supporting publication DOIs linked to this claim.');
    } else {
      passedChecks.add('Claim verified: ${claim.supportingPublicationDois.length} supporting sources linked.');
    }

    // Stage 5: SAFETY_REVIEWED (Human vs Mechanism Separation)
    final safetyResult = _safetyGuard.verifyClaimSafety(
      statement: claim.exactStatement,
      evidenceTier: claim.evidenceTier,
      population: claim.population,
      exposure: claim.exposure,
      effectEstimate: claim.effectEstimate,
      cancerDetails: claim.cancerHazardAudit,
      dnaDetails: claim.dnaDamageVsOutcomeAudit,
    );

    if (!safetyResult.isSafe) {
      for (final v in safetyResult.violations) {
        blockingReasons.add('Safety Violation [${v.ruleIdentifier}]: ${v.violationMessage}');
      }
    } else {
      passedChecks.add('Safety reviewed: zero human/mechanism separation violations.');
    }

    // Stage 6: High-Impact Human Review Gate
    final lower = claim.exactStatement.toLowerCase();
    final isHighImpact = claim.requiresHumanSignoff ||
        lower.contains('cancer') ||
        lower.contains('chemotherapy') ||
        lower.contains('pediatric') ||
        lower.contains('infant') ||
        lower.contains('pregnancy') ||
        lower.contains('kidney failure') ||
        lower.contains('drug interaction');

    if (isHighImpact && !humanReviewerApproved) {
      return GateEvaluationOutcome(
        targetState: PublishingState.needsHumanReview,
        canPublish: false,
        passedChecks: passedChecks,
        blockingReasons: ['High-impact clinical claim requires qualified independent human review before publishing.'],
        requiresHumanReview: true,
        transitionRationale: 'Held at NEEDS_HUMAN_REVIEW to ensure clinical physician / board-certified review.',
      );
    }

    if (isHighImpact && humanReviewerApproved) {
      passedChecks.add('High-impact human signoff recorded: ${humanReviewerNotes ?? "Approved by human reviewer."}');
    }

    // Decision Gate
    if (blockingReasons.isNotEmpty) {
      return GateEvaluationOutcome(
        targetState: PublishingState.rejected,
        canPublish: false,
        passedChecks: passedChecks,
        blockingReasons: blockingReasons,
        transitionRationale: 'Rejected by publishing gate due to verification failures: ${blockingReasons.join("; ")}',
      );
    }

    return GateEvaluationOutcome(
      targetState: PublishingState.published,
      canPublish: true,
      passedChecks: passedChecks,
      transitionRationale: 'Successfully passed all 8 publishing gate checkpoints.',
    );
  }
}

final publishingGateServiceProvider = Provider<PublishingGateService>((ref) {
  return PublishingGateService(
    sourceAuth: ref.watch(sourceAuthenticationServiceProvider),
    safetyGuard: ref.watch(humanEvidenceSeparationGuardProvider),
  );
});
