import '../../core/utils/hash_utils.dart';
import 'package:isar/isar.dart';

part 'isar_schemas.g.dart';

@collection
class IsarIdentity {
  Id get id => fastHash(uuid);

  @Index(unique: true)
  late String uuid;

  late bool isGuest;
  
  late DateTime createdAt;
  
  // E.g., 'apple_health', 'oura'
  List<String> connectedProviders = [];
}

@collection
class IsarBiologicalState {
  Id get id => fastHash(stateId);

  @Index()
  late String stateId;

  @Index()
  late String userId;

  @Index()
  late String stateType; // CircadianState, RecoveryState, etc.

  late DateTime lastUpdated;
  
  late double confidenceScore;
  late double uncertaintyScore;
  
  late int validityWindowSeconds;

  // The serialized JSON representing the full Dart object
  late String serializedData;

  List<String> causalEventIds = [];
  
  // For sync queue tracking
  @Index()
  late bool isSynced;
}

@collection
class IsarBiologicalEvent {
  Id get id => fastHash(eventId);

  @Index(unique: true)
  late String eventId;

  @Index()
  late String userId;

  late String eventType;

  @Index()
  late DateTime occurredAt;

  late DateTime registeredAt;
  
  late String source;
  late String severity;
  late String impactHorizon;
  
  late double confidence;
  late bool isReversible;

  late String serializedPayload;

  @Index()
  late bool isSynced;
}

@collection
class IsarRecommendation {
  Id get id => fastHash(recommendationId);

  @Index(unique: true)
  late String recommendationId;
  
  @Index()
  late String userId;

  late String title;
  late String description;
  
  late double confidence;
  
  late DateTime generatedAt;
  late DateTime expiresAt;
  
  // 'actioned', 'dismissed', 'pending'
  late String status;

  late String type; // 'insight' or 'action'
  List<String> reasoningChain = [];
  List<String> evidenceCitations = [];
  List<String> missingData = [];
  List<String> supportingObservations = [];

  @Index()
  late bool isSynced;
}

@collection
class IsarWearableSnapshot {
  Id get id => fastHash('${userId}_${snapshotTime.millisecondsSinceEpoch}');

  @Index()
  late String userId;

  late String source; // e.g. 'oura'
  late DateTime snapshotTime;
  
  late String rawJsonPayload;
  
  @Index()
  late bool processedByEngine;
}

@collection
class IsarSyncJob {
  Id get id => fastHash('${collectionName}_${recordId}_${queuedAt.millisecondsSinceEpoch}');

  @Index()
  late String collectionName; // e.g., 'biological_events'
  
  late String recordId; 
  
  late String operation; // 'insert', 'update', 'delete'
  
  late DateTime queuedAt;
  
  late int retryCount;
}

@collection
class IsarConflict {
  Id get id => fastHash('${entityId}_${detectedAt.millisecondsSinceEpoch}');

  @Index()
  late String entityId;
  
  late String entityType;
  
  late String localData;
  late String cloudData;
  
  late DateTime detectedAt;
}

@collection
class IsarTimelineFragment {
  Id get id => fastHash('${userId}_${periodStart.millisecondsSinceEpoch}');

  @Index()
  late String userId;
  
  late DateTime periodStart;
  late DateTime periodEnd;
  
  late String serializedFragment; // E.g., a compressed week of health data
}

@collection
class IsarUncertaintySnapshot {
  Id get id => fastHash('${stateId}_${capturedAt.millisecondsSinceEpoch}');

  @Index()
  late String stateId;
  
  late DateTime capturedAt;
  late double priorUncertainty;
  late double posteriorUncertainty;
  
  late String triggerEventId;
}

@collection
class IsarHealthIdentity {
  Id get id => fastHash(userId);

  @Index(unique: true)
  late String userId;

  // Onboarding
  late String name;
  late int age;
  late String gender;
  late double height;
  late double weight;
  late String country;
  late String city;
  late String occupation;
  late String primaryGoal;

  // Lifestyle
  late String sleepTime;
  late String wakeTime;
  late String activityLevel;
  late String exercise;
  late String smoking;
  late String alcohol;
  late int stressLevel;

  // Food
  late String dietPreference; // Veg / Non-Veg
  late double waterIntake;
  late String mealTiming;
  List<String> supplements = [];

  // Family Risk
  late bool hasDiabetesRisk;
  late bool hasHeartDiseaseRisk;
  late bool hasCancerRisk;
  late bool hasThyroidRisk;
  late bool hasBloodPressureRisk;

  late DateTime updatedAt;
}

@collection
class IsarUnderstandingGraphNode {
  Id get id => fastHash(nodeId);

  @Index(unique: true)
  late String nodeId;

  @Index()
  late String nodeKey; // e.g. 'sleep_debt', 'hydration_depth'

  late String title;
  late String description;

  // Store metadata as a serialized JSON string
  late String serializedMetadata;
}

@collection
class IsarUnderstandingGraphEdge {
  Id get id => fastHash(edgeId);

  @Index(unique: true)
  late String edgeId;

  late String sourceNodeId;
  late String targetNodeId;
  late String relationType;
}
