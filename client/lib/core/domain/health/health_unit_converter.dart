import 'health_data_types.dart';

/// Normalizes raw metrics and disparate units from Android Health Connect
/// and Apple HealthKit into standard Nutrient Earth domain units.
class HealthUnitConverter {
  const HealthUnitConverter();

  /// Normalize steps count (always non-negative integer count).
  static double normalizeSteps(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    return rawValue.clamp(0.0, 500000.0).roundToDouble();
  }

  /// Normalize distance to meters.
  /// Converts kilometers, miles, or feet to meters if specified.
  static double normalizeDistanceToMeters(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit == 'km' || cleanUnit == 'kilometer' || cleanUnit == 'kilometres') {
      return (rawValue * 1000.0).clamp(0.0, 500000.0);
    } else if (cleanUnit == 'mi' || cleanUnit == 'mile' || cleanUnit == 'miles') {
      return (rawValue * 1609.344).clamp(0.0, 500000.0);
    } else if (cleanUnit == 'ft' || cleanUnit == 'feet') {
      return (rawValue * 0.3048).clamp(0.0, 500000.0);
    }
    // Default assumed meters
    return rawValue.clamp(0.0, 500000.0);
  }

  /// Normalize active or total energy burned to kilocalories (kcal).
  /// Converts Joules or Kilojoules to kcal if needed.
  static double normalizeCaloriesToKcal(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit == 'j' || cleanUnit == 'joule' || cleanUnit == 'joules') {
      return (rawValue / 4184.0).clamp(0.0, 50000.0);
    } else if (cleanUnit == 'kj' || cleanUnit == 'kilojoule' || cleanUnit == 'kilojoules') {
      return (rawValue / 4.184).clamp(0.0, 50000.0);
    } else if (cleanUnit == 'cal' || cleanUnit == 'calorie') {
      return (rawValue / 1000.0).clamp(0.0, 50000.0);
    }
    // Assumed kcal
    return rawValue.clamp(0.0, 50000.0);
  }

  /// Normalize heart rate to beats per minute (bpm).
  static double normalizeHeartRate(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    return rawValue.clamp(20.0, 260.0);
  }

  /// Normalize weight to kilograms (kg).
  static double normalizeWeightToKg(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit == 'lb' || cleanUnit == 'lbs' || cleanUnit == 'pound' || cleanUnit == 'pounds') {
      return (rawValue * 0.45359237).clamp(10.0, 500.0);
    } else if (cleanUnit == 'st' || cleanUnit == 'stone') {
      return (rawValue * 6.35029).clamp(10.0, 500.0);
    }
    // Default kg
    return rawValue.clamp(10.0, 500.0);
  }

  /// Normalize height to centimeters (cm).
  static double normalizeHeightToCm(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit == 'm' || cleanUnit == 'meter' || cleanUnit == 'meters') {
      return (rawValue * 100.0).clamp(30.0, 300.0);
    } else if (cleanUnit == 'in' || cleanUnit == 'inch' || cleanUnit == 'inches') {
      return (rawValue * 2.54).clamp(30.0, 300.0);
    } else if (cleanUnit == 'ft' || cleanUnit == 'foot' || cleanUnit == 'feet') {
      return (rawValue * 30.48).clamp(30.0, 300.0);
    }
    // Default cm
    return rawValue.clamp(30.0, 300.0);
  }

  /// Normalize blood oxygen saturation (SpO2) to percentage (0.0 to 100.0).
  static double normalizeBloodOxygen(double rawValue) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    if (rawValue <= 1.0 && rawValue > 0.0) {
      // Decimal representation (e.g. 0.98 -> 98.0%)
      return (rawValue * 100.0).clamp(50.0, 100.0);
    }
    return rawValue.clamp(50.0, 100.0);
  }

  /// Normalize temperature to Celsius (°C).
  static double normalizeTemperatureToCelsius(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit.contains('f') || cleanUnit == 'fahrenheit') {
      return ((rawValue - 32.0) * (5.0 / 9.0)).clamp(25.0, 45.0);
    } else if (cleanUnit.contains('k') || cleanUnit == 'kelvin') {
      return (rawValue - 273.15).clamp(25.0, 45.0);
    }
    return rawValue.clamp(25.0, 45.0);
  }

  /// Normalize water volume to milliliters (ml).
  static double normalizeWaterToMl(double rawValue, String unit) {
    if (rawValue.isNaN || rawValue.isInfinite) return 0.0;
    final cleanUnit = unit.toLowerCase().trim();
    if (cleanUnit == 'l' || cleanUnit == 'liter' || cleanUnit == 'liters' || cleanUnit == 'litres') {
      return (rawValue * 1000.0).clamp(0.0, 20000.0);
    } else if (cleanUnit == 'oz' || cleanUnit == 'fl_oz' || cleanUnit == 'floz') {
      return (rawValue * 29.5735).clamp(0.0, 20000.0);
    }
    return rawValue.clamp(0.0, 20000.0);
  }

  /// Helper dispatcher taking a [HealthDataType] and returning the normalized value.
  static double normalize(HealthDataType type, double rawValue, String unit) {
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
        return rawValue.clamp(0.0, 1440.0); // max 24 hours in minutes
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
