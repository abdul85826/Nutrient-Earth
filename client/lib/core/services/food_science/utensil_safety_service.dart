// ==============================================================================
// Nutrient Earth — Cookware & Food-Contact Material Safety Service
// Evaluates cookware safety based on:
// - Food acidity (tomatoes, tamarind, lemon, vinegar)
// - Temperature limits (PTFE degradation at >260°C)
// - Chemical migration (aluminium, copper, lead from glazes, dietary iron)
// - Regulatory compliance (EFSA / FSSAI standards)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/food_science/utensil_safety_models.dart';

abstract class UtensilSafetyService {
  UtensilSafetyProfile getProfileForMaterial(UtensilMaterialType material);

  Map<String, dynamic> evaluateCompatibility({
    required UtensilMaterialType material,
    required bool isAcidicFood,
    required double cookingTemperatureC,
    String? foodName,
  });

  List<UtensilSafetyProfile> getAllProfiles();
}

class DefaultUtensilSafetyService implements UtensilSafetyService {
  @override
  UtensilSafetyProfile getProfileForMaterial(UtensilMaterialType material) {
    switch (material) {
      case UtensilMaterialType.stainlessSteel:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.stainlessSteel,
          maxSafeTemperatureC: 450.0,
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: ['trace_chromium', 'trace_nickel_in_damaged_grades'],
          wearAndScratchRisk: 'Extremely durable; highly resistant to pitting and scratch degradation.',
          regulatoryStandardNotes: 'Meets EFSA and FSSAI standards as universally safe food-contact material (304 / 316 surgical grade).',
          clinicalHealthImplications: 'Biochemically inert under standard culinary conditions; safe for individuals with common dietary sensitivities.',
          bestUseCases: [
            'Simmering acidic tomato, tamarind, and citrus dishes (Rasam, Sambar, Marinades)',
            'Boiling, steaming, and multi-hour slow braising',
            'Pressure cooking and high-heat searing',
          ],
          dangerousMistakesToAvoid: [
            'Using industrial wire brushes that cause deep pitting',
            'Severe nickel-sensitive individuals should prefer nickel-free 430 grade or ceramic',
          ],
        );

      case UtensilMaterialType.castIronSeasoned:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.castIronSeasoned,
          maxSafeTemperatureC: 400.0,
          acidicCompatibility: AcidicCompatibility.cautionShortContact,
          primaryLeachingElements: ['bioavailable_ferrous_iron_fe2', 'ferric_iron_fe3'],
          wearAndScratchRisk: 'Requires polymerized oil seasoning layer; harsh detergent strips seasoning.',
          regulatoryStandardNotes: 'Traditional recognized food-contact material. Iron migration is therapeutically recognized in nutritional literature.',
          clinicalHealthImplications: 'Leaches 2-4 mg of bioavailable elemental iron per serving, significantly improving hemoglobin in iron-deficiency anemia.',
          bestUseCases: [
            'High-heat searing of proteins, rotis, dosas, and stir-fries',
            'Dry roasting spices and vegetable sautéing',
            'Nutritional iron supplementation through food preparation',
          ],
          dangerousMistakesToAvoid: [
            'Cooking prolonged acidic broths (e.g. tamarind rasam or tomato curry >20 min), which strips seasoning and produces a metallic off-taste',
            'Storing cooked food inside the pot overnight (causes oxidation/rust)',
          ],
        );

      case UtensilMaterialType.rawAluminium:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.rawAluminium,
          maxSafeTemperatureC: 300.0,
          acidicCompatibility: AcidicCompatibility.contraindicatedLeaching,
          primaryLeachingElements: ['aluminium_ions_al3'],
          wearAndScratchRisk: 'Soft metal, prone to deep scoring, pitting, and rapid leaching when exposed to acids or metal ladles.',
          regulatoryStandardNotes: 'FSSAI and EFSA explicitly warn against preparing or storing acidic foods in uncoated raw aluminium.',
          clinicalHealthImplications: 'Chronic dietary aluminium accumulation is associated with bone demineralization and neurotoxicity risks in long-term exposures.',
          bestUseCases: [
            'Only acceptable for dry baking or boiling non-acidic plain water',
          ],
          dangerousMistakesToAvoid: [
            'CRITICAL: Never cook tomato gravies, tamarind water, vinegar, or citrus pickles in raw aluminium',
            'Never store cooked curries or salty foods in aluminium vessels overnight',
          ],
        );

      case UtensilMaterialType.anodizedAluminium:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.anodizedAluminium,
          maxSafeTemperatureC: 350.0,
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: ['none_when_intact'],
          wearAndScratchRisk: 'Hard electrochemically oxidized layer is non-reactive and scratch-resistant under normal wooden/silicone tool use.',
          regulatoryStandardNotes: 'Approved by FSSAI/FDA as non-reactive food-grade cookware as long as the hard-anodized seal is intact.',
          clinicalHealthImplications: 'Prevents raw aluminium contact with food; excellent heat distribution with negligible ionic migration.',
          bestUseCases: [
            'Pressure cookers, everyday curries, sautéing, and deep frying',
            'Acidic food cooking where cast iron is not suitable',
          ],
          dangerousMistakesToAvoid: [
            'Using steel wool or caustic dishwasher detergents that strip the anodized coating',
            'Discard pan once the grey anodized layer is worn through to raw shiny metal',
          ],
        );

      case UtensilMaterialType.copperUnlined:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.copperUnlined,
          maxSafeTemperatureC: 250.0,
          acidicCompatibility: AcidicCompatibility.contraindicatedLeaching,
          primaryLeachingElements: ['copper_cu2', 'toxic_verdigris_copper_carbonate'],
          wearAndScratchRisk: 'Reacts rapidly with atmospheric moisture and organic acids.',
          regulatoryStandardNotes: 'FSSAI mandates that copper cookware used for cooking acidic food MUST have a protective tin lining (Kalai).',
          clinicalHealthImplications: 'Acute copper toxicity causes nausea, severe vomiting, and abdominal cramps; chronic excess causes liver strain.',
          bestUseCases: [
            'Storing plain room-temperature drinking water (Tamra Jal, beneficial antimicrobial oligodynamic effect)',
            'Sugar boiling or sweet preparation (where no acid or salt is present)',
          ],
          dangerousMistakesToAvoid: [
            'NEVER cook sambar, tomato rasam, curd, buttermilk, or lemon juice in unlined copper',
            'Never use copper vessels showing greenish-blue patina (verdigris)',
          ],
        );

      case UtensilMaterialType.copperTinLined:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.copperTinLined,
          maxSafeTemperatureC: 230.0, // Tin melts at 231.9°C
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: ['inert_tin'],
          wearAndScratchRisk: 'Soft tin lining wears away with scrubbers and needs periodic re-tinning (Kalai).',
          regulatoryStandardNotes: 'Traditional Ayurvedic and culinary standard. Fully compliant when tin lining is continuous.',
          clinicalHealthImplications: 'Combines supreme thermal conduction of copper with non-reactive food protection of pure tin.',
          bestUseCases: [
            'Traditional slow-simmered aromatic broths, biryanis, and herbal decoctions',
          ],
          dangerousMistakesToAvoid: [
            'Never preheat the pan dry on high flame (tin melts at 232°C and can blister)',
            'Re-tin immediately when the yellow copper metal starts showing through the silver tin layer',
          ],
        );

      case UtensilMaterialType.brass:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.brass,
          maxSafeTemperatureC: 300.0,
          acidicCompatibility: AcidicCompatibility.cautionShortContact,
          primaryLeachingElements: ['copper', 'zinc'],
          wearAndScratchRisk: 'Requires tin lining (Kalai) for cooking moist, salty, or acidic foods.',
          regulatoryStandardNotes: 'Traditional alloy. Safe for dry items, but requires lining for gravies.',
          clinicalHealthImplications: 'Unlined brass reacts with food acids to create bitter zinc/copper salts.',
          bestUseCases: [
            'Boiling milk, making tea, dry roasting grains, serving dry sweets',
          ],
          dangerousMistakesToAvoid: [
            'Do not prepare or ferment acidic foods (pickles, tamarind curries) in unlined brass',
          ],
        );

      case UtensilMaterialType.nonStickPtfe:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.nonStickPtfe,
          maxSafeTemperatureC: 260.0,
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: ['perfluorinated_compounds_if_overheated'],
          wearAndScratchRisk: 'Fragile polymer coating. Scratches easily with metal utensils, releasing micro-flakes.',
          regulatoryStandardNotes: 'EFSA/FDA permit PTFE provided pan is not overheated (>260°C). Scratched pans must be retired.',
          clinicalHealthImplications: 'Thermal degradation above 260°C generates fluoropolymer fumes causing polymer fume fever. Ingested macro-flakes are biologically inert, but degraded micro-fragments carry PFAS risks.',
          bestUseCases: [
            'Low-to-medium heat egg cooking, delicate fish, or oil-free pancakes',
          ],
          dangerousMistakesToAvoid: [
            'Never preheat empty on high heat (reaches 300°C within 2 minutes)',
            'Never use metal spatulas or abrasive sponges',
            'Discard pan immediately when deep scratches expose the base metal',
          ],
        );

      case UtensilMaterialType.clayEarthenware:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.clayEarthenware,
          maxSafeTemperatureC: 300.0,
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: ['natural_beneficial_minerals_calcium_magnesium'],
          wearAndScratchRisk: 'Brittle, thermal shock sensitive. Requires gentle gradual heating.',
          regulatoryStandardNotes: 'Natural unglazed clay is non-toxic. Glazed pottery must be certified lead-free / cadmium-free (ISO 6486).',
          clinicalHealthImplications: 'Porous clay neutralizes acidity, retains moisture, and requires minimal cooking oil while preserving vitamins.',
          bestUseCases: [
            'Slow cooking dals, vegetable curries, and biryanis',
            'Curd setting (clay absorbs whey, creating thick probiotic curd)',
          ],
          dangerousMistakesToAvoid: [
            'Never wash with chemical dishwashing soap (porous clay absorbs soap, which leaches into future meals)',
            'Avoid sudden temperature shocks (e.g. cold water on a hot pot)',
          ],
        );

      case UtensilMaterialType.borosilicateGlass:
      case UtensilMaterialType.siliconeFoodGrade:
      case UtensilMaterialType.ceramicGlazed:
      default:
        return const UtensilSafetyProfile(
          material: UtensilMaterialType.borosilicateGlass,
          maxSafeTemperatureC: 300.0,
          acidicCompatibility: AcidicCompatibility.safe,
          primaryLeachingElements: [],
          wearAndScratchRisk: 'Non-porous and chemically inert.',
          regulatoryStandardNotes: 'Universally approved food-grade contact material.',
          clinicalHealthImplications: 'Zero chemical leaching; completely safe for all food types and storage.',
          bestUseCases: ['Oven baking, microwaving, cold storage of acidic foods'],
          dangerousMistakesToAvoid: ['Thermal shock from rapid freezer-to-oven transitions'],
        );
    }
  }

  @override
  Map<String, dynamic> evaluateCompatibility({
    required UtensilMaterialType material,
    required bool isAcidicFood,
    required double cookingTemperatureC,
    String? foodName,
  }) {
    final profile = getProfileForMaterial(material);
    final isSafe = profile.isSafeForDish(
      isAcidic: isAcidicFood,
      temperatureC: cookingTemperatureC,
    );

    final warnings = <String>[];
    if (cookingTemperatureC > profile.maxSafeTemperatureC) {
      warnings.add(
        'Cooking temperature (${cookingTemperatureC.toInt()}°C) exceeds safe thermal limit (${profile.maxSafeTemperatureC.toInt()}°C).',
      );
    }

    if (isAcidicFood && profile.acidicCompatibility == AcidicCompatibility.contraindicatedLeaching) {
      warnings.add(
        'CRITICAL: Food is acidic (pH < 4.5). ${profile.material.displayName} is contraindicated due to toxic metal leaching (${profile.primaryLeachingElements.join(", ")}).',
      );
    } else if (isAcidicFood && profile.acidicCompatibility == AcidicCompatibility.cautionShortContact) {
      warnings.add(
        'Notice: Food is acidic. Limit cooking to brief durations (<15-20 mins) to prevent stripping seasoning and excessive leaching.',
      );
    }

    return {
      'is_safe': isSafe,
      'material_name': profile.material.displayName,
      'max_safe_temperature_c': profile.maxSafeTemperatureC,
      'acidic_compatibility': profile.acidicCompatibility.label,
      'warnings': warnings,
      'regulatory_notes': profile.regulatoryStandardNotes,
      'clinical_health_implications': profile.clinicalHealthImplications,
      'best_alternatives': isSafe ? [] : ['Stainless Steel 304/316', 'Hard-Anodized Aluminium', 'Borosilicate Glass'],
    };
  }

  @override
  List<UtensilSafetyProfile> getAllProfiles() {
    return UtensilMaterialType.values.map(getProfileForMaterial).toList();
  }
}

final utensilSafetyServiceProvider = Provider<UtensilSafetyService>((ref) {
  return DefaultUtensilSafetyService();
});
