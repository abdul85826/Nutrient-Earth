// ==============================================================================
// Nutrient Earth — Avatar Scene Transition Manager
// Manages smooth, continuous environmental interpolation, wardrobe cross-fades,
// animation interruption arbitration, and state restoration after app suspension.
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/avatar_scene_state.dart';
import '../../domain/entities/world_state.dart';
import '../../domain/entities/astronomical_state.dart';

class AvatarTransitionManager {
  AvatarSceneState _currentScene;
  AvatarSceneState? _targetScene;
  double _transitionProgress = 1.0; // 0.0 to 1.0
  DateTime _transitionStartTime = DateTime.now();
  Duration _transitionDuration = const Duration(milliseconds: 750);

  AvatarTransitionManager(AvatarSceneState initialScene)
      : _currentScene = initialScene;

  AvatarSceneState get currentScene => _currentScene;
  AvatarSceneState? get targetScene => _targetScene;
  bool get isTransitioning => _transitionProgress < 1.0;
  double get transitionProgress => _transitionProgress;

  /// Requests a transition to a new target scene state.
  /// If an existing transition is in progress, smoothly retargets from the current interpolated state.
  void setTargetScene(
    AvatarSceneState newTarget, {
    Duration duration = const Duration(milliseconds: 750),
  }) {
    // If identical target already queued or achieved, do nothing
    if (_targetScene == newTarget || (_targetScene == null && _currentScene == newTarget)) {
      return;
    }

    // Freeze current interpolated state as starting point
    _currentScene = getInterpolatedScene();
    _targetScene = newTarget;
    _transitionDuration = duration;
    _transitionStartTime = DateTime.now();
    _transitionProgress = 0.0;
  }

  /// Advances transition clock by delta time and returns the authoritative interpolated scene.
  AvatarSceneState tick(DateTime now) {
    if (_targetScene == null || _transitionProgress >= 1.0) {
      return _currentScene;
    }

    final elapsedMs = now.difference(_transitionStartTime).inMilliseconds;
    final totalMs = _transitionDuration.inMilliseconds;
    final rawProgress = (elapsedMs / (totalMs > 0 ? totalMs : 1)).clamp(0.0, 1.0);

    // Smooth sinusoidal cubic ease-in-out curve
    _transitionProgress = Curves.easeInOutCubic.transform(rawProgress);

    if (_transitionProgress >= 1.0) {
      _currentScene = _targetScene!;
      _targetScene = null;
      return _currentScene;
    }

    return getInterpolatedScene();
  }

  /// Resets transition immediately without visual animation (e.g. after app resume or reduced motion)
  void snapToTarget(AvatarSceneState newScene) {
    _currentScene = newScene;
    _targetScene = null;
    _transitionProgress = 1.0;
  }

  /// Computes the exact interpolated state between `_currentScene` and `_targetScene`
  AvatarSceneState getInterpolatedScene() {
    if (_targetScene == null || _transitionProgress >= 1.0) {
      return _currentScene;
    }

    final from = _currentScene;
    final to = _targetScene!;
    final t = _transitionProgress;

    // 1. Interpolate World Lighting & Colors
    final interpolatedLighting = AmbientLightingState(
      skyColorTop: Color.lerp(from.world.lighting.skyColorTop, to.world.lighting.skyColorTop, t)!,
      skyColorBottom: Color.lerp(from.world.lighting.skyColorBottom, to.world.lighting.skyColorBottom, t)!,
      directionalLightColor: Color.lerp(
        from.world.lighting.directionalLightColor,
        to.world.lighting.directionalLightColor,
        t,
      )!,
      lightIntensity: _lerpDouble(from.world.lighting.lightIntensity, to.world.lighting.lightIntensity, t),
      warmthFactor: _lerpDouble(from.world.lighting.warmthFactor, to.world.lighting.warmthFactor, t),
      shadowLengthRatio: _lerpDouble(from.world.lighting.shadowLengthRatio, to.world.lighting.shadowLengthRatio, t),
      shadowSoftness: _lerpDouble(from.world.lighting.shadowSoftness, to.world.lighting.shadowSoftness, t),
      starVisibility: _lerpDouble(from.world.lighting.starVisibility, to.world.lighting.starVisibility, t),
      activeParticle: t < 0.5 ? from.world.lighting.activeParticle : to.world.lighting.activeParticle,
    );

    // 2. Interpolate Astronomy (solar altitude, shortest path azimuth)
    final fromAstro = from.world.astronomy;
    final toAstro = to.world.astronomy;
    final interpolatedSolarAltitude = _lerpDouble(fromAstro.solarAltitude, toAstro.solarAltitude, t);
    final interpolatedSolarAzimuth = _lerpAngleDegrees(fromAstro.solarAzimuth, toAstro.solarAzimuth, t);

    final interpolatedAstronomy = toAstro.copyWith(
      solarAltitude: interpolatedSolarAltitude,
      solarAzimuth: interpolatedSolarAzimuth,
    );

    // 3. Interpolate World State
    final interpolatedWorld = WorldState(
      astronomy: interpolatedAstronomy,
      season: t < 0.5 ? from.world.season : to.world.season,
      weather: t < 0.5 ? from.world.weather : to.world.weather,
      culturalPreference: t < 0.5 ? from.world.culturalPreference : to.world.culturalPreference,
      activeCulturalOccasion: t < 0.5 ? from.world.activeCulturalOccasion : to.world.activeCulturalOccasion,
      lighting: interpolatedLighting,
    );

    // 4. Character Appearance Switch (swaps cleanly at midpoint)
    final effectiveAppearance = t < 0.5 ? from.appearance : to.appearance;
    final effectiveBehaviour = t < 0.5 ? from.behaviour : to.behaviour;

    return from.copyWith(
      resolvedAtUtc: to.resolvedAtUtc,
      hasAvatar: to.hasAvatar,
      identity: to.identity, // Identity is immutable
      appearance: effectiveAppearance,
      behaviour: effectiveBehaviour,
      world: interpolatedWorld,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  /// Shortest angular interpolation in degrees (handles 359° -> 1° correctly without spinning 358°)
  static double _lerpAngleDegrees(double a, double b, double t) {
    double diff = (b - a) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return (a + diff * t) % 360.0;
  }
}
