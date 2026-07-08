import 'package:flutter/foundation.dart';

import '../bootstrap/identity_manager.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';

class ObservationEngine {
  static final ObservationEngine _instance = ObservationEngine._internal();
  factory ObservationEngine() => _instance;
  ObservationEngine._internal();

  String get engineName => 'observation_engine';

  // Entry Point
  Future<void> logEvent({
    required String eventType,
    required Map<String, dynamic> payload,
    String source = 'app',
    String severity = 'normal',
    String impactHorizon = 'immediate',
    double confidence = 1.0,
  }) async {
    final userId = IdentityManager().currentUuid;
    if (userId.isEmpty) {
      debugPrint('[OBSERVATION_ENGINE] No active user identity found. Skipping logEvent.');
      return;
    }

    try {
      final String eventId = 'event_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final eventMap = {
        'event_id': eventId,
        'user_id': userId,
        'event_type': eventType,
        'occurred_at': DateTime.now().toIso8601String(),
        'source': source,
        'severity': severity,
        'impact_horizon': impactHorizon,
        'confidence': confidence,
        'is_reversible': true,
        'payload': payload,
      };

      await LocalStorageService().saveBiologicalEvent(userId, eventMap);
      await LocalStorageService().queueSyncJob('biological_events', eventId, 'insert');
      debugPrint('[OBSERVATION_ENGINE] Logged event locally: $eventType');
      
      // Asynchronously trigger sync queue processing
      SyncService().processSyncQueue().catchError((e) {
        debugPrint('[OBSERVATION_ENGINE] Sync failed: $e');
      });
    } catch (e) {
      debugPrint('[OBSERVATION_ENGINE ERROR] Failed to log event: $e');
    }
  }

  Future<void> logDailyCheckIn({
    required int energy,
    required int stress,
    required int mood,
    required int sleepQuality,
  }) async {
    await logEvent(
      eventType: 'daily_check_in',
      payload: {
        'energy_level': energy,
        'stress_level': stress,
        'mood_level': mood,
        'sleep_quality': sleepQuality,
      },
      source: 'user_input',
    );
  }
}
