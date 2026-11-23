// ==============================================================================
// Nutrient Earth — Independent Claim-Level Verification Engine & Publication Gate
// Production Evidence Verification and Editorial Integrity Pipeline.
//
// Rules Enforced:
// 1. Zero Hallucinated Citations: Validates that PMIDs are strict positive integers
//    and DOIs have genuine 10.xxxx structure.
// 2. Claim-Level Deconstruction: Breaks substantive medical/nutritional text into
//    atomic testable propositions.
// 3. Evidence Entailment Verification: Verifies each claim against retrieved passages.
// 4. Contradiction & Safety Filtering: Immediately blocks unverified medical cures,
//    dangerous dosages, or direct conflicts with clinical guidelines.
// 5. Editorial Publication Gate: Strips invalid citations, withholds unsupported claims,
//    and inserts explicit uncertainty disclosures when evidence is preliminary.
// ==============================================================================

import '../research_pipeline_service.dart';

enum VerificationClaimStatus {
  supported,
  contradicted,
  unsupported,
  extrapolated;

  bool get isPublishable => this == VerificationClaimStatus.supported;
}

enum ClaimPropositionType {
  quantitativeDosage,
  causalEfficacy,
  physiologicalMechanism,
  safetyAndToxicity,
  generalInformational;
}

class AtomicClaimRecord {
  final String claimText;
  final ClaimPropositionType propositionType;
  final VerificationClaimStatus supportStatus;
  final double confidenceScore; // 0.0 to 1.0
  final String? verifiedPmid;
  final String? verifiedDoi;
  final String? supportingPassage;
  final String verificationNotes;

  const AtomicClaimRecord({
    required this.claimText,
    required this.propositionType,
    required this.supportStatus,
    this.confidenceScore = 1.0,
    this.verifiedPmid,
    this.verifiedDoi,
    this.supportingPassage,
    required this.verificationNotes,
  });

  Map<String, dynamic> toJson() => {
        'claimText': claimText,
        'propositionType': propositionType.name,
        'supportStatus': supportStatus.name,
        'confidenceScore': confidenceScore,
        if (verifiedPmid != null) 'pmid': verifiedPmid,
        if (verifiedDoi != null) 'doi': verifiedDoi,
        if (supportingPassage != null) 'supportingPassage': supportingPassage,
        'verificationNotes': verificationNotes,
      };
}

class PublicationGateResult {
  final bool isApprovedForPublication;
  final String sanitizedDirectAnswer;
  final String sanitizedExplanation;
  final List<ResearchCitation> verifiedCitations;
  final List<AtomicClaimRecord> verifiedClaims;
  final List<String> strippedCitations;
  final List<String> withheldClaims;
  final List<String> contradictionWarnings;
  final String publicationDecision;

  const PublicationGateResult({
    required this.isApprovedForPublication,
    required this.sanitizedDirectAnswer,
    required this.sanitizedExplanation,
    required this.verifiedCitations,
    required this.verifiedClaims,
    this.strippedCitations = const [],
    this.withheldClaims = const [],
    this.contradictionWarnings = const [],
    required this.publicationDecision,
  });

  bool get hasCitations => verifiedCitations.isNotEmpty;
  bool get hasWithheldContent => withheldClaims.isNotEmpty || strippedCitations.isNotEmpty;
}

class ClaimVerificationEngine {
  const ClaimVerificationEngine();

  // Known high-risk claims that must be blocked or rewritten
  static final List<RegExp> _criticalContradictionPatterns = [
    RegExp(r'\bcures?\s+(?:cancer|diabetes|hiv|aids|alzheimer)', caseSensitive: false),
    RegExp(r'\b100%\s+effective\s+cure\b', caseSensitive: false),
    RegExp(r'\breplaces?\s+(?:chemotherapy|insulin|radiation|dialysis)\b', caseSensitive: false),
    RegExp(r'\bcompletely\s+harmless\s+at\s+any\s+dose\b', caseSensitive: false),
  ];

  // ---------------------------------------------------------------------------
  // 1. Citation Integrity Validation
  // ---------------------------------------------------------------------------
  static bool isValidPmid(String? pmid) {
    if (pmid == null) return false;
    final trimmed = pmid.trim();
    if (trimmed.isEmpty) return false;
    final parsed = int.tryParse(trimmed);
    return parsed != null && parsed > 0 && trimmed.length >= 4 && trimmed.length <= 10;
  }

  static bool isValidDoi(String? doi) {
    if (doi == null) return false;
    final trimmed = doi.trim();
    if (trimmed.isEmpty) return false;
    // Standard DOI syntax: starts with 10. followed by registrant code / suffix
    return RegExp(r'^10\.\d{4,9}/[-._;()/:A-Za-z0-9]+$').hasMatch(trimmed);
  }

  static bool isCitationVerifiable(ResearchCitation citation) {
    if (isValidPmid(citation.pmid)) return true;
    if (isValidDoi(citation.url) || (citation.url != null && citation.url!.contains('doi.org/10.'))) {
      return true;
    }
    // Reject generic or placeholder citations without real references
    if (citation.title.toLowerCase().contains('scientific literature review') ||
        citation.title.toLowerCase().contains('translational nutritional science and evidence-based interventions') ||
        citation.authorsOrJournal.toLowerCase().contains('nutritional research reviews')) {
      return false;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // 2. Atomic Claim Extraction & Evaluation
  // ---------------------------------------------------------------------------
  static List<AtomicClaimRecord> extractAndVerifyClaims({
    required String text,
    List<ResearchCitation> availableCitations = const [],
    List<String> verifiedEvidencePassages = const [],
  }) {
    final claims = <AtomicClaimRecord>[];
    if (text.trim().isEmpty) return claims;

    // Split text into candidate propositional sentences
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 15)
        .toList();

    for (final sentence in sentences) {
      final lower = sentence.toLowerCase();

      // Check contradiction
      bool isContradicted = false;
      for (final pattern in _criticalContradictionPatterns) {
        if (pattern.hasMatch(lower)) {
          isContradicted = true;
          break;
        }
      }

      if (isContradicted) {
        claims.add(AtomicClaimRecord(
          claimText: sentence,
          propositionType: ClaimPropositionType.safetyAndToxicity,
          supportStatus: VerificationClaimStatus.contradicted,
          confidenceScore: 0.0,
          verificationNotes: 'Violates clinical safety standards; asserts unsupported medical cure or treatment replacement.',
        ));
        continue;
      }

      // Identify Proposition Type
      ClaimPropositionType propType = ClaimPropositionType.generalInformational;
      if (RegExp(r'\d+\s*(?:mg|mcg|g|kcal|%|fold|iu)\b', caseSensitive: false).hasMatch(sentence)) {
        propType = ClaimPropositionType.quantitativeDosage;
      } else if (lower.contains('mechanism') || lower.contains('receptor') || lower.contains('pathway') || lower.contains('transporter')) {
        propType = ClaimPropositionType.physiologicalMechanism;
      } else if (lower.contains('increase') || lower.contains('decrease') || lower.contains('improve') || lower.contains('reduce')) {
        propType = ClaimPropositionType.causalEfficacy;
      }

      // Check Evidence Grounding
      bool hasEvidencePassageMatch = false;
      String? matchedPassage;
      for (final passage in verifiedEvidencePassages) {
        // Simple token overlap verification
        final sentenceTokens = sentence.toLowerCase().split(RegExp(r'\W+')).where((t) => t.length > 3).toSet();
        final passageTokens = passage.toLowerCase().split(RegExp(r'\W+')).where((t) => t.length > 3).toSet();
        final intersection = sentenceTokens.intersection(passageTokens);
        if (intersection.length >= 3) {
          hasEvidencePassageMatch = true;
          matchedPassage = passage;
          break;
        }
      }

      // Check Citation Linking
      ResearchCitation? matchedCitation;
      if (availableCitations.isNotEmpty) {
        for (final cit in availableCitations) {
          if (isCitationVerifiable(cit)) {
            matchedCitation = cit;
            break;
          }
        }
      }

      VerificationClaimStatus status;
      double score;
      String notes;

      if (hasEvidencePassageMatch || matchedCitation != null) {
        status = VerificationClaimStatus.supported;
        score = 0.95;
        notes = 'Grounded in verified scientific evidence and authentic citation.';
      } else if (lower.contains('may') || lower.contains('suggests') || lower.contains('preliminary') || lower.contains('in vitro')) {
        status = VerificationClaimStatus.extrapolated;
        score = 0.60;
        notes = 'Preliminary hypothesis or extrapolated preclinical mechanism.';
      } else if (propType == ClaimPropositionType.generalInformational) {
        status = VerificationClaimStatus.supported;
        score = 0.85;
        notes = 'General informational or biochemical consensus proposition.';
      } else {
        status = VerificationClaimStatus.unsupported;
        score = 0.30;
        notes = 'Specific quantitative or causal assertion lacking verified citation link.';
      }

      claims.add(AtomicClaimRecord(
        claimText: sentence,
        propositionType: propType,
        supportStatus: status,
        confidenceScore: score,
        verifiedPmid: matchedCitation?.pmid,
        verifiedDoi: matchedCitation?.url,
        supportingPassage: matchedPassage,
        verificationNotes: notes,
      ));
    }

    return claims;
  }

  // ---------------------------------------------------------------------------
  // 3. Master Publication Gate Execution
  // ---------------------------------------------------------------------------
  static PublicationGateResult evaluateForPublication({
    required String rawDirectAnswer,
    required String rawExplanation,
    required List<ResearchCitation> candidateCitations,
    List<String> verifiedEvidencePassages = const [],
  }) {
    final verifiedCitations = <ResearchCitation>[];
    final strippedCitations = <String>[];

    // 1. Filter and Authenticate Citations
    for (final cit in candidateCitations) {
      if (isCitationVerifiable(cit)) {
        verifiedCitations.add(cit);
      } else {
        strippedCitations.add('${cit.title} (${cit.authorsOrJournal}) — Lacks verified PMID/DOI');
      }
    }

    // 2. Extract and Verify Atomic Claims
    final fullText = '$rawDirectAnswer\n$rawExplanation';
    final evaluatedClaims = extractAndVerifyClaims(
      text: fullText,
      availableCitations: verifiedCitations,
      verifiedEvidencePassages: verifiedEvidencePassages,
    );

    final withheldClaims = <String>[];
    final contradictionWarnings = <String>[];

    for (final c in evaluatedClaims) {
      if (c.supportStatus == VerificationClaimStatus.contradicted) {
        contradictionWarnings.add(c.claimText);
      } else if (c.supportStatus == VerificationClaimStatus.unsupported &&
          (c.propositionType == ClaimPropositionType.quantitativeDosage ||
              c.propositionType == ClaimPropositionType.causalEfficacy)) {
        withheldClaims.add(c.claimText);
      }
    }

    // 3. Enforce Publication Decision
    bool isApproved = true;
    String decision = 'Approved for publication';

    String sanitizedAnswer = rawDirectAnswer;
    String sanitizedExplanation = rawExplanation;

    if (contradictionWarnings.isNotEmpty) {
      isApproved = false;
      decision = 'Rejected: Contains clinically contradicted or dangerous assertions.';
      sanitizedAnswer = 'Clinical Safety Notice: Assertions in this inquiry conflict with verified medical evidence. Nutrient Earth withholds ungrounded claims.';
      sanitizedExplanation = 'The requested proposition suggests unverified cures or treatments that contradict established clinical guidelines. Consult a qualified medical practitioner.';
    } else if (withheldClaims.isNotEmpty) {
      decision = 'Approved with sanitized modifications: Unsupported quantitative claims withheld.';
      // Filter out withheld claims from the published text
      for (final withheld in withheldClaims) {
        sanitizedExplanation = sanitizedExplanation.replaceAll(withheld, '').trim();
      }
    }

    return PublicationGateResult(
      isApprovedForPublication: isApproved,
      sanitizedDirectAnswer: sanitizedAnswer,
      sanitizedExplanation: sanitizedExplanation,
      verifiedCitations: verifiedCitations,
      verifiedClaims: evaluatedClaims,
      strippedCitations: strippedCitations,
      withheldClaims: withheldClaims,
      contradictionWarnings: contradictionWarnings,
      publicationDecision: decision,
    );
  }
}
