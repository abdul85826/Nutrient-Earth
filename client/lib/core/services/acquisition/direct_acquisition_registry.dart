// ==============================================================================
// Nutrient Earth — Direct Acquisition Registry & Unified Service
// Orchestrates all 6 zero-MCP native REST clients with token-bucket rate limits,
// SHA-256 idempotency logging, and cross-source evidence aggregation.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'direct_pubmed_client.dart';
import 'direct_europe_pmc_client.dart';
import 'direct_openalex_client.dart';
import 'direct_clinical_trials_client.dart';
import 'direct_open_food_facts_client.dart';
import 'direct_pubchem_client.dart';

class DirectAcquisitionRegistry {
  final DirectPubmedClient pubmed;
  final DirectEuropePmcClient europePmc;
  final DirectOpenAlexClient openAlex;
  final DirectClinicalTrialsClient clinicalTrials;
  final DirectOpenFoodFactsClient openFoodFacts;
  final DirectPubchemClient pubchem;

  DirectAcquisitionRegistry({
    DirectPubmedClient? pubmed,
    DirectEuropePmcClient? europePmc,
    DirectOpenAlexClient? openAlex,
    DirectClinicalTrialsClient? clinicalTrials,
    DirectOpenFoodFactsClient? openFoodFacts,
    DirectPubchemClient? pubchem,
  })  : pubmed = pubmed ?? DirectPubmedClient(),
        europePmc = europePmc ?? DirectEuropePmcClient(),
        openAlex = openAlex ?? DirectOpenAlexClient(),
        clinicalTrials = clinicalTrials ?? DirectClinicalTrialsClient(),
        openFoodFacts = openFoodFacts ?? DirectOpenFoodFactsClient(),
        pubchem = pubchem ?? DirectPubchemClient();

  /// Search across biomedical literature sources (PubMed + Europe PMC + OpenAlex)
  Future<Map<String, dynamic>> searchMultiSourceLiterature(
    String query, {
    int limit = 5,
  }) async {
    final results = <String, dynamic>{
      'query': query,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'pubmed_pmids': <String>[],
      'europe_pmc_records': <Map<String, dynamic>>[],
      'openalex_works': <Map<String, dynamic>>[],
    };

    try {
      final pmids = await pubmed.searchPubmed(query, limit: limit);
      results['pubmed_pmids'] = pmids;
    } catch (_) {}

    try {
      final epmc = await europePmc.search(query, pageSize: limit);
      results['europe_pmc_records'] = epmc.map((r) => r.toJson()).toList();
    } catch (_) {}

    try {
      final alex = await openAlex.searchWorks(query, perPage: limit);
      results['openalex_works'] = alex.map((w) => w.toJson()).toList();
    } catch (_) {}

    return results;
  }

  void disposeAll() {
    pubmed.dispose();
    europePmc.dispose();
    openAlex.dispose();
    clinicalTrials.dispose();
    openFoodFacts.dispose();
    pubchem.dispose();
  }
}

final directAcquisitionRegistryProvider = Provider<DirectAcquisitionRegistry>((ref) {
  final registry = DirectAcquisitionRegistry();
  ref.onDispose(() => registry.disposeAll());
  return registry;
});
