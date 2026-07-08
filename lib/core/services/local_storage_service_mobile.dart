import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'local_storage_service.dart';
import '../../infrastructure/local/isar_schemas.dart';
import '../../domain/models/biological_twin/biological_models.dart';

LocalStorageService getLocalStorageService() => LocalStorageServiceMobile();

class LocalStorageServiceMobile implements LocalStorageService {
  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw StateError('LocalStorageServiceMobile has not been initialized. Call initialize() first.');
    }
    return _isar!;
  }

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    String dirPath = '';
    final dir = await getApplicationDocumentsDirectory();
    dirPath = dir.path;

    final schemas = [
      IsarIdentitySchema,
      IsarBiologicalStateSchema,
      IsarBiologicalEventSchema,
      IsarRecommendationSchema,
      IsarWearableSnapshotSchema,
      IsarSyncJobSchema,
      IsarConflictSchema,
      IsarTimelineFragmentSchema,
      IsarUncertaintySnapshotSchema,
      BiologicalStateSchema,
      CircadianStateSchema,
      RecoveryStateSchema,
      StressLoadStateSchema,
      HydrationStateSchema,
      SleepDebtStateSchema,
      MetabolicStateSchema,
      CognitiveStateSchema,
      InflammationProxyStateSchema,
      NutrientDeficiencyProbabilitySchema,
      HormonalBalanceProxySchema,
      GutHealthProxySchema,
      BehavioralConsistencyScoreSchema,
      RecommendationConfidenceSchema,
      IsarHealthIdentitySchema,
      IsarUnderstandingGraphNodeSchema,
      IsarUnderstandingGraphEdgeSchema,
    ];

    try {
      debugPrint('[BOOTSTRAP MOBILE] Attempting to open Isar database at "$dirPath"...');
      _isar = await Isar.open(schemas, directory: dirPath);
      debugPrint('[BOOTSTRAP MOBILE] Isar database opened successfully.');
    } catch (e) {
      debugPrint('[BOOTSTRAP MOBILE] Isar schema mismatch or load error detected. Wiping local database for clean start: $e');
      
      // Close instance and wipe
      await Isar.getInstance()?.close(deleteFromDisk: true);
      
      try {
        final coreDb = File('$dirPath/default.isar');
        if (coreDb.existsSync()) coreDb.deleteSync();
        final lockFile = File('$dirPath/default.isar.lock');
        if (lockFile.existsSync()) lockFile.deleteSync();
      } catch (_) {}

      // Retry opening Isar
      debugPrint('[BOOTSTRAP MOBILE] Retrying Isar database open after wipe...');
      _isar = await Isar.open(schemas, directory: dirPath);
      debugPrint('[BOOTSTRAP MOBILE] Isar database opened successfully after retry.');
    }
  }

  @override
  Future<void> saveIdentity({required String uuid, required bool isGuest}) async {
    try {
      final identity = IsarIdentity()
        ..uuid = uuid
        ..isGuest = isGuest
        ..createdAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.isarIdentitys.put(identity);
      });
      debugPrint('[IDENTITY MOBILE] Successfully persisted identity to Isar');
    } catch (e) {
      debugPrint('[IDENTITY MOBILE ERROR] Failed to persist identity to Isar: $e');
    }
  }

  @override
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userProfileMap) async {
    try {
      final stateId = '${userId}_user_profile';
      final state = IsarBiologicalState()
        ..stateId = stateId
        ..userId = userId
        ..stateType = 'user_profile'
        ..lastUpdated = DateTime.now()
        ..confidenceScore = 1.0
        ..uncertaintyScore = 0.0
        ..validityWindowSeconds = 0
        ..serializedData = jsonEncode(userProfileMap)
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.isarBiologicalStates.put(state);
      });
      debugPrint('[ISAR MOBILE] Saved UserProfile for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save UserProfile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readUserProfile(String userId) async {
    try {
      final stateId = '${userId}_user_profile';
      final record = await isar.isarBiologicalStates.filter().stateIdEqualTo(stateId).findFirst();
      if (record != null) {
        return jsonDecode(record.serializedData) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read UserProfile: $e');
    }
    return null;
  }

  @override
  Future<void> saveBiologicalProfile(String userId, Map<String, dynamic> biologicalProfileMap) async {
    try {
      final stateId = '${userId}_biological_profile';
      final state = IsarBiologicalState()
        ..stateId = stateId
        ..userId = userId
        ..stateType = 'biological_profile'
        ..lastUpdated = DateTime.now()
        ..confidenceScore = 1.0
        ..uncertaintyScore = 0.0
        ..validityWindowSeconds = 0
        ..serializedData = jsonEncode(biologicalProfileMap)
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.isarBiologicalStates.put(state);
      });
      debugPrint('[ISAR MOBILE] Saved BiologicalProfile for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save BiologicalProfile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readBiologicalProfile(String userId) async {
    try {
      final stateId = '${userId}_biological_profile';
      final record = await isar.isarBiologicalStates.filter().stateIdEqualTo(stateId).findFirst();
      if (record != null) {
        return jsonDecode(record.serializedData) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read BiologicalProfile: $e');
    }
    return null;
  }

  @override
  Future<void> saveBiologicalEvent(String userId, Map<String, dynamic> eventMap) async {
    try {
      final eventId = eventMap['event_id']?.toString() ?? 'event_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final event = IsarBiologicalEvent()
        ..eventId = eventId
        ..userId = userId
        ..eventType = eventMap['event_type']?.toString() ?? 'observation'
        ..occurredAt = DateTime.tryParse(eventMap['occurred_at'] ?? '') ?? DateTime.now()
        ..registeredAt = DateTime.now()
        ..source = eventMap['source']?.toString() ?? 'app'
        ..severity = eventMap['severity']?.toString() ?? 'normal'
        ..impactHorizon = eventMap['impact_horizon']?.toString() ?? 'immediate'
        ..confidence = (eventMap['confidence'] ?? 1.0).toDouble()
        ..isReversible = eventMap['is_reversible'] ?? true
        ..serializedPayload = jsonEncode(eventMap['payload'] ?? {})
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.isarBiologicalEvents.put(event);
      });
      debugPrint('[ISAR MOBILE] Saved BiologicalEvent for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save BiologicalEvent: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readBiologicalEvents(String userId) async {
    try {
      final records = await isar.isarBiologicalEvents.filter()
          .userIdEqualTo(userId)
          .sortByOccurredAtDesc()
          .findAll();
          
      return records.map((r) => {
        'event_id': r.eventId,
        'user_id': r.userId,
        'event_type': r.eventType,
        'occurred_at': r.occurredAt.toIso8601String(),
        'source': r.source,
        'confidence': r.confidence,
        'payload': jsonDecode(r.serializedPayload),
      }).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read BiologicalEvents: $e');
    }
    return [];
  }

  @override
  Future<void> saveObservation(String userId, Map<String, dynamic> observationMap) async {
    try {
      final stateId = 'observation_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final state = IsarBiologicalState()
        ..stateId = stateId
        ..userId = userId
        ..stateType = 'observation'
        ..lastUpdated = DateTime.now()
        ..confidenceScore = 1.0
        ..uncertaintyScore = 0.0
        ..validityWindowSeconds = 0
        ..serializedData = jsonEncode(observationMap)
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.isarBiologicalStates.put(state);
      });
      debugPrint('[ISAR MOBILE] Saved Observation for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save Observation: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readObservations(String userId) async {
    try {
      final records = await isar.isarBiologicalStates.filter()
          .userIdEqualTo(userId)
          .stateTypeEqualTo('observation')
          .findAll();
      return records.map((r) => jsonDecode(r.serializedData) as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read Observations: $e');
    }
    return [];
  }

  @override
  Future<void> saveHealthIdentity(String userId, Map<String, dynamic> healthIdentityMap) async {
    try {
      final record = IsarHealthIdentity()
        ..userId = userId
        ..name = healthIdentityMap['name']?.toString() ?? ''
        ..age = (healthIdentityMap['age'] ?? 0).toInt()
        ..gender = healthIdentityMap['gender']?.toString() ?? ''
        ..height = (healthIdentityMap['height'] ?? 0.0).toDouble()
        ..weight = (healthIdentityMap['weight'] ?? 0.0).toDouble()
        ..country = healthIdentityMap['country']?.toString() ?? ''
        ..city = healthIdentityMap['city']?.toString() ?? ''
        ..occupation = healthIdentityMap['occupation']?.toString() ?? ''
        ..primaryGoal = healthIdentityMap['primary_goal'] ?? healthIdentityMap['goal']?.toString() ?? ''
        ..sleepTime = healthIdentityMap['sleep_time']?.toString() ?? ''
        ..wakeTime = healthIdentityMap['wake_time']?.toString() ?? ''
        ..activityLevel = healthIdentityMap['activity_level']?.toString() ?? ''
        ..exercise = healthIdentityMap['exercise']?.toString() ?? ''
        ..smoking = healthIdentityMap['smoking']?.toString() ?? ''
        ..alcohol = healthIdentityMap['alcohol']?.toString() ?? ''
        ..stressLevel = (healthIdentityMap['stress_level'] ?? 0).toInt()
        ..dietPreference = healthIdentityMap['diet_preference'] ?? healthIdentityMap['nutrition_diet']?.toString() ?? ''
        ..waterIntake = (healthIdentityMap['water_intake'] ?? 0.0).toDouble()
        ..mealTiming = healthIdentityMap['meal_timing']?.toString() ?? ''
        ..supplements = List<String>.from(healthIdentityMap['supplements'] ?? [])
        ..hasDiabetesRisk = healthIdentityMap['has_diabetes_risk'] ?? healthIdentityMap['family_diabetes'] ?? false
        ..hasHeartDiseaseRisk = healthIdentityMap['has_heart_disease_risk'] ?? healthIdentityMap['family_heart'] ?? false
        ..hasCancerRisk = healthIdentityMap['has_cancer_risk'] ?? healthIdentityMap['family_cancer'] ?? false
        ..hasThyroidRisk = healthIdentityMap['has_thyroid_risk'] ?? healthIdentityMap['family_thyroid'] ?? false
        ..hasBloodPressureRisk = healthIdentityMap['has_blood_pressure_risk'] ?? healthIdentityMap['family_bp'] ?? false
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.isarHealthIdentitys.put(record);
      });
      debugPrint('[ISAR MOBILE] Saved HealthIdentity for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save HealthIdentity: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readHealthIdentity(String userId) async {
    try {
      final record = await isar.isarHealthIdentitys.filter().userIdEqualTo(userId).findFirst();
      if (record != null) {
        return {
          'user_id': record.userId,
          'name': record.name,
          'age': record.age,
          'gender': record.gender,
          'height': record.height,
          'weight': record.weight,
          'country': record.country,
          'city': record.city,
          'occupation': record.occupation,
          'primary_goal': record.primaryGoal,
          'sleep_time': record.sleepTime,
          'wake_time': record.wakeTime,
          'activity_level': record.activityLevel,
          'exercise': record.exercise,
          'smoking': record.smoking,
          'alcohol': record.alcohol,
          'stress_level': record.stressLevel,
          'diet_preference': record.dietPreference,
          'water_intake': record.waterIntake,
          'meal_timing': record.mealTiming,
          'supplements': record.supplements,
          'has_diabetes_risk': record.hasDiabetesRisk,
          'has_heart_disease_risk': record.hasHeartDiseaseRisk,
          'has_cancer_risk': record.hasCancerRisk,
          'has_thyroid_risk': record.hasThyroidRisk,
          'has_blood_pressure_risk': record.hasBloodPressureRisk,
          'updated_at': record.updatedAt.toIso8601String(),
        };
      }
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read HealthIdentity: $e');
    }
    return null;
  }

  @override
  Future<void> saveUserUnderstanding(String userId, Map<String, dynamic> data) async {
    try {
      final stateId = '${userId}_user_understanding';
      final state = IsarBiologicalState()
        ..stateId = stateId
        ..userId = userId
        ..stateType = 'user_understanding'
        ..lastUpdated = DateTime.now()
        ..confidenceScore = 1.0
        ..uncertaintyScore = 0.0
        ..validityWindowSeconds = 0
        ..serializedData = jsonEncode(data)
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.isarBiologicalStates.put(state);
      });
      debugPrint('[ISAR MOBILE] Saved UserUnderstanding for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save UserUnderstanding: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readUserUnderstanding(String userId) async {
    try {
      final stateId = '${userId}_user_understanding';
      final record = await isar.isarBiologicalStates.filter().stateIdEqualTo(stateId).findFirst();
      if (record != null) {
        return jsonDecode(record.serializedData) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read UserUnderstanding: $e');
    }
    return null;
  }

  @override
  Future<void> migrateGuestData(String guestUserId, String cloudUserId) async {
    try {
      debugPrint('[ISAR MOBILE] Migrating guest data from $guestUserId to $cloudUserId');
      
      await isar.writeTxn(() async {
        // 1. Migrate Biological States
        final states = await isar.isarBiologicalStates.filter().userIdEqualTo(guestUserId).findAll();
        for (final state in states) {
          final newStateId = state.stateId.replaceAll(guestUserId, cloudUserId);
          
          String updatedData = state.serializedData;
          try {
            final decoded = jsonDecode(state.serializedData);
            if (decoded is Map<String, dynamic> && decoded['user_id'] == guestUserId) {
              decoded['user_id'] = cloudUserId;
              updatedData = jsonEncode(decoded);
            }
          } catch (_) {}

          final newState = IsarBiologicalState()
            ..stateId = newStateId
            ..userId = cloudUserId
            ..stateType = state.stateType
            ..lastUpdated = state.lastUpdated
            ..confidenceScore = state.confidenceScore
            ..uncertaintyScore = state.uncertaintyScore
            ..validityWindowSeconds = state.validityWindowSeconds
            ..serializedData = updatedData
            ..causalEventIds = state.causalEventIds.map((e) => e.replaceAll(guestUserId, cloudUserId)).toList()
            ..isSynced = false;

          await isar.isarBiologicalStates.put(newState);
          await isar.isarBiologicalStates.delete(state.id);
        }

        // 2. Migrate Biological Events
        final events = await isar.isarBiologicalEvents.filter().userIdEqualTo(guestUserId).findAll();
        for (final event in events) {
          final newEventId = event.eventId.replaceAll(guestUserId, cloudUserId);
          
          String updatedPayload = event.serializedPayload;
          try {
            final decoded = jsonDecode(event.serializedPayload);
            if (decoded is Map<String, dynamic> && decoded['user_id'] == guestUserId) {
              decoded['user_id'] = cloudUserId;
              updatedPayload = jsonEncode(decoded);
            }
          } catch (_) {}

          final newEvent = IsarBiologicalEvent()
            ..eventId = newEventId
            ..userId = cloudUserId
            ..eventType = event.eventType
            ..occurredAt = event.occurredAt
            ..registeredAt = event.registeredAt
            ..source = event.source
            ..severity = event.severity
            ..impactHorizon = event.impactHorizon
            ..confidence = event.confidence
            ..isReversible = event.isReversible
            ..serializedPayload = updatedPayload
            ..isSynced = false;

          await isar.isarBiologicalEvents.put(newEvent);
          await isar.isarBiologicalEvents.delete(event.id);
        }

        // 3. Migrate Health Identity
        final health = await isar.isarHealthIdentitys.filter().userIdEqualTo(guestUserId).findFirst();
        if (health != null) {
          final newHealth = IsarHealthIdentity()
            ..userId = cloudUserId
            ..name = health.name
            ..age = health.age
            ..gender = health.gender
            ..height = health.height
            ..weight = health.weight
            ..country = health.country
            ..city = health.city
            ..occupation = health.occupation
            ..primaryGoal = health.primaryGoal
            ..sleepTime = health.sleepTime
            ..wakeTime = health.wakeTime
            ..activityLevel = health.activityLevel
            ..exercise = health.exercise
            ..smoking = health.smoking
            ..alcohol = health.alcohol
            ..stressLevel = health.stressLevel
            ..dietPreference = health.dietPreference
            ..waterIntake = health.waterIntake
            ..mealTiming = health.mealTiming
            ..supplements = health.supplements
            ..hasDiabetesRisk = health.hasDiabetesRisk
            ..hasHeartDiseaseRisk = health.hasHeartDiseaseRisk
            ..hasCancerRisk = health.hasCancerRisk
            ..hasThyroidRisk = health.hasThyroidRisk
            ..hasBloodPressureRisk = health.hasBloodPressureRisk
            ..updatedAt = DateTime.now();

          await isar.isarHealthIdentitys.put(newHealth);
          await isar.isarHealthIdentitys.delete(health.id);
        }

        // 4. Migrate Timeline Fragments
        final fragments = await isar.isarTimelineFragments.filter().userIdEqualTo(guestUserId).findAll();
        for (final fragment in fragments) {
          final newFragment = IsarTimelineFragment()
            ..userId = cloudUserId
            ..periodStart = fragment.periodStart
            ..periodEnd = fragment.periodEnd
            ..serializedFragment = fragment.serializedFragment;

          await isar.isarTimelineFragments.put(newFragment);
          await isar.isarTimelineFragments.delete(fragment.id);
        }

        // 5. Migrate Recommendations
        final recs = await isar.isarRecommendations.filter().userIdEqualTo(guestUserId).findAll();
        for (final rec in recs) {
          final newRecId = rec.recommendationId.replaceAll(guestUserId, cloudUserId);
          final newRec = IsarRecommendation()
            ..recommendationId = newRecId
            ..userId = cloudUserId
            ..title = rec.title
            ..description = rec.description
            ..confidence = rec.confidence
            ..generatedAt = rec.generatedAt
            ..expiresAt = rec.expiresAt
            ..status = rec.status;

          await isar.isarRecommendations.put(newRec);
          await isar.isarRecommendations.delete(rec.id);
        }
      });
      debugPrint('[ISAR MOBILE] Mobile migration completed successfully');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Mobile migration failed: $e');
    }
  }

  @override
  Future<void> saveRecommendation(String userId, Map<String, dynamic> recMap) async {
    try {
      final recId = recMap['recommendation_id']?.toString() ?? 'rec_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final rec = IsarRecommendation()
        ..recommendationId = recId
        ..userId = userId
        ..title = recMap['title']?.toString() ?? ''
        ..description = recMap['description']?.toString() ?? ''
        ..confidence = (recMap['confidence'] ?? 1.0).toDouble()
        ..generatedAt = DateTime.tryParse(recMap['generated_at'] ?? '') ?? DateTime.now()
        ..expiresAt = DateTime.tryParse(recMap['expires_at'] ?? '') ?? DateTime.now().add(const Duration(days: 1))
        ..status = recMap['status']?.toString() ?? 'pending'
        ..type = recMap['type']?.toString() ?? 'action'
        ..reasoningChain = List<String>.from(recMap['reasoning_chain'] ?? [])
        ..evidenceCitations = List<String>.from(recMap['evidence_citations'] ?? [])
        ..missingData = List<String>.from(recMap['missing_data'] ?? [])
        ..supportingObservations = List<String>.from(recMap['supporting_observations'] ?? [])
        ..isSynced = recMap['is_synced'] ?? false;

      await isar.writeTxn(() async {
        await isar.isarRecommendations.putByRecommendationId(rec);
      });
      debugPrint('[ISAR MOBILE] Saved Recommendation for $userId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save Recommendation: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readRecommendations(String userId) async {
    try {
      final records = await isar.isarRecommendations.filter()
          .userIdEqualTo(userId)
          .findAll();
          
      return records.map((r) => {
        'recommendation_id': r.recommendationId,
        'user_id': r.userId,
        'title': r.title,
        'description': r.description,
        'confidence': r.confidence,
        'generated_at': r.generatedAt.toIso8601String(),
        'expires_at': r.expiresAt.toIso8601String(),
        'status': r.status,
        'type': r.type,
        'reasoning_chain': r.reasoningChain,
        'evidence_citations': r.evidenceCitations,
        'missing_data': r.missingData,
        'supporting_observations': r.supportingObservations,
        'is_synced': r.isSynced,
      }).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read Recommendations: $e');
    }
    return [];
  }

  @override
  Future<void> queueSyncJob(String collectionName, String recordId, String operation) async {
    try {
      final job = IsarSyncJob()
        ..collectionName = collectionName
        ..recordId = recordId
        ..operation = operation
        ..queuedAt = DateTime.now()
        ..retryCount = 0;

      await isar.writeTxn(() async {
        await isar.isarSyncJobs.put(job);
      });
      debugPrint('[ISAR MOBILE] Enqueued SyncJob: $operation for $collectionName ID $recordId');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to queue sync job: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncJobs() async {
    try {
      final records = await isar.isarSyncJobs.where().findAll();
      return records.map((r) => {
        'collection_name': r.collectionName,
        'record_id': r.recordId,
        'operation': r.operation,
        'queued_at': r.queuedAt.toIso8601String(),
        'retry_count': r.retryCount,
      }).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to fetch sync jobs: $e');
    }
    return [];
  }

  @override
  Future<void> deleteSyncJob(String collectionName, String recordId) async {
    try {
      await isar.writeTxn(() async {
        final job = await isar.isarSyncJobs.filter()
            .collectionNameEqualTo(collectionName)
            .recordIdEqualTo(recordId)
            .findFirst();
        if (job != null) {
          await isar.isarSyncJobs.delete(job.id);
          debugPrint('[ISAR MOBILE] Deleted SyncJob for $collectionName ID $recordId');
        }
      });
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to delete sync job: $e');
    }
  }

  @override
  Future<void> saveGraphNodes(List<Map<String, dynamic>> nodes) async {
    try {
      await isar.writeTxn(() async {
        await isar.isarUnderstandingGraphNodes.clear();
        for (var n in nodes) {
          final node = IsarUnderstandingGraphNode()
            ..nodeId = n['id']?.toString() ?? ''
            ..nodeKey = n['node_key']?.toString() ?? ''
            ..title = n['title']?.toString() ?? ''
            ..description = n['description']?.toString() ?? ''
            ..serializedMetadata = jsonEncode(n['metadata'] ?? {});
          await isar.isarUnderstandingGraphNodes.put(node);
        }
      });
      debugPrint('[ISAR MOBILE] Cached ${nodes.length} graph nodes.');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save graph nodes: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readGraphNodes() async {
    try {
      final records = await isar.isarUnderstandingGraphNodes.where().findAll();
      return records.map((r) => {
        'id': r.nodeId,
        'node_key': r.nodeKey,
        'title': r.title,
        'description': r.description,
        'metadata': jsonDecode(r.serializedMetadata),
      }).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read graph nodes: $e');
    }
    return [];
  }

  @override
  Future<void> saveGraphEdges(List<Map<String, dynamic>> edges) async {
    try {
      await isar.writeTxn(() async {
        await isar.isarUnderstandingGraphEdges.clear();
        for (var e in edges) {
          final edge = IsarUnderstandingGraphEdge()
            ..edgeId = e['id']?.toString() ?? ''
            ..sourceNodeId = e['source_node_id']?.toString() ?? ''
            ..targetNodeId = e['target_node_id']?.toString() ?? ''
            ..relationType = e['relation_type']?.toString() ?? '';
          await isar.isarUnderstandingGraphEdges.put(edge);
        }
      });
      debugPrint('[ISAR MOBILE] Cached ${edges.length} graph edges.');
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to save graph edges: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readGraphEdges() async {
    try {
      final records = await isar.isarUnderstandingGraphEdges.where().findAll();
      return records.map((r) => {
        'id': r.edgeId,
        'source_node_id': r.sourceNodeId,
        'target_node_id': r.targetNodeId,
        'relation_type': r.relationType,
      }).toList();
    } catch (e) {
      debugPrint('[ISAR MOBILE ERROR] Failed to read graph edges: $e');
    }
    return [];
  }
}
