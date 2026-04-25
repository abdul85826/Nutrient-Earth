import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_providers.dart';

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

  Future<UserProfile?> loadProfileFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase.from('profiles').select().eq('id', user.id).single();
      return UserProfile.fromMap(data);
    } catch (e) {
      print('Cloud load error (profile): $e');
      return null;
    }
  }
}
