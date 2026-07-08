import '../../../core/utils/hash_utils.dart';
import 'package:isar/isar.dart';

part 'biological_models.g.dart';

/// Embedded object for all state models to satisfy:
/// - versioned
/// - confidence aware
/// - uncertainty aware
/// - temporal decay aware
@embedded
class TwinStateMetadata {
  int version = 1;
  double confidence = 1.0; // 0.0 to 1.0
  double uncertainty = 0.0; // 0.0 to 1.0
  double temporalDecayRate = 0.0; // Rate of decay per hour
  DateTime timestamp = DateTime.now();

  TwinStateMetadata();
}

@collection
class BiologicalState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  
  @Index(type: IndexType.value)
  String userId = 'guest';

  TwinStateMetadata metadata = TwinStateMetadata();

  double overallHealthScore = 0.0;
  double biologicalAgeDelta = 0.0;
}

@collection
class CircadianState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double alignmentScore = 1.0; // 0.0 to 1.0
  double phaseShiftHours = 0.0;
}

@collection
class RecoveryState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double cnsRecoveryScore = 1.0;
  double muscularRecoveryScore = 1.0;
  double overallRecovery = 1.0;
}

@collection
class StressLoadState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double acuteStressLoad = 0.0;
  double chronicStressLoad = 0.0;
  double allostaticLoad = 0.0;
}

@collection
class HydrationState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double estimatedHydrationPercent = 1.0;
  double electrolyteBalanceProxy = 1.0;
}

@collection
class SleepDebtState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double accumulatedSleepDebtHours = 0.0;
  double remDeficitHours = 0.0;
  double deepSleepDeficitHours = 0.0;
}

@collection
class MetabolicState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double metabolicFlexibilityScore = 1.0;
  double estimatedGlycogenDepletion = 0.0;
}

@collection
class CognitiveState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double focusCapacity = 1.0;
  double cognitiveFatigue = 0.0;
}

@collection
class InflammationProxyState {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double systemicInflammationScore = 0.0;
}

@collection
class NutrientDeficiencyProbability {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  // Encoded as JSON string map of Nutrient ID to Probability to avoid complex Isar relations for now
  String nutrientProbabilitiesJson = "{}";
}

@collection
class HormonalBalanceProxy {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double cortisolProxy = 0.5;
  double testosteroneProxy = 0.5;
  double thyroidProxy = 0.5;
}

@collection
class GutHealthProxy {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double microbiomeDiversityProxy = 1.0;
  double gutPermeabilityProxy = 0.0;
}

@collection
class BehavioralConsistencyScore {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double circadianRhythmConsistency = 1.0;
  double feedingWindowConsistency = 1.0;
  double overallConsistency = 1.0;
}

@collection
class RecommendationConfidence {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double aiConfidenceScore = 1.0;
}

@collection
class UncertaintyScore {
  Id get id => fastHash('${userId}_${metadata.timestamp.millisecondsSinceEpoch}');
  @Index() String userId = 'guest';
  TwinStateMetadata metadata = TwinStateMetadata();

  double globalUncertainty = 0.0;
  String missingDataVectorsJson = "[]"; 
}
