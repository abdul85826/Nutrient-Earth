import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../bootstrap/identity_manager.dart';
import '../services/local_storage_service.dart';

// ─── HEALTH IDENTITY ISAR HELPERS & PROVIDER ─────────────────────────────────

Future<void> saveHealthIdentityToIsar(String userId, Map<String, dynamic> healthIdentityMap) async {
  await LocalStorageService().saveHealthIdentity(userId, healthIdentityMap);
}

Future<Map<String, dynamic>?> readHealthIdentityFromIsar(String userId) async {
  return await LocalStorageService().readHealthIdentity(userId);
}



class HealthIdentityNotifier extends StateNotifier<HealthIdentity?> {
  final SupabaseService _supabase;

  HealthIdentityNotifier(this._supabase) : super(null) {
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    try {
      final userId = IdentityManager().currentUuid;
      if (userId.isEmpty) {
        state = null;
        return;
      }
      
      // 1. Try to read from Isar
      final localData = await readHealthIdentityFromIsar(userId);
      if (localData != null) {
        debugPrint('[HEALTH_IDENTITY] Loaded from local Isar for $userId');
        state = HealthIdentity.fromMap(localData);
        return;
      }
      
      state = HealthIdentity.empty(userId);
    } catch (e) {
      debugPrint('[HEALTH_IDENTITY ERROR] Loading failed: $e');
      state = null;
    }
  }

  Future<void> updateIdentity(HealthIdentity identity) async {
    try {
      // 1. Save locally to Isar
      await saveHealthIdentityToIsar(identity.userId, identity.toMap());
      
      // 2. Attempt to save to Supabase (only if cloud user)
      if (!IdentityManager().isGuest) {
        try {
          await _supabase.upsertUserProfile({
            'user_id': identity.userId,
            'age': identity.age,
            'gender': identity.gender.toLowerCase(),
            'weight_kg': identity.weight,
            'height_cm': identity.height,
            'primary_goal': identity.primaryGoal,
            'activity_level': identity.activityLevel,
            'sleep_hours': 8.0,
            'concerns': [
              if (identity.hasDiabetesRisk) 'Diabetes',
              if (identity.hasHeartDiseaseRisk) 'Heart Disease',
              if (identity.hasCancerRisk) 'Cancer',
              if (identity.hasThyroidRisk) 'Thyroid',
              if (identity.hasBloodPressureRisk) 'BP',
            ],
            'lifestyle_stressors': [
              'Occupation: ${identity.occupation}',
              'City: ${identity.city}',
              'Smoking: ${identity.smoking}',
              'Alcohol: ${identity.alcohol}',
            ],
          });
        } catch (supabaseError) {
          debugPrint('[SUPABASE WARNING] Upsert health identity failed: $supabaseError');
        }
      }
      
      state = identity;
    } catch (e) {
      debugPrint('[HEALTH_IDENTITY ERROR] Updating identity failed: $e');
      rethrow;
    }
  }
}

final healthIdentityProvider = StateNotifierProvider<HealthIdentityNotifier, HealthIdentity?>((ref) {
  return HealthIdentityNotifier(SupabaseService());
});


