// ==============================================================================
// Nutrient Earth — Unified Knowledge Search Service
// Single search interface across all scientific and practical health domains:
// - Scientific research & peer-reviewed literature
// - Daily scientific intelligence
// - Ingredient-by-ingredient food processing & nutrient retention
// - Cookware & food-contact material safety
// - Food hazards & cancer-risk evidence
// - Evidence-backed everyday life hacks
// - Personal bitemporal memory context
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../food_science/food_hazards_and_cancer_service.dart';
import '../food_science/food_processing_engine.dart';
import '../food_science/utensil_safety_service.dart';
import '../habits/practical_habits_service.dart';
import '../memory/bitemporal_memory_service.dart';
import '../research/daily_research_service.dart';
import '../research/universal_research_engine.dart';
import '../../domain/food_science/food_hazards_cancer_models.dart';
import '../../domain/food_science/food_processing_models.dart';
import '../../domain/food_science/utensil_safety_models.dart';
import '../../domain/habits/evidence_backed_practice_models.dart';
import '../../domain/memory/bitemporal_memory_models.dart';
import '../../domain/research/universal_research_models.dart';

class UnifiedSearchResult {
  final String query;
  final List<CrawledDocument> scientificPapers;
  final FoodProcessingGuidance? foodGuidance;
  final UtensilSafetyProfile? utensilProfile;
  final FoodSafetyHazardRecord? foodHazard;
  final List<EvidenceBackedPractice> matchedPractices;
  final List<BitemporalPersonalFact> personalFacts;

  const UnifiedSearchResult({
    required this.query,
    this.scientificPapers = const [],
    this.foodGuidance,
    this.utensilProfile,
    this.foodHazard,
    this.matchedPractices = const [],
    this.personalFacts = const [],
  });

  bool get hasResults =>
      scientificPapers.isNotEmpty ||
      foodGuidance != null ||
      utensilProfile != null ||
      foodHazard != null ||
      matchedPractices.isNotEmpty ||
      personalFacts.isNotEmpty;
}

abstract class UnifiedKnowledgeSearchService {
  Future<UnifiedSearchResult> searchAllKnowledge({
    required String query,
    String? userId,
  });
}

class DefaultUnifiedKnowledgeSearchService implements UnifiedKnowledgeSearchService {
  final UniversalResearchEngine _researchEngine;
  final FoodProcessingEngine _foodEngine;
  final UtensilSafetyService _utensilService;
  final FoodHazardsAndCancerService _hazardsService;
  final PracticalHabitsService _habitsService;
  final BitemporalMemoryService _memoryService;
  final DailyResearchService _dailyResearchService;

  DefaultUnifiedKnowledgeSearchService({
    required UniversalResearchEngine researchEngine,
    required FoodProcessingEngine foodEngine,
    required UtensilSafetyService utensilService,
    required FoodHazardsAndCancerService hazardsService,
    required PracticalHabitsService habitsService,
    required BitemporalMemoryService memoryService,
    required DailyResearchService dailyResearchService,
  })  : _researchEngine = researchEngine,
        _foodEngine = foodEngine,
        _utensilService = utensilService,
        _hazardsService = hazardsService,
        _habitsService = habitsService,
        _memoryService = memoryService,
        _dailyResearchService = dailyResearchService;

  @override
  Future<UnifiedSearchResult> searchAllKnowledge({
    required String query,
    String? userId,
  }) async {
    final cleanQ = query.trim().toLowerCase();

    // 1. Scientific Research Search
    final scientificPapers = await _researchEngine.searchAuthoritativeSources(
      query: cleanQ,
      maxResults: 5,
    );

    // 2. Food Processing Guidance
    FoodProcessingGuidance? foodGuidance;
    if (_isFoodRelated(cleanQ)) {
      foodGuidance = _foodEngine.getProcessingGuidance(ingredientQuery: cleanQ);
    }

    // 3. Utensil Material Safety
    UtensilSafetyProfile? utensilProfile;
    final matchedUtensil = _detectUtensilMaterial(cleanQ);
    if (matchedUtensil != null) {
      utensilProfile = _utensilService.getProfileForMaterial(matchedUtensil);
    }

    // 4. Food Hazards & Cancer Risk
    FoodSafetyHazardRecord? foodHazard;
    if (_isHazardRelated(cleanQ)) {
      foodHazard = _hazardsService.getHazardRecord(cleanQ);
    }

    // 5. Evidence-Backed Practices
    final matchedPractices = _habitsService.searchPractices(cleanQ);

    // 6. Personal Bitemporal Memory (if userId provided)
    List<BitemporalPersonalFact> personalFacts = [];
    if (userId != null && userId.isNotEmpty) {
      final allFacts = await _memoryService.getCurrentActiveFacts(userId: userId);
      personalFacts = allFacts.where((f) {
        final titleMatch = f.title.toLowerCase().contains(cleanQ);
        final keyMatch = f.factKey.toLowerCase().contains(cleanQ);
        return titleMatch || keyMatch;
      }).toList();
    }

    return UnifiedSearchResult(
      query: query,
      scientificPapers: scientificPapers,
      foodGuidance: foodGuidance,
      utensilProfile: utensilProfile,
      foodHazard: foodHazard,
      matchedPractices: matchedPractices,
      personalFacts: personalFacts,
    );
  }

  bool _isFoodRelated(String q) {
    return q.contains('cook') ||
        q.contains('prepare') ||
        q.contains('spinach') ||
        q.contains('palak') ||
        q.contains('rice') ||
        q.contains('dal') ||
        q.contains('lentil') ||
        q.contains('millet') ||
        q.contains('boil') ||
        q.contains('steam') ||
        q.contains('sprout') ||
        q.contains('soak') ||
        q.contains('nutrient') ||
        q.contains('resistant starch');
  }

  bool _isHazardRelated(String q) {
    return q.contains('acrylamide') ||
        q.contains('cancer') ||
        q.contains('hazard') ||
        q.contains('arsenic') ||
        q.contains('aflatoxin') ||
        q.contains('lead') ||
        q.contains('pesticide') ||
        q.contains('hca') ||
        q.contains('pah') ||
        q.contains('toxic');
  }

  UtensilMaterialType? _detectUtensilMaterial(String q) {
    if (q.contains('cast iron')) return UtensilMaterialType.castIronSeasoned;
    if (q.contains('aluminium') || q.contains('aluminum')) {
      return q.contains('anodized') ? UtensilMaterialType.anodizedAluminium : UtensilMaterialType.rawAluminium;
    }
    if (q.contains('copper')) {
      return q.contains('tin') || q.contains('kalai')
          ? UtensilMaterialType.copperTinLined
          : UtensilMaterialType.copperUnlined;
    }
    if (q.contains('stainless steel')) return UtensilMaterialType.stainlessSteel;
    if (q.contains('non stick') || q.contains('teflon') || q.contains('ptfe')) return UtensilMaterialType.nonStickPtfe;
    if (q.contains('clay') || q.contains('terracotta') || q.contains('handi')) return UtensilMaterialType.clayEarthenware;
    if (q.contains('brass') || q.contains('pithal')) return UtensilMaterialType.brass;
    return null;
  }
}

final unifiedKnowledgeSearchServiceProvider = Provider<UnifiedKnowledgeSearchService>((ref) {
  return DefaultUnifiedKnowledgeSearchService(
    researchEngine: ref.watch(universalResearchEngineProvider),
    foodEngine: ref.watch(foodProcessingEngineProvider),
    utensilService: ref.watch(utensilSafetyServiceProvider),
    hazardsService: ref.watch(foodHazardsAndCancerServiceProvider),
    habitsService: ref.watch(practicalHabitsServiceProvider),
    memoryService: ref.watch(bitemporalMemoryServiceProvider),
    dailyResearchService: ref.watch(dailyResearchServiceProvider),
  );
});
