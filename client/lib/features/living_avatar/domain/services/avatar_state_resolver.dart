// ==============================================================================
// Nutrient Earth — Master Avatar State Resolver
// Deterministic orchestrator resolving the single authoritative AvatarSceneState.
// Harmonizes astronomical clock, seasonal chronobiology, weather, and appearance.
// ==============================================================================

import 'package:flutter/material.dart';
import '../entities/avatar_identity.dart';
import '../entities/avatar_appearance.dart';
import '../entities/avatar_behaviour.dart';
import '../entities/world_state.dart';
import '../entities/astronomical_state.dart';
import '../entities/avatar_scene_state.dart';
import '../entities/avatar_combination_matrix.dart';
import 'astronomical_calculator.dart';
import 'season_resolver.dart';
import 'cultural_calendar_resolver.dart';

class AvatarStateResolver {
  AvatarStateResolver._();

  /// Resolves the comprehensive, unified, immutable scene state
  static AvatarSceneState resolve({
    required AvatarIdentity identity,
    AvatarAppearance? requestedAppearance,
    required DateTime timeUtc,
    required double latitude,
    required double longitude,
    required String timezoneId,
    AmbientWeatherState? weather,
    CulturalPresentationPreference culturalPreference = CulturalPresentationPreference.neutralNature,
    bool isReducedMotionEnabled = false,
    bool isStaticFallback = false,
    bool hasAvatar = true,
  }) {
    // 1. Calculate continuous deterministic astronomical state
    final astronomy = AstronomicalCalculator.calculate(
      timeUtc: timeUtc,
      latitude: latitude,
      longitude: longitude,
      timezoneId: timezoneId,
    );

    // 2. Resolve regional season (Western 4-season or Indian 6-Ritu)
    final season = SeasonResolver.resolve(
      date: timeUtc,
      latitude: latitude,
      longitude: longitude,
      timezoneId: timezoneId,
      culturalPreference: culturalPreference,
    );

    // 3. Resolve active cultural occasion if user opted in
    final activeOccasion = CulturalCalendarResolver.resolveActiveOccasion(
      dateUtc: timeUtc,
      preference: culturalPreference,
    );

    // 4. Resolve verified environmental weather
    final effectiveWeather = weather ?? AmbientWeatherState.neutralFallback();

    // 5. Derive physically coherent ambient lighting parameters
    final lighting = _resolveAmbientLighting(
      astronomy: astronomy,
      weather: effectiveWeather,
      season: season,
    );

    // 6. Resolve procedural vital avatar behaviour
    final behaviour = _resolveAvatarBehaviour(
      astronomy: astronomy,
      weather: effectiveWeather,
      timeUtc: timeUtc,
    );

    // 7. Validate & arbitrate clothing, accessories, and props via Combination Matrix
    final appearanceBase = requestedAppearance ?? AvatarAppearance.defaultBaseline();
    final validatedAppearance = AvatarCombinationMatrix.resolveAppearance(
      requested: appearanceBase,
      temperatureCelsius: effectiveWeather.temperatureCelsius,
      weatherCondition: effectiveWeather.condition,
      twilight: astronomy.twilightState,
      season: season,
      culturalPreference: culturalPreference,
      occasion: activeOccasion,
    );

    // 8. Assemble unified WorldState
    final world = WorldState(
      astronomy: astronomy,
      season: season,
      weather: effectiveWeather,
      culturalPreference: culturalPreference,
      activeCulturalOccasion: activeOccasion,
      lighting: lighting,
    );

    return AvatarSceneState(
      resolvedAtUtc: timeUtc,
      hasAvatar: hasAvatar,
      identity: identity,
      appearance: validatedAppearance,
      behaviour: behaviour,
      world: world,
      isReducedMotionEnabled: isReducedMotionEnabled,
      isStaticFallback: isStaticFallback,
    );
  }

  /// Calculates real-time sky colors, illumination intensity, shadow softness, and ambient particles
  static AmbientLightingState _resolveAmbientLighting({
    required WorldAstronomyState astronomy,
    required AmbientWeatherState weather,
    required RegionalSeason season,
  }) {
    final double alt = astronomy.solarAltitude;
    Color skyTop;
    Color skyBottom;
    Color lightColor;
    double intensity;
    double warmth;
    double shadowLength;
    double shadowSoftness;
    double starVisibility;
    AmbientParticleType particles = AmbientParticleType.none;

    if (alt > 45.0) {
      // High Midday Sun
      skyTop = const Color(0xFFC4DBC8); // Verdant clear pale sage
      skyBottom = const Color(0xFFE8F2EA);
      lightColor = const Color(0xFFFFFFFA);
      intensity = 1.0;
      warmth = 0.15;
      shadowLength = 0.35;
      shadowSoftness = 0.25;
      starVisibility = 0.0;
    } else if (alt > 12.0) {
      // Gentle Morning / Radiant Afternoon
      skyTop = const Color(0xFFB4D2BE);
      skyBottom = const Color(0xFFE2EEE5);
      lightColor = const Color(0xFFFFF9EE);
      intensity = 0.88;
      warmth = 0.35;
      shadowLength = 0.75;
      shadowSoftness = 0.35;
      starVisibility = 0.0;
    } else if (alt > 0.0) {
      // Golden Hour (Low solar angle, warm apricot / amber radiance)
      skyTop = const Color(0xFFE8B888);
      skyBottom = const Color(0xFFFAF0E6);
      lightColor = const Color(0xFFFFE0B2);
      intensity = 0.75;
      warmth = 0.95;
      shadowLength = 2.1;
      shadowSoftness = 0.45;
      starVisibility = 0.0;
      particles = AmbientParticleType.goldenSunMotes;
    } else if (alt > -6.0) {
      // Civil Twilight
      skyTop = const Color(0xFF4C6B64);
      skyBottom = const Color(0xFFD4997C);
      lightColor = const Color(0xFFFFCCAA);
      intensity = 0.50;
      warmth = 0.75;
      shadowLength = 3.0;
      shadowSoftness = 0.75;
      starVisibility = 0.15;
    } else if (alt > -12.0) {
      // Nautical Twilight
      skyTop = const Color(0xFF1E3A35);
      skyBottom = const Color(0xFF556F68);
      lightColor = const Color(0xFF8AA8A1);
      intensity = 0.32;
      warmth = 0.25;
      shadowLength = 3.5;
      shadowSoftness = 0.90;
      starVisibility = 0.65;
      if (season == RegionalSeason.grishma || season == RegionalSeason.vasanta) {
        particles = AmbientParticleType.twilightFireflies;
      }
    } else if (alt > -18.0) {
      // Astronomical Twilight
      skyTop = const Color(0xFF0F2623);
      skyBottom = const Color(0xFF263D37);
      lightColor = const Color(0xFF5A7871);
      intensity = 0.20;
      warmth = 0.10;
      shadowLength = 4.0;
      shadowSoftness = 0.95;
      starVisibility = 0.85;
    } else {
      // Deep Night (Lunar dominance)
      skyTop = const Color(0xFF061A19);
      skyBottom = const Color(0xFF132824);
      lightColor = const Color(0xFF44635D);
      intensity = 0.14 + (astronomy.lunarIllumination * 0.12);
      warmth = 0.05;
      shadowLength = 2.5;
      shadowSoftness = 0.80;
      starVisibility = 1.0;
      if (season == RegionalSeason.grishma || season == RegionalSeason.vasanta) {
        particles = AmbientParticleType.twilightFireflies;
      }
    }

    // Weather modifications
    if (weather.condition.hasPrecipitation) {
      // Diffuse shadows and desaturate sky
      shadowSoftness = 0.95;
      intensity *= 0.70;
      starVisibility = 0.0;
      if (weather.condition == WeatherConditionType.lightRain || weather.condition == WeatherConditionType.heavyShowers) {
        particles = AmbientParticleType.rainDrops;
      } else if (weather.condition == WeatherConditionType.snowFlurries) {
        particles = AmbientParticleType.gentleSnow;
      }
    } else if (weather.condition == WeatherConditionType.mistyFog) {
      particles = AmbientParticleType.mistVeil;
      shadowSoftness = 0.98;
      starVisibility *= 0.2;
    }

    return AmbientLightingState(
      skyColorTop: skyTop,
      skyColorBottom: skyBottom,
      directionalLightColor: lightColor,
      lightIntensity: intensity,
      warmthFactor: warmth,
      shadowLengthRatio: shadowLength,
      shadowSoftness: shadowSoftness,
      starVisibility: starVisibility,
      activeParticle: particles,
    );
  }

  /// Resolves breathing cadence, blink rate, posture, and facial expression
  static AvatarBehaviour _resolveAvatarBehaviour({
    required WorldAstronomyState astronomy,
    required AmbientWeatherState weather,
    required DateTime timeUtc,
  }) {
    final hour = timeUtc.hour; // UTC diurnal baseline
    final twilight = astronomy.twilightState;

    if (twilight == TwilightState.deepNight) {
      return const AvatarBehaviour(
        expression: FacialExpressionType.restfulPeace,
        gaze: EyeGazeState.softlyClosed,
        posture: PostureAlignment.meditativeStillness,
        currentAction: CharacterAction.restingPresence,
        breathingRateBpm: 6.5, // Slow restorative autonomic rhythm
        blinkFrequencySeconds: 8.0,
      );
    } else if (twilight == TwilightState.goldenHour) {
      return const AvatarBehaviour(
        expression: FacialExpressionType.sereneContentment,
        gaze: EyeGazeState.horizonContemplation,
        posture: PostureAlignment.relaxedPoised,
        currentAction: CharacterAction.restingPresence,
        breathingRateBpm: 10.0,
        blinkFrequencySeconds: 4.8,
      );
    } else if (twilight.isTwilight) {
      return const AvatarBehaviour(
        expression: FacialExpressionType.sereneContentment,
        gaze: EyeGazeState.forwardDirect,
        posture: PostureAlignment.relaxedPoised,
        currentAction: CharacterAction.restingPresence,
        breathingRateBpm: 11.0,
        blinkFrequencySeconds: 4.2,
      );
    } else {
      // Daytime: Morning vs Afternoon
      if (hour >= 5 && hour < 12) {
        return const AvatarBehaviour(
          expression: FacialExpressionType.energizedReady,
          gaze: EyeGazeState.forwardDirect,
          posture: PostureAlignment.uprightEnergized,
          currentAction: CharacterAction.restingPresence,
          breathingRateBpm: 14.0, // Energized daytime respiration
          blinkFrequencySeconds: 3.6,
        );
      } else {
        return const AvatarBehaviour(
          expression: FacialExpressionType.focusedInsight,
          gaze: EyeGazeState.forwardDirect,
          posture: PostureAlignment.relaxedPoised,
          currentAction: CharacterAction.restingPresence,
          breathingRateBpm: 12.0,
          blinkFrequencySeconds: 4.0,
        );
      }
    }
  }
}
