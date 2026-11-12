// ==============================================================================
// Nutrient Earth — Onboarding Storage Service
// Secure local persistence for unauthenticated onboarding progress.
// Enforces 48-hour abandonment expiration and secure session wipes upon
// authentication and account synchronization.
// ==============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/onboarding_journey_state.dart';

class OnboardingStorageService {
  static const String _storageKey = 'ne_staged_onboarding_v1';
  static const String _timestampKey = 'ne_staged_onboarding_timestamp';
  static const Duration maxAbandonmentWindow = Duration(hours: 48);

  static SharedPreferences? _cachedPrefs;
  static OnboardingJourneyState? _cachedStagedState;

  final SharedPreferences? _prefs;

  const OnboardingStorageService({SharedPreferences? prefs}) : _prefs = prefs;

  /// Synchronous access to the active cached staged onboarding state
  OnboardingJourneyState? get cachedStagedState => _cachedStagedState;

  /// Synchronously returns whether the staged onboarding flow has been completed
  bool get isOnboardingCompleted => _cachedStagedState?.onboardingFinished ?? false;

  /// Pre-initializes SharedPreferences and rehydrates staged onboarding synchronously
  static Future<void> initialize([SharedPreferences? prefs]) async {
    try {
      _cachedPrefs = prefs ?? await SharedPreferences.getInstance();
      final timestamp = _cachedPrefs?.getInt(_timestampKey);
      if (timestamp != null) {
        final stagedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = DateTime.now().difference(stagedTime);
        if (age <= maxAbandonmentWindow) {
          final jsonStr = _cachedPrefs?.getString(_storageKey);
          if (jsonStr != null && jsonStr.isNotEmpty) {
            final decoded = jsonDecode(jsonStr);
            if (decoded is Map<String, dynamic>) {
              _cachedStagedState = OnboardingJourneyState.fromJson(decoded);
              debugPrint('[OnboardingStorage] Pre-initialized with active staged onboarding.');
            }
          }
        } else {
          debugPrint('[OnboardingStorage] Staged onboarding expired on startup. Purging.');
          await _cachedPrefs?.remove(_storageKey);
          await _cachedPrefs?.remove(_timestampKey);
          _cachedStagedState = null;
        }
      }
    } catch (e) {
      debugPrint('[OnboardingStorage] Initialization error: $e');
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? _cachedPrefs ?? await SharedPreferences.getInstance();
  }

  /// Persists unauthenticated onboarding state to local storage with timestamp.
  Future<void> saveStagedOnboarding(OnboardingJourneyState state) async {
    try {
      _cachedStagedState = state;
      final prefs = await _getPrefs();
      final jsonMap = state.toJson();
      final jsonStr = jsonEncode(jsonMap);
      await prefs.setString(_storageKey, jsonStr);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[OnboardingStorage] Staged onboarding progress safely persisted.');
    } catch (e) {
      debugPrint('[OnboardingStorage] Failed to save staged onboarding: $e');
    }
  }

  /// Loads staged onboarding state if present and not expired (within 48 hours).
  Future<OnboardingJourneyState?> loadStagedOnboarding() async {
    try {
      final prefs = await _getPrefs();
      final timestamp = prefs.getInt(_timestampKey);
      if (timestamp == null) {
        _cachedStagedState = null;
        return null;
      }

      final stagedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(stagedTime);

      // Enforce 48-hour data retention rule for abandoned unauthenticated onboarding
      if (age > maxAbandonmentWindow) {
        debugPrint('[OnboardingStorage] Staged onboarding expired ($age > 48h). Purging stale data.');
        await clearStagedOnboarding();
        return null;
      }

      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        _cachedStagedState = null;
        return null;
      }

      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        debugPrint('[OnboardingStorage] Restored active unauthenticated onboarding state.');
        final state = OnboardingJourneyState.fromJson(decoded);
        _cachedStagedState = state;
        return state;
      }
      _cachedStagedState = null;
      return null;
    } catch (e) {
      debugPrint('[OnboardingStorage] Error loading staged onboarding: $e');
      _cachedStagedState = null;
      return null;
    }
  }

  /// Clears staged onboarding data from local storage upon completion or cancellation.
  Future<void> clearStagedOnboarding() async {
    try {
      _cachedStagedState = null;
      final prefs = await _getPrefs();
      await prefs.remove(_storageKey);
      await prefs.remove(_timestampKey);
      debugPrint('[OnboardingStorage] Staged onboarding data wiped.');
    } catch (e) {
      debugPrint('[OnboardingStorage] Error clearing staged onboarding: $e');
    }
  }

  /// Checks whether an active unexpired staged onboarding session exists.
  Future<bool> hasActiveStagedSession() async {
    final state = await loadStagedOnboarding();
    return state != null;
  }
}

final onboardingStorageServiceProvider = Provider<OnboardingStorageService>((ref) {
  return const OnboardingStorageService();
});

