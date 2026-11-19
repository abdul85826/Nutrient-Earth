// ==============================================================================
// Nutrient Earth — Cookware & Food-Contact Material Safety Models
// Evaluates material suitability based on:
// - Food acidity (pH thresholds)
// - Thermal tolerances & overheating degradation (PTFE / polymer fumes)
// - Chemical & heavy metal migration (iron, aluminium, nickel, copper, lead)
// - Coating integrity & scratch damage
// - FSSAI & EFSA regulatory safety thresholds
// ==============================================================================

enum UtensilMaterialType {
  stainlessSteel,
  castIronSeasoned,
  rawAluminium,
  anodizedAluminium,
  copperUnlined,
  copperTinLined,
  brass,
  ceramicGlazed,
  clayEarthenware,
  nonStickPtfe,
  siliconeFoodGrade,
  borosilicateGlass;

  String get displayName {
    switch (this) {
      case UtensilMaterialType.stainlessSteel:
        return 'Stainless Steel (304 / 316 Grade)';
      case UtensilMaterialType.castIronSeasoned:
        return 'Seasoned Cast Iron';
      case UtensilMaterialType.rawAluminium:
        return 'Raw / Uncoated Aluminium';
      case UtensilMaterialType.anodizedAluminium:
        return 'Hard-Anodized Aluminium';
      case UtensilMaterialType.copperUnlined:
        return 'Unlined Pure Copper';
      case UtensilMaterialType.copperTinLined:
        return 'Tin-Lined Copper (Traditional Kalai)';
      case UtensilMaterialType.brass:
        return 'Brass (Pithal)';
      case UtensilMaterialType.ceramicGlazed:
        return 'Glazed Ceramic';
      case UtensilMaterialType.clayEarthenware:
        return 'Unfired / Terracotta Clay Pot (Mitti Handi)';
      case UtensilMaterialType.nonStickPtfe:
        return 'Non-Stick PTFE (Teflon Coated)';
      case UtensilMaterialType.siliconeFoodGrade:
        return 'Platinum Food-Grade Silicone';
      case UtensilMaterialType.borosilicateGlass:
        return 'Borosilicate Heat-Resistant Glass';
    }
  }
}

enum AcidicCompatibility {
  safe,
  cautionShortContact,
  contraindicatedLeaching;

  String get label {
    switch (this) {
      case AcidicCompatibility.safe:
        return 'Safe for Acidic Foods (pH < 4.5: Tomatoes, Tamarind, Citrus, Vinegar)';
      case AcidicCompatibility.cautionShortContact:
        return 'Caution: Brief contact (<15 min) acceptable; prolonged simmering causes migration';
      case AcidicCompatibility.contraindicatedLeaching:
        return 'Contraindicated: Severe chemical leaching; DO NOT cook or store acidic foods';
    }
  }
}

class UtensilSafetyProfile {
  final UtensilMaterialType material;
  final double maxSafeTemperatureC;
  final AcidicCompatibility acidicCompatibility;
  final List<String> primaryLeachingElements;
  final String wearAndScratchRisk;
  final String regulatoryStandardNotes; // EFSA / FSSAI standards
  final String clinicalHealthImplications;
  final List<String> bestUseCases;
  final List<String> dangerousMistakesToAvoid;

  const UtensilSafetyProfile({
    required this.material,
    required this.maxSafeTemperatureC,
    required this.acidicCompatibility,
    required this.primaryLeachingElements,
    required this.wearAndScratchRisk,
    required this.regulatoryStandardNotes,
    required this.clinicalHealthImplications,
    required this.bestUseCases,
    required this.dangerousMistakesToAvoid,
  });

  /// Check whether cooking a dish with given acidity and temperature is safe
  bool isSafeForDish({required bool isAcidic, required double temperatureC}) {
    if (temperatureC > maxSafeTemperatureC) return false;
    if (isAcidic && acidicCompatibility == AcidicCompatibility.contraindicatedLeaching) {
      return false;
    }
    return true;
  }
}
