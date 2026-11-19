// ==============================================================================
// Nutrient Earth — Living Food, Nutrition & Scientific Intelligence Widget
// Interactive UI for:
// 1. Food Processing & Nutrient Preservation (spinach, rice, lentils, millets)
// 2. Utensils & Food-Contact Material Safety (cast iron, aluminium, copper, non-stick)
// 3. Food Hazards, Contamination & Cancer Evidence (acrylamide, arsenic, aflatoxins)
// 4. Evidence-Backed Everyday Practices (circadian light, soleus pushups, RS3)
//
// Adheres strictly to Nutrient Earth design:
// Canvas #FAF8F5, Cards #EAF0EC, Text #00251D, Serif headers.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/food_science/food_hazards_cancer_models.dart';
import '../../../../core/domain/food_science/food_processing_models.dart';
import '../../../../core/domain/food_science/utensil_safety_models.dart';
import '../../../../core/domain/habits/evidence_backed_practice_models.dart';
import '../../../../core/services/search/unified_knowledge_search_service.dart';

enum IntelligenceTab {
  foodProcessing,
  utensilSafety,
  foodHazards,
  provenHabits;

  String get label {
    switch (this) {
      case IntelligenceTab.foodProcessing:
        return 'Food Science';
      case IntelligenceTab.utensilSafety:
        return 'Utensils';
      case IntelligenceTab.foodHazards:
        return 'Safety & Cancer';
      case IntelligenceTab.provenHabits:
        return 'Proven Habits';
    }
  }

  IconData get icon {
    switch (this) {
      case IntelligenceTab.foodProcessing:
        return Icons.soup_kitchen_outlined;
      case IntelligenceTab.utensilSafety:
        return Icons.restaurant_outlined;
      case IntelligenceTab.foodHazards:
        return Icons.health_and_safety_outlined;
      case IntelligenceTab.provenHabits:
        return Icons.lightbulb_outline;
    }
  }
}

class UniversalFoodIntelligenceCard extends ConsumerStatefulWidget {
  final String userId;

  const UniversalFoodIntelligenceCard({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UniversalFoodIntelligenceCard> createState() => _UniversalFoodIntelligenceCardState();
}

class _UniversalFoodIntelligenceCardState extends ConsumerState<UniversalFoodIntelligenceCard> {
  IntelligenceTab _activeTab = IntelligenceTab.foodProcessing;
  final TextEditingController _searchController = TextEditingController();
  UnifiedSearchResult? _searchResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _executeSearch('spinach');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final searchService = ref.read(unifiedKnowledgeSearchServiceProvider);
      final result = await searchService.searchAllKnowledge(
        query: query,
        userId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _searchResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectChip(String prompt, IntelligenceTab targetTab) {
    _searchController.text = prompt;
    setState(() => _activeTab = targetTab);
    _executeSearch(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCD7D0)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: const [
              Icon(Icons.biotech, color: Color(0xFF00251D), size: 22),
              SizedBox(width: 8),
              Text(
                'Living Health & Food Intelligence',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00251D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Traceable evidence on preparation, nutrient retention, utensil safety, and proven habits.',
            style: TextStyle(fontSize: 12, color: Color(0xFF4A6B5D)),
          ),
          const SizedBox(height: 14),

          // Interactive Tab Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: IntelligenceTab.values.map((tab) {
                final isSelected = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _activeTab = tab);
                      if (tab == IntelligenceTab.utensilSafety && _searchResult?.utensilProfile == null) {
                        _executeSearch('cast iron');
                      } else if (tab == IntelligenceTab.foodHazards && _searchResult?.foodHazard == null) {
                        _executeSearch('acrylamide');
                      } else if (tab == IntelligenceTab.provenHabits && (_searchResult?.matchedPractices.isEmpty ?? true)) {
                        _executeSearch('sunlight');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00251D) : const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00251D) : const Color(0xFFCCD7D0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 14,
                            color: isSelected ? Colors.white : const Color(0xFF00251D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF00251D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Prompt Suggestion Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('Spinach Oxalates', 'spinach', IntelligenceTab.foodProcessing),
              _buildChip('Resistant Starch Rice', 'rice', IntelligenceTab.foodProcessing),
              _buildChip('Cast Iron Rasam', 'cast iron', IntelligenceTab.utensilSafety),
              _buildChip('Acrylamide Frying', 'acrylamide', IntelligenceTab.foodHazards),
              _buildChip('Soleus Contraction', 'soleus', IntelligenceTab.provenHabits),
            ],
          ),
          const SizedBox(height: 14),

          // Search Input Bar
          TextField(
            controller: _searchController,
            onSubmitted: _executeSearch,
            decoration: InputDecoration(
              hintText: 'Ask about food preparation, utensils, or health claims...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B7E73)),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF00251D)),
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00251D)),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF00251D)),
                      onPressed: () => _executeSearch(_searchController.text),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCCD7D0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCCD7D0)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Tab Content
          if (_searchResult != null) _buildTabContent(_searchResult!),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String query, IntelligenceTab tab) {
    return InkWell(
      onTap: () => _selectChip(query, tab),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD4E2D8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
        ),
      ),
    );
  }

  Widget _buildTabContent(UnifiedSearchResult result) {
    switch (_activeTab) {
      case IntelligenceTab.foodProcessing:
        final guidance = result.foodGuidance;
        if (guidance == null) {
          return _buildEmptyNotice('No ingredient processing profile found for "${result.query}". Try spinach, rice, lentils, or millets.');
        }
        return _buildFoodGuidanceView(guidance);

      case IntelligenceTab.utensilSafety:
        final profile = result.utensilProfile;
        if (profile == null) {
          return _buildEmptyNotice('No cookware profile found for "${result.query}". Try cast iron, raw aluminium, copper, or non-stick.');
        }
        return _buildUtensilView(profile);

      case IntelligenceTab.foodHazards:
        final hazard = result.foodHazard;
        if (hazard == null) {
          return _buildEmptyNotice('No hazard profile found for "${result.query}". Try acrylamide, arsenic, or aflatoxins.');
        }
        return _buildHazardView(hazard);

      case IntelligenceTab.provenHabits:
        if (result.matchedPractices.isEmpty) {
          return _buildEmptyNotice('No evidence-backed practices matched "${result.query}".');
        }
        return _buildHabitsView(result.matchedPractices);
    }
  }

  Widget _buildFoodGuidanceView(FoodProcessingGuidance guidance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCD7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  guidance.ingredientName,
                  style: const TextStyle(fontFamily: 'Serif', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            guidance.scientificRationale,
            style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF2E4035)),
          ),
          const SizedBox(height: 10),
          const Text('Recommended Step-by-Step Protocol:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D))),
          const SizedBox(height: 4),
          ...guidance.stepByStepProcess.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    Expanded(child: Text(step, style: const TextStyle(fontSize: 11.5, height: 1.35, color: Color(0xFF1E2923)))),
                  ],
                ),
              )),
          if (guidance.nutrientTransformations.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Biochemical Nutrient Transformations:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D))),
            const SizedBox(height: 4),
            ...guidance.nutrientTransformations.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.nutrientName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D))),
                            Text(t.scientificMechanism, style: const TextStyle(fontSize: 10, color: Color(0xFF4A6B5D))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4E2D8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.antinutrientReductionPercent > 0
                              ? '-${t.antinutrientReductionPercent.toInt()}% antinutrient'
                              : '${t.averageRetention.toInt()}% retention',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildUtensilView(UtensilSafetyProfile profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCD7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF00251D)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  profile.material.displayName,
                  style: const TextStyle(fontFamily: 'Serif', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E2D8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Max ${profile.maxSafeTemperatureC.toInt()}°C',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.acidicCompatibility.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: profile.acidicCompatibility == AcidicCompatibility.contraindicatedLeaching
                  ? const Color(0xFF9B1C1C)
                  : const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 6),
          Text(profile.clinicalHealthImplications, style: const TextStyle(fontSize: 11.5, height: 1.35, color: Color(0xFF2E4035))),
          const SizedBox(height: 10),
          const Text('Mistakes to Avoid:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9B1C1C))),
          const SizedBox(height: 4),
          ...profile.dangerousMistakesToAvoid.map((m) => Text('• $m', style: const TextStyle(fontSize: 11, color: Color(0xFF9B1C1C)))),
        ],
      ),
    );
  }

  Widget _buildHazardView(FoodSafetyHazardRecord hazard) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCD7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hazard.hazardName, style: const TextStyle(fontFamily: 'Serif', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00251D))),
          if (hazard.iarcClassification != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(4)),
              child: Text(hazard.iarcClassification!.label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF9B1C1C))),
            ),
          ],
          const SizedBox(height: 8),
          Text(hazard.humanEpidemiologySummary, style: const TextStyle(fontSize: 11.5, height: 1.35, color: Color(0xFF2E4035))),
          const SizedBox(height: 8),
          Text(hazard.absoluteVsRelativeRiskExplanation, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF4A6B5D))),
          const SizedBox(height: 10),
          const Text('Evidence-Based Kitchen Mitigations:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          const SizedBox(height: 4),
          ...hazard.practicalMitigationProtocols.map((p) => Text('• $p', style: const TextStyle(fontSize: 11, color: Color(0xFF1E2923)))),
        ],
      ),
    );
  }

  Widget _buildHabitsView(List<EvidenceBackedPractice> practices) {
    return Column(
      children: practices.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCCD7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(p.title, style: const TextStyle(fontFamily: 'Serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00251D)))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFD4E2D8), borderRadius: BorderRadius.circular(4)),
                    child: Text(p.costLevel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00251D))),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(p.targetBenefit, style: const TextStyle(fontSize: 11.5, height: 1.35, color: Color(0xFF2E4035))),
              const SizedBox(height: 6),
              ...p.practicalSteps.map((s) => Text('• $s', style: const TextStyle(fontSize: 11, color: Color(0xFF1E2923)))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyNotice(String message) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E73), fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
