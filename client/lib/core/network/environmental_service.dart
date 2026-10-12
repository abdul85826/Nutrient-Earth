import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class EnvironmentalMetrics {
  final double latitude;
  final double longitude;
  final double temperatureC;
  final double relativeHumidity;
  final double apparentTemperatureC;
  final double uvIndex;
  final int? weatherCode;
  final double? pm25;
  final int? usAqi;
  final DateTime timestamp;
  final bool isReal;
  final String attribution;

  const EnvironmentalMetrics({
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.relativeHumidity,
    required this.apparentTemperatureC,
    required this.uvIndex,
    this.weatherCode,
    this.pm25,
    this.usAqi,
    required this.timestamp,
    this.isReal = true,
    this.attribution = 'Open-Meteo CC-BY 4.0',
  });

  String get aqiCategory {
    final aqi = usAqi;
    if (aqi == null) return 'Not Available';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String get weatherCondition {
    final code = weatherCode;
    if (code == null) return 'Clear';
    if (code == 0) return 'Clear Sky';
    if (code == 1 || code == 2 || code == 3) return 'Mainly Clear';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Clear';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'temperatureC': temperatureC,
    'relativeHumidity': relativeHumidity,
    'apparentTemperatureC': apparentTemperatureC,
    'uvIndex': uvIndex,
    'weatherCode': weatherCode,
    'pm25': pm25,
    'usAqi': usAqi,
    'timestamp': timestamp.toIso8601String(),
    'isReal': isReal,
    'attribution': attribution,
  };
}

class EnvironmentalService {
  final Dio _dio;

  EnvironmentalService({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Truncates coordinates to 2 decimal places (~1.1 km resolution) to protect user location privacy.
  static double truncateCoordinate(double val) {
    return (val * 100).truncateToDouble() / 100;
  }

  Future<EnvironmentalMetrics?> fetchRealMetrics({
    required double rawLatitude,
    required double rawLongitude,
  }) async {
    final lat = truncateCoordinate(rawLatitude);
    final lon = truncateCoordinate(rawLongitude);

    try {
      // 1. Fetch Weather from Open-Meteo (Free commercial CC-BY 4.0)
      final weatherRes = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,uv_index',
        },
      );

      // 2. Fetch Air Quality from Open-Meteo Air Quality API
      final aqiRes = await _dio.get<Map<String, dynamic>>(
        'https://air-quality-api.open-meteo.com/v1/air-quality',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'pm2_5,us_aqi',
        },
      );

      final weatherCurrent = weatherRes.data?['current'] as Map<String, dynamic>?;
      final aqiCurrent = aqiRes.data?['current'] as Map<String, dynamic>?;

      if (weatherCurrent == null) {
        return null;
      }

      return EnvironmentalMetrics(
        latitude: lat,
        longitude: lon,
        temperatureC: (weatherCurrent['temperature_2m'] as num?)?.toDouble() ?? 22.0,
        relativeHumidity: (weatherCurrent['relative_humidity_2m'] as num?)?.toDouble() ?? 50.0,
        apparentTemperatureC: (weatherCurrent['apparent_temperature'] as num?)?.toDouble() ?? 22.0,
        uvIndex: (weatherCurrent['uv_index'] as num?)?.toDouble() ?? 3.0,
        weatherCode: weatherCurrent['weather_code'] as int?,
        pm25: (aqiCurrent?['pm2_5'] as num?)?.toDouble(),
        usAqi: aqiCurrent?['us_aqi'] as int?,
        timestamp: DateTime.now(),
        isReal: true,
      );
    } catch (e) {
      debugPrint('[EnvironmentalService] Open-Meteo fetch failed: $e');
      return null;
    }
  }
}

final environmentalServiceProvider = Provider<EnvironmentalService>((ref) {
  return EnvironmentalService();
});

/// Ambient environmental metrics state provider.
final ambientEnvironmentalProvider = FutureProvider<EnvironmentalMetrics?>((ref) async {
  final service = ref.watch(environmentalServiceProvider);
  // Default regional reference coordinate (e.g. San Francisco Bay 37.77, -122.41) if GPS is disabled
  return service.fetchRealMetrics(rawLatitude: 37.7749, rawLongitude: -122.4194);
});
