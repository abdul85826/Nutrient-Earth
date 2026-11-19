// ==============================================================================
// Nutrient Earth — Food Safety Hazards & Cancer Evidence Service
// Evidence-backed hazard evaluation:
// - IARC Carcinogen Classifications (Groups 1, 2A, 2B, 3)
// - FSSAI & Codex maximum permissible residue limits
// - Processing contaminants: Acrylamide, Heterocyclic Amines (HCA), PAHs
// - Heavy metals & mycotoxins: Arsenic, Lead, Aflatoxins
// - Absolute vs. Relative Risk: Explains true statistical risk without sensationalism
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/food_science/food_hazards_cancer_models.dart';

abstract class FoodHazardsAndCancerService {
  FoodSafetyHazardRecord? getHazardRecord(String hazardId);

  List<FoodSafetyHazardRecord> getAllKnownHazards();

  Map<String, dynamic> evaluateProcessingRisk({
    required String cookingMethod,
    required String foodCategory,
    double temperatureC = 150.0,
  });
}

class DefaultFoodHazardsAndCancerService implements FoodHazardsAndCancerService {
  static final List<FoodSafetyHazardRecord> _hazards = [
    const FoodSafetyHazardRecord(
      id: 'haz_acrylamide',
      hazardName: 'Acrylamide (Thermal Processing Contaminant)',
      category: HazardCategory.processingContaminant,
      iarcClassification: IarcGroup.group2A,
      fssaiLimit: 'Benchmark level: 500 µg/kg in potato crisps; 750 µg/kg in french fries',
      codexLimit: 'Code of Practice for the Reduction of Acrylamide in Foods (CXC 67-2009)',
      highRiskFoodMatrices: ['Fried potato chips', 'French fries', 'Toasted bread / biscuits', 'Roasted coffee'],
      formationOrContaminationMechanism:
          'Forms via the high-temperature Maillard reaction between the free amino acid asparagine and reducing sugars (glucose, fructose) at cooking temperatures above 120°C in low-moisture environments.',
      humanEpidemiologySummary:
          'Extensive prospective cohort studies in human populations show inconsistent associations between dietary acrylamide and human cancer incidence, contrasting with high-dose animal bioassays. Consequently, IARC maintains Group 2A (Probably Carcinogenic to humans).',
      absoluteVsRelativeRiskExplanation:
          'Consuming golden-brown fried foods occasionally contributes minimal absolute lifetime cancer risk. The primary risk occurs with chronic consumption of heavily charred or burnt starchy foods. Avoiding deep dark browning is an effective, non-fear-driven mitigation.',
      practicalMitigationProtocols: [
        'Soak cut raw potatoes in water for 15-30 minutes before frying to leach surface reducing sugars (reduces acrylamide by 40-50%).',
        'Aim for a golden-yellow hue rather than dark brown or blackened crusts when toasting bread or frying.',
        'Never store raw potatoes in the refrigerator (below 6°C), as cold temperatures trigger "cold-induced sweetening", spiking reducing sugar levels.',
        'Boiling or steaming potatoes produces zero acrylamide because temperatures cannot exceed 100°C in water.',
      ],
    ),
    const FoodSafetyHazardRecord(
      id: 'haz_hca_pah',
      hazardName: 'Heterocyclic Amines (HCAs) & Polycyclic Aromatic Hydrocarbons (PAHs)',
      category: HazardCategory.processingContaminant,
      iarcClassification: IarcGroup.group1, // Benzo[a]pyrene is Group 1; specific HCAs are 2A/2B
      fssaiLimit: 'Benzo[a]pyrene limit: 2.0 µg/kg in oils; 5.0 µg/kg in smoked foods',
      codexLimit: 'Maximum 5.0 µg/kg Benzo[a]pyrene in smoked meats and fish',
      highRiskFoodMatrices: ['Charcoal grilled meats', 'Tandoori meats on open flame', 'Smoked fish', 'Reused fried oils'],
      formationOrContaminationMechanism:
          'HCAs form when amino acids, creatine, and sugars react at high temperatures (>150°C). PAHs form when meat fat drips onto hot coals, generating smoke that deposits pyrolytic hydrocarbons onto the food surface.',
      humanEpidemiologySummary:
          'High intake of well-done, charred, and flame-grilled meats is correlated with elevated relative risks of colorectal, prostate, and pancreatic adenomas in prospective epidemiological cohorts.',
      absoluteVsRelativeRiskExplanation:
          'Eating traditionally grilled food in moderation carries low absolute risk, especially when accompanied by antioxidant-rich vegetables. Simple kitchen preparation modifications block the majority of chemical formation.',
      practicalMitigationProtocols: [
        'Marinate meats with antioxidant-rich herbs (rosemary, turmeric, garlic, lemon juice) for 30 minutes before grilling; polyphenol antioxidants block HCA formation by up to 90%.',
        'Avoid direct contact between meat and open flames; use indirect heat or place foil under meat to prevent fat dripping onto burning coals.',
        'Pre-cook meat briefly (1-2 minutes) in the microwave and discard the expelled fluid (which contains precursor creatine) before quick finishing on the grill.',
        'Trim all visibly charred or blackened portions before eating.',
      ],
    ),
    const FoodSafetyHazardRecord(
      id: 'haz_inorganic_arsenic',
      hazardName: 'Inorganic Arsenic (Heavy Metal Contaminant)',
      category: HazardCategory.heavyMetal,
      iarcClassification: IarcGroup.group1,
      fssaiLimit: '0.2 mg/kg in polished white rice; 0.35 mg/kg in husked brown rice',
      codexLimit: '0.2 mg/kg for polished rice; 0.35 mg/kg for husked rice',
      highRiskFoodMatrices: ['Paddy rice', 'Rice bran products', 'Groundwater in endemic areas (e.g. Bengal Basin)'],
      formationOrContaminationMechanism:
          'Flooded anaerobic paddy cultivation enables plant roots to absorb naturally occurring inorganic arsenite and arsenate from groundwater and mineral soils.',
      humanEpidemiologySummary:
          'Chronic high-level ingestion in drinking water is definitively causal for skin, bladder, and lung cancers. Dietary rice intake in diverse diets carries substantially lower risk, but remains a focus for pediatric populations.',
      absoluteVsRelativeRiskExplanation:
          'Normal consumption of varied grains carries low risk. Rinsing and high-water cooking reduces exposure dramatically.',
      practicalMitigationProtocols: [
        'Rinse rice thoroughly in fresh water 3 to 4 times before cooking.',
        'Use the "excess water boiling" method: Cook rice in 6 parts water to 1 part rice, and discard the cooking water (removes 40-50% of inorganic arsenic).',
        'Diversify staple carbohydrates by rotating rice with millets (ragi, foxtail, bajra), wheat, and tubers, which accumulate far less arsenic.',
      ],
    ),
    const FoodSafetyHazardRecord(
      id: 'haz_aflatoxins',
      hazardName: 'Aflatoxin B1 (Mycotoxin)',
      category: HazardCategory.mycotoxin,
      iarcClassification: IarcGroup.group1,
      fssaiLimit: '15 µg/kg total aflatoxins (B1+B2+G1+G2) in nuts, cereals, and spices',
      codexLimit: '15 µg/kg for peanuts intended for further processing; 10 µg/kg for ready-to-eat',
      highRiskFoodMatrices: ['Peanuts (groundnuts)', 'Maize (corn)', 'Cottonseed', 'Dried red chillies / spices'],
      formationOrContaminationMechanism:
          'Produced by Aspergillus flavus and Aspergillus parasiticus fungi during warm, humid post-harvest storage (temperature >25°C, relative humidity >80%).',
      humanEpidemiologySummary:
          'Potent hepatocarcinogen, acting synergistically with Hepatitis B viral infection to increase hepatocellular carcinoma risk in tropical developing nations.',
      absoluteVsRelativeRiskExplanation:
          'Commercially certified packaged nuts undergo strict optical sorting and aflatoxin testing, making risk very low. The primary risk comes from uninspected, moldy, or visibly spoiled street commodities.',
      practicalMitigationProtocols: [
        'Inspect peanuts and grains: discard any nuts that are discolored, moldy, shriveled, or bitter tasting.',
        'Store grains, pulses, and nuts in airtight dry containers away from humidity and warmth.',
        'Ensure proper dry roasting: thermal roasting reduces aflatoxin concentrations by 30-45%.',
      ],
    ),
  ];

  @override
  FoodSafetyHazardRecord? getHazardRecord(String hazardId) {
    return _hazards.cast<FoodSafetyHazardRecord?>().firstWhere(
          (h) => h != null && (h.id == hazardId || h.hazardName.toLowerCase().contains(hazardId.toLowerCase())),
          orElse: () => null,
        );
  }

  @override
  List<FoodSafetyHazardRecord> getAllKnownHazards() => _hazards;

  @override
  Map<String, dynamic> evaluateProcessingRisk({
    required String cookingMethod,
    required String foodCategory,
    double temperatureC = 150.0,
  }) {
    final method = cookingMethod.toLowerCase();
    final food = foodCategory.toLowerCase();

    final identifiedHazards = <String>[];
    final mitigationChecklist = <String>[];

    // Acrylamide check
    if ((method.contains('fry') || method.contains('roast') || method.contains('bake') || method.contains('toast')) &&
        (food.contains('potato') || food.contains('bread') || food.contains('grain') || food.contains('cereal')) &&
        temperatureC >= 120.0) {
      identifiedHazards.add('Acrylamide Formation (IARC Group 2A: Probably Carcinogenic)');
      mitigationChecklist.add('Soak raw potatoes in water for 15-30 minutes before frying to remove precursor sugars.');
      mitigationChecklist.add('Cook to a golden yellow shade; avoid dark brown or scorched edges.');
    }

    // HCA / PAH check
    if ((method.contains('grill') || method.contains('barbecue') || method.contains('flame') || method.contains('tandoor')) &&
        (food.contains('meat') || food.contains('chicken') || food.contains('fish')) &&
        temperatureC >= 150.0) {
      identifiedHazards.add('Heterocyclic Amines (HCAs) & Polycyclic Aromatic Hydrocarbons (PAHs) (IARC Group 1)');
      mitigationChecklist.add('Marinate with rosemary, turmeric, garlic, and lemon for 30 minutes to reduce HCA by up to 90%.');
      mitigationChecklist.add('Prevent fat dripping onto glowing coals; avoid direct flame contact.');
    }

    return {
      'has_elevated_risk': identifiedHazards.isNotEmpty,
      'identified_hazards': identifiedHazards,
      'mitigation_checklist': mitigationChecklist,
      'safe_alternative_methods': ['Gentle Steaming (100°C)', 'Pressure Cooking with Liquid', 'Slow Simmering'],
      'perspective': 'Cooking hazards represent chronic cumulative exposures, not acute poisoning. Following kitchen mitigations eliminates the majority of compound formation.',
    };
  }
}

final foodHazardsAndCancerServiceProvider = Provider<FoodHazardsAndCancerService>((ref) {
  return DefaultFoodHazardsAndCancerService();
});
