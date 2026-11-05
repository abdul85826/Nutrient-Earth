// ==============================================================================
// Nutrient Earth — Resilient Profile Repository
// Retrieves and persists authorized user profile data from public.profiles in Supabase,
// with resilient local storage caching to protect against intermittent network drops.
// ==============================================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../domain/personalization/user_profile_context.dart';

abstract class ProfileRepository {
  Future<UserProfileContext?> getCurrentUserProfile();
  Future<bool> saveUserProfile(UserProfileContext profile);
}

class SupabaseProfileRepository implements ProfileRepository {
  static const String _localCacheKeyPrefix = 'ne_cached_profile_';

  const SupabaseProfileRepository();

  @override
  Future<UserProfileContext?> getCurrentUserProfile() async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    final userId = user?.id ?? 'local_user';

    // 1. Try remote Supabase read if client is active
    if (client != null && user != null) {
      try {
        final data = await client
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null) {
          final profile = UserProfileContext.fromJson(Map<String, dynamic>.from(data));
          // Cache locally for offline resilience
          await _cacheLocally(userId, profile);
          return profile;
        }
      } catch (_) {
        // Fall back to local cache if network/PostgREST error occurs
      }
    }

    // 2. Fall back to local cached profile
    return _readFromLocalCache(userId);
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    final userId = user?.id ?? (profile.userId.isNotEmpty ? profile.userId : 'local_user');

    bool remoteSuccess = false;

    // 1. Save to Supabase if authenticated and online
    if (client != null && user != null) {
      try {
        final payload = Map<String, dynamic>.from(profile.toJson());
        payload['user_id'] = user.id;

        await client.from('profiles').upsert(payload);
        remoteSuccess = true;
      } catch (_) {
        remoteSuccess = false;
      }
    }

    // 2. Always persist locally for offline resilience & immediate availability
    final localSuccess = await _cacheLocally(userId, profile);

    return remoteSuccess || localSuccess;
  }

  Future<bool> _cacheLocally(String userId, UserProfileContext profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(profile.toJson());
      await prefs.setString('$_localCacheKeyPrefix$userId', jsonStr);
      await prefs.setString('${_localCacheKeyPrefix}latest', jsonStr);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserProfileContext?> _readFromLocalCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonStr = prefs.getString('$_localCacheKeyPrefix$userId');
      jsonStr ??= prefs.getString('${_localCacheKeyPrefix}latest');

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserProfileContext.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const SupabaseProfileRepository();
});

/// Asynchronous state provider reflecting the authentic user's profile context.
/// Emits null when signed-out or when the profile is not yet created.
final currentProfileProvider = FutureProvider<UserProfileContext?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile();
});
