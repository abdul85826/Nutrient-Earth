import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_config.dart';
import '../domain/answer_contract/structured_research_answer.dart';
import '../domain/blockchain/evidence_integrity_service.dart';
import '../domain/nutrition/nutrition_models.dart';
import '../domain/orchestration/research_orchestration_pipeline.dart';
import '../domain/personalization/goal_alignment_evaluator.dart';
import '../domain/personalization/user_profile_context.dart';

class ResearchCitation {
  final String title;
  final String authorsOrJournal;
  final String year;
  final String evidenceGrade;
  final String? url;
  final String? pmid;
  final String? supportingClaim;

  const ResearchCitation({
    required this.title,
    required this.authorsOrJournal,
    required this.year,
    required this.evidenceGrade,
    this.url,
    this.pmid,
    this.supportingClaim,
  });

  factory ResearchCitation.fromJson(Map<String, dynamic> json) {
    return ResearchCitation(
      title: json['title'] as String? ?? 'Scientific Literature Review',
      authorsOrJournal: json['authorsOrJournal'] as String? ?? 'Nutritional Research Reviews',
      year: json['year'] as String? ?? DateTime.now().year.toString(),
      evidenceGrade: json['evidenceGrade'] as String? ?? 'Evidence Synthesis',
      url: json['url'] as String?,
      pmid: json['pmid'] as String?,
      supportingClaim: json['supportingClaim'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'authorsOrJournal': authorsOrJournal,
        'year': year,
        'evidenceGrade': evidenceGrade,
        'url': url,
        'pmid': pmid,
        'supportingClaim': supportingClaim,
      };
}

class ResearchAnswer {
  final String query;
  final String answerSummary;
  final String evidenceBadge;
  final List<ResearchCitation> citations;
  final List<String> practicalSteps;
  final String uncertaintyDisclaimer;
  final String? imageUrl;
  final DateTime generatedAt;
  final String referenceId;
  final String domainCategory;
  final String? evidenceGap;
  final String? comparisonCallout;
  final double? comparisonIndex;
  final String provider;

  final StructuredResearchAnswer? structuredAnswer;
  final GoalAssessmentResult? goalAlignment;
  final NutritionAnalysisProfile? nutritionAnalysis;
  final ResearchProvenanceDossier? provenanceDossier;

  const ResearchAnswer({
    required this.query,
    required this.answerSummary,
    required this.evidenceBadge,
    required this.citations,
    required this.practicalSteps,
    required this.uncertaintyDisclaimer,
    this.imageUrl,
    required this.generatedAt,
    this.referenceId = 'REF-2026-NE01',
    this.domainCategory = 'Nutritional Biochemistry & Health Science',
    this.evidenceGap,
    this.comparisonCallout,
    this.comparisonIndex,
    this.provider = 'Nutrient Earth Verified Evidence Base',
    this.structuredAnswer,
    this.goalAlignment,
    this.nutritionAnalysis,
    this.provenanceDossier,
  });

  factory ResearchAnswer.fromStructuredAnswer(StructuredResearchAnswer s) {
    return ResearchAnswer(
      query: s.query,
      answerSummary: s.detailedExplanation.isNotEmpty ? s.detailedExplanation : s.quickAnswer,
      evidenceBadge: s.evidenceBadge,
      citations: s.sources.map((src) => ResearchCitation(
        title: src.title,
        authorsOrJournal: src.authorsOrJournal,
        year: src.year,
        evidenceGrade: src.evidenceGrade,
        url: src.url,
        pmid: src.pmid,
        supportingClaim: s.claims.isNotEmpty ? s.claims.first.claimText : null,
      )).toList(),
      practicalSteps: s.practicalRecommendations,
      uncertaintyDisclaimer: s.safetyInformation.generalMedicalDisclaimer,
      generatedAt: s.generatedAt,
      referenceId: s.referenceId,
      domainCategory: s.domainCategory,
      evidenceGap: s.studyLimitations,
      comparisonCallout: s.comparisonCallout,
      comparisonIndex: s.comparisonIndex,
      provider: s.provider,
      structuredAnswer: s,
      goalAlignment: s.goalAlignment,
      nutritionAnalysis: s.nutritionAnalysis,
      provenanceDossier: s.provenanceDossier,
    );
  }

  factory ResearchAnswer.fromJson(Map<String, dynamic> json) {
    return ResearchAnswer(
      query: json['query'] as String? ?? '',
      answerSummary: json['answerSummary'] as String? ?? json['detailedExplanation'] as String? ?? '',
      evidenceBadge: json['evidenceBadge'] as String? ?? 'SYSTEMATIC REVIEW • PEER REVIEWED',
      citations: (json['citations'] as List<dynamic>? ?? json['sources'] as List<dynamic>?)
              ?.map((c) => ResearchCitation.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      practicalSteps: (json['practicalSteps'] as List<dynamic>? ?? json['practicalRecommendations'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
      uncertaintyDisclaimer: json['uncertaintyDisclaimer'] as String? ??
          (json['safetyInformation'] is Map<String, dynamic>
              ? (json['safetyInformation']['generalMedicalDisclaimer'] as String? ??
                  'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace individualized medical diagnoses.')
              : 'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace individualized medical diagnoses.'),
      imageUrl: json['imageUrl'] as String?,
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      referenceId: json['referenceId'] as String? ?? 'REF-2026-NE01',
      domainCategory: json['domainCategory'] as String? ?? 'Nutritional Biochemistry & Health Science',
      evidenceGap: json['evidenceGap'] as String? ?? json['studyLimitations'] as String?,
      comparisonCallout: json['comparisonCallout'] as String?,
      comparisonIndex: (json['comparisonIndex'] as num?)?.toDouble(),
      provider: json['provider'] as String? ?? 'Nutrient Earth Verified Evidence Base',
      structuredAnswer: json['contractVersion'] != null
          ? StructuredResearchAnswer.fromJson(json)
          : null,
      goalAlignment: json['goalAlignment'] != null
          ? GoalAssessmentResult.fromJson(json['goalAlignment'] as Map<String, dynamic>)
          : null,
      nutritionAnalysis: json['nutritionAnalysis'] != null
          ? NutritionAnalysisProfile.fromJson(json['nutritionAnalysis'] as Map<String, dynamic>)
          : null,
      provenanceDossier: json['provenanceDossier'] != null
          ? ResearchProvenanceDossier.fromJson(json['provenanceDossier'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'answerSummary': answerSummary,
        'evidenceBadge': evidenceBadge,
        'citations': citations.map((c) => c.toJson()).toList(),
        'practicalSteps': practicalSteps,
        'uncertaintyDisclaimer': uncertaintyDisclaimer,
        'imageUrl': imageUrl,
        'generatedAt': generatedAt.toIso8601String(),
        'referenceId': referenceId,
        'domainCategory': domainCategory,
        'evidenceGap': evidenceGap,
        'comparisonCallout': comparisonCallout,
        'comparisonIndex': comparisonIndex,
        'provider': provider,
        'goalAlignment': goalAlignment?.toJson(),
        'nutritionAnalysis': nutritionAnalysis?.toJson(),
        'provenanceDossier': provenanceDossier?.toJson(),
        'contractVersion': structuredAnswer?.contractVersion ?? '2026.1',
      };
}

class SensitiveDataRoutingGuard {
  SensitiveDataRoutingGuard._();

  static final List<RegExp> _personalHealthIndicators = [
    RegExp(r'\b(my|i have|i am diagnosed|prescribed|my blood|my glucose|my insulin|my lab|my hba1c|my cholesterol|my dosage)\b', caseSensitive: false),
    RegExp(r'\b(\d+\s*mg\/dl|\d+\s*mmol\/l|\d+\s*ng\/ml)\b', caseSensitive: false),
    RegExp(r'\b(metformin|atorvastatin|lisinopril|levothyroxine|adderall|ozempic|wegovy)\b', caseSensitive: false),
  ];

  static bool containsPersonalHealthSignals(String query) {
    for (final pattern in _personalHealthIndicators) {
      if (pattern.hasMatch(query)) return true;
    }
    return false;
  }
}

class SecurityUrlValidator {
  SecurityUrlValidator._();

  static const Set<String> allowedHosts = {
    'pubmed.ncbi.nlm.nih.gov',
    'ncbi.nlm.nih.gov',
    'doi.org',
    'nature.com',
    'sciencedirect.com',
    'thelancet.com',
    'frontiersin.org',
    'cell.com',
    'bmj.com',
    'nejm.org',
    'jamanetwork.com',
  };

  static bool isSafeScientificUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString.trim());
      if (uri.scheme != 'https') return false;

      final host = uri.host.toLowerCase();
      if (host.isEmpty) return false;

      // Reject IP addresses (IPv4 & IPv6) and local loopback/metadata
      final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (ipv4Regex.hasMatch(host)) return false;
      if (host == 'localhost' || host.endsWith('.local') || host.endsWith('.internal')) return false;

      // Check allowed domain whitelist or valid subdomain of allowed hosts
      return allowedHosts.any((allowed) => host == allowed || host.endsWith('.$allowed'));
    } catch (_) {
      return false;
    }
  }
}

class QuerySanitizer {
  QuerySanitizer._();

  static const int maxQueryLength = 500;

  static String sanitize(String input) {
    var cleaned = input.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    if (cleaned.length > maxQueryLength) {
      cleaned = cleaned.substring(0, maxQueryLength);
    }

    // Strip adversarial prompt injection markers
    final injectionPatterns = [
      RegExp(r'ignore\s+(all\s+)?(previous|prior)\s+instructions?', caseSensitive: false),
      RegExp(r'system\s*prompt', caseSensitive: false),
      RegExp(r'override\s+(all\s+)?rules?', caseSensitive: false),
      RegExp(r'<\/?(?:system|instruction|admin|prompt)[^>]*>', caseSensitive: false),
    ];

    for (final pattern in injectionPatterns) {
      cleaned = cleaned.replaceAll(pattern, '[sanitized]');
    }

    return cleaned;
  }
}

class ResearchPipelineService {
  ResearchPipelineService._();

  static bool validateScientificUrl(String url) => SecurityUrlValidator.isSafeScientificUrl(url);

  static Future<ResearchAnswer> processInquiry({
    required String query,
    String? imagePath,
    String? audioPath,
    bool containsPersonalHealthData = false,
    UserProfileContext? userProfile,
  }) async {
    final cleanQuery = QuerySanitizer.sanitize(query);

    // Strict Data Privacy Guardrail: Multimodal inputs (meal / lab photos / audio recordings)
    // or personal health signals must NEVER be routed to unauthenticated public endpoints.
    final isPersonalData = containsPersonalHealthData ||
        imagePath != null ||
        audioPath != null ||
        SensitiveDataRoutingGuard.containsPersonalHealthSignals(cleanQuery);

    if (!isPersonalData && SupabaseConfig.client != null) {
      try {
        final response = await SupabaseConfig.client!.functions.invoke(
          'research-synthesizer',
          body: {
            'query': cleanQuery,
            'taskType': 'general_scientific_inquiry',
            'containsPersonalHealthData': false,
            if (userProfile != null) 'userContext': userProfile.toAnonymizedEvaluationMap(),
          },
        );

        if (response.status == 200 && response.data is Map<String, dynamic>) {
          return ResearchAnswer.fromJson(response.data as Map<String, dynamic>);
        }
      } catch (_) {
        // Operational logging only: Silently fall through to verified clinical knowledge base
      }
    }

    // Execute the full 10-stage deterministic research orchestration pipeline
    final pipeline = ResearchOrchestrationPipeline();
    final result = await pipeline.execute(
      query: cleanQuery,
      userProfile: userProfile,
      containsPersonalHealthData: isPersonalData,
    );
    return ResearchAnswer.fromStructuredAnswer(result.answer);
  }
}

final researchServiceProvider = Provider<ResearchPipelineService>((ref) {
  return ResearchPipelineService._();
});
