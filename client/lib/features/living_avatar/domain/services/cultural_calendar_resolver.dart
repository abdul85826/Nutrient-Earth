// ==============================================================================
// Nutrient Earth — Verified Cultural Occasion Resolver
// Strictly optional, user-opt-in only. Zero demographic inference.
// Respects neutral nature baseline while providing verified astronomical festival dates.
// ==============================================================================

import '../entities/world_state.dart';

class CulturalCalendarResolver {
  CulturalCalendarResolver._();

  /// Resolves active festival occasion ONLY IF user has opted into a specific cultural calendar.
  /// If preference is neutralNature (default), returns null unconditionally.
  static VerifiedCulturalOccasion? resolveActiveOccasion({
    required DateTime dateUtc,
    required CulturalPresentationPreference preference,
  }) {
    if (preference.isNeutral) {
      return null;
    }

    final year = dateUtc.year;

    switch (preference) {
      case CulturalPresentationPreference.indicTraditional:
        return _checkIndicCalendar(dateUtc, year);
      case CulturalPresentationPreference.islamicHeritage:
        return _checkIslamicCalendar(dateUtc, year);
      case CulturalPresentationPreference.westernHeritage:
        return _checkWesternCalendar(dateUtc, year);
      case CulturalPresentationPreference.eastAsianHeritage:
        return _checkEastAsianCalendar(dateUtc, year);
      case CulturalPresentationPreference.neutralNature:
        return null;
    }
  }

  static VerifiedCulturalOccasion? _checkIndicCalendar(DateTime utc, int year) {
    // Verified Occasions for 2026 & Generic Windows
    // 1. Makar Sankranti / Pongal (Solar transit of Capricorn: Jan 14-15)
    if (utc.month == 1 && (utc.day == 14 || utc.day == 15)) {
      return VerifiedCulturalOccasion(
        festivalId: 'indic_sankranti_pongal',
        festivalName: 'Makar Sankranti & Pongal',
        visualMotif: 'sun_salutation_brass_accent',
        effectiveFromUtc: DateTime.utc(year, 1, 14),
        effectiveToUtc: DateTime.utc(year, 1, 16),
      );
    }

    // 2. Holi (Phalguna Purnima: ~March 3-4, 2026)
    if (utc.month == 3 && (utc.day >= 3 && utc.day <= 4)) {
      return VerifiedCulturalOccasion(
        festivalId: 'indic_holi',
        festivalName: 'Holi (Festival of Spring Renewal)',
        visualMotif: 'botanical_gulal_shimmer',
        effectiveFromUtc: DateTime.utc(year, 3, 3),
        effectiveToUtc: DateTime.utc(year, 3, 5),
      );
    }

    // 3. Navratri / Dussehra (Sharad Navratri: ~Oct 11-20, 2026)
    if (utc.month == 10 && (utc.day >= 11 && utc.day <= 20)) {
      return VerifiedCulturalOccasion(
        festivalId: 'indic_navratri',
        festivalName: 'Sharad Navratri',
        visualMotif: 'traditional_festive_kurta',
        effectiveFromUtc: DateTime.utc(year, 10, 11),
        effectiveToUtc: DateTime.utc(year, 10, 21),
      );
    }

    // 4. Diwali / Deepavali (Kartika Amavasya: ~Nov 8, 2026)
    if (utc.month == 11 && (utc.day >= 7 && utc.day <= 9)) {
      return VerifiedCulturalOccasion(
        festivalId: 'indic_diwali',
        festivalName: 'Diwali (Deepavali)',
        visualMotif: 'earthen_diya_gentle_glow',
        effectiveFromUtc: DateTime.utc(year, 11, 7),
        effectiveToUtc: DateTime.utc(year, 11, 10),
      );
    }

    return null;
  }

  static VerifiedCulturalOccasion? _checkIslamicCalendar(DateTime utc, int year) {
    // 1. Eid al-Fitr (~Mar 20-21, 2026)
    if (utc.month == 3 && (utc.day >= 20 && utc.day <= 22)) {
      return VerifiedCulturalOccasion(
        festivalId: 'islamic_eid_al_fitr',
        festivalName: 'Eid al-Fitr',
        visualMotif: 'crescent_festive_finery',
        effectiveFromUtc: DateTime.utc(year, 3, 20),
        effectiveToUtc: DateTime.utc(year, 3, 23),
      );
    }

    // 2. Eid al-Adha (~May 27-28, 2026)
    if (utc.month == 5 && (utc.day >= 27 && utc.day <= 29)) {
      return VerifiedCulturalOccasion(
        festivalId: 'islamic_eid_al_adha',
        festivalName: 'Eid al-Adha',
        visualMotif: 'serene_festive_attire',
        effectiveFromUtc: DateTime.utc(year, 5, 27),
        effectiveToUtc: DateTime.utc(year, 5, 30),
      );
    }

    return null;
  }

  static VerifiedCulturalOccasion? _checkWesternCalendar(DateTime utc, int year) {
    // Christmas / Winter Solstice (Dec 24-26)
    if (utc.month == 12 && (utc.day >= 24 && utc.day <= 26)) {
      return VerifiedCulturalOccasion(
        festivalId: 'western_christmas_solstice',
        festivalName: 'Winter Solstice & Christmas Season',
        visualMotif: 'evergreen_winter_knit',
        effectiveFromUtc: DateTime.utc(year, 12, 24),
        effectiveToUtc: DateTime.utc(year, 12, 27),
      );
    }

    // New Year (Dec 31 - Jan 1)
    if ((utc.month == 12 && utc.day == 31) || (utc.month == 1 && utc.day == 1)) {
      return VerifiedCulturalOccasion(
        festivalId: 'western_new_year',
        festivalName: 'New Year Reflection',
        visualMotif: 'restorative_journal_presence',
        effectiveFromUtc: DateTime.utc(year, 12, 31),
        effectiveToUtc: DateTime.utc(year, 1, 2),
      );
    }

    return null;
  }

  static VerifiedCulturalOccasion? _checkEastAsianCalendar(DateTime utc, int year) {
    // Lunar New Year (Spring Festival: ~Feb 17, 2026)
    if (utc.month == 2 && (utc.day >= 16 && utc.day <= 18)) {
      return VerifiedCulturalOccasion(
        festivalId: 'east_asian_lunar_new_year',
        festivalName: 'Lunar New Year',
        visualMotif: 'crimson_silk_accent',
        effectiveFromUtc: DateTime.utc(year, 2, 16),
        effectiveToUtc: DateTime.utc(year, 2, 19),
      );
    }

    // Mid-Autumn Festival (~Sep 25, 2026)
    if (utc.month == 9 && (utc.day >= 24 && utc.day <= 26)) {
      return VerifiedCulturalOccasion(
        festivalId: 'east_asian_mid_autumn',
        festivalName: 'Mid-Autumn Moon Festival',
        visualMotif: 'harvest_moon_contemplation',
        effectiveFromUtc: DateTime.utc(year, 9, 24),
        effectiveToUtc: DateTime.utc(year, 9, 27),
      );
    }

    return null;
  }
}
