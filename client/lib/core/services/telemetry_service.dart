// ==============================================================================
// Nutrient Earth — Environmental & Weather Intelligence Service
// Live weather telemetry and air quality index (AQI) with multi-tier caching,
// stale-while-revalidate failover, and evidence-based physiological hydration guidance.
// SECURITY DIRECTIVE: Zero exposed API credentials. Uses open scientific meteorological endpoints.
// ==============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design_system/tokens/ne_tokens.dart';

class TelemetryData {
  final String formattedTime;
  final String solarCondition;
  final int aqi;
  final String aqiLabel;
  final Color aqiColor;
  final double temperatureCelsius;
  final String weatherCondition;
  final int streakDays;
  final String streakLabel;
  final bool isCelsius;
  final DateTime observationTime;
  final bool isDefaultFallback;
  final bool isStale;
  final int? relativeHumidity;
  final double? apparentTemperatureCelsius;
  final double? pm25;
  final String? hydrationGuidance;

  const TelemetryData({
    required this.formattedTime,
    required this.solarCondition,
    required this.aqi,
    required this.aqiLabel,
    required this.aqiColor,
    required this.temperatureCelsius,
    required this.weatherCondition,
    required this.streakDays,
    required this.streakLabel,
    this.isCelsius = true,
    required this.observationTime,
    this.isDefaultFallback = false,
    this.isStale = false,
    this.relativeHumidity,
    this.apparentTemperatureCelsius,
    this.pm25,
    this.hydrationGuidance,
  });

  String get formattedTemperature {
    if (isCelsius) {
      return '${temperatureCelsius.round()}°C';
    } else {
      final fahrenheit = (temperatureCelsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
  }

  Map<String, dynamic> toJson() => {
        'aqi': aqi,
        'aqiLabel': aqiLabel,
        'temperatureCelsius': temperatureCelsius,
        'weatherCondition': weatherCondition,
        'streakDays': streakDays,
        'streakLabel': streakLabel,
        'isCelsius': isCelsius,
        'observationTime': observationTime.toIso8601String(),
        'isDefaultFallback': isDefaultFallback,
        'isStale': isStale,
        'relativeHumidity': relativeHumidity,
        'apparentTemperatureCelsius': apparentTemperatureCelsius,
        'pm25': pm25,
        'hydrationGuidance': hydrationGuidance,
      };

  factory TelemetryData.fromJson(Map<String, dynamic> json, DateTime now, String solar) {
    final aqiVal = json['aqi'] as int? ?? 42;
    return TelemetryData(
      formattedTime: DateFormat('h:mm a').format(now),
      solarCondition: solar,
      aqi: aqiVal,
      aqiLabel: json['aqiLabel'] as String? ?? _deriveAqiLabel(aqiVal),
      aqiColor: _deriveAqiColor(aqiVal),
      temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 24.0,
      weatherCondition: json['weatherCondition'] as String? ?? 'Partly cloudy',
      streakDays: json['streakDays'] as int? ?? 3,
      streakLabel: json['streakLabel'] as String? ?? 'Keep going',
      isCelsius: json['isCelsius'] as bool? ?? true,
      observationTime: json['observationTime'] != null
          ? DateTime.tryParse(json['observationTime'] as String) ?? now
          : now,
      isDefaultFallback: json['isDefaultFallback'] as bool? ?? false,
      isStale: json['isStale'] as bool? ?? false,
      relativeHumidity: json['relativeHumidity'] as int?,
      apparentTemperatureCelsius: (json['apparentTemperatureCelsius'] as num?)?.toDouble(),
      pm25: (json['pm25'] as num?)?.toDouble(),
      hydrationGuidance: json['hydrationGuidance'] as String?,
    );
  }

  TelemetryData copyWith({
    String? formattedTime,
    String? solarCondition,
    int? aqi,
    String? aqiLabel,
    Color? aqiColor,
    double? temperatureCelsius,
    String? weatherCondition,
    int? streakDays,
    String? streakLabel,
    bool? isCelsius,
    DateTime? observationTime,
    bool? isDefaultFallback,
    bool? isStale,
    int? relativeHumidity,
    double? apparentTemperatureCelsius,
    double? pm25,
    String? hydrationGuidance,
  }) {
    return TelemetryData(
      formattedTime: formattedTime ?? this.formattedTime,
      solarCondition: solarCondition ?? this.solarCondition,
      aqi: aqi ?? this.aqi,
      aqiLabel: aqiLabel ?? this.aqiLabel,
      aqiColor: aqiColor ?? this.aqiColor,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      streakDays: streakDays ?? this.streakDays,
      streakLabel: streakLabel ?? this.streakLabel,
      isCelsius: isCelsius ?? this.isCelsius,
      observationTime: observationTime ?? this.observationTime,
      isDefaultFallback: isDefaultFallback ?? this.isDefaultFallback,
      isStale: isStale ?? this.isStale,
      relativeHumidity: relativeHumidity ?? this.relativeHumidity,
      apparentTemperatureCelsius: apparentTemperatureCelsius ?? this.apparentTemperatureCelsius,
      pm25: pm25 ?? this.pm25,
      hydrationGuidance: hydrationGuidance ?? this.hydrationGuidance,
    );
  }

  static String _deriveAqiLabel(int aqi) {
    if (aqi <= 50) return 'Good AQI';
    if (aqi <= 100) return 'Moderate AQI';
    if (aqi <= 150) return 'Sensitive AQI';
    return 'Unhealthy AQI';
  }

  static Color _deriveAqiColor(int aqi) {
    if (aqi <= 50) return NETokens.aqiGreen;
    if (aqi <= 100) return const Color(0xFFE5B800);
    if (aqi <= 150) return const Color(0xFFE67E22);
    return NETokens.error;
  }
}

class TelemetryService {
  TelemetryService._();

  static const _cacheKey = 'ne_telemetry_cache_v2';
  static const _cacheDuration = Duration(minutes: 30);
  static const _requestTimeout = Duration(seconds: 4);

  // Default coordinate (New York baseline if device location permission not granted)
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;

  /// Fetches live weather and air quality telemetry with multi-tier caching.
  /// Never throws: fails gracefully to cached or baseline telemetry.
  static Future<TelemetryData> getTelemetry({
    double? latitude,
    double? longitude,
    DateTime? nowOverride,
    String? solarConditionOverride,
    HttpClient? customClient,
    int? streakDaysOverride,
    String? streakLabelOverride,
  }) async {
    final now = nowOverride ?? DateTime.now();
    final solar = solarConditionOverride ?? 'Radiant';
    final timeStr = DateFormat('h:mm a').format(now);

    final lat = latitude ?? defaultLatitude;
    final lon = longitude ?? defaultLongitude;

    final effectiveStreakDays = streakDaysOverride;
    final effectiveStreakLabel = streakLabelOverride;

    // 1. Check local cache (Valid for 30 minutes)
    TelemetryData? cachedEntry;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        final savedTime = DateTime.tryParse(data['observationTime'] as String? ?? '');
        if (savedTime != null) {
          cachedEntry = TelemetryData.fromJson(data, now, solar);
          // If fresh (< 30 min), return immediately
          if (now.difference(savedTime) < _cacheDuration) {
            if (effectiveStreakDays != null) {
              return cachedEntry.copyWith(
                streakDays: effectiveStreakDays,
                streakLabel: effectiveStreakLabel ?? cachedEntry.streakLabel,
              );
            }
            return cachedEntry;
          }
        }
      }
    } catch (_) {
      // Storage read error: proceed to live fetch
    }

    // 2. Fetch live data from Open-Meteo Weather & Air Quality APIs
    try {
      final client = customClient ?? HttpClient();
      client.connectionTimeout = _requestTimeout;

      // 2a. Fetch Weather
      final weatherUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=auto',
      );
      final weatherReq = await client.getUrl(weatherUri).timeout(_requestTimeout);
      weatherReq.headers.set(HttpHeaders.userAgentHeader, 'NutrientEarth/1.0');
      final weatherRes = await weatherReq.close().timeout(_requestTimeout);

      if (weatherRes.statusCode == 200) {
        final weatherBody = await weatherRes.transform(utf8.decoder).join();
        final weatherJson = jsonDecode(weatherBody) as Map<String, dynamic>;
        final currentW = weatherJson['current'] as Map<String, dynamic>? ?? {};

        final tempC = (currentW['temperature_2m'] as num?)?.toDouble() ?? 24.0;
        final appTempC = (currentW['apparent_temperature'] as num?)?.toDouble() ?? tempC;
        final humidity = (currentW['relative_humidity_2m'] as num?)?.toInt() ?? 45;
        final wCode = currentW['weather_code'] as int? ?? 1;
        final condition = _mapWmoCodeToCondition(wCode);

        // 2b. Fetch AQI
        int aqiVal = 42;
        double? pm25Val;
        try {
          final aqiUri = Uri.parse(
            'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi,pm2_5',
          );
          final aqiReq = await client.getUrl(aqiUri).timeout(_requestTimeout);
          aqiReq.headers.set(HttpHeaders.userAgentHeader, 'NutrientEarth/1.0');
          final aqiRes = await aqiReq.close().timeout(_requestTimeout);

          if (aqiRes.statusCode == 200) {
            final aqiBody = await aqiRes.transform(utf8.decoder).join();
            final aqiJson = jsonDecode(aqiBody) as Map<String, dynamic>;
            final currentAq = aqiJson['current'] as Map<String, dynamic>? ?? {};
            aqiVal = (currentAq['us_aqi'] as num?)?.toInt() ?? 42;
            pm25Val = (currentAq['pm2_5'] as num?)?.toDouble();
          }
        } catch (_) {
          // If AQI request fails, preserve standard default
        }

        final aqiLabel = TelemetryData._deriveAqiLabel(aqiVal);
        final aqiColor = TelemetryData._deriveAqiColor(aqiVal);
        final guidance = _deriveHydrationGuidance(tempC, humidity, aqiVal);

        final liveTelemetry = TelemetryData(
          formattedTime: timeStr,
          solarCondition: solar,
          aqi: aqiVal,
          aqiLabel: aqiLabel,
          aqiColor: aqiColor,
          temperatureCelsius: tempC,
          weatherCondition: condition,
          streakDays: effectiveStreakDays ?? cachedEntry?.streakDays ?? 3,
          streakLabel: effectiveStreakLabel ?? cachedEntry?.streakLabel ?? 'Keep going',
          isCelsius: true,
          observationTime: now,
          isDefaultFallback: false,
          isStale: false,
          relativeHumidity: humidity,
          apparentTemperatureCelsius: appTempC,
          pm25: pm25Val,
          hydrationGuidance: guidance,
        );

        // Save fresh data to SharedPreferences cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(liveTelemetry.toJson()));
        } catch (_) {}

        return liveTelemetry;
      }
    } catch (_) {
      // Network failure, timeout, or DNS resolution failure
    }

    // 3. Stale-While-Revalidate: Return cached entry if network failed
    if (cachedEntry != null) {
      return TelemetryData(
        formattedTime: timeStr,
        solarCondition: solar,
        aqi: cachedEntry.aqi,
        aqiLabel: cachedEntry.aqiLabel,
        aqiColor: cachedEntry.aqiColor,
        temperatureCelsius: cachedEntry.temperatureCelsius,
        weatherCondition: cachedEntry.weatherCondition,
        streakDays: effectiveStreakDays ?? cachedEntry.streakDays,
        streakLabel: effectiveStreakLabel ?? cachedEntry.streakLabel,
        isCelsius: cachedEntry.isCelsius,
        observationTime: cachedEntry.observationTime,
        isDefaultFallback: false,
        isStale: true, // Transparently marked stale
        relativeHumidity: cachedEntry.relativeHumidity,
        apparentTemperatureCelsius: cachedEntry.apparentTemperatureCelsius,
        pm25: cachedEntry.pm25,
        hydrationGuidance: cachedEntry.hydrationGuidance,
      );
    }

    // 4. Default Baseline Fallback
    final baseline = TelemetryData(
      formattedTime: timeStr,
      solarCondition: solar,
      aqi: 42,
      aqiLabel: 'Good AQI',
      aqiColor: NETokens.aqiGreen,
      temperatureCelsius: 22.0,
      weatherCondition: 'Partly cloudy',
      streakDays: effectiveStreakDays ?? 3,
      streakLabel: effectiveStreakLabel ?? 'Keep going',
      isCelsius: true,
      observationTime: now,
      isDefaultFallback: true,
      isStale: false,
    );

    return baseline;
  }

  static String _mapWmoCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Partly cloudy';
    }
  }

  /// Derives evidence-based hydration and recovery recommendations from environmental telemetry.
  /// Aligned with American College of Sports Medicine (ACSM) fluid replacement position stands.
  static String? _deriveHydrationGuidance(double tempC, int humidity, int aqi) {
    if (tempC >= 28.0) {
      return 'Elevated ambient heat increases sweat rate; target +250–500 mL electrolyte fluid per hour of physical activity (ACSM guidelines).';
    } else if (tempC <= 5.0) {
      return 'Cold ambient air increases respiratory fluid loss; maintain structured hydration despite blunted thirst sensation.';
    } else if (aqi >= 100) {
      return 'Elevated airborne particulate matter (PM2.5); prioritize indoor recovery and antioxidant-dense whole foods.';
    }
    return null;
  }
}
