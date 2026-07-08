/// BiologicalEventBus — Extended Event Definitions.
///
/// Central event bus for decoupled inter-component communication.
/// All components publish and subscribe through this singleton.
library;

import 'dart:async';

// ─── Event Base ───────────────────────────────────────────────────────────────

abstract class BIOSEvent {
  final String id;
  final DateTime timestamp;

  const BIOSEvent({required this.id, required this.timestamp});
}

// ─── Auth Events ──────────────────────────────────────────────────────────────

class UserAuthenticated extends BIOSEvent {
  final String userId;
  final String email;

  UserAuthenticated({required this.userId, required this.email})
      : super(id: 'auth_$userId', timestamp: DateTime.now());
}

class UserSignedOut extends BIOSEvent {
  UserSignedOut() : super(id: 'signout_${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now());
}

// ─── Onboarding Events ────────────────────────────────────────────────────────

class OnboardingStepCompleted extends BIOSEvent {
  final String userId;
  final int step;
  final Map<String, dynamic> stepData;

  OnboardingStepCompleted({required this.userId, required this.step, required this.stepData})
      : super(id: 'onboarding_step_${step}_$userId', timestamp: DateTime.now());
}

class OnboardingCompleted extends BIOSEvent {
  final String userId;

  OnboardingCompleted({required this.userId})
      : super(id: 'onboarding_complete_$userId', timestamp: DateTime.now());
}

// ─── Biological State Events ──────────────────────────────────────────────────

class BiologicalScoreUpdated extends BIOSEvent {
  final String userId;
  final double bisScore;
  final String primaryConstraint;

  BiologicalScoreUpdated({
    required super.id,
    required this.userId,
    required this.bisScore,
    required this.primaryConstraint,
  }) : super(timestamp: DateTime.now());
}

class RecoveryRecalculated extends BIOSEvent {
  final String userId;
  final double recoveryScore;

  RecoveryRecalculated({required this.userId, required this.recoveryScore})
      : super(id: 'recovery_$userId', timestamp: DateTime.now());
}

class EnvironmentalChanged extends BIOSEvent {
  final String userId;
  final double temperatureC;
  final int aqi;
  final double humidity;

  EnvironmentalChanged({
    required this.userId,
    required this.temperatureC,
    required this.aqi,
    required this.humidity,
  }) : super(id: 'env_${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now());
}

// ─── Feedback Events ──────────────────────────────────────────────────────────

class FeedbackReceived extends BIOSEvent {
  final String userId;
  final String recommendationId;
  final double adherenceScore;
  final String outcomeSymptom;

  FeedbackReceived({
    required super.id,
    required this.userId,
    required this.recommendationId,
    required this.adherenceScore,
    required this.outcomeSymptom,
  }) : super(timestamp: DateTime.now());
}

// ─── Wearable Events ──────────────────────────────────────────────────────────

class WearableSyncCompleted extends BIOSEvent {
  final String userId;
  final String provider;
  final int readingsIngested;

  WearableSyncCompleted({
    required this.userId,
    required this.provider,
    required this.readingsIngested,
  }) : super(id: 'wearable_sync_${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now());
}

// ─── System Events ─────────────────────────────────────────────────────────────

class SystemBootCompleted extends BIOSEvent {
  SystemBootCompleted()
      : super(id: 'boot_${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now());
}

class SystemError extends BIOSEvent {
  final String component;
  final String message;
  final Object? error;

  SystemError({required this.component, required this.message, this.error})
      : super(id: 'error_${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now());
}

// ─── Event Bus ─────────────────────────────────────────────────────────────────

class BiologicalEventBus {
  static final BiologicalEventBus _instance = BiologicalEventBus._internal();
  factory BiologicalEventBus() => _instance;
  BiologicalEventBus._internal();

  final StreamController<BIOSEvent> _controller =
      StreamController<BIOSEvent>.broadcast();

  Stream<BIOSEvent> get stream => _controller.stream;

  /// Publish an event to all subscribers.
  void fire(BIOSEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Subscribe to a specific event type.
  StreamSubscription<T> on<T extends BIOSEvent>(void Function(T event) handler) {
    return stream.where((e) => e is T).cast<T>().listen(handler);
  }

  /// Dispose the event bus (call only on app shutdown).
  void dispose() => _controller.close();
}
