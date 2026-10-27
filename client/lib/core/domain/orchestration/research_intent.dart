// ==============================================================================
// Nutrient Earth — Research Intent Classification
// Deterministic intent classifier routing user inquiries to appropriate domain pipelines.
// ==============================================================================

enum ResearchIntent {
  scientificLiterature,
  nutrientAnalysis,
  supplementEvaluation,
  circadianDiurnal,
  generalWellness,
}

class ResearchIntentClassifier {
  ResearchIntentClassifier._();

  static const List<String> _nutrientKeywords = [
    'calories', 'protein', 'carbs', 'carbohydrate', 'fat', 'macronutrient', 'micronutrient',
    'fiber', 'potassium', 'calcium', 'sodium', 'serving', 'grams', 'nutrition facts',
    'plate', 'meal', 'energy density',
  ];

  static const List<String> _supplementKeywords = [
    'magnesium', 'creatine', 'ashwagandha', 'zinc', 'melatonin', 'glycinate', 'citrate',
    'oxide', 'chelate', 'supplement', 'dosage', 'bioavailability', 'nootropic',
    'omega-3', 'epa', 'dha', 'vitamin d', 'glutamine',
  ];

  static const List<String> _circadianKeywords = [
    'sleep', 'circadian', 'diurnal', 'melatonin', 'cortisol', 'morning light',
    'deep sleep', 'rem sleep', 'latency', 'sleep architecture', 'chronotype',
  ];

  static const List<String> _scientificLiteratureKeywords = [
    'study', 'trial', 'rct', 'meta-analysis', 'systematic review', 'evidence',
    'pubmed', 'pmid', 'doi', 'mechanism', 'pharmacokinetics', 'bioavailability',
  ];

  static ResearchIntent classify(String query) {
    final lower = query.toLowerCase();

    // Check nutrient analysis first if explicit food/macro tokens exist
    if (_nutrientKeywords.any((kw) => lower.contains(kw))) {
      return ResearchIntent.nutrientAnalysis;
    }

    if (_circadianKeywords.any((kw) => lower.contains(kw))) {
      return ResearchIntent.circadianDiurnal;
    }

    if (_supplementKeywords.any((kw) => lower.contains(kw))) {
      return ResearchIntent.supplementEvaluation;
    }

    if (_scientificLiteratureKeywords.any((kw) => lower.contains(kw))) {
      return ResearchIntent.scientificLiterature;
    }

    return ResearchIntent.generalWellness;
  }
}
