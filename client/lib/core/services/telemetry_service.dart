import 'dart:convert';
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
      };

  factory TelemetryData.fromJson(Map<String, dynamic> json, DateTime now, String solar) {
    return TelemetryData(
      formattedTime: DateFormat('h:mm a').format(now),
      solarCondition: solar,
      aqi: json['aqi'] as int? ?? 42,
      aqiLabel: json['aqiLabel'] as String? ?? 'Good AQI',
      aqiColor: NETokens.aqiGreen,
      temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 26.0,
      weatherCondition: json['weatherCondition'] as String? ?? 'Partly cloudy',
      streakDays: json['streakDays'] as int? ?? 3,
      streakLabel: json['streakLabel'] as String? ?? 'Keep going',
      isCelsius: json['isCelsius'] as bool? ?? true,
      observationTime: json['observationTime'] != null
          ? DateTime.parse(json['observationTime'] as String)
          : now,
      isDefaultFallback: json['isDefaultFallback'] as bool? ?? true,
    );
  }
}

class TelemetryService {
  TelemetryService._();

  static const _cacheKey = 'ne_telemetry_cache_v1';
  static const _cacheDuration = Duration(minutes: 30);

  static Future<TelemetryData> getTelemetry({
    DateTime? nowOverride,
    String? solarConditionOverride,
  }) async {
    final now = nowOverride ?? DateTime.now();
    final solar = solarConditionOverride ?? 'Radiant';
    final timeStr = DateFormat('h:mm a').format(now);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        final savedTime = DateTime.parse(data['observationTime'] as String);
        if (now.difference(savedTime) < _cacheDuration) {
          return TelemetryData(
            formattedTime: timeStr,
            solarCondition: solar,
            aqi: data['aqi'] as int? ?? 42,
            aqiLabel: data['aqiLabel'] as String? ?? 'Good AQI',
            aqiColor: NETokens.aqiGreen,
            temperatureCelsius: (data['temperatureCelsius'] as num?)?.toDouble() ?? 26.0,
            weatherCondition: data['weatherCondition'] as String? ?? 'Partly cloudy',
            streakDays: data['streakDays'] as int? ?? 3,
            streakLabel: data['streakLabel'] as String? ?? 'Keep going',
            isCelsius: data['isCelsius'] as bool? ?? true,
            observationTime: savedTime,
            isDefaultFallback: data['isDefaultFallback'] as bool? ?? false,
          );
        }
      }
    } catch (_) {
      // Local storage read error; continue to baseline calculation
    }

    // Default robust baseline matching approved visual specification
    final baseline = TelemetryData(
      formattedTime: timeStr,
      solarCondition: solar,
      aqi: 42,
      aqiLabel: 'Good AQI',
      aqiColor: NETokens.aqiGreen,
      temperatureCelsius: 26.0,
      weatherCondition: 'Partly cloudy',
      streakDays: 3,
      streakLabel: 'Keep going',
      isCelsius: true,
      observationTime: now,
      isDefaultFallback: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(baseline.toJson()));
    } catch (_) {}

    return baseline;
  }
}
