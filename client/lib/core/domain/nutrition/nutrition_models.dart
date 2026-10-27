// ==============================================================================
// Nutrient Earth — Nutrition Data Models
// Strictly deterministic nutritional representations tracking provenance and missing values.
// ==============================================================================

enum NutrientUnit {
  kcal,
  kj,
  gram,
  milligram,
  microgram,
  internationalUnit,
}

class ServingSize {
  final double amount;
  final String unitName;
  final double gramWeight;
  final String? householdDescription;

  const ServingSize({
    required this.amount,
    required this.unitName,
    required this.gramWeight,
    this.householdDescription,
  });

  factory ServingSize.fromJson(Map<String, dynamic> json) {
    return ServingSize(
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unitName: json['unitName'] as String? ?? 'serving',
      gramWeight: (json['gramWeight'] as num?)?.toDouble() ?? 100.0,
      householdDescription: json['householdDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'unitName': unitName,
        'gramWeight': gramWeight,
        'householdDescription': householdDescription,
      };
}

class MacronutrientProfile {
  final double proteinGrams;
  final double totalCarbsGrams;
  final double dietaryFiberGrams;
  final double totalFatGrams;
  final double? saturatedFatGrams;
  final double? monounsaturatedFatGrams;
  final double? polyunsaturatedFatGrams;

  const MacronutrientProfile({
    required this.proteinGrams,
    required this.totalCarbsGrams,
    required this.dietaryFiberGrams,
    required this.totalFatGrams,
    this.saturatedFatGrams,
    this.monounsaturatedFatGrams,
    this.polyunsaturatedFatGrams,
  });

  /// Net carbohydrates calculated deterministically: Total Carbs - Dietary Fiber.
  /// Enforces a non-negative floor in case of data reporting variances.
  double get netCarbsGrams {
    final net = totalCarbsGrams - dietaryFiberGrams;
    return net < 0.0 ? 0.0 : net;
  }

  factory MacronutrientProfile.fromJson(Map<String, dynamic> json) {
    return MacronutrientProfile(
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      totalCarbsGrams: (json['totalCarbsGrams'] as num?)?.toDouble() ?? 0.0,
      dietaryFiberGrams: (json['dietaryFiberGrams'] as num?)?.toDouble() ?? 0.0,
      totalFatGrams: (json['totalFatGrams'] as num?)?.toDouble() ?? 0.0,
      saturatedFatGrams: (json['saturatedFatGrams'] as num?)?.toDouble(),
      monounsaturatedFatGrams: (json['monounsaturatedFatGrams'] as num?)?.toDouble(),
      polyunsaturatedFatGrams: (json['polyunsaturatedFatGrams'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'proteinGrams': proteinGrams,
        'totalCarbsGrams': totalCarbsGrams,
        'dietaryFiberGrams': dietaryFiberGrams,
        'totalFatGrams': totalFatGrams,
        'saturatedFatGrams': saturatedFatGrams,
        'monounsaturatedFatGrams': monounsaturatedFatGrams,
        'polyunsaturatedFatGrams': polyunsaturatedFatGrams,
        'netCarbsGrams': netCarbsGrams,
      };
}

class MicronutrientMeasurement {
  final String nutrientName;
  final double amount;
  final NutrientUnit unit;
  final double? percentDailyValue;

  const MicronutrientMeasurement({
    required this.nutrientName,
    required this.amount,
    required this.unit,
    this.percentDailyValue,
  });

  factory MicronutrientMeasurement.fromJson(Map<String, dynamic> json) {
    return MicronutrientMeasurement(
      nutrientName: json['nutrientName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: _parseUnit(json['unit'] as String?),
      percentDailyValue: (json['percentDailyValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nutrientName': nutrientName,
        'amount': amount,
        'unit': unit.name,
        'percentDailyValue': percentDailyValue,
      };

  static NutrientUnit _parseUnit(String? raw) {
    if (raw == null) return NutrientUnit.milligram;
    for (final unit in NutrientUnit.values) {
      if (unit.name.toLowerCase() == raw.toLowerCase()) return unit;
    }
    return NutrientUnit.milligram;
  }
}

class NutritionDataProvenance {
  final String sourceDatabase;
  final String? fdcIdOrExternalCode;
  final String citationOrStandard;
  final DateTime verifiedAt;

  const NutritionDataProvenance({
    required this.sourceDatabase,
    this.fdcIdOrExternalCode,
    required this.citationOrStandard,
    required this.verifiedAt,
  });

  factory NutritionDataProvenance.fromJson(Map<String, dynamic> json) {
    return NutritionDataProvenance(
      sourceDatabase: json['sourceDatabase'] as String? ?? 'USDA FoodData Central SR-Legacy Archive',
      fdcIdOrExternalCode: json['fdcIdOrExternalCode'] as String?,
      citationOrStandard: json['citationOrStandard'] as String? ?? 'Standard Reference Analytical Tables',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceDatabase': sourceDatabase,
        'fdcIdOrExternalCode': fdcIdOrExternalCode,
        'citationOrStandard': citationOrStandard,
        'verifiedAt': verifiedAt.toIso8601String(),
      };
}

class NutritionAnalysisProfile {
  final String foodItemName;
  final ServingSize servingSize;
  final double caloriesKcal;
  final MacronutrientProfile macronutrients;
  final List<MicronutrientMeasurement> micronutrients;
  final List<String> missingOrUnreportedNutrients;
  final NutritionDataProvenance provenance;
  final String? culinaryNotes;

  const NutritionAnalysisProfile({
    required this.foodItemName,
    required this.servingSize,
    required this.caloriesKcal,
    required this.macronutrients,
    this.micronutrients = const [],
    this.missingOrUnreportedNutrients = const [],
    required this.provenance,
    this.culinaryNotes,
  });

  factory NutritionAnalysisProfile.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysisProfile(
      foodItemName: json['foodItemName'] as String? ?? 'Whole Food Item',
      servingSize: ServingSize.fromJson(json['servingSize'] as Map<String, dynamic>? ?? {}),
      caloriesKcal: (json['caloriesKcal'] as num?)?.toDouble() ?? 0.0,
      macronutrients: MacronutrientProfile.fromJson(json['macronutrients'] as Map<String, dynamic>? ?? {}),
      micronutrients: (json['micronutrients'] as List<dynamic>?)
              ?.map((m) => MicronutrientMeasurement.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      missingOrUnreportedNutrients: (json['missingOrUnreportedNutrients'] as List<dynamic>?)
              ?.map((n) => n.toString())
              .toList() ??
          const [],
      provenance: NutritionDataProvenance.fromJson(json['provenance'] as Map<String, dynamic>? ?? {}),
      culinaryNotes: json['culinaryNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'foodItemName': foodItemName,
        'servingSize': servingSize.toJson(),
        'caloriesKcal': caloriesKcal,
        'macronutrients': macronutrients.toJson(),
        'micronutrients': micronutrients.map((m) => m.toJson()).toList(),
        'missingOrUnreportedNutrients': missingOrUnreportedNutrients,
        'provenance': provenance.toJson(),
        'culinaryNotes': culinaryNotes,
      };
}
