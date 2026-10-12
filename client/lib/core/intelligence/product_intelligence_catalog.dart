import 'intelligence_contracts.dart';

class ProductIntelligenceCatalog {
  ProductIntelligenceCatalog._();

  static const List<EvidenceItem> scientificEvidence = [
    EvidenceItem(
      id: 'EV_BABAULT_2015',
      title: 'Pea proteins oral supplementation promotes muscle thickness gains during resistance training: a double-blind, randomized, Placebo-controlled clinical trial',
      authors: 'Babault N, Païzis C, Deley G, et al.',
      year: 2015,
      source: 'Journal of the International Society of Sports Nutrition, 12(1):3',
      url: 'https://doi.org/10.1186/s12970-014-0064-5',
      studyType: 'Double-Blind RCT (n=161)',
      keyFinding: 'Pea protein showed equivalent increases in biceps muscle thickness compared to whey protein over 12 weeks of resistance training when matched for leucine and protein intake.',
      qualityScore: 0.94,
    ),
    EvidenceItem(
      id: 'EV_WEAVER_2016',
      title: 'The National Osteoporosis Foundation dietary calcium intake and bone mineral density across the lifespan',
      authors: 'Weaver CM, Gordon CM, Janz KF, et al.',
      year: 2016,
      source: 'Advances in Nutrition, 7(1):23-34',
      url: 'https://doi.org/10.3945/an.115.009944',
      studyType: 'Systematic Review & Evidence-Based Guideline',
      keyFinding: 'Calcium intake from bioavailable whole-food and supplemental sources supports peak bone mass attainment in early adulthood and attenuates fracture risk.',
      qualityScore: 0.96,
    ),
    EvidenceItem(
      id: 'EV_HOLICK_2011',
      title: 'Evaluation, treatment, and prevention of vitamin D deficiency: an Endocrine Society clinical practice guideline',
      authors: 'Holick MF, Binkley NC, Bischoff-Ferrari HA, et al.',
      year: 2011,
      source: 'Journal of Clinical Endocrinology & Metabolism, 96(7):1911-1930',
      url: 'https://doi.org/10.1210/jc.2011-0385',
      studyType: 'Clinical Practice Guideline',
      keyFinding: 'Serum 25-hydroxyvitamin D [25(OH)D] above 30 ng/mL (75 nmol/L) maximizes intestinal calcium absorption and optimizes musculoskeletal and immunological markers.',
      qualityScore: 0.95,
    ),
    EvidenceItem(
      id: 'EV_USDA_FDC_2023',
      title: 'USDA FoodData Central Standard Nutrient Database & Bioavailability Parameters',
      authors: 'Agricultural Research Service, U.S. Department of Agriculture',
      year: 2023,
      source: 'USDA FoodData Central Release v2023',
      url: 'https://fdc.nal.usda.gov',
      studyType: 'Government Standard Analytical Assay',
      keyFinding: 'Standardized proximate values and amino acid scoring patterns for whole foods, isolates, and fortified botanical formulations.',
      qualityScore: 0.98,
    ),
    EvidenceItem(
      id: 'EV_EFSA_MAGNESIUM_2015',
      title: 'Scientific Opinion on Dietary Reference Values for magnesium',
      authors: 'EFSA Panel on Dietetic Products, Nutrition and Allergies (NDA)',
      year: 2015,
      source: 'EFSA Journal, 13(7):4186',
      url: 'https://doi.org/10.2903/j.efsa.2015.4186',
      studyType: 'Scientific Opinion & Consensus Panel',
      keyFinding: 'Adequate intake of 350 mg/day for men and 300 mg/day for women maintains healthy magnesium balance, cellular electrolyte homeostasis, and enzyme cofactor activity.',
      qualityScore: 0.92,
    ),
  ];

  static List<EvidenceItem> findRelevantEvidence(String query) {
    final lower = query.toLowerCase();
    final matched = <EvidenceItem>[];
    for (final item in scientificEvidence) {
      if (lower.contains('protein') || lower.contains('muscle') || lower.contains('pea') || lower.contains('whey')) {
        if (item.id == 'EV_BABAULT_2015' || item.id == 'EV_USDA_FDC_2023') {
          matched.add(item);
        }
      }
      if (lower.contains('calcium') || lower.contains('bone') || lower.contains('mineral')) {
        if (item.id == 'EV_WEAVER_2016') {
          matched.add(item);
        }
      }
      if (lower.contains('vitamin d') || lower.contains('sun') || lower.contains('immunity')) {
        if (item.id == 'EV_HOLICK_2011') {
          matched.add(item);
        }
      }
      if (lower.contains('magnesium') || lower.contains('sleep') || lower.contains('cramp')) {
        if (item.id == 'EV_EFSA_MAGNESIUM_2015') {
          matched.add(item);
        }
      }
    }
    // Default fallback to highest quality base evidence if no specific keyword matched
    if (matched.isEmpty) {
      matched.addAll(scientificEvidence.take(2));
    }
    return matched.toSet().toList();
  }
}
