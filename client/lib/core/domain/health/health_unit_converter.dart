import 'health_data_types.dart';

/// Normalizes raw metrics and disparate units from Android Health Connect
/// and Apple HealthKit into standard Nutrient Earth domain units.
/// Strictly enforces clinical plausibility: returns null for invalid, non-finite,
/// or physiologically implausible inputs instead of clamping to arbitrary values.
class HealthUnitConverter {
  const HealthUnitConverter();

  /// Normalize steps count (valid range: 0 to 200,000 steps).
  static double? normalizeSteps(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue < 0.0 || rawValue > 200000.0) {
      return null;
    }
    return rawValue.roundToDouble();
  }

  /// Normalize distance to meters (valid range: 0 to 200,000 meters).
  static double? normalizeDistanceToMeters(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue < 0.0) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inMeters;
    if (cleanUnit == 'km' || cleanUnit == 'kilometer' || cleanUnit == 'kilometres') {
      inMeters = rawValue * 1000.0;
    } else if (cleanUnit == 'mi' || cleanUnit == 'mile' || cleanUnit == 'miles') {
      inMeters = rawValue * 1609.344;
    } else if (cleanUnit == 'ft' || cleanUnit == 'feet') {
      inMeters = rawValue * 0.3048;
    } else {
      inMeters = rawValue;
    }

    if (inMeters < 0.0 || inMeters > 200000.0) return null;
    return inMeters;
  }

  /// Normalize active energy burned to kilocalories (valid range: 0 to 25,000 kcal).
  static double? normalizeCaloriesToKcal(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue < 0.0) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inKcal;
    if (cleanUnit == 'j' || cleanUnit == 'joule' || cleanUnit == 'joules') {
      inKcal = rawValue / 4184.0;
    } else if (cleanUnit == 'kj' || cleanUnit == 'kilojoule' || cleanUnit == 'kilojoules') {
      inKcal = rawValue / 4.184;
    } else if (cleanUnit == 'cal' || cleanUnit == 'calorie') {
      inKcal = rawValue / 1000.0;
    } else {
      inKcal = rawValue;
    }

    if (inKcal < 0.0 || inKcal > 25000.0) return null;
    return inKcal;
  }

  /// Normalize heart rate to beats per minute (valid physiological range: 30 to 250 bpm).
  static double? normalizeHeartRate(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue < 30.0 || rawValue > 250.0) {
      return null;
    }
    return rawValue;
  }

  /// Normalize weight to kilograms (valid physiological range: 2.0 to 450.0 kg).
  static double? normalizeWeightToKg(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue <= 0.0) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inKg;
    if (cleanUnit == 'lb' || cleanUnit == 'lbs' || cleanUnit == 'pound' || cleanUnit == 'pounds') {
      inKg = rawValue * 0.45359237;
    } else if (cleanUnit == 'st' || cleanUnit == 'stone') {
      inKg = rawValue * 6.35029;
    } else {
      inKg = rawValue;
    }

    if (inKg < 2.0 || inKg > 450.0) return null;
    return inKg;
  }

  /// Normalize height to centimeters (valid physiological range: 30.0 to 280.0 cm).
  static double? normalizeHeightToCm(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue <= 0.0) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inCm;
    if (cleanUnit == 'm' || cleanUnit == 'meter' || cleanUnit == 'meters') {
      inCm = rawValue * 100.0;
    } else if (cleanUnit == 'in' || cleanUnit == 'inch' || cleanUnit == 'inches') {
      inCm = rawValue * 2.54;
    } else if (cleanUnit == 'ft' || cleanUnit == 'foot' || cleanUnit == 'feet') {
      inCm = rawValue * 30.48;
    } else {
      inCm = rawValue;
    }

    if (inCm < 30.0 || inCm > 280.0) return null;
    return inCm;
  }

  /// Normalize blood oxygen saturation (SpO2) to percentage (valid physiological range: 60.0 to 100.0%).
  static double? normalizeBloodOxygen(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue <= 0.0) return null;
    double inPercent = rawValue;
    if (rawValue <= 1.0 && rawValue > 0.0) {
      inPercent = rawValue * 100.0;
    }
    if (inPercent < 60.0 || inPercent > 100.0) return null;
    return inPercent;
  }

  /// Normalize temperature to Celsius (valid physiological range: 30.0 to 45.0 °C).
  static double? normalizeTemperatureToCelsius(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inC;
    if (cleanUnit.contains('f') || cleanUnit == 'fahrenheit') {
      inC = (rawValue - 32.0) * (5.0 / 9.0);
    } else if (cleanUnit.contains('k') || cleanUnit == 'kelvin') {
      inC = rawValue - 273.15;
    } else {
      inC = rawValue;
    }

    if (inC < 30.0 || inC > 45.0) return null;
    return inC;
  }

  /// Normalize water volume to milliliters (valid range: 0.0 to 20,000.0 ml).
  static double? normalizeWaterToMl(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite || rawValue < 0.0) return null;
    final cleanUnit = unit.toLowerCase().trim();
    double inMl;
    if (cleanUnit == 'l' || cleanUnit == 'liter' || cleanUnit == 'liters' || cleanUnit == 'litres') {
      inMl = rawValue * 1000.0;
    } else if (cleanUnit == 'oz' || cleanUnit == 'fl_oz' || cleanUnit == 'floz') {
      inMl = rawValue * 29.5735;
    } else {
      inMl = rawValue;
    }

    if (inMl < 0.0 || inMl > 20000.0) return null;
    return inMl;
  }

  /// Helper dispatcher taking a [HealthDataType] and returning the normalized value,
  /// or null if the value is missing, non-finite, or physiologically implausible.
  static double? normalize(HealthDataType type, double? rawValue, String unit) {
    if (rawValue == null || rawValue.isNaN || rawValue.isInfinite) return null;

    switch (type) {
      case HealthDataType.steps:
        return normalizeSteps(rawValue);
      case HealthDataType.distance:
        return normalizeDistanceToMeters(rawValue, unit);
      case HealthDataType.activeCalories:
        return normalizeCaloriesToKcal(rawValue, unit);
      case HealthDataType.heartRate:
      case HealthDataType.restingHeartRate:
        return normalizeHeartRate(rawValue);
      case HealthDataType.sleep:
      case HealthDataType.workout:
        if (rawValue < 0.0 || rawValue > 1440.0) return null;
        return rawValue;
      case HealthDataType.weight:
        return normalizeWeightToKg(rawValue, unit);
      case HealthDataType.height:
        return normalizeHeightToCm(rawValue, unit);
      case HealthDataType.bloodOxygen:
        return normalizeBloodOxygen(rawValue);
      case HealthDataType.bodyTemperature:
        return normalizeTemperatureToCelsius(rawValue, unit);
      case HealthDataType.water:
        return normalizeWaterToMl(rawValue, unit);
    }
  }
}
