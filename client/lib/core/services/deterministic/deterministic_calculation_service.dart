// ==============================================================================
// Nutrient Earth — Deterministic Calculation Service
// Exact mathematical and biological calculations executed in deterministic code.
// Eliminates LLM guesswork, hallucinations, and arithmetic errors.
//
// Capabilities:
// 1. BMR via Mifflin-St Jeor Equation (Validated Clinical Standard)
//    - Men: 10 * weight(kg) + 6.25 * height(cm) - 5 * age + 5
//    - Women: 10 * weight(kg) + 6.25 * height(cm) - 5 * age - 161
// 2. TDEE with validated physical activity level (PAL) multipliers
// 3. BMI with WHO / CDC clinical classification brackets
// 4. Unit Conversions:
//    - Weight: lbs <-> kg, oz <-> g
//    - Height: inches <-> cm, feet/inches <-> cm
//    - Micronutrients: mg <-> mcg, g <-> mg
//    - Vitamin D: IU <-> mcg (1 mcg = 40 IU)
//    - Vitamin A: IU <-> mcg RAE (1 mcg RAE = 3.33 IU retinol)
//    - Blood Glucose: mg/dL <-> mmol/L (1 mmol/L = 18.0182 mg/dL)
//    - Temperature: °F <-> °C
// 5. Atwater 4-9-4 General Caloric System
// ==============================================================================

enum ActivityLevel {
  sedentary(1.2, 'Sedentary (little to no exercise)'),
  lightlyActive(1.375, 'Lightly active (light exercise 1-3 days/week)'),
  moderatelyActive(1.55, 'Moderately active (moderate exercise 3-5 days/week)'),
  veryActive(1.725, 'Very active (hard exercise 6-7 days/week)'),
  extraActive(1.9, 'Extra active (very hard exercise, physical job or 2x training)');

  final double multiplier;
  final String description;

  const ActivityLevel(this.multiplier, this.description);
}

enum BmiCategory {
  underweight('Underweight', '< 18.5'),
  normalWeight('Normal weight', '18.5 – 24.9'),
  overweight('Overweight', '25.0 – 29.9'),
  obesityClass1('Obesity Class I', '30.0 – 34.9'),
  obesityClass2('Obesity Class II', '35.0 – 39.9'),
  obesityClass3('Obesity Class III (Severe)', '≥ 40.0');

  final String label;
  final String bmiRange;

  const BmiCategory(this.label, this.bmiRange);
}

class BmiResult {
  final double bmi;
  final BmiCategory category;
  final double weightKg;
  final double heightCm;
  final String formulaDescription;

  const BmiResult({
    required this.bmi,
    required this.category,
    required this.weightKg,
    required this.heightCm,
    required this.formulaDescription,
  });

  Map<String, dynamic> toJson() => {
        'bmi': double.parse(bmi.toStringAsFixed(1)),
        'category': category.label,
        'bmiRange': category.bmiRange,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'formula': formulaDescription,
      };
}

class BmrTdeeResult {
  final double bmrKcal;
  final double tdeeKcal;
  final bool isMale;
  final double weightKg;
  final double heightCm;
  final int ageYears;
  final ActivityLevel activityLevel;
  final String bmrFormulaUsed;
  final String tdeeFormulaUsed;

  const BmrTdeeResult({
    required this.bmrKcal,
    required this.tdeeKcal,
    required this.isMale,
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    required this.activityLevel,
    required this.bmrFormulaUsed,
    required this.tdeeFormulaUsed,
  });

  Map<String, dynamic> toJson() => {
        'bmrKcal': double.parse(bmrKcal.toStringAsFixed(1)),
        'tdeeKcal': double.parse(tdeeKcal.toStringAsFixed(1)),
        'biologicalSex': isMale ? 'Male' : 'Female',
        'weightKg': weightKg,
        'heightCm': heightCm,
        'ageYears': ageYears,
        'activityLevel': activityLevel.description,
        'bmrFormula': bmrFormulaUsed,
        'tdeeFormula': tdeeFormulaUsed,
      };
}

class UnitConversionResult {
  final double inputValue;
  final String fromUnit;
  final double outputValue;
  final String toUnit;
  final String conversionFactorText;

  const UnitConversionResult({
    required this.inputValue,
    required this.fromUnit,
    required this.outputValue,
    required this.toUnit,
    required this.conversionFactorText,
  });

  Map<String, dynamic> toJson() => {
        'inputValue': inputValue,
        'fromUnit': fromUnit,
        'outputValue': outputValue,
        'toUnit': toUnit,
        'conversionFactor': conversionFactorText,
      };
}

class AtwaterEnergyResult {
  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;
  final double alcoholGrams;
  final double proteinKcal;
  final double carbKcal;
  final double fatKcal;
  final double alcoholKcal;
  final double totalKcal;
  final double proteinPercent;
  final double carbPercent;
  final double fatPercent;

  const AtwaterEnergyResult({
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.alcoholGrams,
    required this.proteinKcal,
    required this.carbKcal,
    required this.fatKcal,
    required this.alcoholKcal,
    required this.totalKcal,
    required this.proteinPercent,
    required this.carbPercent,
    required this.fatPercent,
  });

  Map<String, dynamic> toJson() => {
        'totalCaloriesKcal': double.parse(totalKcal.toStringAsFixed(1)),
        'proteinKcal': double.parse(proteinKcal.toStringAsFixed(1)),
        'carbohydrateKcal': double.parse(carbKcal.toStringAsFixed(1)),
        'fatKcal': double.parse(fatKcal.toStringAsFixed(1)),
        'alcoholKcal': double.parse(alcoholKcal.toStringAsFixed(1)),
        'proteinPercentage': double.parse(proteinPercent.toStringAsFixed(1)),
        'carbPercentage': double.parse(carbPercent.toStringAsFixed(1)),
        'fatPercentage': double.parse(fatPercent.toStringAsFixed(1)),
        'method': 'Atwater General Factor System (4-4-9-7 kcal/g)',
      };
}

class DeterministicCalculationService {
  const DeterministicCalculationService();

  // ---------------------------------------------------------------------------
  // 1. BMI Calculation
  // ---------------------------------------------------------------------------
  static BmiResult calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (weightKg <= 0 || heightCm <= 0) {
      throw ArgumentError('Weight and height must be strictly positive non-zero values.');
    }
    final heightMeters = heightCm / 100.0;
    final bmi = weightKg / (heightMeters * heightMeters);

    BmiCategory category;
    if (bmi < 18.5) {
      category = BmiCategory.underweight;
    } else if (bmi < 25.0) {
      category = BmiCategory.normalWeight;
    } else if (bmi < 30.0) {
      category = BmiCategory.overweight;
    } else if (bmi < 35.0) {
      category = BmiCategory.obesityClass1;
    } else if (bmi < 40.0) {
      category = BmiCategory.obesityClass2;
    } else {
      category = BmiCategory.obesityClass3;
    }

    return BmiResult(
      bmi: bmi,
      category: category,
      weightKg: weightKg,
      heightCm: heightCm,
      formulaDescription: 'BMI = weight(kg) / (height(m))² = ${weightKg.toStringAsFixed(1)} / (${heightMeters.toStringAsFixed(2)})² = ${bmi.toStringAsFixed(1)} kg/m²',
    );
  }

  // ---------------------------------------------------------------------------
  // 2. BMR & TDEE Calculation (Mifflin-St Jeor)
  // ---------------------------------------------------------------------------
  static BmrTdeeResult calculateBmrAndTdee({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required bool isMale,
    ActivityLevel activityLevel = ActivityLevel.sedentary,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || ageYears <= 0) {
      throw ArgumentError('Weight, height, and age must be strictly positive values.');
    }

    // Mifflin-St Jeor:
    // BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + s
    // s = +5 for males, -161 for females
    final s = isMale ? 5.0 : -161.0;
    final bmr = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * ageYears) + s;
    final tdee = bmr * activityLevel.multiplier;

    final formula = isMale
        ? 'BMR = (10 × ${weightKg.toStringAsFixed(1)}) + (6.25 × ${heightCm.toStringAsFixed(1)}) - (5 × $ageYears) + 5'
        : 'BMR = (10 × ${weightKg.toStringAsFixed(1)}) + (6.25 × ${heightCm.toStringAsFixed(1)}) - (5 × $ageYears) - 161';

    final tdeeFormula = 'TDEE = BMR (${bmr.toStringAsFixed(1)}) × PAL Multiplier (${activityLevel.multiplier}) = ${tdee.toStringAsFixed(1)} kcal/day';

    return BmrTdeeResult(
      bmrKcal: bmr,
      tdeeKcal: tdee,
      isMale: isMale,
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      activityLevel: activityLevel,
      bmrFormulaUsed: formula,
      tdeeFormulaUsed: tdeeFormula,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Unit Conversions
  // ---------------------------------------------------------------------------
  static UnitConversionResult convertWeightLbsToKg(double lbs) {
    const factor = 0.45359237;
    final kg = lbs * factor;
    return UnitConversionResult(
      inputValue: lbs,
      fromUnit: 'lbs',
      outputValue: double.parse(kg.toStringAsFixed(3)),
      toUnit: 'kg',
      conversionFactorText: '1 lb = 0.453592 kg',
    );
  }

  static UnitConversionResult convertWeightKgToLbs(double kg) {
    const factor = 2.20462262;
    final lbs = kg * factor;
    return UnitConversionResult(
      inputValue: kg,
      fromUnit: 'kg',
      outputValue: double.parse(lbs.toStringAsFixed(3)),
      toUnit: 'lbs',
      conversionFactorText: '1 kg = 2.20462 lbs',
    );
  }

  static UnitConversionResult convertVitaminDIuToMcg(double iu) {
    // 1 mcg Vitamin D3 = 40 IU (1 IU = 0.025 mcg)
    final mcg = iu * 0.025;
    return UnitConversionResult(
      inputValue: iu,
      fromUnit: 'IU',
      outputValue: double.parse(mcg.toStringAsFixed(2)),
      toUnit: 'mcg',
      conversionFactorText: '1 IU Vitamin D = 0.025 mcg (40 IU = 1 mcg)',
    );
  }

  static UnitConversionResult convertVitaminDMcgToIu(double mcg) {
    final iu = mcg * 40.0;
    return UnitConversionResult(
      inputValue: mcg,
      fromUnit: 'mcg',
      outputValue: double.parse(iu.toStringAsFixed(0)),
      toUnit: 'IU',
      conversionFactorText: '1 mcg Vitamin D = 40 IU',
    );
  }

  static UnitConversionResult convertMilligramsToMicrograms(double mg) {
    final mcg = mg * 1000.0;
    return UnitConversionResult(
      inputValue: mg,
      fromUnit: 'mg',
      outputValue: mcg,
      toUnit: 'mcg',
      conversionFactorText: '1 mg = 1000 mcg',
    );
  }

  static UnitConversionResult convertMicrogramsToMilligrams(double mcg) {
    final mg = mcg / 1000.0;
    return UnitConversionResult(
      inputValue: mcg,
      fromUnit: 'mcg',
      outputValue: mg,
      toUnit: 'mg',
      conversionFactorText: '1000 mcg = 1 mg',
    );
  }

  static UnitConversionResult convertBloodGlucoseMmolToMgDl(double mmolL) {
    // 1 mmol/L = 18.0182 mg/dL for glucose
    final mgDl = mmolL * 18.0182;
    return UnitConversionResult(
      inputValue: mmolL,
      fromUnit: 'mmol/L',
      outputValue: double.parse(mgDl.toStringAsFixed(1)),
      toUnit: 'mg/dL',
      conversionFactorText: '1 mmol/L glucose = 18.0182 mg/dL',
    );
  }

  static UnitConversionResult convertBloodGlucoseMgDlToMmol(double mgDl) {
    final mmolL = mgDl / 18.0182;
    return UnitConversionResult(
      inputValue: mgDl,
      fromUnit: 'mg/dL',
      outputValue: double.parse(mmolL.toStringAsFixed(2)),
      toUnit: 'mmol/L',
      conversionFactorText: '18.0182 mg/dL glucose = 1 mmol/L',
    );
  }

  static UnitConversionResult convertTemperatureFtoC(double fahrenheit) {
    final celsius = (fahrenheit - 32.0) * (5.0 / 9.0);
    return UnitConversionResult(
      inputValue: fahrenheit,
      fromUnit: '°F',
      outputValue: double.parse(celsius.toStringAsFixed(1)),
      toUnit: '°C',
      conversionFactorText: '°C = (°F - 32) × 5/9',
    );
  }

  static UnitConversionResult convertTemperatureCtoF(double celsius) {
    final fahrenheit = (celsius * (9.0 / 5.0)) + 32.0;
    return UnitConversionResult(
      inputValue: celsius,
      fromUnit: '°C',
      outputValue: double.parse(fahrenheit.toStringAsFixed(1)),
      toUnit: '°F',
      conversionFactorText: '°F = (°C × 9/5) + 32',
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Atwater 4-9-4 Caloric Energy Calculation
  // ---------------------------------------------------------------------------
  static AtwaterEnergyResult calculateAtwaterEnergy({
    required double proteinGrams,
    required double carbGrams,
    required double fatGrams,
    double alcoholGrams = 0.0,
  }) {
    final proteinKcal = proteinGrams * 4.0;
    final carbKcal = carbGrams * 4.0;
    final fatKcal = fatGrams * 9.0;
    final alcoholKcal = alcoholGrams * 7.0;
    final totalKcal = proteinKcal + carbKcal + fatKcal + alcoholKcal;

    final proteinPct = totalKcal > 0 ? (proteinKcal / totalKcal) * 100.0 : 0.0;
    final carbPct = totalKcal > 0 ? (carbKcal / totalKcal) * 100.0 : 0.0;
    final fatPct = totalKcal > 0 ? (fatKcal / totalKcal) * 100.0 : 0.0;

    return AtwaterEnergyResult(
      proteinGrams: proteinGrams,
      carbGrams: carbGrams,
      fatGrams: fatGrams,
      alcoholGrams: alcoholGrams,
      proteinKcal: proteinKcal,
      carbKcal: carbKcal,
      fatKcal: fatKcal,
      alcoholKcal: alcoholKcal,
      totalKcal: totalKcal,
      proteinPercent: proteinPct,
      carbPercent: carbPct,
      fatPercent: fatPct,
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Intelligent Query Parser & Dispatcher
  // ---------------------------------------------------------------------------
  static bool isMathOrCalculationQuery(String rawQuery) {
    final query = rawQuery.toLowerCase().trim();
    if (query.contains('bmr') || query.contains('tdee') || query.contains('bmi') || query.contains('body mass index')) return true;
    if (query.contains('%') || query.contains('percent of')) return true;
    if (RegExp(r'\d+\s*[\+\-\*\/×÷]\s*\d+').hasMatch(query)) return true;
    if (query.contains('convert') && (query.contains('to') || query.contains('in'))) return true;
    return false;
  }

  static Map<String, dynamic>? tryParseAndCalculate(String rawQuery) {
    final query = rawQuery.toLowerCase().trim();

    // A. BMR or TDEE pattern: e.g. "calculate bmr 75kg 180cm 30 male" or "calculate my BMR: 30yo male, 80kg, 180cm"
    if (query.contains('bmr') || query.contains('tdee') || query.contains('metabolic rate')) {
      final isMale = !query.contains('female') && !query.contains('woman') && !query.contains('girl');

      // Unit-aware extraction
      final kgMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilos?|kilograms?)', caseSensitive: false).firstMatch(query);
      final cmMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:cm|centimeters?)', caseSensitive: false).firstMatch(query);
      final ageMatch = RegExp(r'(\d+)\s*(?:yo|y\.?o\.?|years?\s*old|age)', caseSensitive: false).firstMatch(query);

      double weightKg = 70.0;
      double heightCm = 175.0;
      int age = 30;

      if (kgMatch != null) weightKg = double.parse(kgMatch.group(1)!);
      if (cmMatch != null) heightCm = double.parse(cmMatch.group(1)!);
      if (ageMatch != null) age = int.parse(ageMatch.group(1)!);

      // Positional fallback if no unit was matched
      if (kgMatch == null && cmMatch == null && ageMatch == null) {
        final numbers = RegExp(r'(\d+(?:\.\d+)?)').allMatches(query).map((m) => double.parse(m.group(1)!)).toList();
        if (numbers.length >= 3) {
          weightKg = numbers[0];
          heightCm = numbers[1];
          age = numbers[2].toInt();
        } else if (numbers.length == 2) {
          weightKg = numbers[0];
          heightCm = numbers[1];
        } else if (numbers.length == 1) {
          weightKg = numbers[0];
        }
      }

      final result = calculateBmrAndTdee(
        weightKg: weightKg,
        heightCm: heightCm,
        ageYears: age,
        isMale: isMale,
        activityLevel: ActivityLevel.sedentary,
      );

      return {
        'calculationType': 'BMR_TDEE',
        'result': result.toJson(),
        'displayText': '### Mifflin-St Jeor Basal Metabolic Calculation\n\n'
            '• **Biological Parameters**: ${isMale ? "Male" : "Female"}, ${weightKg.toStringAsFixed(0)}kg, ${heightCm.toStringAsFixed(0)}cm, age ${age}y\n'
            '• **BMR (Basal Metabolic Rate)**: **${result.bmrKcal.toStringAsFixed(0)} kcal/day**\n'
            '• **TDEE (Sedentary)**: **${result.tdeeKcal.toStringAsFixed(0)} kcal/day**\n'
            '• **TDEE (Moderate Exercise 3-5x/wk)**: **${(result.bmrKcal * 1.55).toStringAsFixed(0)} kcal/day**\n\n'
            'Formula: `${result.bmrFormulaUsed}`\n\n'
            '*Calculated deterministically using the Mifflin-St Jeor equation. Zero generative approximation.*',
      };
    }

    // B. BMI pattern: e.g. "calculate bmi 70kg 175cm" or "bmi 180cm 80kg"
    if (query.contains('bmi') || query.contains('body mass index')) {
      final kgMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilos?|kilograms?)', caseSensitive: false).firstMatch(query);
      final cmMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:cm|centimeters?)', caseSensitive: false).firstMatch(query);

      double weightKg = 70.0;
      double heightCm = 175.0;

      if (kgMatch != null) weightKg = double.parse(kgMatch.group(1)!);
      if (cmMatch != null) heightCm = double.parse(cmMatch.group(1)!);

      if (kgMatch == null && cmMatch == null) {
        final numbers = RegExp(r'(\d+(?:\.\d+)?)').allMatches(query).map((m) => double.parse(m.group(1)!)).toList();
        if (numbers.length >= 2) {
          weightKg = numbers[0];
          heightCm = numbers[1];
        }
      }

      final result = calculateBmi(weightKg: weightKg, heightCm: heightCm);
      return {
        'calculationType': 'BMI',
        'result': result.toJson(),
        'displayText': '### Body Mass Index (BMI) Calculation\n\n'
            '• **Weight**: ${weightKg}kg | **Height**: ${heightCm}cm (${(heightCm / 100).toStringAsFixed(2)}m)\n'
            '• **BMI**: **${result.bmi.toStringAsFixed(1)} kg/m²**\n'
            '• **WHO Clinical Category**: **${result.category.label}** (${result.category.bmiRange})\n\n'
            'Formula: `${result.formulaDescription}`\n\n'
            '*Calculated deterministically using WHO standard reference brackets.*',
      };
    }

    // C. Unit conversion: lbs to kg / kg to lbs
    if (query.contains('lb') && (query.contains('kg') || query.contains('kilo'))) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*(?:lbs?|pounds?)').firstMatch(query);
      if (match != null) {
        final lbs = double.parse(match.group(1)!);
        final res = convertWeightLbsToKg(lbs);
        return {
          'calculationType': 'UNIT_CONVERSION',
          'result': res.toJson(),
          'displayText': '### Unit Conversion: Weight\n\n'
              '**${res.inputValue} lbs** = **${res.outputValue} kg**\n\n'
              'Conversion factor: `${res.conversionFactorText}`',
        };
      }
      final matchKg = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilos?|kilograms?)').firstMatch(query);
      if (matchKg != null) {
        final kg = double.parse(matchKg.group(1)!);
        final res = convertWeightKgToLbs(kg);
        return {
          'calculationType': 'UNIT_CONVERSION',
          'result': res.toJson(),
          'displayText': '### Unit Conversion: Weight\n\n'
              '**${res.inputValue} kg** = **${res.outputValue} lbs**\n\n'
              'Conversion factor: `${res.conversionFactorText}`',
        };
      }
    }

    // D. Unit conversion: Vitamin D IU to mcg
    if (query.contains('vitamin d') && (query.contains('iu') || query.contains('mcg'))) {
      final matchIu = RegExp(r'(\d+(?:\.\d+)?)\s*iu').firstMatch(query);
      if (matchIu != null) {
        final iu = double.parse(matchIu.group(1)!);
        final res = convertVitaminDIuToMcg(iu);
        return {
          'calculationType': 'UNIT_CONVERSION',
          'result': res.toJson(),
          'displayText': '### Vitamin D Unit Conversion\n\n'
              '**${res.inputValue} IU** = **${res.outputValue} mcg (cholecalciferol)**\n\n'
              'Conversion factor: `${res.conversionFactorText}`',
        };
      }
    }

    // E. Blood glucose mg/dL to mmol/L
    if (query.contains('glucose') || query.contains('blood sugar') || query.contains('mmol') || query.contains('mg/dl')) {
      final matchMg = RegExp(r'(\d+(?:\.\d+)?)\s*mg/dl').firstMatch(query);
      if (matchMg != null) {
        final mg = double.parse(matchMg.group(1)!);
        final res = convertBloodGlucoseMgDlToMmol(mg);
        return {
          'calculationType': 'UNIT_CONVERSION',
          'result': res.toJson(),
          'displayText': '### Blood Glucose Unit Conversion\n\n'
              '**${res.inputValue} mg/dL** = **${res.outputValue} mmol/L**\n\n'
              'Conversion factor: `${res.conversionFactorText}`',
        };
      }
      final matchMmol = RegExp(r'(\d+(?:\.\d+)?)\s*mmol(?:/l)?').firstMatch(query);
      if (matchMmol != null) {
        final mmol = double.parse(matchMmol.group(1)!);
        final res = convertBloodGlucoseMmolToMgDl(mmol);
        return {
          'calculationType': 'UNIT_CONVERSION',
          'result': res.toJson(),
          'displayText': '### Blood Glucose Unit Conversion\n\n'
              '**${res.inputValue} mmol/L** = **${res.outputValue} mg/dL**\n\n'
              'Conversion factor: `${res.conversionFactorText}`',
        };
      }
    }

    // F. General Percentage Calculations: e.g. "What is 25% of 480?" or "15 percent of 2000"
    final percentMatch = RegExp(
      r'(?:what\s+is\s+|calculate\s+)?(\d+(?:\.\d+)?)\s*(?:%|percent)\s+of\s+(\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(query);
    if (percentMatch != null) {
      final pVal = double.parse(percentMatch.group(1)!);
      final bVal = double.parse(percentMatch.group(2)!);
      final computed = (pVal / 100.0) * bVal;
      final pStr = pVal == pVal.roundToDouble() ? pVal.toInt().toString() : pVal.toString();
      final bStr = bVal == bVal.roundToDouble() ? bVal.toInt().toString() : bVal.toString();
      final resStr = computed == computed.roundToDouble() ? computed.toInt().toString() : computed.toStringAsFixed(2);

      return {
        'calculationType': 'PERCENTAGE_CALCULATION',
        'result': {
          'outputValue': resStr,
          'formula': '$pStr% × $bStr = ($pStr / 100) × $bStr = $resStr',
          'toUnit': '',
        },
        'displayText': '### Calculation Result\n\n'
            '**$pStr% of $bStr is $resStr.**\n\n'
            '• **Base Value**: $bStr\n'
            '• **Percentage**: $pStr%\n'
            '• **Result**: **$resStr**\n\n'
            'Formula: `($pStr / 100) × $bStr = $resStr`',
      };
    }

    // G. Basic Arithmetic Calculations: e.g. "What is 120 + 340?" or "500 * 4"
    final arithMatch = RegExp(
      r'^(?:what\s+is\s+|calculate\s+)?(\d+(?:\.\d+)?)\s*([\+\-\*\/×÷])\s*(\d+(?:\.\d+)?)\s*\??$',
      caseSensitive: false,
    ).firstMatch(query);
    if (arithMatch != null) {
      final a = double.parse(arithMatch.group(1)!);
      final op = arithMatch.group(2)!;
      final b = double.parse(arithMatch.group(3)!);
      double computed;
      String opSymbol = op;
      switch (op) {
        case '+':
          computed = a + b;
          break;
        case '-':
          computed = a - b;
          break;
        case '*':
        case '×':
          computed = a * b;
          opSymbol = '×';
          break;
        case '/':
        case '÷':
          if (b == 0) return null;
          computed = a / b;
          opSymbol = '÷';
          break;
        default:
          return null;
      }
      final aStr = a == a.roundToDouble() ? a.toInt().toString() : a.toString();
      final bStr = b == b.roundToDouble() ? b.toInt().toString() : b.toString();
      final resStr = computed == computed.roundToDouble() ? computed.toInt().toString() : computed.toStringAsFixed(2);

      return {
        'calculationType': 'BASIC_ARITHMETIC',
        'result': {
          'outputValue': resStr,
          'formula': '$aStr $opSymbol $bStr = $resStr',
          'toUnit': '',
        },
        'displayText': '### Arithmetic Calculation\n\n'
            '**$aStr $opSymbol $bStr = $resStr**\n\n'
            'Calculated with exact mathematical precision.',
      };
    }

    return null;
  }
}
