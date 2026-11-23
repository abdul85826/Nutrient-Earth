// ==============================================================================
// Nutrient Earth — Resolved World State Contract
// Harmonizes astronomical position, regional season, weather, cultural context,
// and physical lighting parameters into one unified, non-contradictory environment.
// ==============================================================================

import 'package:flutter/material.dart';
import 'astronomical_state.dart';

enum RegionalSeason {
  // Western 4-Season Framework
  spring('Spring', 'Awakening vitality, green shoots, and renewed growth'),
  summer('Summer', 'Radiant solar intensity, abundance, and lush greenery'),
  autumn('Autumn', 'Harvest golden tones, crisp air, and foliar shift'),
  winter('Winter', 'Quiet restoration, cool temperatures, and structural stillness'),

  // Classical Indian 6-Ritu Framework (Ayurvedic & Vedic chronobiology)
  vasanta('Vasanta (Spring)', 'Chaitra–Vaishakha: Kapha pacification and blooming nature'),
  grishma('Grishma (Summer)', 'Jyeshtha–Ashadha: High Pitta, hydration emphasis, intense solar heat'),
  varsha('Varsha (Monsoon)', 'Shravana–Bhadrapada: Heavy rains, lush moss, digestive care'),
  sharad('Sharad (Autumn)', 'Ashwina–Kartika: Clear post-monsoon blue skies and golden moonlight'),
  hemanta('Hemanta (Early Winter)', 'Margashirsha–Pausha: Strong digestive Agni and cooling winds'),
  shishira('Shishira (Late Winter)', 'Magha–Phalguna: Cold stillness, dewy mornings, and internal renewal');

  final String displayName;
  final String description;
  const RegionalSeason(this.displayName, this.description);

  bool get isMonsoon => this == RegionalSeason.varsha;
  bool get isWinterLike => this == RegionalSeason.winter || this == RegionalSeason.hemanta || this == RegionalSeason.shishira;
  bool get isSummerLike => this == RegionalSeason.summer || this == RegionalSeason.grishma;
  bool get isIndianRitu =>
      this == RegionalSeason.vasanta ||
      this == RegionalSeason.grishma ||
      this == RegionalSeason.varsha ||
      this == RegionalSeason.sharad ||
      this == RegionalSeason.hemanta ||
      this == RegionalSeason.shishira;

  static const RegionalSeason varshaMonsoon = RegionalSeason.varsha;
  static const RegionalSeason vasantaSpring = RegionalSeason.vasanta;
}

enum WeatherConditionType {
  clearSky,
  partlyCloudy,
  overcast,
  mistyFog,
  lightRain,
  heavyShowers,
  snowFlurries;

  bool get hasPrecipitation =>
      this == WeatherConditionType.lightRain ||
      this == WeatherConditionType.heavyShowers ||
      this == WeatherConditionType.snowFlurries;
}

@immutable
class AmbientWeatherState {
  final WeatherConditionType condition;
  final double temperatureCelsius;
  final double relativeHumidity; // 0.0 to 100.0
  final double atmosphericAqi;
  final bool isObservationFresh;
  final String providerAttribution;

  const AmbientWeatherState({
    this.condition = WeatherConditionType.partlyCloudy,
    this.temperatureCelsius = 24.0,
    this.relativeHumidity = 55.0,
    this.atmosphericAqi = 42.0,
    this.isObservationFresh = true,
    this.providerAttribution = 'Open-Meteo Verified Cache',
  });

  /// Neutral baseline when weather provider is offline or unpermitted
  factory AmbientWeatherState.neutralFallback({double temperature = 22.0}) {
    return AmbientWeatherState(
      condition: WeatherConditionType.partlyCloudy,
      temperatureCelsius: temperature,
      relativeHumidity: 50.0,
      atmosphericAqi: 45.0,
      isObservationFresh: false,
      providerAttribution: 'Offline Neutral Climate Model',
    );
  }

  bool get isRaining =>
      condition == WeatherConditionType.lightRain ||
      condition == WeatherConditionType.heavyShowers;

  bool get isSnowing => condition == WeatherConditionType.snowFlurries;

  bool get isMisty => condition == WeatherConditionType.mistyFog;

  double get rainIntensity =>
      condition == WeatherConditionType.heavyShowers
          ? 0.95
          : (condition == WeatherConditionType.lightRain ? 0.4 : 0.0);

  double get fogDensity => condition == WeatherConditionType.mistyFog ? 0.8 : 0.0;

  double get cloudCoverFraction =>
      condition == WeatherConditionType.overcast
          ? 1.0
          : (condition == WeatherConditionType.partlyCloudy ? 0.4 : 0.0);

  String get conditionName => condition.name;
}

enum CulturalPresentationPreference {
  neutralNature('Neutral Nature (Default)', 'Pure natural landscape, seasonal botanicals, zero religious/cultural icons'),
  indicTraditional('Indic Cultural Heritage', 'Verified traditional Indian festivals (Diwali, Pongal/Sankranti, Holi, Navratri)'),
  islamicHeritage('Islamic Cultural Heritage', 'Verified festive observances (Eid al-Fitr, Eid al-Adha)'),
  westernHeritage('Western Cultural Heritage', 'Verified cultural milestones (Winter Solstice / Christmas season, New Year)'),
  eastAsianHeritage('East Asian Heritage', 'Verified lunisolar festivals (Lunar New Year, Mid-Autumn)');

  final String displayName;
  final String description;
  const CulturalPresentationPreference(this.displayName, this.description);

  bool get isNeutral => this == CulturalPresentationPreference.neutralNature;

  static const CulturalPresentationPreference southAsian = CulturalPresentationPreference.indicTraditional;
  static const CulturalPresentationPreference western = CulturalPresentationPreference.westernHeritage;
}

@immutable
class VerifiedCulturalOccasion {
  final String festivalId;
  final String festivalName;
  final String visualMotif; // e.g. 'brass_diya_glow', 'festive_attire_accent'
  final DateTime effectiveFromUtc;
  final DateTime effectiveToUtc;

  const VerifiedCulturalOccasion({
    required this.festivalId,
    required this.festivalName,
    required this.visualMotif,
    required this.effectiveFromUtc,
    required this.effectiveToUtc,
  });

  String get occasionId => festivalId;
}

enum AmbientParticleType {
  none,
  goldenSunMotes,
  mistVeil,
  rainDrops,
  twilightFireflies,
  gentleSnow;
}

@immutable
class AmbientLightingState {
  final Color skyColorTop;
  final Color skyColorBottom;
  final Color directionalLightColor;
  final double lightIntensity; // 0.0 (midnight) to 1.0 (zenith midday)
  final double warmthFactor; // 0.0 (cool blue moonlight) to 1.0 (golden sunrise/sunset)
  final double shadowLengthRatio; // 0.2 (midday overhead) to 2.5 (golden hour low angle)
  final double shadowSoftness; // 0.1 (sharp direct) to 0.9 (cloud diffused)
  final double starVisibility; // 0.0 (day) to 1.0 (deep night clear sky)
  final AmbientParticleType activeParticle;

  const AmbientLightingState({
    required this.skyColorTop,
    required this.skyColorBottom,
    required this.directionalLightColor,
    required this.lightIntensity,
    required this.warmthFactor,
    required this.shadowLengthRatio,
    required this.shadowSoftness,
    required this.starVisibility,
    this.activeParticle = AmbientParticleType.none,
  });

  Color get ambientWashColor => directionalLightColor;

  factory AmbientLightingState.defaultDaylight() {
    return const AmbientLightingState(
      skyColorTop: Color(0xFFD4E6D9), // Nutrient Earth Pale Sage
      skyColorBottom: Color(0xFFEDF4EC),
      directionalLightColor: Color(0xFFFFF7E6),
      lightIntensity: 0.9,
      warmthFactor: 0.3,
      shadowLengthRatio: 0.6,
      shadowSoftness: 0.35,
      starVisibility: 0.0,
      activeParticle: AmbientParticleType.none,
    );
  }
}

@immutable
class WorldState {
  final WorldAstronomyState astronomy;
  final RegionalSeason season;
  final AmbientWeatherState weather;
  final CulturalPresentationPreference culturalPreference;
  final VerifiedCulturalOccasion? activeCulturalOccasion;
  final AmbientLightingState lighting;

  const WorldState({
    required this.astronomy,
    required this.season,
    required this.weather,
    this.culturalPreference = CulturalPresentationPreference.neutralNature,
    this.activeCulturalOccasion,
    required this.lighting,
  });

  WorldState copyWith({
    WorldAstronomyState? astronomy,
    RegionalSeason? season,
    AmbientWeatherState? weather,
    CulturalPresentationPreference? culturalPreference,
    VerifiedCulturalOccasion? activeCulturalOccasion,
    AmbientLightingState? lighting,
  }) {
    return WorldState(
      astronomy: astronomy ?? this.astronomy,
      season: season ?? this.season,
      weather: weather ?? this.weather,
      culturalPreference: culturalPreference ?? this.culturalPreference,
      activeCulturalOccasion: activeCulturalOccasion ?? this.activeCulturalOccasion,
      lighting: lighting ?? this.lighting,
    );
  }
}
