// ==============================================================================
// Nutrient Earth — Traditional Food & Living Intelligence Engine
// Investigates:
// 1. Traditional Indian millets & ancient grains (Jowar, Bajra, Ragi, Foxtail)
// 2. Fermentation: Dahi, Kanji, Dosa batter vs Western fermented foods & the Indian gut
// 3. Ayurvedic frameworks (Agni, Dosha, Dinacharya, Ritucharya) cross-referenced
//    against modern gastroenterology, circadian photobiology, and chronobiology
// 4. Historical longevity & survival bias: Scientific evaluation of ancient lifestyles
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MilletProfile {
  final String commonName;
  final String regionalNames; // Hindi, Tamil, Telugu, Kannada
  final String botanicalName;
  final String nutritionalSignature;
  final String optimalPreparationProtocol;
  final String traditionalCulinaryUse;
  final String modernPhysiologicalEvidence;

  const MilletProfile({
    required this.commonName,
    required this.regionalNames,
    required this.botanicalName,
    required this.nutritionalSignature,
    required this.optimalPreparationProtocol,
    required this.traditionalCulinaryUse,
    required this.modernPhysiologicalEvidence,
  });
}

class FermentedFoodSuitability {
  final String foodName;
  final String indigenousMicrobiology;
  final String suitabilityForIndianGut;
  final String biochemicalMechanism;
  final String practicalPreparationTip;

  const FermentedFoodSuitability({
    required this.foodName,
    required this.indigenousMicrobiology,
    required this.suitabilityForIndianGut,
    required this.biochemicalMechanism,
    required this.practicalPreparationTip,
  });
}

class AyurvedicConceptScientificCrosswalk {
  final String traditionalConcept;
  final String traditionalDefinition;
  final String modernPhysiologicalCorrelate;
  final String verifiedEvidence;
  final String limitsAndMisconceptions;

  const AyurvedicConceptScientificCrosswalk({
    required this.traditionalConcept,
    required this.traditionalDefinition,
    required this.modernPhysiologicalCorrelate,
    required this.verifiedEvidence,
    required this.limitsAndMisconceptions,
  });
}

abstract class TraditionalLivingIntelligenceService {
  List<MilletProfile> getMilletProfiles();

  MilletProfile? getMilletByName(String name);

  List<FermentedFoodSuitability> getFermentationSuitability();

  List<AyurvedicConceptScientificCrosswalk> getAyurvedicCrosswalks();

  Map<String, dynamic> evaluateHistoricalLongevityClaims();
}

class DefaultTraditionalLivingIntelligenceService implements TraditionalLivingIntelligenceService {
  static const List<MilletProfile> _millets = [
    MilletProfile(
      commonName: 'Finger Millet (Ragi / Mandua / Kezhvaragu)',
      regionalNames: 'Ragi (Kannada/Hindi), Kezhvaragu (Tamil), Ragulu (Telugu)',
      botanicalName: 'Eleusine coracana',
      nutritionalSignature: '344 mg calcium per 100g (10x higher than rice/wheat), rich in polyphenols and slowly digestible starch.',
      optimalPreparationProtocol:
          'Soak for 12 hours, sprout for 24 hours to trigger endogenous phytases, dry, and mill. Sprouting increases bioavailable iron and zinc by up to 300% while degrading phytate chelators.',
      traditionalCulinaryUse: 'Ragi mudde (steamed dumpling), ragi malt/kanji, rotis, and fermented dosas.',
      modernPhysiologicalEvidence:
          'Clinical trials show finger millet lowers glycemic index, delays gastric emptying, and significantly improves bone mineral density markers.',
    ),
    MilletProfile(
      commonName: 'Pearl Millet (Bajra / Kambu / Sajjalu)',
      regionalNames: 'Bajra (Hindi), Kambu (Tamil), Sajjalu (Telugu), Sajje (Kannada)',
      botanicalName: 'Pennisetum glaucum',
      nutritionalSignature: 'High non-heme iron (8 mg/100g), high magnesium, rich in oleic and linoleic unsaturated fatty acids.',
      optimalPreparationProtocol:
          'Due to high lipid content, milled bajra flour oxidizes rapidly. Grind fresh in small batches. Combine with vitamin C sources (lemon, tomato) to enhance iron absorption.',
      traditionalCulinaryUse: 'Bajra roti (bhakri), kambu koozh (traditional summer fermented porridge), khichdi.',
      modernPhysiologicalEvidence:
          'Regular consumption of biofortified pearl millet reverses iron deficiency and improves cognitive endurance in adolescents (p < 0.01).',
    ),
    MilletProfile(
      commonName: 'Foxtail Millet (Kangni / Thinai / Korra)',
      regionalNames: 'Kangni (Hindi), Thinai (Tamil), Korra (Telugu), Navane (Kannada)',
      botanicalName: 'Setaria italica',
      nutritionalSignature: 'High dietary fiber (8-10%), low glycemic load, abundant thiamine (B1) and tryptophan.',
      optimalPreparationProtocol:
          'Wash 2 times, soak for 4-6 hours, and cook with 1:2.5 water ratio as a direct rice replacement.',
      traditionalCulinaryUse: 'Thinai payasam, upma, idli/dosa, and seasoned millet rice.',
      modernPhysiologicalEvidence:
          'Significant improvements in fasting blood glucose and lipid profiles in individuals with type 2 diabetes consuming foxtail millet over 90 days.',
    ),
  ];

  static const List<FermentedFoodSuitability> _fermentedFoods = [
    FermentedFoodSuitability(
      foodName: 'Traditional Dahi (Indian Curd) vs Greek Yogurt',
      indigenousMicrobiology: 'Lactobacillus acidophilus, Streptococcus thermophilus, Lactobacillus delbrueckii',
      suitabilityForIndianGut:
          'Traditional home-set dahi using wild heirloom starters contains diverse lactic acid bacteria adapted to Indian gastrointestinal tracts. Unlike commercial Greek yogurt (which is heavily strained, discarding mineral-rich whey and often past-pasteurized), home dahi retains intact bioavailable whey peptides and natural bacteriocins.',
      biochemicalMechanism:
          'Fermentation pre-digests lactose into lactic acid, breaks down milk caseins into digestible peptides, and lowers intestinal pH to inhibit gram-negative pathogens.',
      practicalPreparationTip:
          'Set curd in an earthenware/terracotta pot (mitti handi); clay micro-pores absorb excess moisture, creating naturally thick, rich probiotic curd without industrial gums or artificial straining.',
    ),
    FermentedFoodSuitability(
      foodName: 'Traditional Rice Kanji (Fermented Rice Broth / Pazhaya Sadam)',
      indigenousMicrobiology: 'Weissella, Leuconostoc mesenteroides, Lactobacillus fermentum',
      suitabilityForIndianGut:
          'Overnight submerged water fermentation of cooked parboiled rice elevates vitamin B12 (via bacterial synthesis) by over 10-fold and unlocks micro-minerals from phytic acid complexes.',
      biochemicalMechanism:
          'Short-chain fatty acid (SCFA) accumulation (acetate, butyrate) creates a protective mucosal barrier against tropical gut dysbiosis.',
      practicalPreparationTip:
          'Soak leftover cooked rice in earthen pots with clean drinking water for 12 hours at room temperature; consume with a small raw shallot for prebiotic inulin synergy.',
    ),
  ];

  static const List<AyurvedicConceptScientificCrosswalk> _crosswalks = [
    AyurvedicConceptScientificCrosswalk(
      traditionalConcept: 'Agni (The Digestive Fire)',
      traditionalDefinition: 'The metabolic energy responsible for digestion, absorption, and assimilation. Weak Agni leads to Ama (undigested toxic residues).',
      modernPhysiologicalCorrelate:
          'Gastric acid secretion (HCl), pancreatic enzyme output (amylase, protease, lipase), and gastrointestinal motility modulated by parasympathetic vagal tone.',
      verifiedEvidence:
          'Enzyme secretion and digestive transit follow a strict circadian rhythm, peaking around solar noon (12:00-13:30) and declining sharply at night. Aligning largest caloric intake with peak gastric secretion optimizes postprandial glycemic clearance.',
      limitsAndMisconceptions:
          'Agni is an explanatory physiological framework, not a literal flame. Do not treat "weak Agni" as a licensed medical diagnosis for acute gastrointestinal pathology (e.g. inflammatory bowel disease, ulcers).',
    ),
    AyurvedicConceptScientificCrosswalk(
      traditionalConcept: 'Ritucharya (Seasonal Living & Dietary Regimen)',
      traditionalDefinition: 'Seasonal adaptation of diet and lifestyle according to changing planetary and climatic cycles.',
      modernPhysiologicalCorrelate:
          'Seasonal variation in human gut microbiome composition, thyroid metabolic set-points, vitamin D photobiology, and insulin sensitivity.',
      verifiedEvidence:
          'Microbiome metagenomic sequencing confirms that human gut microbial diversity shifts seasonally with seasonal produce availability (e.g. higher fiber and root starches in winter, higher cooling astringent foods in summer).',
      limitsAndMisconceptions:
          'Seasonal guidelines are heuristic dietary patterns, not rigid dogmas. They should accommodate modern food safety, cold storage hygiene, and individual metabolic needs.',
    ),
  ];

  @override
  List<MilletProfile> getMilletProfiles() => _millets;

  @override
  MilletProfile? getMilletByName(String name) {
    final lower = name.toLowerCase();
    return _millets.cast<MilletProfile?>().firstWhere(
          (m) => m != null && (m.commonName.toLowerCase().contains(lower) || m.regionalNames.toLowerCase().contains(lower)),
          orElse: () => null,
        );
  }

  @override
  List<FermentedFoodSuitability> getFermentationSuitability() => _fermentedFoods;

  @override
  List<AyurvedicConceptScientificCrosswalk> getAyurvedicCrosswalks() => _crosswalks;

  @override
  Map<String, dynamic> evaluateHistoricalLongevityClaims() {
    return {
      'core_conclusion': 'Historical claims that ancient humans routinely lived to 100+ years are unsupported by demographic and anthropological records. The reality is characterized by high infant mortality, infectious disease, and survival bias.',
      'anthropological_evidence': [
        'Average life expectancy at birth in ancient and pre-industrial civilizations was 30-38 years, heavily depressed by infant and maternal mortality and infectious diseases (malaria, cholera, dysentery).',
        'However, individuals who survived past childhood often lived into their 60s and 70s, demonstrating that the human lifespan ceiling has remained relatively constant (~80-90 years) throughout recorded history.',
        'Ancient populations possessed lower rates of modern metabolic chronic diseases (type 2 diabetes, obesity, coronary atherosclerosis) due to high daily functional physical exertion, seasonal whole food diversity, and absence of ultra-processed industrial food.',
      ],
      'product_principle':
          'Nutrient Earth extracts sustainable, evidence-supported practices (whole grain diversity, circadian meal timing, outdoor movement, fermented foods) without promising that ancient living magically guarantees extreme longevity.',
    };
  }
}

final traditionalLivingIntelligenceServiceProvider = Provider<TraditionalLivingIntelligenceService>((ref) {
  return DefaultTraditionalLivingIntelligenceService();
});
