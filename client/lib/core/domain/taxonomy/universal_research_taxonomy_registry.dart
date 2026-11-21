// ==============================================================================
// Nutrient Earth — Universal 25-Domain Research Taxonomy Registry
// Comprehensive coverage registry for the entire everyday-health research universe:
// Nutrition, materials, plastics, chemicals, cancer, DNA, environmental exposures,
// clothing, footwear, jewellery, light, exercise, gym equipment, sleep, urination,
// bowel health, products, medicines, traditional practices, organ systems, etc.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResearchTaxonomyDomain {
  final int domainNumber;
  final String id;
  final String name;
  final String description;
  final List<String> subdomains;
  final List<String> exposureCategories;
  final List<String> primaryMethodologies;
  final List<String> sourceAllowlist;
  final String updateCadence;
  final List<String> canonicalSearchTerms;

  const ResearchTaxonomyDomain({
    required this.domainNumber,
    required this.id,
    required this.name,
    required this.description,
    required this.subdomains,
    required this.exposureCategories,
    required this.primaryMethodologies,
    this.sourceAllowlist = const ['PubMed', 'Europe PMC', 'OpenAlex', 'Cochrane Library'],
    this.updateCadence = 'daily',
    this.canonicalSearchTerms = const [],
  });
}

class UniversalResearchTaxonomyRegistry {
  const UniversalResearchTaxonomyRegistry();

  static const List<ResearchTaxonomyDomain> allDomains = [
    ResearchTaxonomyDomain(
      domainNumber: 1,
      id: 'domain_01_nutrition',
      name: 'Nutrition & Macronutrient Kinetics',
      description: 'Protein kinetics, carbohydrate digestion, lipid absorption, and metabolic energy balance.',
      subdomains: ['protein_synthesis', 'glycemic_index', 'lipolysis', 'fiber_fractions'],
      exposureCategories: ['Dietary Macronutrients', 'Feeding Timing', 'Caloric Restriction'],
      primaryMethodologies: ['RoB 2 (RCTs)', 'AMSTAR 2 (Meta-Analyses)', 'GRADE'],
      canonicalSearchTerms: ['muscle protein synthesis', 'glycemic load', 'dietary fiber satiety'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 2,
      id: 'domain_02_micronutrients',
      name: 'Micronutrients & Phytochemicals',
      description: 'Essential vitamins, trace minerals, polyphenols, chelation, and biological availability.',
      subdomains: ['magnesium_chelates', 'vitamin_d_endocrine', 'iron_ferritin', 'curcuminoids'],
      exposureCategories: ['Elemental Minerals', 'Fat-Soluble Vitamins', 'Bioactive Polyphenols'],
      primaryMethodologies: ['RoB 2', 'Pharmacokinetic Assays', 'GRADE'],
      canonicalSearchTerms: ['magnesium bisglycinate bioavailability', 'vitamin D3 K2 synergy'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 3,
      id: 'domain_03_food_processing',
      name: 'Food Processing & Culinary Physics',
      description: 'Thermal transformations, boiling vs steaming, antinutrient degradation, and sprouting kinetics.',
      subdomains: ['phytate_deactivation', 'oxalate_solubility', 'thermal_ascorbate_loss'],
      exposureCategories: ['Pressure Cooking', 'Soaking & Sprouting', 'Lacto-Fermentation'],
      primaryMethodologies: ['Controlled Analytical Trials', 'GRADE'],
      canonicalSearchTerms: ['spinach boiling oxalate reduction', 'dal soaking phytase activation'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 4,
      id: 'domain_04_cookware',
      name: 'Cookware, Utensils & Food Contact Materials',
      description: 'Cast iron, stainless steel, non-stick PTFE/PFAS, copper, brass, and clay pot leaching dynamics.',
      subdomains: ['iron_migration', 'ptfe_pyrolysis', 'acidic_corrosion', 'earthen_mineral_porosity'],
      exposureCategories: ['Heated Food Contact Surfaces', 'Acidic Food Simmering'],
      primaryMethodologies: ['Food Contact Toxicology', 'Spectrometry Migration Assays'],
      canonicalSearchTerms: ['cast iron tomato acidic leaching', 'ptfe non stick degradation temperature'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 5,
      id: 'domain_05_plastics',
      name: 'Plastics, Microplastics & Nanoplastics',
      description: 'Cutting boards, polymer shedding, cellular internalization, and colonic barrier disruption.',
      subdomains: ['polypropylene_cutting_boards', 'nanoplastic_translocation', 'microfiber_ingestion'],
      exposureCategories: ['Mechanical Kitchen Wear', 'Hot Liquid in Polyethylene'],
      primaryMethodologies: ['Analytical Raman Spectroscopy', 'ROBINS-I', 'GRADE'],
      canonicalSearchTerms: ['cutting board microplastic shedding human food', 'nanoplastic intestinal barrier'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 6,
      id: 'domain_06_endocrine_disruptors',
      name: 'Endocrine Disruptors & Everyday Chemicals',
      description: 'Phthalates, bisphenols (BPA, BPS), parabens, pesticide residues, and hormone receptor interference.',
      subdomains: ['bpa_thermal_paper', 'phthalate_adipogenesis', 'organophosphate_dietary_residues'],
      exposureCategories: ['Plasticizers', 'Personal Care Formulations', 'Agricultural Residues'],
      primaryMethodologies: ['ROBINS-I', 'Epidemiological Cohorts', 'GRADE'],
      canonicalSearchTerms: ['bpa urinary concentration metabolic health', 'phthalate exposure children'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 7,
      id: 'domain_07_environmental',
      name: 'Environmental Exposures, Air Quality & Particulates',
      description: 'Particulate matter (PM2.5, PM10), indoor ozone, volatile organic compounds (VOCs), and outdoor exercise.',
      subdomains: ['pm25_vascular_endothelium', 'aqi_strenuous_running', 'hepa_indoor_filtration'],
      exposureCategories: ['Ambient Inhalation', 'Combustion Aerosols'],
      primaryMethodologies: ['Prospective Cohorts', 'ROBINS-I'],
      canonicalSearchTerms: ['exercise in high aqi cardiovascular risk', 'pm25 pulmonary oxidative stress'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 8,
      id: 'domain_08_heavy_metals',
      name: 'Heavy Metals & Water Toxicology',
      description: 'Lead, arsenic, cadmium, and mercury bioaccumulation in municipal water, spices, and cacao.',
      subdomains: ['lead_neurodevelopment', 'arsenic_rice_irrigation', 'cadmium_dark_chocolate'],
      exposureCategories: ['Tap Water Ingestion', 'Dietary Heavy Metal Exposure'],
      primaryMethodologies: ['ICP-MS Analytical Chemistry', 'Toxicology Guidelines'],
      canonicalSearchTerms: ['rice cooking arsenic removal protocol', 'lead in turmeric spice adulteration'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 9,
      id: 'domain_09_light_photobiology',
      name: 'Light, Photobiology & Circadian Entrainment',
      description: 'Retinal ganglion cells (ipRGCs), melanopsin, natural morning sunlight, and evening blue suppression.',
      subdomains: ['morning_lux_entrainment', 'iprgc_melanopsin_excitation', 'phase_delay_blue_light'],
      exposureCategories: ['Solar Lux Exposure', 'Narrow-Band Blue Photons (460-480nm)'],
      primaryMethodologies: ['Human Chronobiology Trials', 'RoB 2'],
      canonicalSearchTerms: ['morning sunlight cortisol awakening response', 'evening blue light melatonin phase'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 10,
      id: 'domain_10_sleep_somnology',
      name: 'Sleep Architecture & Somnology',
      description: 'Slow-wave sleep (SWS), REM, adenosine clearance, glymphatic neurological wash, and chronotype alignment.',
      subdomains: ['adenosine_homeostasis', 'glymphatic_flow', 'temperature_circadian_drop'],
      exposureCategories: ['Sleep Timing', 'Darkness Hygiene', 'Thermal Environment'],
      primaryMethodologies: ['Polysomnography RCTs', 'RoB 2', 'GRADE'],
      canonicalSearchTerms: ['slow wave sleep cardiovascular restoration', 'core temperature sleep onset latency'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 11,
      id: 'domain_11_exercise_physiology',
      name: 'Exercise Physiology & Skeletal Muscle Adaptation',
      description: 'Mechanical tension, mitochondrial biogenesis, soleus pushups, non-insulin GLUT4, and Zone 2 cardio.',
      subdomains: ['glut4_insulin_independent', 'soleus_oxidative_rate', 'mtorc1_hypertrophy'],
      exposureCategories: ['Resistance Training', 'Low-Intensity Steady State', 'Postprandial Walking'],
      primaryMethodologies: ['Human Muscle Biopsy Trials', 'RoB 2'],
      canonicalSearchTerms: ['soleus muscle glucose lipid metabolism', 'postprandial walking glucose spike attenuation'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 12,
      id: 'domain_12_gym_biomechanics',
      name: 'Gym Equipment, Biomechanics & Injury Prevention',
      description: 'Resistance curves, joint moment arms, eccentric loading, spinal shear forces, and connective tissue remodeling.',
      subdomains: ['spinal_compression_shear', 'patellar_tendon_strain', 'cable_resistance_profiles'],
      exposureCategories: ['Mechanical Vector Loading', 'Joint Shear Stress'],
      primaryMethodologies: ['Biomechanical Kinematics', 'Electromyography (EMG)'],
      canonicalSearchTerms: ['squat knee angle patellofemoral shear', 'eccentric resistance tendon remodeling'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 13,
      id: 'domain_13_clothing_textiles',
      name: 'Clothing, Textiles & Dermal Absorption',
      description: 'Synthetic fibers (polyester, nylon), microplastic shedding, azo dyes, flame retardants, and dermal microflora.',
      subdomains: ['synthetic_sweat_interaction', 'transdermal_azo_dyes', 'textile_breathability_heat'],
      exposureCategories: ['Epidermal Contact', 'Friction Under Perspiration'],
      primaryMethodologies: ['Dermal Permeation Assays', 'ROBINS-I'],
      canonicalSearchTerms: ['synthetic activewear microplastic dermal absorption', 'azo dyes sweat dissolution'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 14,
      id: 'domain_14_footwear_gait',
      name: 'Footwear, Gait & Musculoskeletal Alignment',
      description: 'Toe spring, drop, minimalist mechanics, intrinsic foot muscle atrophy, and ground reaction force absorption.',
      subdomains: ['plantar_fascia_stiffness', 'intrinsic_foot_hypertrophy', 'tibial_impact_transience'],
      exposureCategories: ['Footwear Stack Height', 'Toe Box Constriction'],
      primaryMethodologies: ['Force Plate Gait Analysis', 'RoB 2'],
      canonicalSearchTerms: ['minimalist footwear foot intrinsic muscle strength', 'elevated heel running knee loading'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 15,
      id: 'domain_15_jewellery_metals',
      name: 'Jewellery, Metals & Cutaneous Sensitization',
      description: 'Nickel allergic contact dermatitis, cobalt, chromium, piercing hygiene, and hypoallergenic biocompatibility.',
      subdomains: ['nickel_ion_release', 'acidic_perspiration_corrosion', 'hypoallergenic_titanium'],
      exposureCategories: ['Prolonged Cutaneous Metal Contact', 'Transdermal Piercing Channels'],
      primaryMethodologies: ['Patch Testing Trials', 'Dermatology Consensus Guidelines'],
      canonicalSearchTerms: ['nickel contact dermatitis sweat release rate', 'titanium vs stainless steel piercing healing'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 16,
      id: 'domain_16_bowel_health',
      name: 'Bowel Health, Motility & Stool Biomarkers',
      description: 'Bristol stool classification, colonic transit time, short-chain fatty acids (SCFAs), and bile acid sequestrants.',
      subdomains: ['psyllium_mucilage_stool_viscosity', 'butyrate_colonocyte_fuel', 'gut_motility_circadian'],
      exposureCategories: ['Soluble / Insoluble Fiber', 'Microbial Fermentables'],
      primaryMethodologies: ['RoB 2', 'Randomized Crossover Trials', 'GRADE'],
      canonicalSearchTerms: ['psyllium colonic transit time chronic constipation', 'short chain fatty acids gut barrier'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 17,
      id: 'domain_17_renal_hydration',
      name: 'Renal Function, Hydration & Urination Dynamics',
      description: 'Urine specific gravity, electrolyte clearance, glomerular filtration rate (GFR), and diurnal vasopressin cycles.',
      subdomains: ['renal_solute_load', 'nocturia_circadian_vasopressin', 'electrolyte_hydration_osmosis'],
      exposureCategories: ['Fluid Volume Intake', 'Mineral Salt Concentrations'],
      primaryMethodologies: ['Clinical Nephrology Trials', 'GRADE'],
      canonicalSearchTerms: ['urine specific gravity athletic hydration status', 'diurnal vasopressin nocturnal polyuria'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 18,
      id: 'domain_18_cancer_research',
      name: 'Cancer Biology, Carcinogenesis & Epidemiology',
      description: 'IARC hazard tiers, human epidemiological evidence vs cellular mechanisms, dietary mutagens, and absolute risk.',
      subdomains: ['iarc_monograph_classification', 'acrylamide_dietary_exposure', 'red_meat_heme_colorectal'],
      exposureCategories: ['Carcinogenic Hazard Identification', 'High-Temperature Maillard Mutagens'],
      primaryMethodologies: ['IARC Evaluation Framework', 'GRADE', 'ROBINS-I (Prospective Cohorts)'],
      canonicalSearchTerms: ['dietary fiber colorectal cancer meta-analysis', 'acrylamide cooking human cancer epidemiology'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 19,
      id: 'domain_19_dna_epigenetics',
      name: 'DNA Integrity, Epigenetics & Telomere Biology',
      description: 'Base oxidation (8-OHdG), PARP DNA repair, DNA methylation, histone acetylation, and telomere maintenance.',
      subdomains: ['base_excision_repair', 'one_carbon_metabolism_folate', 'telomere_attrition_lifestyle'],
      exposureCategories: ['Oxidative Stress Inducers', 'Methyl Donor Micronutrients'],
      primaryMethodologies: ['Molecular Biology Assays', 'Human Biomarker Trials'],
      canonicalSearchTerms: ['8-hydroxydeoxyguanosine exercise oxidative stress', 'folate b12 dna methylation stability'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 20,
      id: 'domain_20_organ_systems',
      name: 'Organ Systems (Cardiovascular, Hepatic, Metabolic)',
      description: 'Endothelial flow-mediated dilation, hepatic de novo lipogenesis, ApoB clearance, and systemic arterial stiffness.',
      subdomains: ['flow_mediated_dilation_nitric_oxide', 'apob_atherogenic_particles', 'nafld_fructose_metabolism'],
      exposureCategories: ['Saturated vs Polyunsaturated Fats', 'Dietary Fructose Ingestion'],
      primaryMethodologies: ['Cardiology RCTs', 'AMSTAR 2', 'GRADE'],
      canonicalSearchTerms: ['apob particle number cardiovascular risk meta analysis', 'flow mediated dilation dietary polyphenols'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 21,
      id: 'domain_21_pharmacokinetics',
      name: 'Pharmaceutical Pharmacokinetics & Supplements',
      description: 'Biological half-life, systemic bioavailability, hepatic CYP3A4 metabolism, and supplement-drug interactions.',
      subdomains: ['cyp450_enzyme_inhibition', 'first_pass_hepatic_clearance', 'st_johns_wort_interactions'],
      exposureCategories: ['Botanical Concentrates', 'Chelated Supplement Molecules'],
      primaryMethodologies: ['Clinical Pharmacokinetics Trials', 'In-Vitro Microsomal Assays'],
      canonicalSearchTerms: ['grapefruit cyp3a4 statin interaction', 'piperine curcumin bioavailability enhancement'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 22,
      id: 'domain_22_traditional_ayush',
      name: 'Traditional, Ancestral & AYUSH Living Practices',
      description: 'Ayurvedic Dinacharya, seasonal Ritucharya, digestive Agni, regional millets, and earthen cookware physics.',
      subdomains: ['ayurgomics_genotype_phenotype', 'ragi_calcium_matrix', 'kanji_lactic_fermentation'],
      exposureCategories: ['Ancient Grain Cultivars', 'Earthen Pot Slow Cooking', 'Spiced Culinary Formulations'],
      primaryMethodologies: ['Ministry of AYUSH Clinical Guidelines', 'Integrative Nutritional Science'],
      canonicalSearchTerms: ['ayurveda agni circadian gastroduodenal physiology', 'finger millet ragi diabetes clinical trial'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 23,
      id: 'domain_23_oral_health',
      name: 'Oral Microbiome & Dentition Health',
      description: 'Salivary nitrate-nitrite-nitric oxide pathway, Streptococcus mutans, hydroxyapatite vs fluoride enamel kinetics.',
      subdomains: ['oral_nitric_oxide_axis', 'enamel_remineralization_hydroxyapatite', 'chlorhexidine_blood_pressure'],
      exposureCategories: ['Antiseptic Mouthwash Use', 'Dietary Dietary Nitrate (Beetroot/Greens)'],
      primaryMethodologies: ['RoB 2', 'Microbiome Sequencing', 'GRADE'],
      canonicalSearchTerms: ['antiseptic mouthwash salivary nitrate nitric oxide loss', 'hydroxyapatite enamel remineralization rct'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 24,
      id: 'domain_24_ergonomics',
      name: 'Occupational & Household Ergonomics',
      description: 'Sedentary interruption protocols, sit-stand desk kinematics, ciliary eye fatigue (20-20-20), and lumbar pressure.',
      subdomains: ['intermittent_standing_insulin', 'ciliary_muscle_digital_eyestrain', 'lumbar_disc_intradiscal_pressure'],
      exposureCategories: ['Sustained Static Posture', 'Visual Display Terminal Exposure'],
      primaryMethodologies: ['Occupational Health Trials', 'ROBINS-I'],
      canonicalSearchTerms: ['standing desk postprandial glucose trial', '20-20-20 rule computer vision syndrome'],
    ),
    ResearchTaxonomyDomain(
      domainNumber: 25,
      id: 'domain_25_longevity',
      name: 'Longevity, Cellular Senescence & Autophagy',
      description: 'Sirtuin activation, NAD+ salvage, intermittent fasting autophagic flux, senolytic clearance, and healthspan.',
      subdomains: ['autophagy_flux_markers', 'nad_sirt1_axis', 'senescent_sasp_phenotype'],
      exposureCategories: ['Time-Restricted Feeding', 'Heat Shock (Sauna) / Cold Exposure'],
      primaryMethodologies: ['Translational Human Trials', 'RoB 2', 'GRADE'],
      canonicalSearchTerms: ['intermittent fasting human autophagy biomarkers', 'sauna frequency cardiovascular mortality cohort'],
    ),
  ];

  static ResearchTaxonomyDomain? getDomainById(String id) {
    for (final d in allDomains) {
      if (d.id == id) return d;
    }
    return null;
  }

  static ResearchTaxonomyDomain? getDomainByNumber(int num) {
    for (final d in allDomains) {
      if (d.domainNumber == num) return d;
    }
    return null;
  }

  static ResearchTaxonomyDomain matchQueryToDomain(String query) {
    final lower = query.toLowerCase();

    for (final domain in allDomains) {
      for (final term in domain.canonicalSearchTerms) {
        if (lower.contains(term.toLowerCase())) return domain;
      }
      for (final sub in domain.subdomains) {
        if (lower.contains(sub.replaceAll('_', ' '))) return domain;
      }
    }

    // Default fallback based on high-level keywords
    if (lower.contains('cancer') || lower.contains('tumor') || lower.contains('carcinogen')) {
      return getDomainByNumber(18)!;
    }
    if (lower.contains('dna') || lower.contains('mutation') || lower.contains('telomere')) {
      return getDomainByNumber(19)!;
    }
    if (lower.contains('plastic') || lower.contains('cutting board')) {
      return getDomainByNumber(5)!;
    }
    if (lower.contains('pan') || lower.contains('cast iron') || lower.contains('cookware')) {
      return getDomainByNumber(4)!;
    }
    if (lower.contains('sleep') || lower.contains('melatonin') || lower.contains('insomnia')) {
      return getDomainByNumber(10)!;
    }
    if (lower.contains('exercise') || lower.contains('workout') || lower.contains('running')) {
      return getDomainByNumber(11)!;
    }
    if (lower.contains('ayurveda') || lower.contains('millet') || lower.contains('ragi')) {
      return getDomainByNumber(22)!;
    }

    // Default to Domain 1 (Nutrition)
    return allDomains.first;
  }
}

final universalResearchTaxonomyRegistryProvider = Provider<UniversalResearchTaxonomyRegistry>((ref) {
  return const UniversalResearchTaxonomyRegistry();
});
