// ==============================================================================
// Nutrient Earth — Rive Avatar Adapter & Input Bindings
// Clean architectural adapter bridging Rive State Machine controllers with
// the Living Avatar procedural engine. Provides graceful fallback when
// .riv assets are absent or loading.
// ==============================================================================

import '../../domain/entities/avatar_scene_state.dart';

/// Contract for binding real-time Living Avatar scene state into a Rive StateMachine.
abstract class RiveAvatarAdapter {
  /// Whether an active Rive file is loaded and operating
  bool get isRiveActive;

  /// Initialize Rive asset from bundle
  Future<bool> initialize({String assetPath = 'assets/rive/living_avatar.riv'});

  /// Sync the current scene state to Rive StateMachine inputs
  void syncState(AvatarSceneState sceneState);

  /// Trigger a discrete animation event (e.g., blink, nod, sip)
  void triggerEvent(String eventName);

  /// Dispose Rive controller resources
  void dispose();
}

/// Fallback / Procedural implementation of the Rive Avatar Adapter.
/// Used when .riv binaries are not packaged, ensuring 100% offline procedural operation.
class ProceduralAvatarAdapter implements RiveAvatarAdapter {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  @override
  bool get isRiveActive => false;

  @override
  Future<bool> initialize({String assetPath = 'assets/rive/living_avatar.riv'}) async {
    // Graceful procedural fallback
    _initialized = true;
    return false;
  }

  @override
  void syncState(AvatarSceneState sceneState) {
    // State is rendered dynamically by CustomPainters
  }

  @override
  void triggerEvent(String eventName) {
    // Procedural events handled via animation ticker
  }

  @override
  void dispose() {
    _initialized = false;
  }
}

/// Typed definitions of Rive State Machine Inputs for Living Avatar specifications.
class RiveStateMachineInputs {
  // Numbers
  static const String breathingRateBpm = 'num_breathing_bpm';
  static const String solarAltitudeDeg = 'num_solar_altitude';
  static const String lunarPhaseFraction = 'num_lunar_phase';
  static const String temperatureCelsius = 'num_temp_celsius';
  static const String rainIntensity = 'num_rain_intensity';
  static const String gazeX = 'num_gaze_x';
  static const String gazeY = 'num_gaze_y';

  // Booleans
  static const String isNight = 'bool_is_night';
  static const String isRaining = 'bool_is_raining';
  static const String isHoldingProp = 'bool_holding_prop';

  // Triggers
  static const String triggerBlink = 'trig_blink';
  static const String triggerSaccade = 'trig_saccade';
  static const String triggerSip = 'trig_sip';

  // Enums / State Integers
  static const String clothingTypeIndex = 'enum_clothing_type';
  static const String seasonIndex = 'enum_season';
}
