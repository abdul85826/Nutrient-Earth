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

  final SharedPreferences? _prefs;

  const OnboardingStorageService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Persists unauthenticated onboarding state to local storage with timestamp.
  Future<void> saveStagedOnboarding(OnboardingJourneyState state) async {
    try {
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
        return null;
      }

      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        debugPrint('[OnboardingStorage] Restored active unauthenticated onboarding state.');
        return OnboardingJourneyState.fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint('[OnboardingStorage] Error loading staged onboarding: $e');
      return null;
    }
  }

  /// Clears staged onboarding data from local storage upon completion or cancellation.
  Future<void> clearStagedOnboarding() async {
    try {
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

