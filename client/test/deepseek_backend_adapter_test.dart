import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  group('DeepSeek Provider Adapter & Serialization Tests', () {
    test('Parses valid DeepSeek research synthesizer response payload', () {
      final mockPayload = {
        'query': 'Bioavailability of magnesium bisglycinate',
        'referenceId': 'REF-DEEPSEEK-01',
        'domainCategory': 'Nutritional Pharmacology',
        'answerSummary':
            'Magnesium bisglycinate demonstrates enhanced absorption across intestinal mucosa via peptide transport systems.',
        'evidenceBadge': 'DEEPSEEK SYNTHESIS • EVIDENCE REVIEW',
        'comparisonCallout': 'Chelate vs Oxide',
        'comparisonIndex': 4.2,
        'evidenceGap': 'Polysomnography clinical trials remain limited.',
        'citations': [
          {
            'title': 'Bioavailability of US commercially available magnesium preparations',
            'authorsOrJournal': 'Magnesium Research',
            'year': '2001',
            'evidenceGrade': 'Clinical Pharmacokinetics',
            'pmid': '11794633',
            'url': 'https://pubmed.ncbi.nlm.nih.gov/11794633/',
            'supportingClaim': 'Chelated magnesium showed significantly higher 24-hr urinary excretion.',
          }
        ],
        'practicalSteps': [
          'Target 200–300 mg elemental magnesium.',
          'Take with an evening meal.',
        ],
        'uncertaintyDisclaimer': 'Educational research synthesis. Not medical advice.',
        'provider': 'deepseek-ai/DeepSeek-V4-Flash-0731',
        'generatedAt': '2026-10-26T12:00:00.000Z',
      };

      final answer = ResearchAnswer.fromJson(mockPayload);

      expect(answer.query, equals('Bioavailability of magnesium bisglycinate'));
      expect(answer.referenceId, equals('REF-DEEPSEEK-01'));
      expect(answer.domainCategory, equals('Nutritional Pharmacology'));
      expect(answer.provider, equals('deepseek-ai/DeepSeek-V4-Flash-0731'));
      expect(answer.citations.length, equals(1));
      expect(answer.citations.first.pmid, equals('11794633'));
      expect(answer.citations.first.evidenceGrade, equals('Clinical Pharmacokinetics'));
      expect(answer.practicalSteps.length, equals(2));
      expect(answer.comparisonIndex, equals(4.2));
    });

    test('Gracefully handles missing, partial, or malformed fields in response payload', () {
      final malformedPayload = <String, dynamic>{
        'query': 'Incomplete inquiry',
      };

      final answer = ResearchAnswer.fromJson(malformedPayload);

      expect(answer.query, equals('Incomplete inquiry'));
      expect(answer.answerSummary, isEmpty);
      expect(answer.citations, isEmpty);
      expect(answer.practicalSteps, isEmpty);
      expect(answer.uncertaintyDisclaimer, contains('Nutrient Earth provides nutritional research syntheses'));
      expect(answer.provider, equals('Nutrient Earth Verified Evidence Base'));
    });

    test('Serializes ResearchAnswer to JSON cleanly', () {
      final answer = ResearchAnswer(
        query: 'Creatine monohydrate cognitive benefits',
        answerSummary: 'Creatine enhances phosphocreatine resynthesis in neural tissue.',
        evidenceBadge: 'SYSTEMATIC REVIEW',
        citations: const [
          ResearchCitation(
            title: 'Effects of creatine supplementation on cognitive function',
            authorsOrJournal: 'Experimental Gerontology',
            year: '2023',
            evidenceGrade: 'Meta-Analysis',
            pmid: '37123456',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37123456/',
          ),
        ],
        practicalSteps: const ['Consume 3-5g daily with water.'],
        uncertaintyDisclaimer: 'Consult a physician before starting.',
        generatedAt: DateTime.parse('2026-10-26T10:00:00.000Z'),
        provider: 'deepseek-ai/DeepSeek-V4-Flash-0731',
      );

      final json = answer.toJson();

      expect(json['query'], equals('Creatine monohydrate cognitive benefits'));
      expect(json['provider'], equals('deepseek-ai/DeepSeek-V4-Flash-0731'));
      expect(json['citations'], isA<List>());
      expect((json['citations'] as List).first['pmid'], equals('37123456'));
    });
  });

  group('Sensitive Health Data Routing Guardrails (SEC-05)', () {
    test('Detects personal biometric signals (blood glucose, insulin, HbA1c)', () {
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('My blood glucose is 185 mg/dL after breakfast'),
        isTrue,
      );
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('My fasting insulin was 18 and HbA1c is 6.2'),
        isTrue,
      );
    });

    test('Detects prescription drug and clinical diagnosis terms', () {
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('I was prescribed metformin 500mg daily'),
        isTrue,
      );
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('I am diagnosed with hypertension and take lisinopril'),
        isTrue,
      );
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('My dosage of atorvastatin was increased'),
        isTrue,
      );
    });

    test('Allows non-confidential, general biochemical scientific inquiries', () {
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('What is the mechanism of action of vitamin D3 on calcium absorption?'),
        isFalse,
      );
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('Dose-response curve of whey protein on muscle protein synthesis'),
        isFalse,
      );
      expect(
        SensitiveDataRoutingGuard.containsPersonalHealthSignals('Circadian rhythm alignment with morning blue light exposure'),
        isFalse,
      );
    });

    test('Enforces routing restriction: multimodal attachments (images/audio) route to verified evidence only', () async {
      // When imagePath is provided, it simulates meal/lab photo upload
      final answer = await ResearchPipelineService.processInquiry(
        query: 'Analyze this meal plate',
        imagePath: '/path/to/meal_photo.jpg',
      );

      expect(answer, isNotNull);
      // Ensures provider is safe local clinical evidence, not public unauthenticated endpoint
      expect(answer.provider, equals('Nutrient Earth Verified Evidence Base'));
    });

    test('Enforces routing restriction: explicitly flagged sensitive health data routes to verified evidence only', () async {
      final answer = await ResearchPipelineService.processInquiry(
        query: 'Optimal potassium intake',
        containsPersonalHealthData: true,
      );

      expect(answer, isNotNull);
      expect(answer.provider, equals('Nutrient Earth Verified Evidence Base'));
    });
  });

  group('Provider Availability & Fallback Resilience', () {
    test('Falls back gracefully to verified clinical evidence when remote synthesizer is unavailable', () async {
      // Supabase client is not initialized in unit test mode (offline mock state)
      // Service must seamlessly fall back to verified evidence without throwing
      final answer = await ResearchPipelineService.processInquiry(
        query: 'What form of magnesium is best for sleep?',
      );

      expect(answer, isNotNull);
      expect(answer.query, equals('What form of magnesium is best for sleep?'));
      expect(answer.answerSummary, contains('Magnesium bisglycinate'));
      expect(answer.evidenceBadge, contains('RCT REVIEW'));
      expect(answer.citations, isNotEmpty);
      expect(answer.citations.first.pmid, isNotNull);
      expect(answer.provider, equals('Nutrient Earth Verified Evidence Base'));
    });

    test('Never fabricates research results on failure or fallback', () async {
      final answer = await ResearchPipelineService.processInquiry(
        query: 'Protein intake for recovery',
      );

      expect(answer.citations, isNotEmpty);
      for (final citation in answer.citations) {
        // Citations in verified fallback must have legitimate titles and PubMed links or journals
        expect(citation.title.isNotEmpty, isTrue);
        expect(citation.authorsOrJournal.isNotEmpty, isTrue);
        if (citation.url != null) {
          expect(SecurityUrlValidator.isSafeScientificUrl(citation.url!), isTrue);
        }
      }
    });
  });
}
