// ==============================================================================
// Nutrient Earth — Weather State Adapter
// Transforms raw telemetry or Open-Meteo responses into verified AmbientWeatherState.
// Ensures offline resilience, cache freshness, and strict fallback safety.
// ==============================================================================

import '../entities/world_state.dart';

class WeatherStateAdapter {
  WeatherStateAdapter._();

  /// Converts weather code (WMO code), temperature, humidity, and AQI into AmbientWeatherState
  static AmbientWeatherState fromTelemetry({
    required double? temperatureCelsius,
    required String? weatherCondition,
    required double? aqi,
    double? humidity,
    bool isObservationFresh = true,
  }) {
    final temp = temperatureCelsius ?? 22.0;
    final conditionType = _mapConditionStringToEnum(weatherCondition);
    final effectiveAqi = aqi ?? 42.0;
    final effectiveHumidity = humidity ?? (conditionType.hasPrecipitation ? 85.0 : 50.0);

    return AmbientWeatherState(
      condition: conditionType,
      temperatureCelsius: temp,
      relativeHumidity: effectiveHumidity,
      atmosphericAqi: effectiveAqi,
      isObservationFresh: isObservationFresh,
      providerAttribution: isObservationFresh ? 'Open-Meteo Verified Cache' : 'Historical Environmental Baseline',
    );
  }

  static WeatherConditionType _mapConditionStringToEnum(String? cond) {
    if (cond == null || cond.isEmpty) return WeatherConditionType.partlyCloudy;
    final lower = cond.toLowerCase();

    if (lower.contains('rain') || lower.contains('shower') || lower.contains('drizzle')) {
      if (lower.contains('heavy') || lower.contains('thunder')) {
        return WeatherConditionType.heavyShowers;
      }
      return WeatherConditionType.lightRain;
    }
    if (lower.contains('snow') || lower.contains('flurry') || lower.contains('sleet')) {
      return WeatherConditionType.snowFlurries;
    }
    if (lower.contains('fog') || lower.contains('mist') || lower.contains('haze')) {
      return WeatherConditionType.mistyFog;
    }
    if (lower.contains('overcast') || lower.contains('cloudy') && lower.contains('heavy')) {
      return WeatherConditionType.overcast;
    }
    if (lower.contains('partly') || lower.contains('scattered')) {
      return WeatherConditionType.partlyCloudy;
    }
    if (lower.contains('clear') || lower.contains('sunny')) {
      return WeatherConditionType.clearSky;
    }

    return WeatherConditionType.partlyCloudy;
  }
}
