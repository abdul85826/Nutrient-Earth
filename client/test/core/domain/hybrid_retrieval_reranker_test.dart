// ==============================================================================
// Nutrient Earth — Two-Stage Hybrid Literature Retrieval & Cross-Encoder Test Suite
// Verifies:
// 1. Reciprocal Rank Fusion (RRF) k=60 mathematical rank combination.
// 2. Cross-Encoder stance classification and claim negation detection.
// 3. Evidence tier adjustment when contradictory findings are detected.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/provenance_manifest.dart';
import 'package:nutrient_earth_client/core/domain/evidence/hybrid_retrieval_reranker.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_contract.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_repository.dart';

void main() {
  group('HybridRetrievalReranker — RRF Fusion (Stage 1)', () {
    const reranker = HybridRetrievalReranker();

    const sourceA = ScientificSource(
      title: 'Study A: Systematic Review of Micronutrients',
      authorsOrJournal: 'Lancet',
      year: '2023',
      evidenceGrade: 'Grade A Meta-Analysis',
      studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
      pmid: '10001',
    );

    const sourceB = ScientificSource(
      title: 'Study B: Observational Cohort Analysis',
      authorsOrJournal: 'BMJ',
      year: '2022',
      evidenceGrade: 'Grade B Cohort',
      studyDesign: StudyDesignGrade.cohortStudy,
      pmid: '10002',
    );

    const sourceC = ScientificSource(
      title: 'Study C: In-Vitro Cellular Assay',
      authorsOrJournal: 'FASEB',
      year: '2021',
      evidenceGrade: 'Grade C Preclinical',
      studyDesign: StudyDesignGrade.inVitroPharmacokinetics,
      pmid: '10003',
      isHumanTrial: false,
    );

    test('Computes exact RRF scores combining dense and lexical ranks (k=60)', () {
      final semanticRanked = [sourceA, sourceB];
      final lexicalRanked = [sourceA, sourceC];

      final fused = reranker.reciprocalRankFusion(
        semanticRanked: semanticRanked,
        lexicalRanked: lexicalRanked,
      );

      expect(fused.length, equals(3));
      // Source A is rank 1 in both lists: (1 / 61) + (1 / 61) = 2 / 61 ≈ 0.032786
      expect(fused[0].item.pmid, equals('10001'));
      expect(fused[0].score, closeTo(2.0 / 61.0, 0.0001));

      // Source B is rank 2 in semantic only: (1 / 62) ≈ 0.016129
      final bCandidate = fused.firstWhere((c) => c.item.pmid == '10002');
      expect(bCandidate.score, closeTo(1.0 / 62.0, 0.0001));
    });
  });

  group('HybridRetrievalReranker — Cross-Encoder Stance & Negation (Stage 2)', () {
    const reranker = HybridRetrievalReranker();

    const supportingSource = ScientificSource(
      title: 'Magnesium bisglycinate increases deep sleep efficiency in insomnia',
      authorsOrJournal: 'Sleep Research',
      year: '2023',
      evidenceGrade: 'Double-blind RCT (N=80)',
      studyDesign: StudyDesignGrade.randomizedControlledTrial,
      pmid: '20001',
      isHumanTrial: true,
    );

    const contradictingSource = ScientificSource(
      title: 'High-dose antioxidant supplementation blunts mitochondrial biogenesis',
      authorsOrJournal: 'J Physiol',
      year: '2024',
      evidenceGrade: 'Randomized Controlled Trial (N=30)',
      studyDesign: StudyDesignGrade.randomizedControlledTrial,
      pmid: '20002',
      isHumanTrial: true,
    );

    test('Identifies claim negation and marks stance as contradicted', () {
      final candidates = [
        const ScoredCandidate(item: contradictingSource, score: 0.03),
      ];

      final reranked = reranker.crossEncodeAndRerank(
        query: 'Does antioxidant supplementation improve mitochondrial adaptation?',
        candidates: candidates,
      );

      expect(reranked.first.stance, equals(ClaimSupportStatus.contradicted));
    });

    test('Weights human randomized trials higher than low-powered studies', () {
      final candidates = [
        const ScoredCandidate(item: supportingSource, score: 0.03),
      ];

      final reranked = reranker.crossEncodeAndRerank(
        query: 'magnesium deep sleep efficiency',
        candidates: candidates,
      );

      expect(reranked.first.stance, equals(ClaimSupportStatus.supported));
      expect(reranked.first.score, greaterThan(0.5));
    });
  });

  group('ScientificEvidenceRepository — searchEvidenceWithReranking', () {
    test('Returns reranked sources and maintains strong tier for magnesium sleep inquiry', () {
      final result = ScientificEvidenceRepository.searchEvidenceWithReranking('magnesium sleep');
      expect(result.matchedSources.isNotEmpty, isTrue);
      expect(result.overallEvidenceTier, equals(EvidenceTier.strong));
      expect(result.claims.isNotEmpty, isTrue);
    });

    test('Detects conflicting evidence and updates tier accordingly for high-dose antioxidants', () {
      final result = ScientificEvidenceRepository.searchEvidenceWithReranking('vitamin c antioxidant blunt soreness');
      expect(result.matchedSources.isNotEmpty, isTrue);
      expect(result.overallEvidenceTier, equals(EvidenceTier.conflicting));
      expect(result.contradictoryFinding, isNotNull);
    });
  });
}
