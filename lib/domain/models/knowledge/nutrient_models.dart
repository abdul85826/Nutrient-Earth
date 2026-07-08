class Nutrient {
  final String id;
  final String name; // 'magnesium', 'vitamin_d', etc.
  final String category; // 'mineral', 'vitamin', 'macronutrient'
  final String standardUnit; // 'mg', 'mcg', 'IU', 'g'

  Nutrient({
    required this.id,
    required this.name,
    required this.category,
    required this.standardUnit,
  });
}

class NutrientDeficiency {
  final String nutrientId;
  final List<String> associatedSymptoms;
  final List<String> associatedBiomarkers;
  final double severityImpact; // 0.0 - 1.0

  NutrientDeficiency({
    required this.nutrientId,
    required this.associatedSymptoms,
    required this.associatedBiomarkers,
    required this.severityImpact,
  });
}

class NutrientSource {
  final String nutrientId;
  final String foodName;
  final double amountPer100g;
  final double bioavailability; // 0.0 - 1.0 (how well it absorbs)

  NutrientSource({
    required this.nutrientId,
    required this.foodName,
    required this.amountPer100g,
    required this.bioavailability,
  });
}

class NutrientInteraction {
  final String primaryNutrientId;
  final String secondaryNutrientId;
  final String interactionType; // 'synergistic', 'antagonistic'
  final String description;

  NutrientInteraction({
    required this.primaryNutrientId,
    required this.secondaryNutrientId,
    required this.interactionType,
    required this.description,
  });
}

class NutrientTiming {
  final String nutrientId;
  final String optimalTimeOfDay; // 'morning', 'evening', 'post_workout'
  final bool requiresFasted;
  final bool requiresFat; // e.g., Vitamin D absorbs better with fat

  NutrientTiming({
    required this.nutrientId,
    required this.optimalTimeOfDay,
    required this.requiresFasted,
    required this.requiresFat,
  });
}
