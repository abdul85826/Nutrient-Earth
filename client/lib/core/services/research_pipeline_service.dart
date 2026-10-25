import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResearchCitation {
  final String title;
  final String authorsOrJournal;
  final String year;
  final String evidenceGrade;
  final String? url;

  const ResearchCitation({
    required this.title,
    required this.authorsOrJournal,
    required this.year,
    required this.evidenceGrade,
    this.url,
  });
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

  const ResearchAnswer({
    required this.query,
    required this.answerSummary,
    required this.evidenceBadge,
    required this.citations,
    required this.practicalSteps,
    required this.uncertaintyDisclaimer,
    this.imageUrl,
    required this.generatedAt,
  });
}

class ResearchPipelineService {
  ResearchPipelineService._();

  static Future<ResearchAnswer> processInquiry({
    required String query,
    String? imagePath,
    String? audioPath,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    // Simulate genuine evidence retrieval and synthesis
    // In production, connects with Gemini / PubMed API
    await Future.delayed(const Duration(milliseconds: 650));

    final lower = cleanQuery.toLowerCase();

    if (lower.contains('magnesium') || lower.contains('sleep')) {
      return ResearchAnswer(
        query: cleanQuery,
        answerSummary:
            'Clinical trials demonstrate that magnesium glycinate significantly outperforms magnesium oxide in bioavailability (approx. 24% vs. 4%) and gastrointestinal tolerance. In double-blind studies, magnesium supplementation improved subjective sleep quality and reduced sleep onset latency in adults with sub-clinical deficiency.',
        evidenceBadge: 'RCT REVIEW • HIGH CONFIDENCE',
        citations: const [
          ResearchCitation(
            title: 'Bioavailability of Magnesium Preparations in Healthy Volunteers',
            authorsOrJournal: 'Journal of Dietary Supplements',
            year: '2023',
            evidenceGrade: 'RCT Meta-analysis',
            url: 'https://pubmed.ncbi.nlm.nih.gov/31144217/',
          ),
          ResearchCitation(
            title: 'Oral Magnesium Supplementation and Primary Insomnia in the Elderly',
            authorsOrJournal: 'Journal of Research in Medical Sciences',
            year: '2022',
            evidenceGrade: 'Double-blind RCT',
            url: 'https://pubmed.ncbi.nlm.nih.gov/23853635/',
          ),
        ],
        practicalSteps: const [
          'Target 200–300 mg elemental magnesium glycinate 60 minutes before bedtime.',
          'Pair with a light carbohydrate or tryptophan-containing snack for optimal absorption.',
          'Monitor digestive comfort over an initial 14-day protocol window.',
        ],
        uncertaintyDisclaimer:
            'Evidence indicates individual metabolic response varies based on baseline serum magnesium, dietary fiber intake, and concurrent medications.',
        generatedAt: DateTime.now(),
      );
    } else if (lower.contains('protein') || lower.contains('recovery') || lower.contains('plate')) {
      return ResearchAnswer(
        query: cleanQuery,
        answerSummary:
            'A balanced plate containing 30–35g of bioavailable protein with complex carbohydrates and dietary fiber optimizes muscle protein synthesis (MPS) and stabilizes postprandial glucose curves over 3–5 hours.',
        evidenceBadge: 'HPLC POTENCY • VERIFIED NUTRITION',
        citations: const [
          ResearchCitation(
            title: 'Dose-dependent response of muscle protein synthesis to dietary protein',
            authorsOrJournal: 'American Journal of Clinical Nutrition',
            year: '2024',
            evidenceGrade: 'Systematic Review',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24299726/',
          ),
        ],
        practicalSteps: const [
          'Distribute protein evenly across 3 meals with a target of 0.4g/kg per meal.',
          'Prioritize leucine-rich sources (eggs, fermented dairy, legumes, fish).',
          'Include 8–10g of soluble fiber to slow gastric emptying.',
        ],
        uncertaintyDisclaimer:
            'Activity level and lean mass determine optimal protein thresholds; consult specialized guidance for renal conditions.',
        generatedAt: DateTime.now(),
      );
    } else {
      return ResearchAnswer(
        query: cleanQuery,
        answerSummary:
            'Evidence-based research indicates that personalized lifestyle interventions combining circadian light exposure, dietary nutrient density, and structured recovery yield measurable improvements across metabolic and cognitive biomarkers.',
        evidenceBadge: 'SYSTEMATIC REVIEW • PEER REVIEWED',
        citations: const [
          ResearchCitation(
            title: 'Translational Nutritional Science and Evidence-Based Interventions',
            authorsOrJournal: 'Nutritional Research Reviews',
            year: '2025',
            evidenceGrade: 'Evidence Synthesis',
            url: 'https://pubmed.ncbi.nlm.nih.gov/',
          ),
        ],
        practicalSteps: const [
          'Establish consistent diurnal timing for meals and hydration.',
          'Incorporate diverse whole-food polyphenols daily.',
          'Review progress after 21 days of continuous habit tracking.',
        ],
        uncertaintyDisclaimer:
            'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace individualized medical diagnoses.',
        generatedAt: DateTime.now(),
      );
    }
  }
}

final researchServiceProvider = Provider<ResearchPipelineService>((ref) {
  return ResearchPipelineService._();
});
