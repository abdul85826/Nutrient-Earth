import 'biological_event.dart';

// Helper to quickly create events without repetitive boilerplate
abstract class BaseBiologicalEvent extends BiologicalEvent {
  BaseBiologicalEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.eventType,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.reversibility,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  });

  @override
  Map<String, dynamic> toMap() {
    return baseMap();
  }
}

class SleepEvent extends BaseBiologicalEvent {
  SleepEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'sleep',
          reversibility: true,
        );
}

class RecoveryEvent extends BaseBiologicalEvent {
  RecoveryEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'recovery',
          reversibility: true,
        );
}

class HydrationEvent extends BaseBiologicalEvent {
  HydrationEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'hydration',
          reversibility: true,
        );
}

class StressEvent extends BaseBiologicalEvent {
  StressEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'stress',
          reversibility: true,
        );
}

class NutritionEvent extends BaseBiologicalEvent {
  NutritionEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'nutrition',
          reversibility: true,
        );
}

class SupplementEvent extends BaseBiologicalEvent {
  SupplementEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'supplement',
          reversibility: true,
        );
}

class ActivityEvent extends BaseBiologicalEvent {
  ActivityEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'activity',
          reversibility: true,
        );
}

class HabitEvent extends BaseBiologicalEvent {
  HabitEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'habit',
          reversibility: true,
        );
}

class WearableSyncEvent extends BaseBiologicalEvent {
  WearableSyncEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'wearable_sync',
          reversibility: false,
        );
}

class RecommendationEvent extends BaseBiologicalEvent {
  RecommendationEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'recommendation',
          reversibility: false,
        );
}

class RiskDetectionEvent extends BaseBiologicalEvent {
  RiskDetectionEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'risk_detection',
          reversibility: false,
        );
}

class BiologicalStateChangeEvent extends BaseBiologicalEvent {
  BiologicalStateChangeEvent({
    super.eventId,
    required super.userId,
    required super.guestId,
    required super.timestamp,
    required super.source,
    required super.sourceDevice,
    required super.confidence,
    required super.uncertainty,
    required super.severity,
    required super.biologicalImpact,
    required super.causalityChain,
    required super.linkedStateIds,
    required super.metadata,
  }) : super(
          eventType: 'state_change',
          reversibility: true,
        );
}
