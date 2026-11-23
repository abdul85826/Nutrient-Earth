// ==============================================================================
// Nutrient Earth — World Astronomy State Contract
// Comprehensive deterministic offline celestial state snapshot.
// Implements strict handling for extreme latitudes, polar days/nights, and twilight tiers.
// ==============================================================================

import 'package:flutter/foundation.dart';

enum TwilightState {
  day('Full Daylight', 'Bright ambient illumination and clear directional sunlight'),
  goldenHour('Golden Hour', 'Low-angle warm solar radiance and extended soft shadows'),
  civilTwilight('Civil Twilight', 'Sun between 0° and -6° below horizon; terrestrial objects clearly discernible'),
  nauticalTwilight('Nautical Twilight', 'Sun between -6° and -12° below horizon; general horizon visible, bright stars emerging'),
  astronomicalTwilight('Astronomical Twilight', 'Sun between -12° and -18° below horizon; faint stars visible, subtle atmospheric glow'),
  deepNight('Deep Night', 'Sun below -18°; full stellar visibility and lunar dominance');

  final String displayName;
  final String description;
  const TwilightState(this.displayName, this.description);

  bool get isDaylight => this == TwilightState.day || this == TwilightState.goldenHour;
  bool get isTwilight => this == TwilightState.civilTwilight || this == TwilightState.nauticalTwilight || this == TwilightState.astronomicalTwilight;
  bool get isNight => this == TwilightState.deepNight;
}

enum LunarPhase {
  newMoon('New Moon', 0.0),
  waxingCrescent('Waxing Crescent', 0.25),
  firstQuarter('First Quarter', 0.5),
  waxingGibbous('Waxing Gibbous', 0.75),
  fullMoon('Full Moon', 1.0),
  waningGibbous('Waning Gibbous', 0.75),
  thirdQuarter('Third Quarter (Last Quarter)', 0.5),
  waningCrescent('Waning Crescent', 0.25);

  final String displayName;
  final double approximateIllumination;
  const LunarPhase(this.displayName, this.approximateIllumination);
}

enum LocationPrecisionLevel {
  preciseGps,
  approximateCity,
  defaultReference;
}

@immutable
class WorldAstronomyState {
  final DateTime calculatedAtUtc;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final double solarAltitude; // -90° to +90°
  final double solarAzimuth; // 0° to 360° (0=N, 90=E, 180=S, 270=W)
  final DateTime? sunriseUtc; // null during polar day or polar night
  final DateTime? sunsetUtc; // null during polar day or polar night
  final DateTime solarNoonUtc;
  final TwilightState twilightState;
  final bool isPolarDay;
  final bool isPolarNight;
  final LunarPhase lunarPhase;
  final double lunarIllumination; // 0.0 (New) to 1.0 (Full)
  final double lunarAltitude; // -90° to +90°
  final double lunarAzimuth; // 0° to 360°
  final bool isMoonAboveHorizon;
  final String calculationAccuracy;
  final LocationPrecisionLevel locationAccuracy;

  const WorldAstronomyState({
    required this.calculatedAtUtc,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.solarAltitude,
    required this.solarAzimuth,
    this.sunriseUtc,
    this.sunsetUtc,
    required this.solarNoonUtc,
    required this.twilightState,
    this.isPolarDay = false,
    this.isPolarNight = false,
    required this.lunarPhase,
    required this.lunarIllumination,
    required this.lunarAltitude,
    required this.lunarAzimuth,
    required this.isMoonAboveHorizon,
    this.calculationAccuracy = 'NOAA Solar & Meeus Lunar Equations (Offline Certified)',
    this.locationAccuracy = LocationPrecisionLevel.approximateCity,
  });

  bool get isDay => twilightState.isDaylight;
  bool get isNight => twilightState.isNight;
  bool get isCivilTwilight => twilightState == TwilightState.civilTwilight;
  bool get isNauticalTwilight => twilightState == TwilightState.nauticalTwilight;
  bool get isAstronomicalTwilight => twilightState == TwilightState.astronomicalTwilight;
  double get lunarIlluminationFraction => lunarIllumination;

  WorldAstronomyState copyWith({
    DateTime? calculatedAtUtc,
    double? latitude,
    double? longitude,
    String? timezoneId,
    double? solarAltitude,
    double? solarAzimuth,
    DateTime? sunriseUtc,
    DateTime? sunsetUtc,
    DateTime? solarNoonUtc,
    TwilightState? twilightState,
    bool? isPolarDay,
    bool? isPolarNight,
    LunarPhase? lunarPhase,
    double? lunarIllumination,
    double? lunarAltitude,
    double? lunarAzimuth,
    bool? isMoonAboveHorizon,
    String? calculationAccuracy,
    LocationPrecisionLevel? locationAccuracy,
  }) {
    TwilightState resolvedTwilight = twilightState ?? this.twilightState;
    if (solarAltitude != null && twilightState == null) {
      if (solarAltitude > 6.0) {
        resolvedTwilight = TwilightState.day;
      } else if (solarAltitude > 0.0) {
        resolvedTwilight = TwilightState.goldenHour;
      } else if (solarAltitude >= -6.0) {
        resolvedTwilight = TwilightState.civilTwilight;
      } else if (solarAltitude >= -12.0) {
        resolvedTwilight = TwilightState.nauticalTwilight;
      } else if (solarAltitude >= -18.0) {
        resolvedTwilight = TwilightState.astronomicalTwilight;
      } else {
        resolvedTwilight = TwilightState.deepNight;
      }
    }

    return WorldAstronomyState(
      calculatedAtUtc: calculatedAtUtc ?? this.calculatedAtUtc,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneId: timezoneId ?? this.timezoneId,
      solarAltitude: solarAltitude ?? this.solarAltitude,
      solarAzimuth: solarAzimuth ?? this.solarAzimuth,
      sunriseUtc: sunriseUtc ?? this.sunriseUtc,
      sunsetUtc: sunsetUtc ?? this.sunsetUtc,
      solarNoonUtc: solarNoonUtc ?? this.solarNoonUtc,
      twilightState: resolvedTwilight,
      isPolarDay: isPolarDay ?? this.isPolarDay,
      isPolarNight: isPolarNight ?? this.isPolarNight,
      lunarPhase: lunarPhase ?? this.lunarPhase,
      lunarIllumination: lunarIllumination ?? this.lunarIllumination,
      lunarAltitude: lunarAltitude ?? this.lunarAltitude,
      lunarAzimuth: lunarAzimuth ?? this.lunarAzimuth,
      isMoonAboveHorizon: isMoonAboveHorizon ?? this.isMoonAboveHorizon,
      calculationAccuracy: calculationAccuracy ?? this.calculationAccuracy,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
    );
  }

  /// Factory creating verified default baseline (reference temperate coordinates)
  factory WorldAstronomyState.defaultBaseline({DateTime? time}) {
    final utc = (time ?? DateTime.now()).toUtc();
    return WorldAstronomyState(
      calculatedAtUtc: utc,
      latitude: 28.6139, // New Delhi reference
      longitude: 77.2090,
      timezoneId: 'Asia/Kolkata',
      solarAltitude: 35.0,
      solarAzimuth: 160.0,
      solarNoonUtc: DateTime.utc(utc.year, utc.month, utc.day, 6, 40),
      sunriseUtc: DateTime.utc(utc.year, utc.month, utc.day, 1, 15),
      sunsetUtc: DateTime.utc(utc.year, utc.month, utc.day, 12, 10),
      twilightState: TwilightState.day,
      lunarPhase: LunarPhase.waxingCrescent,
      lunarIllumination: 0.35,
      lunarAltitude: -15.0,
      lunarAzimuth: 240.0,
      isMoonAboveHorizon: false,
      locationAccuracy: LocationPrecisionLevel.defaultReference,
    );
  }

  Map<String, dynamic> toJson() => {
        'calculated_at_utc': calculatedAtUtc.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'timezone_id': timezoneId,
        'solar_altitude': solarAltitude,
        'solar_azimuth': solarAzimuth,
        'sunrise_utc': sunriseUtc?.toIso8601String(),
        'sunset_utc': sunsetUtc?.toIso8601String(),
        'solar_noon_utc': solarNoonUtc.toIso8601String(),
        'twilight_state': twilightState.name,
        'is_polar_day': isPolarDay,
        'is_polar_night': isPolarNight,
        'lunar_phase': lunarPhase.name,
        'lunar_illumination': lunarIllumination,
        'lunar_altitude': lunarAltitude,
        'lunar_azimuth': lunarAzimuth,
        'is_moon_above_horizon': isMoonAboveHorizon,
        'calculation_accuracy': calculationAccuracy,
        'location_accuracy': locationAccuracy.name,
      };
}
