// ==============================================================================
// Nutrient Earth — Multimodal Personal Intelligence & Evidence Engine Tests
// Comprehensive verification of Milestones B, C, D, E, F:
// - Milestone B: Image Quality Assessment, OCR suitability, & Barcode resolution
// - Milestone C: Video Upload ingestion & multilingual transcription routing
// - Milestone D: Social platform retrieval & honest platform boundary enforcement
// - Milestone E & F: Evidence provenance & deterministic Goal Match calculation
// ==============================================================================

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/input_classification_gateway.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_match_calculation_service.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/multimodal/image_quality_service.dart';
import 'package:nutrient_earth_client/core/services/multimodal/product_candidate_service.dart';
import 'package:nutrient_earth_client/core/services/multimodal/social_platform_retrieval_service.dart';
import 'package:nutrient_earth_client/core/services/multimodal/video_upload_ingestion_service.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  group('Milestone B: Image Quality Assessment & Diagnostic Feedback', () {
    test('identifies sharp, well-lit image payload as suitable for label task', () {
      final sharpBytes = Uint8List(256);
      for (int i = 0; i < sharpBytes.length; i++) {
        sharpBytes[i] = (i % 2 == 0) ? 50 : 200;
      }

      final assessment = ImageQualityService.assessImageQuality(sharpBytes);

      expect(assessment.blurScore, lessThan(0.60));
      expect(assessment.textLegible, isTrue);
      expect(assessment.isSuitableForTask, isTrue);
      expect(assessment.diagnosticNotes, contains('suitable for food identification'));
    });

    test('flags blurry or uniform image payload with explicit uncertainty feedback', () {
      final blurryBytes = Uint8List(256);
      for (int i = 0; i < blurryBytes.length; i++) {
        blurryBytes[i] = 128;
      }

      final assessment = ImageQualityService.assessImageQuality(blurryBytes);

      expect(assessment.blurScore, greaterThanOrEqualTo(0.70));
      expect(assessment.textLegible, isFalse);
      expect(assessment.isSuitableForTask, isFalse);
      expect(assessment.diagnosticNotes, isNotEmpty);
    });

    test('handles empty or truncated image bytes gracefully without throwing exceptions', () {
      final emptyAssessment = ImageQualityService.assessImageQuality(Uint8List(0));
      expect(emptyAssessment.isSuitableForTask, isFalse);
      expect(emptyAssessment.blurScore, equals(1.0));

      final shortAssessment = ImageQualityService.assessImageQuality(Uint8List(10));
      expect(shortAssessment.isSuitableForTask, isFalse);
    });
  });

  group('Milestone B: Barcode Checksum Validation & Product Resolution', () {
    test('validates valid UPC-A modulo 10 checksum', () {
      expect(ProductCandidateService.validateBarcodeChecksum('012345678905'), isTrue);
      expect(ProductCandidateService.validateBarcodeChecksum('012345678904'), isFalse);
    });

    test('validates valid EAN-13 modulo 10 checksum', () {
      // 0793573188540 and 4006381333931: valid EAN-13
      expect(ProductCandidateService.validateBarcodeChecksum('0793573188540'), isTrue);
      expect(ProductCandidateService.validateBarcodeChecksum('4006381333931'), isTrue);
      // Mutate check digit
      expect(ProductCandidateService.validateBarcodeChecksum('4006381333932'), isFalse);
    });

    test('resolves catalogued barcode with nutritional transparency', () {
      final product = ProductCandidateService.resolveBarcode('012345678905');
      expect(product.isCandidateUncertain, isFalse);
      expect(product.productName, contains('Hydration Electrolyte'));
      expect(product.nutrition.caloriesKcal, equals(10));
      expect(product.ingredients, contains('Sodium citrate'));
    });

    test('flags uncatalogued barcode with explicit uncertainty rather than fake data', () {
      final product = ProductCandidateService.resolveBarcode('999999999999');
      expect(product.isCandidateUncertain, isTrue);
      expect(product.ingredients, isEmpty);
      expect(product.confidenceScore, lessThan(0.50));
    });
  });

  group('Milestone C: Video Upload Ingestion & Timestamped Claims', () {
    test('validates MP4 video payload by magic bytes', () {
      final mp4Bytes = Uint8List(32);
      mp4Bytes[4] = 0x66;
      mp4Bytes[5] = 0x74;
      mp4Bytes[6] = 0x79;
      mp4Bytes[7] = 0x70;

      final validation = VideoUploadIngestionService.validateVideoPayload(mp4Bytes);
      expect(validation.isValid, isTrue);
      expect(validation.containerFormat, equals('mp4'));
    });

    test('rejects oversized video payloads exceeding 100 MB', () {
      final oversizedBytes = Uint8List(105 * 1024 * 1024);
      final validation = VideoUploadIngestionService.validateVideoPayload(oversizedBytes);
      expect(validation.isValid, isFalse);
      expect(validation.errorMessage, contains('exceeds maximum permitted size'));
    });

    test('extracts timestamped claims and separates creator statements from evidence', () {
      const transcript = 'Drinking apple cider vinegar before meals melts belly fat instantly in 5 days.';
      final artifact = VideoUploadIngestionService.processVideoTranscription(
        rawTranscript: transcript,
        languageCode: 'en',
        videoDurationSeconds: 45,
      );

      expect(artifact.claims.isNotEmpty, isTrue);
      final claim = artifact.claims.first;
      expect(claim.scientificStatus, equals('contradicted'));
      expect(claim.scientificFinding, contains('modest postprandial glycemic blunting'));
    });
  });

  group('Milestone D: Social Platform Retrieval & Permission Boundaries', () {
    test('extracts YouTube video ID from standard watch and shorts URLs', () {
      final standard = SocialPlatformRetrievalService.inspectUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(standard.platform, equals(SocialPlatformType.youTube));
      expect(standard.videoOrContentId, equals('dQw4w9WgXcQ'));
      expect(standard.isAccessible, isTrue);

      final shorts = SocialPlatformRetrievalService.inspectUrl('https://youtube.com/shorts/abc123xyz');
      expect(shorts.platform, equals(SocialPlatformType.youTube));
      expect(shorts.videoOrContentId, equals('abc123xyz'));
      expect(shorts.isAccessible, isTrue);
    });

    test('enforces honest permission boundary for Instagram Reels with direct upload fallback', () {
      final insta = SocialPlatformRetrievalService.inspectUrl('https://www.instagram.com/reel/C-xyz123abc/');
      expect(insta.platform, equals(SocialPlatformType.instagram));
      expect(insta.isAccessible, isFalse);
      expect(insta.requiresDirectUploadFallback, isTrue);
      expect(insta.limitationMessage, contains('Instagram Reels and Posts require user authentication'));
      expect(insta.limitationMessage, contains('please record or download the video'));
    });

    test('identifies PubMed scientific repository URLs', () {
      final pubmed = SocialPlatformRetrievalService.inspectUrl('https://pubmed.ncbi.nlm.nih.gov/11794633/');
      expect(pubmed.platform, equals(SocialPlatformType.scientificRepository));
      expect(pubmed.videoOrContentId, equals('11794633'));
      expect(pubmed.isAccessible, isTrue);
    });
  });

  group('Milestone E & F: Goal Match Calculation & Evidence Separation', () {
    const testProfile = UserProfileContext(
      userId: 'test-user-1',
      displayName: 'Alex Rivers',
      age: 32,
      biologicalSex: 'female',
      primaryGoals: ['Sleep Quality & Circadian Rhythm', 'Athletic Recovery'],
      activityLevel: 'active',
      dietaryPreference: 'vegan',
      budgetConstraint: 'moderate',
      willingnessToChange: 'high',
      allergies: ['shellfish', 'peanuts'],
      activeSupplements: ['Vitamin D3'],
      knownConditions: [],
    );

    test('calculates high goal match for synergistic vegan sleep nutrients', () {
      final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
        query: 'Magnesium bisglycinate chelate for deep sleep',
        userProfile: testProfile,
        productDietaryAttributes: const ['vegan', 'gluten-free'],
      );

      expect(goalMatch.hasSufficientContext, isTrue);
      expect(goalMatch.matchPercentage, isNotNull);
      expect(goalMatch.matchPercentage!, greaterThanOrEqualTo(80));
      expect(goalMatch.status, equals(GoalAlignmentStatus.aligned));
      expect(goalMatch.positiveFactors.any((f) => f.contains('sleep')), isTrue);
    });

    test('penalizes strict dietary conflicts (e.g. animal collagen for vegan user)', () {
      final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
        query: 'Bovine bone broth collagen peptides',
        userProfile: testProfile,
      );

      expect(goalMatch.status, equals(GoalAlignmentStatus.misaligned));
      expect(goalMatch.matchPercentage!, lessThan(30));
      expect(goalMatch.riskFactors.any((r) => r.contains('vegan')), isTrue);
    });

    test('returns null percentage when user profile lacks declared goals', () {
      const emptyProfile = UserProfileContext(
        userId: 'test-user-2',
        displayName: 'Guest',
        age: 25,
        biologicalSex: 'male',
        primaryGoals: [],
        activityLevel: 'sedentary',
        dietaryPreference: 'none',
        budgetConstraint: 'low',
        willingnessToChange: 'medium',
        allergies: [],
        activeSupplements: [],
        knownConditions: [],
      );

      final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
        query: 'Creatine monohydrate',
        userProfile: emptyProfile,
      );

      expect(goalMatch.hasSufficientContext, isFalse);
      expect(goalMatch.matchPercentage, isNull);
      expect(goalMatch.status, equals(GoalAlignmentStatus.insufficientInformation));
      expect(goalMatch.missingContextNotes, isNotNull);
    });

    test('preserves strict separation: goal match score does not alter evidence classification', () {
      final goalMatch = GoalMatchCalculationService.calculateGoalMatch(
        query: 'Exotic herbal relaxation tea for sleep',
        userProfile: testProfile,
      );

      expect(goalMatch.status, equals(GoalAlignmentStatus.aligned));
      expect(goalMatch.matchPercentage!, greaterThanOrEqualTo(75));

      final answer = UniversalIntelligenceAnswer(
        referenceId: 'REF-SEP-01',
        detectedInputType: UserInputType.text,
        query: 'Exotic herbal relaxation tea for sleep',
        heroAnswer: 'While anecdotal sleep improvements are reported, clinical human trials are currently lacking.',
        recommendation: 'Use established botanicals like chamomile or magnesium instead.',
        detailedExplanation: 'Limited pharmacological data exists for this specific herbal blend.',
        goalMatch: goalMatch,
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'No verified scientific sources',
          citations: [],
        ),
        uncertaintyDisclaimer: 'Educational synthesis only.',
        generatedAt: DateTime.now(),
      );

      expect(answer.goalMatch.matchPercentage, greaterThanOrEqualTo(75));
      expect(answer.showEvidenceWatermark, isFalse);
      expect(answer.evidence.classification, equals(EvidenceClassification.notVerified));
    });
  });

  group('Milestone G: ResearchPipelineService.processUniversalInquiry', () {
    test('end-to-end barcode inquiry produces verified answer contract', () async {
      final descriptor = InputClassificationGateway.classifyRawInput(
        rawInput: '012345678905',
        sourceType: InputSourceType.barcodeScanner,
      );

      final answer = await ResearchPipelineService.processUniversalInquiry(
        descriptor: descriptor,
      );

      expect(answer.detectedInputType, equals(UserInputType.barcode));
      expect(answer.heroAnswer, contains('Hydration Electrolyte Replenisher'));
      expect(answer.foodComposition, isNotNull);
      expect(answer.foodComposition!.caloriesKcal, equals(10));
      expect(answer.showEvidenceWatermark, isTrue);
    });

    test('end-to-end Instagram URL produces honest platform restriction without failing', () async {
      final descriptor = InputClassificationGateway.classifyRawInput(
        rawInput: 'https://www.instagram.com/reel/DE-test1234/',
        sourceType: InputSourceType.clipboardUrl,
      );

      final answer = await ResearchPipelineService.processUniversalInquiry(
        descriptor: descriptor,
      );

      expect(answer.detectedInputType, equals(UserInputType.socialVideoUrl));
      expect(answer.heroAnswer, contains('Platform restriction'));
      expect(answer.recommendation, contains('Upload the video file'));
      expect(answer.showEvidenceWatermark, isFalse);
    });
  });
}
