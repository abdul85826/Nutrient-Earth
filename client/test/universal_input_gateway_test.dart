import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_contract.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/input_classification_gateway.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  group('Milestone A: InputClassificationGateway — Text & Barcodes', () {
    const gateway = InputClassificationGateway();

    test('classifies English, Hindi, and Tamil queries as UserInputType.text', () {
      final queries = [
        'How does magnesium glycinate support deep sleep?',
        'क्या हल्दी और काली मिर्च से जोड़ों के दर्द में राहत मिलती है?',
        'வைட்டமின் டி குறைபாடு அறிகுறிகள் என்ன?',
      ];

      for (final q in queries) {
        final result = gateway.processTextOrUrl(q);
        expect(result.isSuccess, isTrue);
        expect(result.validatedDescriptor!.type, equals(UserInputType.text));
        expect(result.validatedDescriptor!.rawContent, equals(q));
      }
    });

    test('identifies UPC-A and EAN-13 barcodes accurately', () {
      final upc = gateway.processTextOrUrl('012345678905'); // 12 digits
      expect(upc.isSuccess, isTrue);
      expect(upc.validatedDescriptor!.type, equals(UserInputType.barcode));
      expect(upc.validatedDescriptor!.barcodeValue, equals('012345678905'));

      final ean = gateway.processTextOrUrl('8901030383792'); // 13 digits
      expect(ean.isSuccess, isTrue);
      expect(ean.validatedDescriptor!.type, equals(UserInputType.barcode));
    });

    test('rejects empty input payloads', () {
      final result = gateway.processTextOrUrl('   ');
      expect(result.isSuccess, isFalse);
      expect(result.status, equals(InputValidationStatus.emptyPayload));
    });
  });

  group('Milestone A: InputClassificationGateway — URLs & SSRF Protection', () {
    const gateway = InputClassificationGateway();

    test('identifies YouTube and Instagram links as social video URLs', () {
      final yt = gateway.processTextOrUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(yt.isSuccess, isTrue);
      expect(yt.validatedDescriptor!.type, equals(UserInputType.socialVideoUrl));
      expect(yt.validatedDescriptor!.socialPlatform, equals('youtube'));

      final ig = gateway.processTextOrUrl('https://www.instagram.com/reel/Cz12345/');
      expect(ig.isSuccess, isTrue);
      expect(ig.validatedDescriptor!.type, equals(UserInputType.socialVideoUrl));
      expect(ig.validatedDescriptor!.socialPlatform, equals('instagram'));
    });

    test('identifies PubMed publication link as web URL', () {
      final pubmed = gateway.processTextOrUrl('https://pubmed.ncbi.nlm.nih.gov/11794633/');
      expect(pubmed.isSuccess, isTrue);
      expect(pubmed.validatedDescriptor!.type, equals(UserInputType.webUrl));
      expect(pubmed.validatedDescriptor!.socialPlatform, isNull);
    });

    test('strictly rejects unencrypted non-HTTPS URLs', () {
      final insecure = gateway.processTextOrUrl('http://pubmed.ncbi.nlm.nih.gov/11794633/');
      expect(insecure.isSuccess, isFalse);
      expect(insecure.status, equals(InputValidationStatus.invalidUrlScheme));
      expect(insecure.errorMessage, contains('Only encrypted HTTPS URLs are permitted'));
    });

    test('strictly blocks loopback, private RFC 1918, and cloud metadata SSRF vectors', () {
      final ssrfTargets = [
        'https://localhost:8080/admin',
        'https://127.0.0.1/etc/passwd',
        'https://10.0.0.1/internal-dashboard',
        'https://192.168.1.1/router-settings',
        'https://172.16.5.10/database-dump',
        'https://169.254.169.254/latest/meta-data/', // AWS/GCP metadata instance identity
        'https://company.internal/secret',
      ];

      for (final url in ssrfTargets) {
        final result = gateway.processTextOrUrl(url);
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(InputValidationStatus.ssrfBlocked));
      }
    });
  });

  group('Milestone A: InputClassificationGateway — Magic Bytes & File Uploads', () {
    const gateway = InputClassificationGateway();

    test('validates JPEG image upload by magic bytes (0xFF, 0xD8, 0xFF)', () {
      final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46]);
      final result = gateway.processFile(
        filePath: 'supplement_label.jpg',
        fileBytes: jpegBytes,
        userPrompt: 'Check ingredients on this bottle',
      );

      expect(result.isSuccess, isTrue);
      expect(result.validatedDescriptor!.type, equals(UserInputType.image));
      expect(result.validatedDescriptor!.mimeType, equals('image/jpeg'));
    });

    test('validates PDF document upload by magic bytes (%PDF-)', () {
      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x35]);
      final result = gateway.processFile(
        filePath: 'clinical_trial_review.pdf',
        fileBytes: pdfBytes,
        userPrompt: 'Extract findings from clinical paper',
      );

      expect(result.isSuccess, isTrue);
      expect(result.validatedDescriptor!.type, equals(UserInputType.documentPdf));
      expect(result.validatedDescriptor!.mimeType, equals('application/pdf'));
    });

    test('validates MP4 video upload by magic bytes container (ftyp)', () {
      final mp4Bytes = Uint8List.fromList([
        0x00, 0x00, 0x00, 0x20, // size
        0x66, 0x74, 0x79, 0x70, // 'ftyp'
        0x69, 0x73, 0x6F, 0x6D, // 'isom'
      ]);
      final result = gateway.processFile(
        filePath: 'reel_video.mp4',
        fileBytes: mp4Bytes,
        userPrompt: 'Verify claims in this nutrition video',
      );

      expect(result.isSuccess, isTrue);
      expect(result.validatedDescriptor!.type, equals(UserInputType.videoUpload));
      expect(result.validatedDescriptor!.mimeType, equals('video/mp4'));
    });

    test('rejects empty 0-byte file uploads', () {
      final emptyBytes = Uint8List(0);
      final result = gateway.processFile(
        filePath: 'empty.jpg',
        fileBytes: emptyBytes,
      );

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(InputValidationStatus.emptyPayload));
    });
  });

  group('Milestone A: Universal Intelligence Answer Contract (Schema v2026.2)', () {
    test('enforces presentation hierarchy and rules', () {
      final answer = UniversalIntelligenceAnswer(
        referenceId: 'REF-2026-TEST',
        detectedInputType: UserInputType.image,
        query: 'Is this electrolyte powder suitable for my endurance goals?',
        heroAnswer: 'This electrolyte blend suits your hydration and endurance needs with 500mg sodium and 200mg potassium per serving.',
        recommendation: 'Take 1 scoop diluted in 500mL water 30 minutes before prolonged cardiovascular training.',
        detailedExplanation: 'Sodium and potassium replacement prevents hypokalemia and maintains cardiac conduction during vigorous aerobic sweat deficits.',
        goalMatch: const GoalMatchIndicator(
          matchPercentage: 84,
          status: GoalAlignmentStatus.aligned,
          matchLabel: '84% Goal match',
          rationale: 'Aligned with declared endurance goal and moderate sodium replenishment.',
          positiveFactors: ['500mg bioavailable sodium citrate', 'Zero artificial sweeteners'],
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Verified sources available',
          citations: [
            ScientificSource(
              title: 'Electrolyte replacement in prolonged endurance exercise',
              authorsOrJournal: 'Sports Medicine Journal',
              year: '2023',
              evidenceGrade: 'Systematic Review (N=120)',
              pmid: '31284920',
              url: 'https://pubmed.ncbi.nlm.nih.gov/31284920/',
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: [
          'Hydrate with 500mL 30-min prior to run',
          'Avoid taking concurrently with high-dose calcium to prevent mineral absorption interference',
        ],
        uncertaintyDisclaimer: 'Nutrient Earth provides nutritional research syntheses; consult a sports dietitian for medical endurance regimens.',
        generatedAt: DateTime.now(),
      );

      // Rule 1: The answer is the hero
      expect(answer.heroAnswer, contains('500mg sodium'));

      // Rule 2: Goal-match indicator is secondary element with distinct percentage
      expect(answer.goalMatch.matchPercentage, equals(84));
      expect(answer.goalMatch.matchLabel, equals('84% Goal match'));

      // Rule 3 & 4: Evidence symbol appears ONLY when verified sources exist
      expect(answer.showEvidenceWatermark, isTrue);
      expect(answer.evidence.citations.length, equals(1));
      expect(answer.evidence.citations.first.pmid, equals('31284920'));

      // Serialization round-trip
      final json = answer.toJson();
      final roundTrip = UniversalIntelligenceAnswer.fromJson(json);
      expect(roundTrip.heroAnswer, equals(answer.heroAnswer));
      expect(roundTrip.goalMatch.matchPercentage, equals(84));
      expect(roundTrip.evidence.hasVerifiedSources, isTrue);
    });

    test('hides evidence symbol when no verified sources exist', () {
      final answerWithoutSources = UniversalIntelligenceAnswer(
        referenceId: 'REF-UNVERIFIED',
        detectedInputType: UserInputType.socialVideoUrl,
        query: 'Does this exotic seed stop baldness?',
        heroAnswer: 'There is no indexed clinical evidence demonstrating that this seed halts androgenic alopecia.',
        recommendation: 'Consult a dermatologist for evidence-backed treatments (e.g. minoxidil/finasteride).',
        detailedExplanation: 'Social media claims regarding this seed rely on anecdotal testimonials without human trials.',
        goalMatch: const GoalMatchIndicator(
          matchPercentage: null,
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Not enough information to assess',
          rationale: 'User profile lacks alopecia condition history.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'No verified scientific sources',
          citations: [],
        ),
        uncertaintyDisclaimer: 'No peer-reviewed trials exist for this claim.',
      );

      // Rule 4: Zero verified evidence means NO evidence symbol
      expect(answerWithoutSources.showEvidenceWatermark, isFalse);
      expect(answerWithoutSources.evidence.citations, isEmpty);
      expect(answerWithoutSources.goalMatch.hasSufficientContext, isFalse);
    });

    test('converts seamlessly to legacy ResearchAnswer preserving backward compatibility', () {
      final universal = UniversalIntelligenceAnswer(
        referenceId: 'REF-COMPAT-01',
        detectedInputType: UserInputType.text,
        query: 'What is the best form of magnesium?',
        heroAnswer: 'Magnesium glycinate provides superior gastrointestinal tolerability.',
        recommendation: 'Take 200mg 1 hour before sleep.',
        detailedExplanation: 'Glycine chelation facilitates passive mucosal paracellular transport.',
        goalMatch: const GoalMatchIndicator(
          matchPercentage: 90,
          status: GoalAlignmentStatus.aligned,
          matchLabel: '90% Goal match',
          rationale: 'Matches declared sleep quality goal.',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Verified sources available',
          citations: [
            ScientificSource(
              title: 'Magnesium bioavailability study',
              authorsOrJournal: 'Nutr Res',
              year: '2022',
              evidenceGrade: 'RCT',
              pmid: '11794633',
            ),
          ],
        ),
        uncertaintyDisclaimer: 'Educational synthesis only.',
        generatedAt: DateTime.now(),
      );

      final legacy = ResearchAnswer.fromUniversalAnswer(universal);
      expect(legacy.query, equals('What is the best form of magnesium?'));
      expect(legacy.answerSummary, contains('Magnesium glycinate'));
      expect(legacy.evidenceBadge, equals('VERIFIED SOURCES AVAILABLE'));
      expect(legacy.citations.length, equals(1));
      expect(legacy.universalAnswer, isNotNull);
    });
  });
}
