// ==============================================================================
// Nutrient Earth — Avatar Behaviour & Kinesics Contract
// Models procedural vitality: non-repetitive breathing, natural blinks, micro-saccades,
// diurnal posture transitions, and contextual actions.
// ==============================================================================

import 'package:flutter/foundation.dart';

enum FacialExpressionType {
  calmAwake,
  focusedInsight,
  sereneContentment,
  restfulPeace,
  gentleCuriosity,
  energizedReady;

  String get displayName {
    switch (this) {
      case FacialExpressionType.calmAwake:
        return 'Calm & Grounded';
      case FacialExpressionType.focusedInsight:
        return 'Deep Scientific Focus';
      case FacialExpressionType.sereneContentment:
        return 'Serene Contentment';
      case FacialExpressionType.restfulPeace:
        return 'Restful Deep Peace';
      case FacialExpressionType.gentleCuriosity:
        return 'Gentle Curiosity';
      case FacialExpressionType.energizedReady:
        return 'Energized & Vital';
    }
  }
}

enum EyeGazeState {
  forwardDirect,
  horizonContemplation,
  downwardReflection,
  softlyClosed;
}

enum PostureAlignment {
  uprightEnergized,
  relaxedPoised,
  gentleStretch,
  restfulCozy,
  meditativeStillness;
}

enum CharacterAction {
  restingPresence,
  sippingHydration,
  reviewingJournal,
  holdingBotanical,
  shelteredFromRain,
  relaxingHerbalTea;

  static const CharacterAction hydrating = CharacterAction.sippingHydration;
  static const CharacterAction readingJournal = CharacterAction.reviewingJournal;
}

@immutable
class AvatarBehaviour {
  final FacialExpressionType expression;
  final EyeGazeState gaze;
  final PostureAlignment posture;
  final CharacterAction currentAction;
  final double breathingRateBpm; // e.g. 14.0 bpm morning, 10.0 evening, 6.0 night
  final double blinkFrequencySeconds; // average interval between blinks (3.5 - 5.5s)
  final double headTiltDegrees; // subtle micro-tilt (-3.0 to +3.0)
  final double gazeShiftX; // micro-saccade horizontal (-1.0 to 1.0)
  final double gazeShiftY; // micro-saccade vertical (-1.0 to 1.0)

  const AvatarBehaviour({
    this.expression = FacialExpressionType.calmAwake,
    this.gaze = EyeGazeState.forwardDirect,
    this.posture = PostureAlignment.relaxedPoised,
    this.currentAction = CharacterAction.restingPresence,
    this.breathingRateBpm = 12.0,
    this.blinkFrequencySeconds = 4.0,
    this.headTiltDegrees = 0.0,
    this.gazeShiftX = 0.0,
    this.gazeShiftY = 0.0,
  });

  /// Default baseline behaviour
  factory AvatarBehaviour.defaultBaseline() => const AvatarBehaviour();

  AvatarBehaviour copyWith({
    FacialExpressionType? expression,
    EyeGazeState? gaze,
    PostureAlignment? posture,
    CharacterAction? currentAction,
    double? breathingRateBpm,
    double? blinkFrequencySeconds,
    double? headTiltDegrees,
    double? gazeShiftX,
    double? gazeShiftY,
  }) {
    return AvatarBehaviour(
      expression: expression ?? this.expression,
      gaze: gaze ?? this.gaze,
      posture: posture ?? this.posture,
      currentAction: currentAction ?? this.currentAction,
      breathingRateBpm: breathingRateBpm ?? this.breathingRateBpm,
      blinkFrequencySeconds: blinkFrequencySeconds ?? this.blinkFrequencySeconds,
      headTiltDegrees: headTiltDegrees ?? this.headTiltDegrees,
      gazeShiftX: gazeShiftX ?? this.gazeShiftX,
      gazeShiftY: gazeShiftY ?? this.gazeShiftY,
    );
  }

  Map<String, dynamic> toJson() => {
        'expression': expression.name,
        'gaze': gaze.name,
        'posture': posture.name,
        'current_action': currentAction.name,
        'breathing_rate_bpm': breathingRateBpm,
        'blink_frequency_seconds': blinkFrequencySeconds,
        'head_tilt_degrees': headTiltDegrees,
        'gaze_shift_x': gazeShiftX,
        'gaze_shift_y': gazeShiftY,
      };

  factory AvatarBehaviour.fromJson(Map<String, dynamic> json) {
    return AvatarBehaviour(
      expression: FacialExpressionType.values.firstWhere(
        (e) => e.name == json['expression'],
        orElse: () => FacialExpressionType.calmAwake,
      ),
      gaze: EyeGazeState.values.firstWhere(
        (e) => e.name == json['gaze'],
        orElse: () => EyeGazeState.forwardDirect,
      ),
      posture: PostureAlignment.values.firstWhere(
        (e) => e.name == json['posture'],
        orElse: () => PostureAlignment.relaxedPoised,
      ),
      currentAction: CharacterAction.values.firstWhere(
        (e) => e.name == json['current_action'],
        orElse: () => CharacterAction.restingPresence,
      ),
      breathingRateBpm: (json['breathing_rate_bpm'] as num?)?.toDouble() ?? 12.0,
      blinkFrequencySeconds: (json['blink_frequency_seconds'] as num?)?.toDouble() ?? 4.0,
      headTiltDegrees: (json['head_tilt_degrees'] as num?)?.toDouble() ?? 0.0,
      gazeShiftX: (json['gaze_shift_x'] as num?)?.toDouble() ?? 0.0,
      gazeShiftY: (json['gaze_shift_y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
