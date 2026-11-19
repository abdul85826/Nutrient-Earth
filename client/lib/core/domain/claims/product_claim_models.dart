// ==============================================================================
// Nutrient Earth — Product Claim Validation & Evidence Linkage Models
// Distinguishes manufacturer statements, packaging claims, regulatory data,
// independent lab tests, and peer-reviewed scientific studies.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum ClaimStatementType {
  packagingStatement,
  manufacturerMarketing,
  regulatoryApprovedClaim,
  thirdPartyLabCertification;

  String get value => name;

  static ClaimStatementType fromString(String val) {
    return ClaimStatementType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().replaceAll('_', ''),
      orElse: () => ClaimStatementType.packagingStatement,
    );
  }
}

enum EvidenceSourceType {
  clinicalTrial,
  metaAnalysis,
  independentTestingLab,
  regulatoryFinding,
  traditionalTreatise;

  String get value => name;
}

enum ClaimVerdict {
  supported,
  contradicted,
  insufficientEvidence,
  misleading;

  String get value => name;
}

class ClaimEvidenceItem {
  final String id;
  final String claimId;
  final EvidenceSourceType evidenceSourceType;
  final String citationReference; // e.g. 'PMID: 31200000' or 'Lab Report #A-992'
  final ClaimVerdict verdict;
  final double confidenceScore;
  final String? populationStudied;
  final String? testedDosage;
  final String? limitations;

  const ClaimEvidenceItem({
    required this.id,
    required this.claimId,
    required this.evidenceSourceType,
    required this.citationReference,
    required this.verdict,
    this.confidenceScore = 1.0,
    this.populationStudied,
    this.testedDosage,
    this.limitations,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_id': claimId,
        'evidence_source_type': evidenceSourceType.value,
        'citation_reference': citationReference,
        'verdict': verdict.value,
        'confidence_score': confidenceScore,
        'population_studied': populationStudied,
        'tested_dosage': testedDosage,
        'limitations': limitations,
      };
}

class ProductClaimItem {
  final String id;
  final String formulationId;
  final String claimText;
  final ClaimStatementType statementType;
  final String? relevantIngredient;
  final List<ClaimEvidenceItem> evidence;

  const ProductClaimItem({
    required this.id,
    required this.formulationId,
    required this.claimText,
    required this.statementType,
    this.relevantIngredient,
    this.evidence = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'formulation_id': formulationId,
        'claim_text': claimText,
        'statement_type': statementType.value,
        'relevant_ingredient': relevantIngredient,
        'evidence_count': evidence.length,
      };
}

class ClaimValidationReport {
  final ProductClaimItem claim;
  final List<ClaimEvidenceItem> supportingEvidence;
  final List<ClaimEvidenceItem> contradictoryEvidence;
  final ClaimVerdict overallVerdict;
  final double confidenceScore;
  final String explanation;
  final String? dosageDiscrepancyNote;

  const ClaimValidationReport({
    required this.claim,
    this.supportingEvidence = const [],
    this.contradictoryEvidence = const [],
    required this.overallVerdict,
    required this.confidenceScore,
    required this.explanation,
    this.dosageDiscrepancyNote,
  });

  Map<String, dynamic> toJson() => {
        'claim_text': claim.claimText,
        'statement_type': claim.statementType.value,
        'relevant_ingredient': claim.relevantIngredient,
        'overall_verdict': overallVerdict.value,
        'confidence_score': confidenceScore,
        'explanation': explanation,
        'supporting_evidence_count': supportingEvidence.length,
        'contradictory_evidence_count': contradictoryEvidence.length,
        'dosage_discrepancy_note': dosageDiscrepancyNote,
      };
}
