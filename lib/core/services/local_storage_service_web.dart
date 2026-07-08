import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';

LocalStorageService getLocalStorageService() => LocalStorageServiceWeb();

class LocalStorageServiceWeb implements LocalStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> initialize() async {
    // SharedPreferences initializes on-demand or during boot.
    await prefs;
    debugPrint('[BOOTSTRAP WEB] SharedPreferences storage service initialized.');
  }

  @override
  Future<void> saveIdentity({required String uuid, required bool isGuest}) async {
    try {
      final p = await prefs;
      await p.setString('ne_device_uuid', uuid);
      await p.setString('ne_auth_mode', isGuest ? 'guest' : 'cloud');
      
      // Store in an identity JSON for structured representation if needed
      final identityMap = {
        'uuid': uuid,
        'isGuest': isGuest,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await p.setString('ne_identity_data', jsonEncode(identityMap));
      debugPrint('[IDENTITY WEB] Successfully persisted identity to SharedPreferences');
    } catch (e) {
      debugPrint('[IDENTITY WEB ERROR] Failed to persist identity: $e');
    }
  }

  @override
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userProfileMap) async {
    try {
      final p = await prefs;
      final key = 'ne_user_profile_$userId';
      await p.setString(key, jsonEncode(userProfileMap));
      debugPrint('[SP WEB] Saved UserProfile for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save UserProfile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readUserProfile(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_user_profile_$userId';
      final raw = p.getString(key);
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read UserProfile: $e');
    }
    return null;
  }

  @override
  Future<void> saveBiologicalProfile(String userId, Map<String, dynamic> biologicalProfileMap) async {
    try {
      final p = await prefs;
      final key = 'ne_biological_profile_$userId';
      await p.setString(key, jsonEncode(biologicalProfileMap));
      debugPrint('[SP WEB] Saved BiologicalProfile for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save BiologicalProfile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readBiologicalProfile(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_biological_profile_$userId';
      final raw = p.getString(key);
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read BiologicalProfile: $e');
    }
    return null;
  }

  @override
  Future<void> saveBiologicalEvent(String userId, Map<String, dynamic> eventMap) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await readBiologicalEvents(userId);
    
    final newEvent = {
      'event_id': eventMap['event_id']?.toString() ?? 'event_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'event_type': eventMap['event_type']?.toString() ?? 'observation',
      'occurred_at': eventMap['occurred_at'] ?? DateTime.now().toIso8601String(),
      'source': eventMap['source']?.toString() ?? 'app',
      'confidence': eventMap['confidence'] ?? 1.0,
      'payload': eventMap['payload'] ?? {},
    };
    
    events.insert(0, newEvent);
    
    // Keep last 1000 events on web to prevent quota issues
    if (events.length > 1000) {
      events.removeRange(1000, events.length);
    }
    
    await prefs.setString('${userId}_events', jsonEncode(events));
  }

  @override
  Future<List<Map<String, dynamic>>> readBiologicalEvents(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('${userId}_events');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<void> saveObservation(String userId, Map<String, dynamic> observationMap) async {
    try {
      final p = await prefs;
      final key = 'ne_observations_$userId';
      final list = p.getStringList(key) ?? [];
      list.add(jsonEncode(observationMap));
      await p.setStringList(key, list);
      debugPrint('[SP WEB] Saved Observation for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save Observation: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readObservations(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_observations_$userId';
      final list = p.getStringList(key) ?? [];
      return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read Observations: $e');
    }
    return [];
  }

  @override
  Future<void> saveHealthIdentity(String userId, Map<String, dynamic> healthIdentityMap) async {
    try {
      final p = await prefs;
      final key = 'ne_health_identity_$userId';
      await p.setString(key, jsonEncode(healthIdentityMap));
      debugPrint('[SP WEB] Saved HealthIdentity for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save HealthIdentity: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readHealthIdentity(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_health_identity_$userId';
      final raw = p.getString(key);
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read HealthIdentity: $e');
    }
    return null;
  }

  @override
  Future<void> saveUserUnderstanding(String userId, Map<String, dynamic> data) async {
    try {
      final p = await prefs;
      final key = 'ne_user_understanding_$userId';
      await p.setString(key, jsonEncode(data));
      debugPrint('[SP WEB] Saved UserUnderstanding for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save UserUnderstanding: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> readUserUnderstanding(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_user_understanding_$userId';
      final raw = p.getString(key);
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read UserUnderstanding: $e');
    }
    return null;
  }

  @override
  Future<void> saveRecommendation(String userId, Map<String, dynamic> recMap) async {
    try {
      final p = await prefs;
      final key = 'ne_recommendations_$userId';
      final list = p.getStringList(key) ?? [];
      list.add(jsonEncode(recMap));
      await p.setStringList(key, list);
      debugPrint('[SP WEB] Saved Recommendation for $userId');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save Recommendation: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readRecommendations(String userId) async {
    try {
      final p = await prefs;
      final key = 'ne_recommendations_$userId';
      final list = p.getStringList(key) ?? [];
      return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read Recommendations: $e');
    }
    return [];
  }

  @override
  Future<void> queueSyncJob(String collectionName, String recordId, String operation) async {
    debugPrint('[SP WEB] Queued sync job: $operation on $collectionName ID $recordId');
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncJobs() async {
    return [];
  }

  @override
  Future<void> deleteSyncJob(String collectionName, String recordId) async {}

  @override
  Future<void> saveGraphNodes(List<Map<String, dynamic>> nodes) async {
    try {
      final p = await prefs;
      await p.setString('ne_graph_nodes', jsonEncode(nodes));
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save graph nodes: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readGraphNodes() async {
    try {
      final p = await prefs;
      final raw = p.getString('ne_graph_nodes');
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read graph nodes: $e');
    }
    return [];
  }

  @override
  Future<void> saveGraphEdges(List<Map<String, dynamic>> edges) async {
    try {
      final p = await prefs;
      await p.setString('ne_graph_edges', jsonEncode(edges));
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to save graph edges: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readGraphEdges() async {
    try {
      final p = await prefs;
      final raw = p.getString('ne_graph_edges');
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('[SP WEB ERROR] Failed to read graph edges: $e');
    }
    return [];
  }

  @override
  Future<void> migrateGuestData(String guestUserId, String cloudUserId) async {
    try {
      final p = await prefs;
      debugPrint('[SP WEB] Migrating guest data from $guestUserId to $cloudUserId');
      
      final keysToMigrate = [
        'ne_user_profile_',
        'ne_biological_profile_',
        'ne_health_identity_',
        'ne_observations_',
        'ne_user_understanding_',
        'ne_onboarding_draft_',
      ];
      
      for (final prefix in keysToMigrate) {
        final oldKey = '$prefix$guestUserId';
        final newKey = '$prefix$cloudUserId';
        final val = p.get(oldKey);
        if (val != null) {
          if (val is String) {
            try {
              final decoded = jsonDecode(val);
              if (decoded is Map<String, dynamic> && decoded['user_id'] == guestUserId) {
                decoded['user_id'] = cloudUserId;
                await p.setString(newKey, jsonEncode(decoded));
              } else {
                await p.setString(newKey, val);
              }
            } catch (_) {
              await p.setString(newKey, val);
            }
          } else if (val is List<String>) {
            await p.setStringList(newKey, val);
          }
          await p.remove(oldKey);
        }
      }
      
      final oldEventsKey = '${guestUserId}_events';
      final newEventsKey = '${cloudUserId}_events';
      final eventsStr = p.getString(oldEventsKey);
      if (eventsStr != null) {
        try {
          final List<dynamic> decoded = jsonDecode(eventsStr);
          for (var e in decoded) {
            if (e is Map<String, dynamic>) {
              e['user_id'] = cloudUserId;
            }
          }
          await p.setString(newEventsKey, jsonEncode(decoded));
        } catch (_) {
          await p.setString(newEventsKey, eventsStr);
        }
        await p.remove(oldEventsKey);
      }
      
      debugPrint('[SP WEB] Web migration completed successfully');
    } catch (e) {
      debugPrint('[SP WEB ERROR] Web migration failed: $e');
    }
  }
}
