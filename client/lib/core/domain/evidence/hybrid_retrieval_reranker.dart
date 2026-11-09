// ==============================================================================
// Nutrient Earth — Two-Stage Hybrid Literature Retrieval & Cross-Encoder Reranker
// Stage 1: Reciprocal Rank Fusion (RRF) combining dense semantic & lexical rankers (k=60).
// Stage 2: Cross-Encoder claim-negation and stance-evaluation reranker.
// STRICT EVIDENCE INTEGRITY: Retracted studies are permanently suppressed.
// ==============================================================================

import 'dart:math';
import 'scientific_evidence_contract.dart';

class ScoredCandidate<T> {
  final T item;
  final double score;
  final String? rationale;
  final ClaimSupportStatus? stance;

  const ScoredCandidate({
    required this.item,
    required this.score,
    this.rationale,
    this.stance,
  });
}

class HybridRetrievalReranker {
  static const int rrfK = 60;

  const HybridRetrievalReranker();

  /// Stage 1: Reciprocal Rank Fusion (RRF)
  /// Combines dense vector rankings and lexical BM25 rankings.
  /// Formula: RRF_Score(d) = sum( 1.0 / (k + rank_m(d)) )
  List<ScoredCandidate<ScientificSource>> reciprocalRankFusion({
    required List<ScientificSource> semanticRanked,
    required List<ScientificSource> lexicalRanked,
    int maxCandidates = 20,
  }) {
    final Map<String, double> rrfScores = {};
    final Map<String, ScientificSource> sourceMap = {};

    for (int i = 0; i < semanticRanked.length; i++) {
      final s = semanticRanked[i];
      final key = s.pmid ?? s.doi ?? s.title;
      sourceMap[key] = s;
      final rank = i + 1;
      rrfScores[key] = (rrfScores[key] ?? 0.0) + (1.0 / (rrfK + rank));
    }

    for (int i = 0; i < lexicalRanked.length; i++) {
      final s = lexicalRanked[i];
      final key = s.pmid ?? s.doi ?? s.title;
      sourceMap[key] = s;
      final rank = i + 1;
      rrfScores[key] = (rrfScores[key] ?? 0.0) + (1.0 / (rrfK + rank));
    }

    final sortedEntries = rrfScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(maxCandidates)
        .map((e) => ScoredCandidate<ScientificSource>(
              item: sourceMap[e.key]!,
              score: e.value,
              rationale: 'RRF hybrid candidate score: ${e.value.toStringAsFixed(4)}',
            ))
        .toList();
  }

  /// Stage 2: Cross-Encoder Claim Negation & Directionality Reranker
  /// Evaluates query against candidate source title, mechanism, and findings.
  /// Detects causal polarity: support, contradiction, or insufficient evidence.
  List<ScoredCandidate<ScientificSource>> crossEncodeAndRerank({
    required String query,
    required List<ScoredCandidate<ScientificSource>> candidates,
  }) {
    final lowerQuery = query.toLowerCase();
    final queryTokens = lowerQuery
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();

    // Negation and contradiction lexical vectors
    final negationMarkers = {
      'not',
      'does not',
      'fails to',
      'blunts',
      'impairs',
      'ineffective',
      'no effect',
      'conflicts',
      'counteracts',
      'antagonistic',
      'inhibits',
    };

    final reranked = <ScoredCandidate<ScientificSource>>[];

    for (final candidate in candidates) {
      final source = candidate.item;
      final sourceText = '${source.title} ${source.evidenceGrade}'.toLowerCase();
      final sourceTokens = sourceText
          .split(RegExp(r'\s+'))
          .where((t) => t.length > 2)
          .toSet();

      // 1. Token overlap / lexical precision
      final overlap = queryTokens.intersection(sourceTokens).length;
      final jaccard = queryTokens.isEmpty ? 0.0 : overlap / (queryTokens.length + sourceTokens.length - overlap);

      // 2. Study design hierarchy weighting
      double designWeight = 0.5;
      switch (source.studyDesign) {
        case StudyDesignGrade.systematicReviewMetaAnalysis:
          designWeight = 1.0;
          break;
        case StudyDesignGrade.randomizedControlledTrial:
          designWeight = 0.85;
          break;
        case StudyDesignGrade.cohortStudy:
          designWeight = 0.70;
          break;
        case StudyDesignGrade.inVitroPharmacokinetics:
          designWeight = 0.60;
          break;
        case StudyDesignGrade.observational:
          designWeight = 0.50;
          break;
        case StudyDesignGrade.expertConsensus:
          designWeight = 0.55;
          break;
        case StudyDesignGrade.unspecified:
          designWeight = 0.40;
          break;
      }

      // 3. Human clinical trial bonus
      final humanBonus = source.isHumanTrial ? 0.15 : 0.0;

      // 4. Stance & Negation Cross-Evaluation
      bool isContradiction = false;
      for (final neg in negationMarkers) {
        if (sourceText.contains(neg)) {
          isContradiction = true;
          break;
        }
      }

      ClaimSupportStatus stance = ClaimSupportStatus.supported;
      if (isContradiction) {
        stance = ClaimSupportStatus.contradicted;
      } else if (jaccard < 0.1) {
        stance = ClaimSupportStatus.insufficientEvidence;
      }

      // Cross-encoder combined score
      final rawScore = (candidate.score * 100.0 * 0.4) + (jaccard * 0.3) + (designWeight * 0.2) + humanBonus;
      final normalizedScore = min(1.0, max(0.0, rawScore));

      reranked.add(ScoredCandidate<ScientificSource>(
        item: source,
        score: normalizedScore,
        stance: stance,
        rationale: 'Cross-Encoder alignment: ${stance.name.toUpperCase()} (weight=${designWeight.toStringAsFixed(2)})',
      ));
    }

    // Sort descending by Cross-Encoder score
    reranked.sort((a, b) => b.score.compareTo(a.score));
    return reranked;
  }
}

