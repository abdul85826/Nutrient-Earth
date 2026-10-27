// ==============================================================================
// Nutrient Earth — Nutrition Computation Engine
// Pure mathematical functions for energy breakdown, unit conversions, and serving scaling.
// Never fabricates missing values; explicitly logs data provenance.
// ==============================================================================

import 'nutrition_models.dart';

class MacronutrientEnergyBreakdown {
  final double proteinKcal;
  final double carbohydrateKcal;
  final double fatKcal;
  final double totalCalculatedKcal;
  final double proteinRatio;
  final double carbohydrateRatio;
  final double fatRatio;

  const MacronutrientEnergyBreakdown({
    required this.proteinKcal,
    required this.carbohydrateKcal,
    required this.fatKcal,
    required this.totalCalculatedKcal,
    required this.proteinRatio,
    required this.carbohydrateRatio,
    required this.fatRatio,
  });
}

abstract class FoodCompositionDataProvider {
  Future<NutritionAnalysisProfile?> lookupFoodItem(String query);
  Future<List<NutritionAnalysisProfile>> searchFoodItems(String query, {int limit = 10});
}

class NutritionComputationEngine {
  NutritionComputationEngine._();

  // Atwater general factor system constants
  static const double kcalPerGramProtein = 4.0;
  static const double kcalPerGramCarbohydrate = 4.0;
  static const double kcalPerGramFat = 9.0;
  static const double kjPerKcal = 4.184;

  /// Calculates deterministic caloric distribution from macronutrients using Atwater factors.
  /// Uses net (available) carbohydrates rather than total carbohydrates to avoid double-counting dietary fiber.
  static MacronutrientEnergyBreakdown calculateEnergyBreakdown(MacronutrientProfile macros) {
    final proteinKcal = macros.proteinGrams * kcalPerGramProtein;
    final carbKcal = macros.netCarbsGrams * kcalPerGramCarbohydrate;
    final fatKcal = macros.totalFatGrams * kcalPerGramFat;
    final total = proteinKcal + carbKcal + fatKcal;

    if (total <= 0.0) {
      return const MacronutrientEnergyBreakdown(
        proteinKcal: 0.0,
        carbohydrateKcal: 0.0,
        fatKcal: 0.0,
        totalCalculatedKcal: 0.0,
        proteinRatio: 0.0,
        carbohydrateRatio: 0.0,
        fatRatio: 0.0,
      );
    }

    return MacronutrientEnergyBreakdown(
      proteinKcal: proteinKcal,
      carbohydrateKcal: carbKcal,
      fatKcal: fatKcal,
      totalCalculatedKcal: total,
      proteinRatio: proteinKcal / total,
      carbohydrateRatio: carbKcal / total,
      fatRatio: fatKcal / total,
    );
  }

  /// Converts between mass and energy units deterministically.
  static double convertUnit({
    required double value,
    required NutrientUnit from,
    required NutrientUnit to,
  }) {
    if (from == to) return value;

    // Mass conversions
    if (_isMassUnit(from) && _isMassUnit(to)) {
      final grams = _toGrams(value, from);
      return _fromGrams(grams, to);
    }

    // Energy conversions
    if (from == NutrientUnit.kcal && to == NutrientUnit.kj) {
      return value * kjPerKcal;
    }
    if (from == NutrientUnit.kj && to == NutrientUnit.kcal) {
      return value / kjPerKcal;
    }

    throw ArgumentError('Incompatible unit conversion from ${from.name} to ${to.name}.');
  }

  /// Scales a nutrition profile linearly to a target gram weight.
  static NutritionAnalysisProfile scaleToGramWeight(
    NutritionAnalysisProfile profile,
    double targetGramWeight,
  ) {
    if (targetGramWeight <= 0.0) {
      throw ArgumentError('Target gram weight must be strictly positive.');
    }

    final originalGrams = profile.servingSize.gramWeight;
    if (originalGrams <= 0.0) {
      throw StateError('Original profile serving gram weight is invalid: $originalGrams');
    }

    final factor = targetGramWeight / originalGrams;

    final scaledMacros = MacronutrientProfile(
      proteinGrams: _round(profile.macronutrients.proteinGrams * factor),
      totalCarbsGrams: _round(profile.macronutrients.totalCarbsGrams * factor),
      dietaryFiberGrams: _round(profile.macronutrients.dietaryFiberGrams * factor),
      totalFatGrams: _round(profile.macronutrients.totalFatGrams * factor),
      saturatedFatGrams: profile.macronutrients.saturatedFatGrams != null
          ? _round(profile.macronutrients.saturatedFatGrams! * factor)
          : null,
      monounsaturatedFatGrams: profile.macronutrients.monounsaturatedFatGrams != null
          ? _round(profile.macronutrients.monounsaturatedFatGrams! * factor)
          : null,
      polyunsaturatedFatGrams: profile.macronutrients.polyunsaturatedFatGrams != null
          ? _round(profile.macronutrients.polyunsaturatedFatGrams! * factor)
          : null,
    );

    final scaledMicros = profile.micronutrients.map((m) {
      return MicronutrientMeasurement(
        nutrientName: m.nutrientName,
        amount: _round(m.amount * factor),
        unit: m.unit,
        percentDailyValue: m.percentDailyValue != null ? _round(m.percentDailyValue! * factor) : null,
      );
    }).toList();

    return NutritionAnalysisProfile(
      foodItemName: profile.foodItemName,
      servingSize: ServingSize(
        amount: _round(profile.servingSize.amount * factor),
        unitName: profile.servingSize.unitName,
        gramWeight: targetGramWeight,
        householdDescription: profile.servingSize.householdDescription,
      ),
      caloriesKcal: _round(profile.caloriesKcal * factor),
      macronutrients: scaledMacros,
      micronutrients: scaledMicros,
      missingOrUnreportedNutrients: List.unmodifiable(profile.missingOrUnreportedNutrients),
      provenance: profile.provenance,
      culinaryNotes: profile.culinaryNotes,
    );
  }

  static bool _isMassUnit(NutrientUnit unit) {
    return unit == NutrientUnit.gram || unit == NutrientUnit.milligram || unit == NutrientUnit.microgram;
  }

  static double _toGrams(double value, NutrientUnit unit) {
    switch (unit) {
      case NutrientUnit.gram:
        return value;
      case NutrientUnit.milligram:
        return value / 1000.0;
      case NutrientUnit.microgram:
        return value / 1000000.0;
      default:
        throw ArgumentError('Not a mass unit: $unit');
    }
  }

  static double _fromGrams(double grams, NutrientUnit unit) {
    switch (unit) {
      case NutrientUnit.gram:
        return grams;
      case NutrientUnit.milligram:
        return grams * 1000.0;
      case NutrientUnit.microgram:
        return grams * 1000000.0;
      default:
        throw ArgumentError('Not a mass unit: $unit');
    }
  }

  static double _round(double val, {int decimals = 2}) {
    return double.parse(val.toStringAsFixed(decimals));
  }
}
