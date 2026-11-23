// ==============================================================================
// Nutrient Earth — Regional Season Resolver
// Supports Western 4-Season and Classical Indian 6-Ritu (Ayurvedic) frameworks.
// Performs Southern Hemisphere inversion and latitude-aware climatology.
// ==============================================================================

import '../entities/world_state.dart';

class SeasonResolver {
  SeasonResolver._();

  /// Resolves the authentic regional season based on date, latitude, longitude, and optional preference
  static RegionalSeason resolve({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String timezoneId,
    CulturalPresentationPreference culturalPreference = CulturalPresentationPreference.neutralNature,
  }) {
    final month = date.month;
    final day = date.day;
    final dayOfYear = _dayOfYear(date.year, month, day);

    // 1. Detect if location belongs to Indian Subcontinent / South Asia
    final bool isIndianSubcontinent = (latitude >= 6.0 && latitude <= 37.0 && longitude >= 68.0 && longitude <= 98.0) ||
        timezoneId.contains('Kolkata') ||
        timezoneId.contains('Calcutta') ||
        culturalPreference == CulturalPresentationPreference.indicTraditional;

    if (isIndianSubcontinent) {
      return _resolveIndianRitu(dayOfYear);
    }

    // 2. Temperate / Global Climatology with Southern Hemisphere Inversion
    final bool isSouthernHemisphere = latitude < 0.0;
    final int effectiveDayOfYear = isSouthernHemisphere ? ((dayOfYear + 182) % 365) : dayOfYear;

    return _resolveWesternSeason(effectiveDayOfYear);
  }

  /// Indian 6-Ritu Astronomical & Climatological Boundaries
  /// 1. Shishira (Late Winter): Jan 15 – Mar 14 (~day 15 to 73)
  /// 2. Vasanta (Spring): Mar 15 – May 14 (~day 74 to 134)
  /// 3. Grishma (Summer): May 15 – Jul 14 (~day 135 to 195)
  /// 4. Varsha (Monsoon): Jul 15 – Sep 14 (~day 196 to 257)
  /// 5. Sharad (Autumn): Sep 15 – Nov 14 (~day 258 to 318)
  /// 6. Hemanta (Early Winter): Nov 15 – Jan 14 (~day 319 to 365 and 1 to 14)
  static RegionalSeason _resolveIndianRitu(int dayOfYear) {
    if (dayOfYear >= 74 && dayOfYear <= 134) {
      return RegionalSeason.vasanta;
    } else if (dayOfYear >= 135 && dayOfYear <= 195) {
      return RegionalSeason.grishma;
    } else if (dayOfYear >= 196 && dayOfYear <= 257) {
      return RegionalSeason.varsha;
    } else if (dayOfYear >= 258 && dayOfYear <= 318) {
      return RegionalSeason.sharad;
    } else if (dayOfYear >= 319 || dayOfYear <= 14) {
      return RegionalSeason.hemanta;
    } else {
      return RegionalSeason.shishira;
    }
  }

  /// Western 4-Season Framework
  /// Vernal Equinox (~Mar 21, day 80) to Summer Solstice (~Jun 21, day 172) -> Spring
  /// Summer Solstice to Autumnal Equinox (~Sep 22, day 265) -> Summer
  /// Autumnal Equinox to Winter Solstice (~Dec 21, day 355) -> Autumn
  /// Winter Solstice to Vernal Equinox -> Winter
  static RegionalSeason _resolveWesternSeason(int dayOfYear) {
    if (dayOfYear >= 80 && dayOfYear < 172) {
      return RegionalSeason.spring;
    } else if (dayOfYear >= 172 && dayOfYear < 265) {
      return RegionalSeason.summer;
    } else if (dayOfYear >= 265 && dayOfYear < 355) {
      return RegionalSeason.autumn;
    } else {
      return RegionalSeason.winter;
    }
  }

  static int _dayOfYear(int year, int month, int day) {
    const daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int count = 0;
    for (int i = 1; i < month; i++) {
      count += daysInMonths[i];
    }
    // Leap year adjustment
    if (month > 2 && ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)) {
      count += 1;
    }
    return count + day;
  }
}
