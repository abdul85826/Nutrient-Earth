// ==============================================================================
// Nutrient Earth — Single Authoritative Avatar Scene State
// The definitive, immutable state consumed by all rendering layers.
// Prevents conflicting visual states (e.g. rain with dry sky, midday sun at night).
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'avatar_identity.dart';
import 'avatar_appearance.dart';
import 'avatar_behaviour.dart';
import 'astronomical_state.dart';
import 'world_state.dart';

@immutable
class AvatarSceneState {
  final String sceneVersion;
  final DateTime resolvedAtUtc;
  final bool hasAvatar;
  final AvatarIdentity identity;
  final AvatarAppearance appearance;
  final AvatarBehaviour behaviour;
  final WorldState world;
  final bool isReducedMotionEnabled;
  final bool isStaticFallback;

  const AvatarSceneState({
    this.sceneVersion = '2026.3.1',
    required this.resolvedAtUtc,
    this.hasAvatar = true,
    required this.identity,
    required this.appearance,
    required this.behaviour,
    required this.world,
    this.isReducedMotionEnabled = false,
    this.isStaticFallback = false,
  });

  /// Verified default baseline scene state
  factory AvatarSceneState.defaultBaseline({
    String? skinToneHex,
    bool hasAvatar = false,
  }) {
    final now = DateTime.now().toUtc();
    final astronomy = WorldAstronomyState.defaultBaseline(time: now);
    return AvatarSceneState(
      resolvedAtUtc: now,
      hasAvatar: hasAvatar,
      identity: AvatarIdentity.defaultBaseline(skinToneHex: skinToneHex),
      appearance: AvatarAppearance.defaultBaseline(),
      behaviour: AvatarBehaviour.defaultBaseline(),
      world: WorldState(
        astronomy: astronomy,
        season: RegionalSeason.vasanta,
        weather: AmbientWeatherState.neutralFallback(),
        culturalPreference: CulturalPresentationPreference.neutralNature,
        lighting: AmbientLightingState.defaultDaylight(),
      ),
    );
  }

  AvatarSceneState copyWith({
    String? sceneVersion,
    DateTime? resolvedAtUtc,
    bool? hasAvatar,
    AvatarIdentity? identity,
    AvatarAppearance? appearance,
    AvatarBehaviour? behaviour,
    WorldState? world,
    bool? isReducedMotionEnabled,
    bool? isStaticFallback,
  }) {
    return AvatarSceneState(
      sceneVersion: sceneVersion ?? this.sceneVersion,
      resolvedAtUtc: resolvedAtUtc ?? this.resolvedAtUtc,
      hasAvatar: hasAvatar ?? this.hasAvatar,
      identity: identity ?? this.identity,
      appearance: appearance ?? this.appearance,
      behaviour: behaviour ?? this.behaviour,
      world: world ?? this.world,
      isReducedMotionEnabled: isReducedMotionEnabled ?? this.isReducedMotionEnabled,
      isStaticFallback: isStaticFallback ?? this.isStaticFallback,
    );
  }
}
