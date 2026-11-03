// ==============================================================================
// Nutrient Earth — Canonical Research Provenance Manifest
// Cryptographically verifiable research manifest adhering to RFC-8785 JSON canonicalization.
// STRICT PRIVACY DIRECTIVE: ZERO PII. NEVER stores or anchors user identities,
// prompts, personal health records, or biometric data on-chain.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

enum EvidenceTier {
  strong,
  moderate,
  limited,
  emerging,
  conflicting,
  insufficient;

  String get displayName {
    switch (this) {
      case EvidenceTier.strong:
        return 'Strong Evidence (Grade A - Systematic / Double-Blind RCT)';
      case EvidenceTier.moderate:
        return 'Moderate Evidence (Grade B - Controlled Cohort / Trial)';
      case EvidenceTier.limited:
        return 'Limited Evidence (Grade C - Small Pilot / Pharmacokinetics)';
      case EvidenceTier.emerging:
        return 'Emerging Findings (Grade D - Observational / In-Vitro)';
      case EvidenceTier.conflicting:
        return 'Conflicting Evidence (Grade X - Mixed Outcomes in Trials)';
      case EvidenceTier.insufficient:
        return 'Insufficient Evidence (Grade I - Inadequate Empirical Data)';
    }
  }

  String get badgeLabel {
    switch (this) {
      case EvidenceTier.strong:
        return 'GRADE A • SYSTEMATIC EVIDENCE';
      case EvidenceTier.moderate:
        return 'GRADE B • RANDOMIZED TRIAL';
      case EvidenceTier.limited:
        return 'GRADE C • PRELIMINARY DATA';
      case EvidenceTier.emerging:
        return 'GRADE D • EMERGING FINDINGS';
      case EvidenceTier.conflicting:
        return 'GRADE X • CONFLICTING EVIDENCE';
      case EvidenceTier.insufficient:
        return 'GRADE I • INSUFFICIENT DATA';
    }
  }

  static EvidenceTier fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'strong':
        return EvidenceTier.strong;
      case 'moderate':
        return EvidenceTier.moderate;
      case 'limited':
        return EvidenceTier.limited;
      case 'emerging':
        return EvidenceTier.emerging;
      case 'conflicting':
        return EvidenceTier.conflicting;
      case 'insufficient':
      default:
        return EvidenceTier.insufficient;
    }
  }
}

class CanonicalProvenanceManifest {
  final String inquiryReferenceId;
  final String querySanitized;
  final String domainCategory;
  final EvidenceTier evidenceTier;
  final List<String> claimHashes;
  final List<String> sourceIdentifiers; // PMIDs, DOIs, ISBNs
  final DateTime generatedAtUtc;
  final String schemaVersion;

  const CanonicalProvenanceManifest({
    required this.inquiryReferenceId,
    required this.querySanitized,
    required this.domainCategory,
    required this.evidenceTier,
    required this.claimHashes,
    required this.sourceIdentifiers,
    required this.generatedAtUtc,
    this.schemaVersion = '1.0.0',
  });

  /// Deterministically serializes manifest to sorted canonical JSON (RFC-8785)
  String toCanonicalJson() {
    final sortedClaimHashes = List<String>.from(claimHashes)..sort();
    final sortedSourceIdentifiers = List<String>.from(sourceIdentifiers)..sort();

    // Map keys must be strictly ordered alphabetically
    final canonicalMap = <String, dynamic>{
      'claim_hashes': sortedClaimHashes,
      'domain_category': domainCategory.trim(),
      'evidence_tier': evidenceTier.name,
      'generated_at_utc': generatedAtUtc.toUtc().toIso8601String(),
      'inquiry_reference_id': inquiryReferenceId.trim(),
      'query_sanitized': querySanitized.trim(),
      'schema_version': schemaVersion,
      'source_identifiers': sortedSourceIdentifiers,
    };

    return jsonEncode(canonicalMap);
  }

  /// Calculates SHA-256 hex digest of the canonical JSON manifest
  String computeManifestHash() {
    final canonicalString = toCanonicalJson();
    final bytes = utf8.encode(canonicalString);
    return sha256.convert(bytes).toString();
  }

  Map<String, dynamic> toJson() => {
        'inquiry_reference_id': inquiryReferenceId,
        'query_sanitized': querySanitized,
        'domain_category': domainCategory,
        'evidence_tier': evidenceTier.name,
        'claim_hashes': claimHashes,
        'source_identifiers': sourceIdentifiers,
        'generated_at_utc': generatedAtUtc.toUtc().toIso8601String(),
        'schema_version': schemaVersion,
        'manifest_hash': computeManifestHash(),
      };

  factory CanonicalProvenanceManifest.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('inquiry_reference_id') || json['inquiry_reference_id'] == null) {
      throw const FormatException('Missing required manifest field: inquiry_reference_id');
    }
    if (!json.containsKey('domain_category') || json['domain_category'] == null) {
      throw const FormatException('Missing required manifest field: domain_category');
    }
    if (!json.containsKey('evidence_tier') || json['evidence_tier'] == null) {
      throw const FormatException('Missing required manifest field: evidence_tier');
    }
    if (!json.containsKey('claim_hashes') || json['claim_hashes'] == null) {
      throw const FormatException('Missing required manifest field: claim_hashes');
    }
    if (!json.containsKey('source_identifiers') || json['source_identifiers'] == null) {
      throw const FormatException('Missing required manifest field: source_identifiers');
    }
    if (!json.containsKey('generated_at_utc') || json['generated_at_utc'] == null) {
      throw const FormatException('Missing required manifest field: generated_at_utc');
    }

    return CanonicalProvenanceManifest(
      inquiryReferenceId: json['inquiry_reference_id'] as String,
      querySanitized: json['query_sanitized'] as String? ?? '',
      domainCategory: json['domain_category'] as String,
      evidenceTier: EvidenceTier.fromString(json['evidence_tier'] as String),
      claimHashes: (json['claim_hashes'] as List<dynamic>).map((e) => e.toString()).toList(),
      sourceIdentifiers: (json['source_identifiers'] as List<dynamic>).map((e) => e.toString()).toList(),
      generatedAtUtc: DateTime.parse(json['generated_at_utc'] as String).toUtc(),
      schemaVersion: json['schema_version'] as String? ?? '1.0.0',
    );
  }
}
