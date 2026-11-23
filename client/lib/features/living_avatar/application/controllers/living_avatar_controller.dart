// ==============================================================================
// Nutrient Earth — Living Avatar Controller
// High-performance StateNotifier managing the authoritative AvatarSceneState.
// Schedules diurnal astronomical recalculation every 5 minutes and updates
// in response to telemetry, seasonal chronobiology, and user preferences.
// ==============================================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/personalization/user_profile_context.dart';
import '../../domain/entities/avatar_identity.dart';
import '../../domain/entities/avatar_appearance.dart';
import '../../domain/entities/world_state.dart';
import '../../domain/entities/avatar_scene_state.dart';
import '../../domain/services/avatar_state_resolver.dart';
import '../../domain/services/weather_state_adapter.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../today/state/today_state.dart';

/// Provider for the single authoritative Living Avatar scene state
final livingAvatarControllerProvider =
    StateNotifierProvider<LivingAvatarController, AvatarSceneState>((ref) {
  final todayState = ref.watch(todayNotifierProvider);
  return LivingAvatarController(
    profile: todayState.userProfile,
    telemetry: todayState.telemetry,
  );
});

class LivingAvatarController extends StateNotifier<AvatarSceneState> {
  Timer? _astronomicalRefreshTimer;
  UserProfileContext? _userProfile;
  TelemetryData? _latestTelemetry;
  AvatarAppearance? _customAppearance;
  CulturalPresentationPreference _culturalPreference =
      CulturalPresentationPreference.neutralNature;

  // Geographic context (defaults to standard coordinates, easily configurable)
  double _latitude = 37.7749;
  double _longitude = -122.4194;
  String _timezoneId = 'America/Los_Angeles';

  LivingAvatarController({
    UserProfileContext? profile,
    TelemetryData? telemetry,
    double? latitude,
    double? longitude,
    String? timezoneId,
  })  : _userProfile = profile,
        _latestTelemetry = telemetry,
        _latitude = latitude ?? 37.7749,
        _longitude = longitude ?? -122.4194,
        _timezoneId = timezoneId ?? 'America/Los_Angeles',
        super(_initialScene(profile, telemetry, latitude ?? 37.7749, longitude ?? -122.4194, timezoneId ?? 'America/Los_Angeles')) {
    _startPeriodicAstronomicalSync();
  }

  static AvatarSceneState _initialScene(
    UserProfileContext? profile,
    TelemetryData? telemetry,
    double latitude,
    double longitude,
    String timezoneId,
  ) {
    final identity = _buildIdentity(profile);
    final weather = telemetry != null
        ? WeatherStateAdapter.fromTelemetry(
            temperatureCelsius: telemetry.temperatureCelsius,
            weatherCondition: telemetry.weatherCondition,
            aqi: telemetry.aqi.toDouble(),
          )
        : AmbientWeatherState.neutralFallback();

    return AvatarStateResolver.resolve(
      identity: identity,
      timeUtc: DateTime.now().toUtc(),
      latitude: latitude,
      longitude: longitude,
      timezoneId: timezoneId,
      weather: weather,
      culturalPreference: CulturalPresentationPreference.neutralNature,
      hasAvatar: profile?.hasAvatar ?? false,
    );
  }

  void _startPeriodicAstronomicalSync() {
    _astronomicalRefreshTimer?.cancel();
    // Recompute astronomy and diurnal lighting every 5 minutes (300 seconds)
    // 100% offline, pure deterministic math (NOAA + Meeus)
    _astronomicalRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => recalculateWorldState(),
    );
  }

  /// Recalculates astronomy, seasons, and lighting for the current moment
  void recalculateWorldState() {
    final identity = _buildIdentity(_userProfile);
    final weather = _latestTelemetry != null
        ? WeatherStateAdapter.fromTelemetry(
            temperatureCelsius: _latestTelemetry!.temperatureCelsius,
            weatherCondition: _latestTelemetry!.weatherCondition,
            aqi: _latestTelemetry!.aqi.toDouble(),
          )
        : AmbientWeatherState.neutralFallback();

    final nextScene = AvatarStateResolver.resolve(
      identity: identity,
      requestedAppearance: _customAppearance,
      timeUtc: DateTime.now().toUtc(),
      latitude: _latitude,
      longitude: _longitude,
      timezoneId: _timezoneId,
      weather: weather,
      culturalPreference: _culturalPreference,
      hasAvatar: _userProfile?.hasAvatar ?? state.hasAvatar,
    );

    state = nextScene;
  }

  /// Synchronize when user profile updates (e.g., skin tone, demographics)
  void syncUserProfile(UserProfileContext? profile) {
    _userProfile = profile;
    recalculateWorldState();
  }

  /// Synchronize when telemetry updates (e.g., temperature, rain, AQI)
  void syncTelemetry(TelemetryData telemetry) {
    _latestTelemetry = telemetry;
    recalculateWorldState();
  }

  /// Set explicit geographic coordinates
  void setCoordinates({
    required double latitude,
    required double longitude,
    required String timezoneId,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _timezoneId = timezoneId;
    recalculateWorldState();
  }

  /// Set cultural calendar preference (strictly opt-in, default neutralNature)
  void setCulturalPreference(CulturalPresentationPreference preference) {
    _culturalPreference = preference;
    recalculateWorldState();
  }

  /// Update user skin tone (preserves base geometry)
  void updateSkinTone(String hex) {
    final updatedIdentity = state.identity.copyWith(skinToneHex: hex);
    state = state.copyWith(
      identity: updatedIdentity,
      hasAvatar: true,
    );
  }

  /// Update hairstyle
  void updateHairstyle(HairstyleIdentity hair) {
    final updatedIdentity = state.identity.copyWith(hairIdentity: hair);
    state = state.copyWith(identity: updatedIdentity);
  }

  /// Update clothing
  void updateClothing(ClothingType clothing) {
    _customAppearance = state.appearance.copyWith(clothing: clothing);
    recalculateWorldState();
  }

  /// Update outerwear
  void updateOuterwear(OuterwearType outerwear) {
    _customAppearance = state.appearance.copyWith(outerwear: outerwear);
    recalculateWorldState();
  }

  /// Helper to convert UserProfileContext into immutable AvatarIdentity
  static AvatarIdentity _buildIdentity(UserProfileContext? profile) {
    final hex = profile?.skinTone ?? '#E0AC69';
    final name = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : 'Companion';

    // Parse additional avatarConfig if present
    final config = profile?.avatarConfig ?? const {};
    final faceGeoName = config['face_geometry'] as String?;
    final faceGeometry = FaceGeometryType.values.firstWhere(
      (e) => e.name == faceGeoName,
      orElse: () => FaceGeometryType.oval,
    );

    final hairName = config['hair_identity'] as String?;
    final hairIdentity = HairstyleIdentity.values.firstWhere(
      (e) => e.name == hairName,
      orElse: () => HairstyleIdentity.wavyMedium,
    );

    return AvatarIdentity(
      identityId: 'id_${profile?.userId ?? 'usr_guest'}',
      name: name,
      skinToneHex: hex,
      faceGeometry: faceGeometry,
      hairIdentity: hairIdentity,
      eyeColorHex: config['eye_color_hex'] as String? ?? '#2C1E14',
      hairColorHex: config['hair_color_hex'] as String? ?? '#1B1C19',
    );
  }

  @override
  void dispose() {
    _astronomicalRefreshTimer?.cancel();
    super.dispose();
  }
}
