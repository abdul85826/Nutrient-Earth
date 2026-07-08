import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bootstrap/identity_manager.dart';
import '../providers/biological_profile_provider.dart';
import '../providers/engine_providers.dart';

class UserStateEngine {
  final Ref _ref;

  UserStateEngine(this._ref);

  /// Analyze data in the database to find what is known, unknown, and missing.
  Future<Map<String, dynamic>> analyzeState() async {
    final userId = IdentityManager().currentUuid;
    if (userId.isEmpty) {
      return {
        'known': [],
        'unknown': ['All Identity, Environment, Behavior, and Daily check-in fields'],
        'missing': ['All User Understanding signals'],
        'completeness': 0.0,
      };
    }

    final known = <String>[];
    final unknown = <String>[];
    final missing = <String>[];
    
    int filledFields = 0;
    int totalFields = 0;

    void checkField(String label, dynamic val, String description) {
      totalFields++;
      if (val == null || val == 0 || val == 0.0 || (val is String && val.isEmpty) || val == false) {
        unknown.add(description);
        missing.add(label);
      } else {
        known.add('$description: $val');
        filledFields++;
      }
    }

    // 1. Check Profile
    final profile = _ref.read(healthIdentityProvider);
    if (profile != null) {
      checkField('Age', profile.age, 'Age');
      checkField('Gender', profile.gender, 'Gender');
      checkField('Height', profile.height, 'Height (cm)');
      checkField('Weight', profile.weight, 'Weight (kg)');
      checkField('City', profile.city, 'City');
      checkField('Primary Goal', profile.primaryGoal, 'Primary Goal');
      checkField('Sleep Time', profile.sleepTime, 'Sleep Time');
      checkField('Wake Time', profile.wakeTime, 'Wake Time');
      checkField('Activity Level', profile.activityLevel, 'Activity Level');
      checkField('Stress Level', profile.stressLevel, 'Stress Level');
      checkField('Diet Preference', profile.dietPreference, 'Diet Preference');
      checkField('Water Intake', profile.waterIntake, 'Water Intake (Liters)');
    } else {
      totalFields += 12; // Approximation of core fields
      missing.add('Health Profile');
      unknown.add('All Health Profile fields');
    }

    // 2. Check Timeline
    final timeline = await _ref.read(observationTimelineProvider.future);
    final hasCheckIn = timeline.any((e) => e['event_type'] == 'daily_check_in');
    final hasLocation = timeline.any((e) => e['event_type'] == 'contextual_snapshot' && (e['payload']?['location'] as Map?)?.isNotEmpty == true);
    
    totalFields += 2;
    if (hasCheckIn) {
      known.add('Daily Check-in: Completed at least once');
      filledFields++;
    } else {
      missing.add('Daily Check-in');
      unknown.add('No check-ins on record');
    }
    
    if (hasLocation) {
      known.add('Location/Environment: Known');
      filledFields++;
    } else {
      missing.add('Location Permissions');
      unknown.add('No location data recorded');
    }

    return {
      'known': known,
      'unknown': unknown,
      'missing': missing,
      'completeness': totalFields > 0 ? filledFields / totalFields : 0.0,
    };
  }

  Future<void> updateUnderstandingFromSystem() async {
    // No-op for now, triggers ref refresh in the UI
    _ref.invalidate(userUnderstandingProvider);
  }
}

// ─── PROVIDERS ───────────────────────────────────────────────────────────────

final userStateEngineProvider = Provider<UserStateEngine>((ref) {
  return UserStateEngine(ref);
});

final userUnderstandingProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final timeline = await ref.watch(observationTimelineProvider.future);
  final checkIns = timeline.where((e) => e['event_type'] == 'daily_check_in').toList();
  if (checkIns.isNotEmpty) {
    return checkIns.first['payload'] as Map<String, dynamic>?;
  }
  return null;
});
