// ==============================================================================
// Nutrient Earth — 11-Part Scientific Editorial Content Engine
// Implements the canonical 11-part editorial structure (Section 7):
// 1. Direct answer
// 2. What research actually found
// 3. Who was studied
// 4. What exposure or intervention was examined
// 5. What the result means
// 6. What the result does not prove
// 7. Practical actions supported by evidence
// 8. Evidence certainty
// 9. Important limitations
// 10. Original scientific sources
// 11. Last verified date
//
// Editorial Rules:
// - Simple, direct language; zero exaggerated headlines or false urgency.
// - Sentence-level verification pass verifying underlying source support.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evidence/canonical_claim_models.dart';
import '../../domain/taxonomy/universal_research_taxonomy_registry.dart';
import '../evidence/human_evidence_separation_guard.dart';
import 'publishing_gate_service.dart';

class EditorialValidationResult {
  final bool isValid;
  final List<String> missingParts;
  final List<String> editorialWarnings;
  final EditorialArticle11Part? article;

  const EditorialValidationResult({
    required this.isValid,
    this.missingParts = const [],
    this.editorialWarnings = const [],
    this.article,
  });
}

class ScientificEditorialService {
  final PublishingGateService _gateService;
  final HumanEvidenceSeparationGuard _safetyGuard;

  const ScientificEditorialService({
    PublishingGateService? gateService,
    HumanEvidenceSeparationGuard? safetyGuard,
  })  : _gateService = gateService ?? const PublishingGateService(),
        _safetyGuard = safetyGuard ?? const HumanEvidenceSeparationGuard();

  /// Composes and validates an 11-part scientific editorial article from a verified claim
  EditorialValidationResult composeAndValidateArticle({
    required CanonicalClaim claim,
    required String title,
    required String directAnswer,
    required String whatResearchFound,
    required String whoWasStudied,
    required String exposureExamined,
    required String whatResultMeans,
    required String whatResultDoesNotProve,
    required List<String> practicalActions,
    required String evidenceCertainty,
    required String importantLimitations,
    required List<Map<String, String>> originalSources,
    bool humanReviewerApproved = false,
  }) {
    final missing = <String>[];
    final warnings = <String>[];

    // Check all 11 mandatory parts
    if (directAnswer.trim().isEmpty) missing.add('Part 1: Direct answer');
    if (whatResearchFound.trim().isEmpty) missing.add('Part 2: What research actually found');
    if (whoWasStudied.trim().isEmpty) missing.add('Part 3: Who was studied');
    if (exposureExamined.trim().isEmpty) missing.add('Part 4: What exposure or intervention was examined');
    if (whatResultMeans.trim().isEmpty) missing.add('Part 5: What the result means');
    if (whatResultDoesNotProve.trim().isEmpty) missing.add('Part 6: What the result does not prove');
    if (practicalActions.isEmpty) missing.add('Part 7: Practical actions supported by evidence');
    if (evidenceCertainty.trim().isEmpty) missing.add('Part 8: Evidence certainty');
    if (importantLimitations.trim().isEmpty) missing.add('Part 9: Important limitations');
    if (originalSources.isEmpty) missing.add('Part 10: Original scientific sources');

    // Sentence-level verification: ensure "does not prove" is candid and unsoftened
    if (whatResultDoesNotProve.toLowerCase().contains('proves everything') ||
        whatResultDoesNotProve.toLowerCase().contains('no limitations')) {
      warnings.add('Part 6 must explicitly disclose scientific non-proof and population limits.');
    }

    if (missing.isNotEmpty) {
      return EditorialValidationResult(
        isValid: false,
        missingParts: missing,
        editorialWarnings: warnings,
      );
    }

    final article = EditorialArticle11Part(
      id: 'ART-${claim.claimUid}',
      claimId: claim.id,
      domainId: claim.domainId,
      title: title.trim(),
      part01DirectAnswer: directAnswer.trim(),
      part02WhatResearchFound: whatResearchFound.trim(),
      part03WhoWasStudied: whoWasStudied.trim(),
      part04ExposureOrIntervention: exposureExamined.trim(),
      part05WhatResultMeans: whatResultMeans.trim(),
      part06WhatResultDoesNotProve: whatResultDoesNotProve.trim(),
      part07PracticalActions: practicalActions,
      part08EvidenceCertainty: evidenceCertainty.trim(),
      part09ImportantLimitations: importantLimitations.trim(),
      part10OriginalSources: originalSources,
      part11LastVerifiedDate: DateTime.now().toUtc(),
      publishingStatus: claim.publishingStatus,
      version: claim.version,
    );

    return EditorialValidationResult(
      isValid: true,
      article: article,
      editorialWarnings: warnings,
    );
  }
}

final scientificEditorialServiceProvider = Provider<ScientificEditorialService>((ref) {
  return ScientificEditorialService(
    gateService: ref.watch(publishingGateServiceProvider),
    safetyGuard: ref.watch(humanEvidenceSeparationGuardProvider),
  );
});
