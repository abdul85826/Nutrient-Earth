// ==============================================================================
// Nutrient Earth — Citation & Source Validator
// Validates scientific publication identifiers (PMID, DOI) and rejects malformed metadata.
// ==============================================================================

import '../evidence/scientific_evidence_contract.dart';

class CitationValidationResult {
  final bool isValid;
  final List<String> validationErrors;
  final List<String> warnings;

  const CitationValidationResult({
    required this.isValid,
    this.validationErrors = const [],
    this.warnings = const [],
  });
}

class CitationValidator {
  CitationValidator._();

  // Validates standard PubMed IDs (numeric string 1-9 digits)
  static final RegExp _pmidRegex = RegExp(r'^[1-9]\d{0,8}$');

  // Validates standard Digital Object Identifiers (10.xxxx/...)
  static final RegExp _doiRegex = RegExp(r'^10\.\d{4,9}/[-._;()/:A-Za-z0-9]+$');

  static CitationValidationResult validateSource(ScientificSource source) {
    final errors = <String>[];
    final warnings = <String>[];

    if (source.title.trim().isEmpty) {
      errors.add('Citation title cannot be empty.');
    }

    if (source.authorsOrJournal.trim().isEmpty) {
      errors.add('Citation authors or journal cannot be empty.');
    }

    // Validate PMID format if provided
    if (source.pmid != null && source.pmid!.trim().isNotEmpty) {
      final cleanPmid = source.pmid!.trim();
      if (!_pmidRegex.hasMatch(cleanPmid)) {
        errors.add('Malformed PubMed ID: "$cleanPmid". PMIDs must be numeric.');
      }
    }

    // Validate DOI format if provided
    if (source.doi != null && source.doi!.trim().isNotEmpty) {
      final cleanDoi = source.doi!.trim();
      if (!_doiRegex.hasMatch(cleanDoi)) {
        errors.add('Malformed DOI: "$cleanDoi". DOIs must start with 10.xxxx/.');
      }
    }

    // Check year validity
    final yearNum = int.tryParse(source.year.trim());
    if (yearNum == null || yearNum < 1900 || yearNum > DateTime.now().year + 1) {
      warnings.add('Unusual publication year "${source.year}". Verify source date.');
    }

    // If source claims to be live-verified, it must have either a valid PMID or DOI
    if (source.verificationStatus == EvidenceVerificationStatus.liveVerified) {
      if ((source.pmid == null || source.pmid!.trim().isEmpty) &&
          (source.doi == null || source.doi!.trim().isEmpty)) {
        errors.add('Source marked as live-verified requires a verifiable PMID or DOI.');
      }
    }

    return CitationValidationResult(
      isValid: errors.isEmpty,
      validationErrors: errors,
      warnings: warnings,
    );
  }

  static bool isValidPmid(String? pmid) {
    if (pmid == null) return false;
    return _pmidRegex.hasMatch(pmid.trim());
  }

  static bool isValidDoi(String? doi) {
    if (doi == null) return false;
    return _doiRegex.hasMatch(doi.trim());
  }
}
