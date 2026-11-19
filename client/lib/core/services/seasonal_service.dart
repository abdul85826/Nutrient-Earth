// ==============================================================================
// Nutrient Earth — Seasonal Intelligence & Environmental Atmosphere Engine
// Scientifically models regional seasonality (Temperate, Tropical, Monsoon, Polar)
// and computes daylight color temperature and atmospheric transitions without
// relying on Western four-season assumptions for tropical/monsoon zones.
// ==============================================================================

import 'package:flutter/material.dart';

enum RegionalSeason {
  spring('Spring', 'Renewal & pollen alignment'),
  summer('Summer', 'Thermoregulation & hydration focus'),
  monsoon('Monsoon', 'Immune resilience & humidity adaptation'),
  postMonsoon('Post-Monsoon', 'Atmospheric transition'),
  autumn('Autumn', 'Metabolic stabilization'),
  winter('Winter', 'Thermal conservation & vitamin D synthesis'),
  drySeason('Dry Season', 'Hydration & barrier integrity'),
  wetSeason('Wet Season', 'Microbiome & digestive defense');

  final String label;
  final String focusDescription;

  const RegionalSeason(this.label, this.focusDescription);
}

enum DaylightPhase {
  dawn('Dawn', Color(0xFFFFF6ED)),
  morning('Morning', Color(0xFFFAF8F5)),
  midday('Midday', Color(0xFFF6FAF7)),
  afternoon('Afternoon', Color(0xFFF9FAF6)),
  goldenHour('Golden Hour', Color(0xFFFAF2EC)),
  dusk('Dusk', Color(0xFFF2F5F3)),
  night('Night', Color(0xFFECF2EF));

  final String label;
  final Color ambientCanvasColor;

  const DaylightPhase(this.label, this.ambientCanvasColor);
}

class SeasonalContext {
  final RegionalSeason season;
  final DaylightPhase daylightPhase;
  final bool isNorthernHemisphere;
  final String regionClassification;
  final Color ambientBackground;
  final Color cardBackground;
  final String seasonalGuidanceNote;

  const SeasonalContext({
    required this.season,
    required this.daylightPhase,
    required this.isNorthernHemisphere,
    required this.regionClassification,
    required this.ambientBackground,
    required this.cardBackground,
    required this.seasonalGuidanceNote,
  });
}

class SeasonalService {
  SeasonalService._();

  /// Calculates authoritative seasonal context based on coordinates and date
  static SeasonalContext computeContext({
    double? latitude,
    double? longitude,
    DateTime? nowOverride,
    bool isRainy = false,
  }) {
    final now = nowOverride ?? DateTime.now();
    final lat = latitude ?? 40.7128;
    final lon = longitude ?? -74.0060;
    final isNorth = lat >= 0;

    final month = now.month;
    final hour = now.hour;

    // 1. Determine Regional Season
    RegionalSeason season;
    String regionName;

    // Check if region is South Asian / Indian Subcontinent (Monsoon belt: 8°N-35°N, 68°E-97°E)
    final isIndianSubcontinent = (lat >= 8.0 && lat <= 36.0 && lon >= 68.0 && lon <= 97.0);
    // Check if tropical belt (-23.5° to 23.5° latitude)
    final isTropics = lat >= -23.5 && lat <= 23.5;

    if (isIndianSubcontinent) {
      regionName = 'South Asian Monsoon Zone';
      if (month == 12 || month == 1 || month == 2) {
        season = RegionalSeason.winter;
      } else if (month >= 3 && month <= 5) {
        season = RegionalSeason.summer;
      } else if (month >= 6 && month <= 9) {
        season = RegionalSeason.monsoon;
      } else {
        season = RegionalSeason.postMonsoon;
      }
    } else if (isTropics) {
      regionName = 'Tropical Zone';
      // Wet/Dry binary classification based on hemisphere precipitation cycles
      if (month >= 5 && month <= 10) {
        season = isNorth ? RegionalSeason.wetSeason : RegionalSeason.drySeason;
      } else {
        season = isNorth ? RegionalSeason.drySeason : RegionalSeason.wetSeason;
      }
    } else if (isNorth) {
      regionName = 'Temperate Northern Hemisphere';
      if (month == 12 || month == 1 || month == 2) {
        season = RegionalSeason.winter;
      } else if (month >= 3 && month <= 5) {
        season = RegionalSeason.spring;
      } else if (month >= 6 && month <= 8) {
        season = RegionalSeason.summer;
      } else {
        season = RegionalSeason.autumn;
      }
    } else {
      regionName = 'Temperate Southern Hemisphere';
      // Southern Hemisphere: seasons are inverted
      if (month == 12 || month == 1 || month == 2) {
        season = RegionalSeason.summer;
      } else if (month >= 3 && month <= 5) {
        season = RegionalSeason.autumn;
      } else if (month >= 6 && month <= 8) {
        season = RegionalSeason.winter;
      } else {
        season = RegionalSeason.spring;
      }
    }

    // 2. Compute Circadian Daylight Phase
    DaylightPhase phase;
    if (hour >= 5 && hour < 7) {
      phase = DaylightPhase.dawn;
    } else if (hour >= 7 && hour < 12) {
      phase = DaylightPhase.morning;
    } else if (hour >= 12 && hour < 15) {
      phase = DaylightPhase.midday;
    } else if (hour >= 15 && hour < 17) {
      phase = DaylightPhase.afternoon;
    } else if (hour >= 17 && hour < 19) {
      phase = DaylightPhase.goldenHour;
    } else if (hour >= 19 && hour < 21) {
      phase = DaylightPhase.dusk;
    } else {
      phase = DaylightPhase.night;
    }

    // 3. Derive Ambient Background Colors
    Color canvasColor = phase.ambientCanvasColor;
    Color cardColor = const Color(0xFFEAF0EC); // Canonical sage green card

    if (isRainy) {
      canvasColor = const Color(0xFFEFF3F1);
      cardColor = const Color(0xFFE3EDE7);
    }

    return SeasonalContext(
      season: season,
      daylightPhase: phase,
      isNorthernHemisphere: isNorth,
      regionClassification: regionName,
      ambientBackground: canvasColor,
      cardBackground: cardColor,
      seasonalGuidanceNote: season.focusDescription,
    );
  }
}
