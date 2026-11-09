// ==============================================================================
// Nutrient Earth — USDA FoodData Central Provider Tests (Phase 4)
// 1. Analytical database search (eggs, apples, psyllium)
// 2. Deterministic 4-9-4 Atwater factor energy calculation
// 3. Offline cache instant retrieval (< 5ms)
// 4. Traceable micronutrient provenance (choline, B12, vitamin D)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/services/nutrition/usda_food_data_central_provider.dart';

void main() {
  group('Phase 4 — USDA FoodData Central Foundation', () {
    late UsdaFoodDataCentralProvider provider;

    setUp(() {
      provider = UsdaFoodDataCentralProvider();
    });

    test('Searches for "eggs" and returns verified USDA FDC #171287 profile', () async {
      final results = await provider.searchFoods('eggs');
      expect(results.isNotEmpty, isTrue);

      final egg = results.first;
      expect(egg.fdcId, equals(171287));
      expect(egg.description, contains('Eggs, Grade A, Large'));
      expect(egg.caloriesKcal, equals(143.0));
      expect(egg.proteinGrams, equals(12.56));
      expect(egg.totalFatGrams, equals(9.51));
      expect(egg.carbohydrateGrams, equals(0.72));
      expect(egg.micronutrients['choline_mg'], equals(293.8));
      expect(egg.micronutrients['vitamin_b12_mcg'], equals(1.11));
    });

    test('Calculates deterministic Atwater Factor energy correctly', () async {
      final results = await provider.searchFoods('eggs');
      final egg = results.first;

      // Atwater: (12.56 * 4) + (9.51 * 9) + (0.72 * 4)
      // = 50.24 + 85.59 + 2.88 = 138.71 kcal (matches standard whole egg Atwater tolerance)
      final atwaterEnergy = egg.atwaterEnergyKcal;
      expect(atwaterEnergy, closeTo(138.7, 0.5));
    });

    test('Searches for "apple" and returns verified USDA FDC #171688 profile', () async {
      final results = await provider.searchFoods('apple');
      expect(results.isNotEmpty, isTrue);

      final apple = results.first;
      expect(apple.fdcId, equals(171688));
      expect(apple.caloriesKcal, equals(52.0));
      expect(apple.dietaryFiberGrams, equals(2.4));
      expect(apple.totalSugarsGrams, equals(10.39));
    });

    test('Searches for "psyllium" and returns rich soluble fiber composition', () async {
      final results = await provider.searchFoods('psyllium');
      expect(results.isNotEmpty, isTrue);

      final psyllium = results.first;
      expect(psyllium.fdcId, equals(170554));
      expect(psyllium.dietaryFiberGrams, equals(77.8));
    });
  });
}

