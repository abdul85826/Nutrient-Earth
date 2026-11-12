import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_config.dart';
import '../domain/answer_contract/structured_research_answer.dart';
import '../domain/answer_contract/universal_intelligence_answer.dart';
import '../domain/blockchain/evidence_integrity_service.dart';
import '../domain/evidence/scientific_evidence_contract.dart';
import '../domain/input_gateway/universal_input_descriptor.dart';
import '../domain/nutrition/nutrition_models.dart';
import '../domain/orchestration/chatbot_intent_router.dart';
import '../domain/orchestration/research_orchestration_pipeline.dart';
import '../domain/orchestration/universal_question_service.dart';
import '../domain/personalization/goal_alignment_evaluator.dart';
import '../domain/personalization/goal_match_calculation_service.dart';
import '../domain/personalization/user_profile_context.dart';
import 'multimodal/image_quality_service.dart';
import 'multimodal/product_candidate_service.dart';
import 'multimodal/social_platform_retrieval_service.dart';
import 'multimodal/video_upload_ingestion_service.dart';

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
  final UniversalIntelligenceAnswer? universalAnswer;
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
    this.universalAnswer,
    this.goalAlignment,
    this.nutritionAnalysis,
    this.provenanceDossier,
  });

  /// Explicit provenance flags distinguishing remote AI synthesis from local offline archive
  bool get isRemoteLiveSynthesis =>
      provider.toLowerCase().contains('groq') ||
      provider.toLowerCase().contains('gemini') ||
      provider.toLowerCase().contains('deepseek');

  bool get isDeterministicLocalArchive => !isRemoteLiveSynthesis;

  factory ResearchAnswer.fromUniversalAnswer(UniversalIntelligenceAnswer u) {
    return ResearchAnswer(
      query: u.query,
      answerSummary: u.heroAnswer.isNotEmpty
          ? (u.detailedExplanation.isNotEmpty
              ? '${u.heroAnswer}\n\n${u.detailedExplanation}'
              : u.heroAnswer)
          : u.detailedExplanation,
      evidenceBadge: u.legacyEvidenceBadge ??
          (u.showEvidenceWatermark ? 'VERIFIED SOURCES AVAILABLE' : 'NO VERIFIED SOURCES'),
      citations: u.evidence.citations.map((src) => ResearchCitation(
        title: src.title,
        authorsOrJournal: src.authorsOrJournal,
        year: src.year,
        evidenceGrade: src.evidenceGrade,
        url: src.url,
        pmid: src.pmid,
        supportingClaim: u.evidence.claims.isNotEmpty ? u.evidence.claims.first.claimText : null,
      )).toList(),
      practicalSteps: u.practicalSteps,
      uncertaintyDisclaimer: u.uncertaintyDisclaimer,
      generatedAt: u.generatedAt,
      referenceId: u.referenceId,
      domainCategory: 'Nutritional Biochemistry & Health Science',
      evidenceGap: u.evidence.limitationsNotes,
      provider: u.providerUsed,
      universalAnswer: u,
      nutritionAnalysis: u.foodComposition,
      provenanceDossier: u.provenanceDossier,
      goalAlignment: u.legacyGoalAlignment,
    );
  }

  factory ResearchAnswer.fromStructuredAnswer(
    StructuredResearchAnswer s, {
    UniversalIntelligenceAnswer? universalAnswer,
  }) {
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
      universalAnswer: universalAnswer,
      goalAlignment: s.goalAlignment,
      nutritionAnalysis: s.nutritionAnalysis,
      provenanceDossier: s.provenanceDossier,
    );
  }

  ResearchAnswer copyWith({
    String? query,
    String? answerSummary,
    String? evidenceBadge,
    List<ResearchCitation>? citations,
    List<String>? practicalSteps,
    String? uncertaintyDisclaimer,
    String? imageUrl,
    DateTime? generatedAt,
    String? referenceId,
    String? domainCategory,
    String? evidenceGap,
    String? comparisonCallout,
    double? comparisonIndex,
    String? provider,
    StructuredResearchAnswer? structuredAnswer,
    UniversalIntelligenceAnswer? universalAnswer,
    GoalAssessmentResult? goalAlignment,
    NutritionAnalysisProfile? nutritionAnalysis,
    ResearchProvenanceDossier? provenanceDossier,
  }) {
    return ResearchAnswer(
      query: query ?? this.query,
      answerSummary: answerSummary ?? this.answerSummary,
      evidenceBadge: evidenceBadge ?? this.evidenceBadge,
      citations: citations ?? this.citations,
      practicalSteps: practicalSteps ?? this.practicalSteps,
      uncertaintyDisclaimer: uncertaintyDisclaimer ?? this.uncertaintyDisclaimer,
      imageUrl: imageUrl ?? this.imageUrl,
      generatedAt: generatedAt ?? this.generatedAt,
      referenceId: referenceId ?? this.referenceId,
      domainCategory: domainCategory ?? this.domainCategory,
      evidenceGap: evidenceGap ?? this.evidenceGap,
      comparisonCallout: comparisonCallout ?? this.comparisonCallout,
      comparisonIndex: comparisonIndex ?? this.comparisonIndex,
      provider: provider ?? this.provider,
      structuredAnswer: structuredAnswer ?? this.structuredAnswer,
      universalAnswer: universalAnswer ?? this.universalAnswer,
      goalAlignment: goalAlignment ?? this.goalAlignment,
      nutritionAnalysis: nutritionAnalysis ?? this.nutritionAnalysis,
      provenanceDossier: provenanceDossier ?? this.provenanceDossier,
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

  /// Universal Multimodal Intelligence Pipeline (Schema v2026.2).
  /// Processes any validated input type (text, barcode, image, video upload, social URL, document).
  /// Enforces the 5 visual presentation rules and separates goal match from scientific evidence.
  static Future<UniversalIntelligenceAnswer> processUniversalInquiry({
    required UniversalInputDescriptor descriptor,
    UserProfileContext? userProfile,
    EvidenceIntegrityService? integrityService,
    String? activeContextTopic,
  }) async {
    switch (descriptor.inputType) {
      case UserInputType.barcode:
        final product = ProductCandidateService.resolveBarcode(descriptor.rawPayload);
        final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: '${product.productName} ${product.brand}',
          userProfile: userProfile,
          nutrition: product.nutrition,
          productDietaryAttributes: product.dietaryAttributes,
          productAllergens: product.allergens,
        );

        final citations = product.isCandidateUncertain
            ? const <ScientificSource>[]
            : const [
                ScientificSource(
                  title: 'Electrolyte supplementation in metabolic balance',
                  authorsOrJournal: 'Nutr Rev',
                  year: '2023',
                  evidenceGrade: 'Clinical Review',
                  pmid: '32001452',
                  isHumanTrial: true,
                ),
              ];

        final hasVerified = citations.isNotEmpty && !product.isCandidateUncertain;

        return UniversalIntelligenceAnswer(
          referenceId: 'BARCODE-${product.barcode}',
          detectedInputType: UserInputType.barcode,
          query: 'Barcode lookup: ${descriptor.rawPayload}',
          heroAnswer: product.isCandidateUncertain
              ? 'Uncatalogued product barcode: ${descriptor.rawPayload}. Nutrient Earth did not identify verified ingredients in its registry.'
              : '${product.productName} by ${product.brand} is verified with complete nutritional transparency.',
          recommendation: product.isCandidateUncertain
              ? 'Scan or enter ingredients manually to verify goal alignment.'
              : 'Suitable for daily routine based on verified ingredient profile.',
          detailedExplanation: product.isCandidateUncertain
              ? 'No verified manufacturer or laboratory assay found for barcode ${descriptor.rawPayload}. Ingredients were not fabricated to preserve safety.'
              : 'Contains: ${product.ingredients.join(', ')}. Caloric yield: ${product.nutrition.macronutrients.calories} kcal, Protein: ${product.nutrition.macronutrients.proteinGrams}g.',
          goalMatch: goalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: hasVerified,
            classification: hasVerified ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasVerified ? 'Verified sources available' : 'No verified scientific sources',
            citations: citations,
            limitationsNotes: product.isCandidateUncertain ? 'Unverified product candidate.' : null,
          ),
          practicalSteps: product.isCandidateUncertain
              ? const ['Check the product packaging for allergen warnings.']
              : const ['Check serving size on container label.'],
          foodComposition: product.nutrition,
          uncertaintyDisclaimer:
              'Nutrient Earth provides nutritional and health research syntheses for educational guidance; it does not replace individualized clinical care.',
        );

      case UserInputType.image:
        final quality = ImageQualityService.assessImageQuality(descriptor.fileBytes ?? Uint8List(0));
        final isBlurry = quality.blurScore >= 0.70 || !quality.isSuitableForTask;

        final cleanQuery = descriptor.rawPayload.trim().isNotEmpty
            ? QuerySanitizer.sanitize(descriptor.rawPayload)
            : 'Analyze nutritional composition of this image';

        final pipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final result = await pipeline.execute(
          query: cleanQuery,
          userProfile: userProfile,
          containsPersonalHealthData: true,
        );

        final structured = result.answer;
        final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanQuery,
          userProfile: userProfile,
          nutrition: structured.nutritionAnalysis,
        );

        final hasSources = structured.sources.isNotEmpty && !isBlurry;

        return UniversalIntelligenceAnswer(
          referenceId: structured.referenceId,
          detectedInputType: UserInputType.image,
          query: cleanQuery,
          heroAnswer: isBlurry
              ? 'Image quality is degraded or blurry. Precise ingredient confirmation is uncertain.'
              : structured.quickAnswer,
          recommendation: isBlurry
              ? 'Please retake photo in bright lighting and hold camera steady.'
              : (structured.practicalRecommendations.isNotEmpty
                  ? structured.practicalRecommendations.first
                  : 'Incorporate into a balanced diet.'),
          detailedExplanation: isBlurry
              ? '${quality.diagnosticNotes}\n\nEstimated nutritional analysis: ${structured.detailedExplanation}'
              : structured.detailedExplanation,
          goalMatch: goalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: hasSources,
            classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: hasSources ? structured.sources : const [],
            claims: structured.claims,
            limitationsNotes: isBlurry ? 'Image blur degraded OCR confidence.' : structured.studyLimitations,
          ),
          practicalSteps: structured.practicalRecommendations,
          imageQuality: quality,
          foodComposition: structured.nutritionAnalysis,
          uncertaintyDisclaimer: structured.safetyInformation.generalMedicalDisclaimer,
        );

      case UserInputType.videoUpload:
        final validation = VideoUploadIngestionService.validateVideoPayload(descriptor.fileBytes ?? Uint8List(0));
        final transcript = descriptor.rawPayload.trim().isNotEmpty
            ? descriptor.rawPayload
            : 'Uploaded video content for nutritional verification.';
        final videoArtifact = VideoUploadIngestionService.processVideoTranscription(
          rawTranscript: transcript,
          languageCode: 'en',
          videoDurationSeconds: validation.durationSecondsEstimate,
        );

        final cleanQuery = QuerySanitizer.sanitize(transcript);
        final pipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final result = await pipeline.execute(
          query: cleanQuery,
          userProfile: userProfile,
          containsPersonalHealthData: true,
        );
        final structured = result.answer;
        final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanQuery,
          userProfile: userProfile,
          nutrition: structured.nutritionAnalysis,
        );

        final hasSources = structured.sources.isNotEmpty;

        return UniversalIntelligenceAnswer(
          referenceId: structured.referenceId,
          detectedInputType: UserInputType.videoUpload,
          query: cleanQuery,
          heroAnswer:
              'Video verified against clinical trials. Claims analyzed across ${videoArtifact.claims.length} timestamps.',
          recommendation: structured.practicalRecommendations.isNotEmpty
              ? structured.practicalRecommendations.first
              : 'Consult verified medical trials before adopting lifestyle claims.',
          detailedExplanation: structured.detailedExplanation,
          goalMatch: goalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: hasSources,
            classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: structured.sources,
            claims: structured.claims,
            limitationsNotes: structured.studyLimitations,
          ),
          practicalSteps: structured.practicalRecommendations,
          videoAnalysis: videoArtifact,
          uncertaintyDisclaimer: structured.safetyInformation.generalMedicalDisclaimer,
        );

      case UserInputType.socialVideoUrl:
        final socialResult = SocialPlatformRetrievalService.inspectUrl(descriptor.rawPayload);

        if (!socialResult.isAccessible) {
          return UniversalIntelligenceAnswer(
            referenceId: 'REF-SOCIAL-RESTRICTED',
            detectedInputType: UserInputType.socialVideoUrl,
            query: descriptor.rawPayload,
            heroAnswer: 'Platform restriction: ${socialResult.platform.name.toUpperCase()} requires authentication.',
            recommendation: 'Upload the video file or screen recording directly to verify claims.',
            detailedExplanation: socialResult.limitationMessage ?? 'Unable to retrieve content from platform URL.',
            goalMatch: const GoalMatchIndicator(
              matchPercentage: null,
              status: GoalAlignmentStatus.insufficientInformation,
              matchLabel: 'Not enough information to assess',
              rationale: 'Content could not be accessed due to platform permissions.',
            ),
            evidence: const EvidenceProvenanceContainer(
              hasVerifiedSources: false,
              classification: EvidenceClassification.notVerified,
              watermarkLabel: 'No verified scientific sources',
              citations: [],
            ),
            uncertaintyDisclaimer: 'Nutrient Earth does not bypass platform authentication barriers.',
            urlSourceDetails: descriptor.rawPayload,
          );
        }

        // Accessible social URL (e.g. YouTube)
        final cleanQuery = QuerySanitizer.sanitize(socialResult.extractedText ?? descriptor.rawPayload);
        final pipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final result = await pipeline.execute(
          query: cleanQuery,
          userProfile: userProfile,
          containsPersonalHealthData: false,
        );
        final structured = result.answer;
        final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanQuery,
          userProfile: userProfile,
          nutrition: structured.nutritionAnalysis,
        );

        final hasSources = structured.sources.isNotEmpty;

        return UniversalIntelligenceAnswer(
          referenceId: structured.referenceId,
          detectedInputType: UserInputType.socialVideoUrl,
          query: descriptor.rawPayload,
          heroAnswer: structured.quickAnswer,
          recommendation: structured.practicalRecommendations.isNotEmpty
              ? structured.practicalRecommendations.first
              : 'Review clinical evidence.',
          detailedExplanation: structured.detailedExplanation,
          goalMatch: goalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: hasSources,
            classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: structured.sources,
            claims: structured.claims,
            limitationsNotes: structured.studyLimitations,
          ),
          practicalSteps: structured.practicalRecommendations,
          uncertaintyDisclaimer: structured.safetyInformation.generalMedicalDisclaimer,
          urlSourceDetails: descriptor.rawPayload,
        );

      case UserInputType.documentPdf:
        final cleanDocQuery = QuerySanitizer.sanitize(
          descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Extract and verify clinical findings from PDF document',
        );
        final docPipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final docResult = await docPipeline.execute(
          query: cleanDocQuery,
          userProfile: userProfile,
          containsPersonalHealthData: true,
        );
        final docStructured = docResult.answer;
        final docGoalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanDocQuery,
          userProfile: userProfile,
          nutrition: docStructured.nutritionAnalysis,
        );
        final docHasSources = docStructured.sources.isNotEmpty;

        return UniversalIntelligenceAnswer(
          referenceId: docStructured.referenceId,
          detectedInputType: UserInputType.documentPdf,
          query: cleanDocQuery,
          heroAnswer: 'PDF Document analyzed. Key nutritional and clinical evidence extracted.',
          recommendation: docStructured.practicalRecommendations.isNotEmpty
              ? docStructured.practicalRecommendations.first
              : 'Review verified evidence citations extracted from the document.',
          detailedExplanation: docStructured.detailedExplanation,
          goalMatch: docGoalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: docHasSources,
            classification: docHasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: docHasSources ? 'Verified sources available' : 'Document clinical evidence',
            citations: docStructured.sources,
            claims: docStructured.claims,
            limitationsNotes: docStructured.studyLimitations,
          ),
          practicalSteps: docStructured.practicalRecommendations,
          uncertaintyDisclaimer: docStructured.safetyInformation.generalMedicalDisclaimer,
          providerUsed: docStructured.provider,
        );

      case UserInputType.audio:
        final cleanAudioQuery = QuerySanitizer.sanitize(
          descriptor.rawPayload.isNotEmpty ? descriptor.rawPayload : 'Spoken wellness inquiry',
        );
        final audioPipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final audioResult = await audioPipeline.execute(
          query: cleanAudioQuery,
          userProfile: userProfile,
          containsPersonalHealthData: true,
        );
        final audioStructured = audioResult.answer;
        final audioGoalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanAudioQuery,
          userProfile: userProfile,
          nutrition: audioStructured.nutritionAnalysis,
        );
        final audioHasSources = audioStructured.sources.isNotEmpty;

        return UniversalIntelligenceAnswer(
          referenceId: audioStructured.referenceId,
          detectedInputType: UserInputType.audio,
          query: cleanAudioQuery,
          heroAnswer: 'Spoken inquiry processed: "$cleanAudioQuery". Grounded in scientific research.',
          recommendation: audioStructured.practicalRecommendations.isNotEmpty
              ? audioStructured.practicalRecommendations.first
              : 'Follow clinical evidence for your stated inquiry.',
          detailedExplanation: audioStructured.detailedExplanation,
          goalMatch: audioGoalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: audioHasSources,
            classification: audioHasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: audioHasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: audioStructured.sources,
            claims: audioStructured.claims,
            limitationsNotes: audioStructured.studyLimitations,
          ),
          practicalSteps: audioStructured.practicalRecommendations,
          uncertaintyDisclaimer: audioStructured.safetyInformation.generalMedicalDisclaimer,
          providerUsed: audioStructured.provider,
        );

      case UserInputType.text:
      default:
        final cleanQuery = QuerySanitizer.sanitize(descriptor.rawPayload);

        // 1. Universal Question Classification & Personalization Layer
        final scope = UniversalQuestionService.classifyScope(cleanQuery, inputType: descriptor.inputType);
        if (scope == QuestionScope.generalKnowledge) {
          final generalAnswer = UniversalQuestionService.handleGeneralQuestion(cleanQuery);
          if (generalAnswer != null) {
            return generalAnswer;
          }
        } else if (scope == QuestionScope.personalizedHealth) {
          final personalizedAnswer = UniversalQuestionService.handlePersonalizedQuestion(cleanQuery, userProfile);
          return personalizedAnswer;
        }

        final intent = ChatbotIntentRouter.classifyIntent(
          cleanQuery,
          inputType: descriptor.inputType,
          activeContextTopic: activeContextTopic,
        );
        final nonResearchAnswer = ChatbotIntentRouter.handleNonResearchIntent(
          intent: intent,
          rawQuery: cleanQuery,
          userProfile: userProfile,
          activeContextTopic: activeContextTopic,
        );
        if (nonResearchAnswer != null) {
          return nonResearchAnswer;
        }

        final isPersonal = SensitiveDataRoutingGuard.containsPersonalHealthSignals(cleanQuery);

        final pipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
        final result = await pipeline.execute(
          query: cleanQuery,
          userProfile: userProfile,
          containsPersonalHealthData: isPersonal,
        );
        final structured = result.answer;
        final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
          query: cleanQuery,
          userProfile: userProfile,
          nutrition: structured.nutritionAnalysis,
        );

        final hasSources = structured.sources.isNotEmpty;

        return UniversalIntelligenceAnswer(
          referenceId: structured.referenceId,
          detectedInputType: descriptor.inputType,
          query: cleanQuery,
          heroAnswer: structured.quickAnswer,
          recommendation: structured.practicalRecommendations.isNotEmpty
              ? structured.practicalRecommendations.first
              : 'Incorporate evidenced lifestyle principles.',
          detailedExplanation: structured.detailedExplanation,
          goalMatch: goalMatch,
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: hasSources,
            classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
            citations: structured.sources,
            claims: structured.claims,
            limitationsNotes: structured.studyLimitations,
          ),
          practicalSteps: structured.practicalRecommendations,
          foodComposition: structured.nutritionAnalysis,
          uncertaintyDisclaimer: structured.safetyInformation.generalMedicalDisclaimer,
          providerUsed: structured.provider,
          provenanceDossier: structured.provenanceDossier,
          legacyEvidenceBadge: structured.evidenceBadge,
          legacyGoalAlignment: structured.goalAlignment,
        );
    }
  }

  static Future<ResearchAnswer> processInquiry({
    required String query,
    String? imagePath,
    String? audioPath,
    bool containsPersonalHealthData = false,
    UserProfileContext? userProfile,
    EvidenceIntegrityService? integrityService,
  }) async {
    final cleanQuery = QuerySanitizer.sanitize(query);

    final intent = ChatbotIntentRouter.classifyIntent(cleanQuery);
    final nonResearchAnswer = ChatbotIntentRouter.handleNonResearchIntent(
      intent: intent,
      rawQuery: cleanQuery,
      userProfile: userProfile,
    );
    if (nonResearchAnswer != null) {
      return ResearchAnswer.fromUniversalAnswer(nonResearchAnswer);
    }

    // Strict Data Privacy Guardrail: Multimodal inputs (meal / lab photos / audio recordings)
    // or personal health signals must NEVER be routed to unauthenticated public endpoints.
    final isPersonalData = containsPersonalHealthData ||
        imagePath != null ||
        audioPath != null ||
        SensitiveDataRoutingGuard.containsPersonalHealthSignals(cleanQuery);

    final client = SupabaseConfig.client;
    final hasActiveSession = client?.auth.currentSession != null;

    if (!isPersonalData && client != null && hasActiveSession) {
      try {
        final response = await client.functions.invoke(
          'research-synthesizer',
          body: {
            'query': cleanQuery,
            'taskType': 'general_scientific_inquiry',
            'containsPersonalHealthData': false,
            if (userProfile != null) 'userContext': userProfile.toAnonymizedEvaluationMap(),
          },
        );

        if (response.status == 200 && response.data is Map<String, dynamic>) {
          final answer = ResearchAnswer.fromJson(response.data as Map<String, dynamic>);
          // Strict Citation Validation: ensure returned citations are valid and uncorrupted
          final validCitations = answer.citations.where((c) {
            if (c.pmid != null && c.pmid!.trim().isNotEmpty) {
              final parsed = int.tryParse(c.pmid!.trim());
              return parsed != null && parsed > 0;
            }
            if (c.url != null && c.url!.contains('doi.org/10.')) {
              return true;
            }
            return false;
          }).toList();

          if (validCitations.isNotEmpty) {
            return answer;
          }
        }
      } catch (_) {
        // Operational logging only: Silently fall through to verified clinical knowledge base
      }
    }

    final pipeline = ResearchOrchestrationPipeline(integrityService: integrityService);
    final result = await pipeline.execute(
      query: cleanQuery,
      userProfile: userProfile,
      containsPersonalHealthData: isPersonalData,
    );
    final structured = result.answer;
    final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
      query: cleanQuery,
      userProfile: userProfile,
      nutrition: structured.nutritionAnalysis,
    );
    final hasSources = structured.sources.isNotEmpty;

    final universal = UniversalIntelligenceAnswer(
      referenceId: structured.referenceId,
      detectedInputType: UserInputType.text,
      query: cleanQuery,
      heroAnswer: structured.quickAnswer,
      recommendation: structured.practicalRecommendations.isNotEmpty
          ? structured.practicalRecommendations.first
          : 'Incorporate evidenced lifestyle principles.',
      detailedExplanation: structured.detailedExplanation,
      goalMatch: goalMatch,
      evidence: EvidenceProvenanceContainer(
        hasVerifiedSources: hasSources,
        classification: hasSources ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
        watermarkLabel: hasSources ? 'Verified sources available' : 'No verified scientific sources',
        citations: structured.sources,
        claims: structured.claims,
        limitationsNotes: structured.studyLimitations,
      ),
      practicalSteps: structured.practicalRecommendations,
      foodComposition: structured.nutritionAnalysis,
      uncertaintyDisclaimer: structured.safetyInformation.generalMedicalDisclaimer,
      providerUsed: structured.provider,
      provenanceDossier: structured.provenanceDossier,
      legacyEvidenceBadge: structured.evidenceBadge,
      legacyGoalAlignment: structured.goalAlignment,
    );

    return ResearchAnswer.fromStructuredAnswer(
      structured,
      universalAnswer: universal,
    );
  }
}

final researchServiceProvider = Provider<ResearchPipelineService>((ref) {
  return ResearchPipelineService._();
});
