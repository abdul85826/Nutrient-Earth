import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import 'local_storage_service.dart';


class SyncService {
  static const String _profileKey = 'user_profile';
  static const String _actionKey = 'action_state';

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  Future<UserProfile?> loadProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data != null) {
      return UserProfile.fromMap(jsonDecode(data));
    }
    return null;
  }

  Future<void> saveActionStateLocally(ActionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_actionKey, jsonEncode(state.toMap()));
  }

  Future<ActionState?> loadActionStateLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_actionKey);
    if (data != null) {
      return ActionState.fromMap(jsonDecode(data));
    }
    return null;
  }

  // Supabase Sync
  Future<void> syncProfileToCloud(UserProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        ...profile.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Cloud sync error (profile): $e');
    }
  }

  Future<void> syncActionStateToCloud(ActionState state) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('action_states').upsert({
        'user_id': user.id,
        'state_data': state.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Cloud sync error (actions): $e');
    }
  }

  Future<void> processSyncQueue() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('[SYNC SERVICE] No active user session. Skipping sync queue processing.');
      return;
    }

    try {
      final jobs = await LocalStorageService().getPendingSyncJobs();
      if (jobs.isEmpty) return;

      debugPrint('[SYNC SERVICE] Processing ${jobs.length} pending sync jobs.');

      for (var job in jobs) {
        final collectionName = job['collection_name']?.toString() ?? '';
        final recordId = job['record_id']?.toString() ?? '';
        
        if (collectionName == 'biological_events') {
          final events = await LocalStorageService().readBiologicalEvents(user.id);
          final event = events.firstWhere(
            (e) => e['event_id'] == recordId,
            orElse: () => <String, dynamic>{},
          );
          if (event.isNotEmpty) {
            await _supabase.from('biological_events').upsert({
              'id': event['event_id'],
              'user_id': user.id,
              'event_type': event['event_type'],
              'source': event['source'],
              'confidence': (event['confidence'] ?? 1.0).toDouble(),
              'severity': (event['severity'] ?? 1.0).toDouble(),
              'biological_impact': (event['biological_impact'] ?? 0.0).toDouble(),
              'occurred_at': event['occurred_at'],
              'payload': event['payload'] ?? {},
            });
            await LocalStorageService().deleteSyncJob(collectionName, recordId);
          } else {
            await LocalStorageService().deleteSyncJob(collectionName, recordId);
          }
        } else if (collectionName == 'recommendations') {
          final recs = await LocalStorageService().readRecommendations(user.id);
          final rec = recs.firstWhere(
            (r) => r['recommendation_id'] == recordId,
            orElse: () => <String, dynamic>{},
          );
          if (rec.isNotEmpty) {
            await _supabase.from('recommendations').upsert({
              'id': rec['recommendation_id'],
              'user_id': user.id,
              'title': rec['title'],
              'description': rec['description'],
              'confidence': (rec['confidence'] ?? 1.0).toDouble(),
              'status': rec['status'] ?? 'pending',
              'type': rec['type'] ?? 'action',
              'reasoning_chain': rec['reasoning_chain'],
              'evidence_citations': rec['evidence_citations'],
              'missing_data': rec['missing_data'],
              'supporting_observations': rec['supporting_observations'],
              'generated_at': rec['generated_at'],
              'expires_at': rec['expires_at'],
            });
            await LocalStorageService().deleteSyncJob(collectionName, recordId);
          } else {
            await LocalStorageService().deleteSyncJob(collectionName, recordId);
          }
        }
      }
      debugPrint('[SYNC SERVICE] Finished processing sync queue.');
    } catch (e) {
      debugPrint('[SYNC SERVICE ERROR] Failed to process sync queue: $e');
    }
  }

  Future<void> cacheGlobalGraphData() async {
    try {
      final nodes = await _supabase.from('understanding_graph_nodes').select();
      final edges = await _supabase.from('understanding_graph_edges').select();
      
      await LocalStorageService().saveGraphNodes(List<Map<String, dynamic>>.from(nodes));
      await LocalStorageService().saveGraphEdges(List<Map<String, dynamic>>.from(edges));
      debugPrint('[SYNC SERVICE] Successfully cached global graph nodes and edges.');
    } catch (e) {
      debugPrint('[SYNC SERVICE ERROR] Failed to cache global graph: $e');
    }
  }

  Future<UserProfile?> loadProfileFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserProfile.fromMap(data);
    } catch (e) {
      print('Cloud load error (profile): $e');
      return null;
    }
  }
}
