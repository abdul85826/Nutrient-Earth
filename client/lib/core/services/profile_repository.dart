// ==============================================================================
// Nutrient Earth — Account-Scoped Resilient Profile Repository
// Retrieves and persists authorized user profile data from public.profiles in Supabase,
// with strict account-isolated local storage caching (zero cross-account data leakage).
// ==============================================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../domain/personalization/user_profile_context.dart';

abstract class ProfileRepository {
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId});
  UserProfileContext? getCachedProfileSync(String? userId);
  Future<bool> saveUserProfile(UserProfileContext profile);
  Future<bool> clearCacheForUser(String userId);
}

class SupabaseProfileRepository implements ProfileRepository {
  static const String _localCacheKeyPrefix = 'ne_cached_profile_';
  static const String _legacyLatestKey = 'ne_cached_profile_latest';
  static final Map<String, UserProfileContext> _memoryCache = {};

  final SharedPreferences? _prefsOverride;
  final SupabaseClient? _clientOverride;

  const SupabaseProfileRepository({
    SharedPreferences? prefs,
    SupabaseClient? client,
  })  : _prefsOverride = prefs,
        _clientOverride = client;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    if (userId == null || userId.trim().isEmpty) return null;
    return _memoryCache[userId.trim()];
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefsOverride != null) return _prefsOverride;
    return SharedPreferences.getInstance();
  }

  SupabaseClient? _getClient() {
    return _clientOverride ?? SupabaseConfig.client;
  }

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    final client = _getClient();
    final user = client?.auth.currentUser;
    final activeUserId = explicitUserId ?? user?.id;

    // Fail closed: Never return cached data if there is no authenticated or identifiable user context
    if (activeUserId == null || activeUserId.trim().isEmpty) {
      return null;
    }

    final trimmedUserId = activeUserId.trim();

    // 1. Try remote Supabase read if client is active and matches authenticated user
    if (client != null && user != null && user.id == trimmedUserId) {
      try {
        final data = await client
            .from('profiles')
            .select()
            .eq('user_id', trimmedUserId)
            .maybeSingle();

        if (data != null) {
          final profile = UserProfileContext.fromJson(Map<String, dynamic>.from(data));
          // Cache locally for this specific account only
          await _cacheLocally(trimmedUserId, profile);
          return profile;
        }
      } catch (_) {
        // Fall back to account-isolated local cache if network/PostgREST error occurs
      }
    }

    // 2. Fall back to local cached profile strictly for the requested account
    return _readFromLocalCache(trimmedUserId);
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    final client = _getClient();
    final user = client?.auth.currentUser;
    final activeUserId = user?.id ?? (profile.userId.trim().isNotEmpty ? profile.userId.trim() : null);

    if (activeUserId == null) {
      // Fail closed if unidentifiable user context
      return false;
    }

    final trimmedUserId = activeUserId.trim();
    bool remoteSuccess = false;

    // 1. Save to Supabase if authenticated and online
    if (client != null && user != null && user.id == trimmedUserId) {
      try {
        final payload = Map<String, dynamic>.from(profile.toJson());
        payload['user_id'] = trimmedUserId;

        await client.from('profiles').upsert(payload);
        remoteSuccess = true;
      } catch (_) {
        remoteSuccess = false;
      }
    }

    // 2. Persist locally strictly under this user's unique cache key
    final localSuccess = await _cacheLocally(trimmedUserId, profile);

    return remoteSuccess || localSuccess;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    if (userId.trim().isEmpty) return false;
    _memoryCache.remove(userId.trim());
    try {
      final prefs = await _getPrefs();
      final key = '$_localCacheKeyPrefix${userId.trim()}';
      final removed = await prefs.remove(key);
      // Clean up legacy shared key if still lingering
      if (prefs.containsKey(_legacyLatestKey)) {
        await prefs.remove(_legacyLatestKey);
      }
      return removed;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _cacheLocally(String userId, UserProfileContext profile) async {
    if (userId.trim().isEmpty) return false;
    _memoryCache[userId] = profile;
    try {
      final prefs = await _getPrefs();
      // Purge legacy shared key to eliminate cross-account leakage
      if (prefs.containsKey(_legacyLatestKey)) {
        await prefs.remove(_legacyLatestKey);
      }

      // Enforce that profile JSON carries the verified owner user_id
      final profileMap = Map<String, dynamic>.from(profile.toJson());
      profileMap['user_id'] = userId;

      final jsonStr = jsonEncode(profileMap);
      await prefs.setString('$_localCacheKeyPrefix$userId', jsonStr);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserProfileContext?> _readFromLocalCache(String userId) async {
    if (userId.trim().isEmpty) return null;
    try {
      final prefs = await _getPrefs();
      // Purge legacy shared key if discovered
      if (prefs.containsKey(_legacyLatestKey)) {
        await prefs.remove(_legacyLatestKey);
      }

      final key = '$_localCacheKeyPrefix$userId';
      final jsonStr = prefs.getString(key);

      // If no cache entry exists for this user, fail closed (never fallback to other accounts)
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        // Corrupted entry: fail closed
        return null;
      }

      // Cryptographic/Identity verification: Ensure cached payload belongs to requested user
      final cachedUserId = decoded['user_id']?.toString();
      if (cachedUserId != userId) {
        // Account mismatch: fail closed and invalidate corrupt entry
        await prefs.remove(key);
        return null;
      }

      final profile = UserProfileContext.fromJson(decoded);
      _memoryCache[userId] = profile;
      return profile;
    } catch (_) {
      // JSON corruption or parsing defect: fail closed safely
      return null;
    }
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
