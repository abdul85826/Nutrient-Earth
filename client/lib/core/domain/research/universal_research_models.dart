// ==============================================================================
// Nutrient Earth — Universal Research & Web Intelligence Models
// Implements multi-source search contracts, crawler governance (Robots & SSRF),
// and strict prompt injection isolation.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

enum ResearchSourceType {
  pubMed,
  europePmc,
  pmcOpenAccess,
  clinicalTrials,
  openAlex,
  crossref,
  usdaFoodDataCentral,
  openFoodFacts,
  pubChem,
  fssai,
  whoCodex,
  ayushPortal;

  String get id {
    switch (this) {
      case ResearchSourceType.pubMed:
        return 'src_pubmed';
      case ResearchSourceType.europePmc:
        return 'src_europe_pmc';
      case ResearchSourceType.pmcOpenAccess:
        return 'src_pmc_oa';
      case ResearchSourceType.clinicalTrials:
        return 'src_clinical_trials';
      case ResearchSourceType.openAlex:
        return 'src_openalex';
      case ResearchSourceType.crossref:
        return 'src_crossref';
      case ResearchSourceType.usdaFoodDataCentral:
        return 'src_usda_fdc';
      case ResearchSourceType.openFoodFacts:
        return 'src_open_food_facts';
      case ResearchSourceType.pubChem:
        return 'src_pubchem';
      case ResearchSourceType.fssai:
        return 'src_fssai';
      case ResearchSourceType.whoCodex:
        return 'src_codex';
      case ResearchSourceType.ayushPortal:
        return 'src_ayushportal';
    }
  }

  String get displayName {
    switch (this) {
      case ResearchSourceType.pubMed:
        return 'PubMed / NLM';
      case ResearchSourceType.europePmc:
        return 'Europe PMC';
      case ResearchSourceType.pmcOpenAccess:
        return 'PMC Open Access';
      case ResearchSourceType.clinicalTrials:
        return 'ClinicalTrials.gov';
      case ResearchSourceType.openAlex:
        return 'OpenAlex Scholarly Graph';
      case ResearchSourceType.crossref:
        return 'Crossref DOI';
      case ResearchSourceType.usdaFoodDataCentral:
        return 'USDA FoodData Central';
      case ResearchSourceType.openFoodFacts:
        return 'Open Food Facts';
      case ResearchSourceType.pubChem:
        return 'PubChem Compounds';
      case ResearchSourceType.fssai:
        return 'FSSAI Food Safety Standards';
      case ResearchSourceType.whoCodex:
        return 'WHO / FAO Codex Alimentarius';
      case ResearchSourceType.ayushPortal:
        return 'AYUSH Research Portal';
    }
  }
}

class CrawlDomainPolicy {
  final String domain;
  final bool isAllowed;
  final int crawlDelaySeconds;
  final int rateLimitPerMinute;
  final String userAgent;

  const CrawlDomainPolicy({
    required this.domain,
    this.isAllowed = true,
    this.crawlDelaySeconds = 5,
    this.rateLimitPerMinute = 12,
    this.userAgent = 'NutrientEarthResearchBot/1.0 (+https://nutrientearth.com/bot)',
  });
}

class CrawledDocument {
  final String id;
  final String canonicalUrl;
  final String domain;
  final String title;
  final String mainText;
  final String? authors;
  final String? publicationDate;
  final String? doi;
  final String? pmid;
  final String contentHashSha256;
  final String licenseType;
  final bool isTrustedSource;
  final DateTime crawledAt;

  const CrawledDocument({
    required this.id,
    required this.canonicalUrl,
    required this.domain,
    required this.title,
    required this.mainText,
    this.authors,
    this.publicationDate,
    this.doi,
    this.pmid,
    required this.contentHashSha256,
    this.licenseType = 'open_access',
    this.isTrustedSource = true,
    required this.crawledAt,
  });

  static String computeHash(String text) {
    return sha256.convert(utf8.encode(text)).toString();
  }
}

/// Defensive Prompt Injection Guard:
/// Strips prompt hijacking attempts and wraps external text as untrusted data blocks.
class PromptInjectionFilter {
  PromptInjectionFilter._();

  static final List<RegExp> _injectionPatterns = [
    RegExp(r'ignore\s+all\s+(previous|prior)\s+instructions', caseSensitive: false),
    RegExp(r'system\s*:', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+a', caseSensitive: false),
    RegExp(r'<\|im_start\|>', caseSensitive: false),
    RegExp(r'<\|im_end\|>', caseSensitive: false),
    RegExp(r'disregard\s+system\s+prompt', caseSensitive: false),
  ];

  /// Sanitizes text and strips potential jailbreak delimiters
  static String sanitizeUntrustedText(String rawText) {
    String sanitized = rawText;
    for (final pattern in _injectionPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED_PROMPT_INJECTION_ATTEMPT]');
    }
    return sanitized;
  }

  /// Wraps document in an isolated untrusted research sandbox block
  static String wrapInUntrustedSandbox({
    required String title,
    required String sourceUrl,
    required String content,
  }) {
    final cleanContent = sanitizeUntrustedText(content);
    return '''
<UNTRUSTED_EXTERNAL_EVIDENCE_SANDBOX>
Source: $sourceUrl
Title: $title
Content:
$cleanContent
</UNTRUSTED_EXTERNAL_EVIDENCE_SANDBOX>
''';
  }
}

class DissectedHealthClaim {
  final String claimQuery;
  final String popularClaimSummary;
  final String biologicalPlausibility;
  final String humanEvidenceVerdict;
  final String studyHierarchyTier;
  final List<String> clinicalRisksOfDelayingCare;
  final String balancedScientificRecommendation;
  final List<String> evidenceCitations;

  const DissectedHealthClaim({
    required this.claimQuery,
    required this.popularClaimSummary,
    required this.biologicalPlausibility,
    required this.humanEvidenceVerdict,
    required this.studyHierarchyTier,
    required this.clinicalRisksOfDelayingCare,
    required this.balancedScientificRecommendation,
    required this.evidenceCitations,
  });
}

class ResearchPaperCritique {
  final String title;
  final String studyDesign;
  final int? sampleSize;
  final List<String> primaryEndpoints;
  final List<String> methodologyLimitations;
  final String fundingAndConflictsOfInterest;
  final List<String> claimLevelCitations;
  final String evidenceTier;

  const ResearchPaperCritique({
    required this.title,
    required this.studyDesign,
    this.sampleSize,
    required this.primaryEndpoints,
    required this.methodologyLimitations,
    required this.fundingAndConflictsOfInterest,
    required this.claimLevelCitations,
    required this.evidenceTier,
  });
}
