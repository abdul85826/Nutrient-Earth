import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    final String redirectTo = kIsWeb
        ? Uri.base.origin
        : 'com.nutrientearth.app://login-callback/';
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> ensureUserRecordExists(String uid, String email, {String authProvider = 'google'}) async {
    try {
      await _client.from('users').upsert({
        'id': uid,
        'email': email,
        'auth_provider': authProvider,
        'last_active': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('SupabaseService: Ensured public.users record exists and updated active timestamps for $uid');
    } catch (e) {
      print('SupabaseService: Primary upsert failed ($e). Attempting fallback with minimal schema...');
      try {
        await _client.from('users').upsert({
          'id': uid,
          'email': email,
        });
        print('SupabaseService: Ensured public.users record exists via minimal fallback for $uid');
      } catch (fallbackError) {
        print('SupabaseService: Fallback upsert also failed: $fallbackError');
      }
    }
  }

  // ─── DATABASE (Extended) ──────────────────────────────────────────────────

  /// Fetches the complete AppUser record with defensive error handling for schema cache issues.
  /// Fetches the complete AppUser record with extreme resilience to schema mismatches.
  /// Fetches sub-tables individually to prevent joined-query failures if relationships are missing.
  Future<AppUser?> getAppUser(String uid) async {
    try {
      // 1. Fetch core user record
      final userResponse = await _client
          .from('users')
          .select('*')
          .eq('id', uid)
          .maybeSingle();

      if (userResponse == null) {
        print('SupabaseService: No user record found in "users" table for $uid');
        return null;
      }

      final Map<String, dynamic> userData = Map<String, dynamic>.from(userResponse);

      // 2. Fetch Profile (Optional/Resilient)
      final Map<String, dynamic> combinedProfile = {};
      try {
        final profileResponse = await _client
            .from('profiles')
            .select('*')
            .eq('user_id', uid)
            .maybeSingle();
        if (profileResponse != null) {
          combinedProfile.addAll(Map<String, dynamic>.from(profileResponse));
        }
      } catch (e) {
        print('SupabaseService: profiles table missing or inaccessible: $e');
      }

      // 3. Fetch Biological Profile (Optional/Resilient)
      try {
        final bioResponse = await _client
            .from('biological_profiles')
            .select('*')
            .eq('user_id', uid)
            .maybeSingle();
        if (bioResponse != null) {
          combinedProfile.addAll(Map<String, dynamic>.from(bioResponse));
        }
      } catch (e) {
        print('SupabaseService: biological_profiles table missing or inaccessible: $e');
      }

      userData['user_profiles'] = combinedProfile;

      // 4. Fetch Subscriptions (Optional/Resilient)
      try {
        final subResponse = await _client
            .from('subscriptions')
            .select('*')
            .eq('user_id', uid)
            .maybeSingle();
        userData['subscription_tier'] = subResponse?['tier'] ?? 'free';
      } catch (e) {
        print('SupabaseService: subscriptions table missing or inaccessible: $e');
      }

      return AppUser.fromMap(userData);
    } catch (e) {
      print('SupabaseService: Critical error in getAppUser: $e');
      // If the 'users' table itself is missing, we rethrow with the schema mismatch error
      if (e.toString().contains('schema cache') || e.toString().contains('400')) {
         throw Exception('DATABASE_SCHEMA_MISMATCH: Core "users" table is missing or inaccessible. Please run migrations.');
      }
      rethrow;
    }
  }

  /// Persists an onboarding draft to prevent data loss.
  Future<void> saveOnboardingDraft(String userId, int step, Map<String, dynamic> data) async {
    try {
      await _client.from('onboarding_drafts').upsert({
        'user_id': userId,
        'step': step,
        'data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('SupabaseService: Failed to save onboarding draft (Table might be missing): $e');
    }
  }

  /// Loads the latest onboarding draft for a user.
  Future<Map<String, dynamic>?> loadOnboardingDraft(String userId) async {
    try {
      final response = await _client
          .from('onboarding_drafts')
          .select('step, data')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return {
        'step': response['step'],
        'data': response['data'],
      };
    } catch (e) {
      print('SupabaseService: Failed to load onboarding draft: $e');
      return null;
    }
  }

  /// Checks if a profile meets mandatory completeness requirements.
  bool isProfileComplete(UserProfile? profile) {
    if (profile == null) return false;
    
    // Mandatory requirements: age, weight, height, primary goal, at least one concern
    final hasAge = profile.age > 0;
    final hasWeight = profile.weight > 0;
    final hasHeight = profile.height > 0;
    final hasGoal = profile.primaryGoal.isNotEmpty;
    final hasConcerns = profile.concerns.isNotEmpty;

    return hasAge && hasWeight && hasHeight && hasGoal && hasConcerns;
  }

  Future<void> completeProfile(String uid) async {
    // Ensure user record exists in the public users table
    final user = _client.auth.currentUser;
    if (user != null) {
      final data = {'id': uid, 'email': user.email, 'profile_completed': true};

      // Upsert to ensure the row exists and is marked as complete
      await _client.from('users').upsert(data);
    } else {
      // Fallback update if auth user is somehow null but uid is provided
      await _client
          .from('users')
          .update({'profile_completed': true})
          .eq('id', uid);
    }
  }

  Future<void> updateOnboardingStep(String uid, int step) async {
    await _client
        .from('users')
        .update({'onboarding_step': step})
        .eq('id', uid);
  }

  Future<void> updateSubscriptionTier(String uid, String tier) async {
    await _client
        .from('users')
        .update({'subscription_tier': tier})
        .eq('id', uid);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    profile.validate(); // Hardened validation for biological safety
    
    final profileData = {
      'user_id': profile.userId,
      'activity_level': profile.activityLevel.toLowerCase(),
      'primary_goal': profile.primaryGoal,
      'secondary_goals': profile.concerns,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final biologicalData = {
      'user_id': profile.userId,
      'gender': profile.gender.toLowerCase(),
      'weight_kg': profile.weight,
      'height_cm': profile.height,
      'diet_type': profile.dietPreference,
      'date_of_birth': DateTime(DateTime.now().year - profile.age, 1, 1).toIso8601String().split('T')[0],
      'has_diabetes': profile.diabetesStatus != 'none' && profile.diabetesStatus != 'no',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').upsert(profileData, onConflict: 'user_id');
    await _client.from('biological_profiles').upsert(biologicalData, onConflict: 'user_id');
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final profileResponse = await _client
          .from('profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      final bioResponse = await _client
          .from('biological_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (profileResponse == null && bioResponse == null) return null;

      return {
        ...?profileResponse,
        ...?bioResponse,
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOnboardingDraft(String uid) async {
    try {
      final response = await _client
          .from('onboarding_drafts')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = data['user_id'];
      
      final profileData = {
        'user_id': userId,
        'activity_level': data['activity_level'],
        'primary_goal': data['primary_goal'],
        'secondary_goals': data['concerns'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      final biologicalData = {
        'user_id': userId,
        'gender': data['gender'],
        'weight_kg': data['weight_kg'],
        'height_cm': data['height_cm'],
        'date_of_birth': data['age'] != null 
            ? DateTime(DateTime.now().year - (data['age'] as int), 1, 1).toIso8601String().split('T')[0]
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('profiles').upsert(profileData, onConflict: 'user_id');
      await _client.from('biological_profiles').upsert(biologicalData, onConflict: 'user_id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logSymptom(String userId, String type, int severity) async {
    // Legacy method - symptoms are logged via the biological event system now
  }

  Future<UserPlan?> getActivePlan(String userId) async {
    return null; // Plans are now integrated into the biological twin/recommendation timeline
  }

  Future<void> saveUserPlan(UserPlan plan) async {
    // Legacy method
  }

  Future<List<DailyProgress>> getProgressHistory(String userId) async {
    try {
      final response = await _client
          .from('daily_metrics')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return (response as List).map((m) {
        return DailyProgress(
          id: m['id']?.toString() ?? '',
          userId: m['user_id']?.toString() ?? '',
          date: m['date']?.toString() ?? '',
          tasksCompleted: (((m['adherence_score'] as num? ?? 0.0).toDouble()) * 3).toInt(),
          totalTasks: 3,
          adherencePercentage: (m['adherence_score'] as num? ?? 0.0).toDouble(),
          energyLevel: 3,
          waterIntake: ((m['water_intake_ml'] as num? ?? 0.0).toDouble()) / 1000.0,
          sleepHours: (m['sleep_hours'] as num? ?? 0.0).toDouble(),
          steps: (m['steps'] as num? ?? 0).toInt(),
          symptomsTracked: [],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateDailyProgress(DailyProgress progress) async {
    await _client.from('daily_metrics').upsert({
      'user_id': progress.userId,
      'date': progress.date,
      'sleep_hours': progress.sleepHours,
      'water_intake_ml': (progress.waterIntake * 1000).toInt(),
      'steps': progress.steps,
      'adherence_score': progress.adherencePercentage,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, date');
  }

  Future<DailyProgress?> getTodayProgress(String userId) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    try {
      final response = await _client
          .from('daily_metrics')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      if (response == null) return null;
      return DailyProgress(
        id: response['id']?.toString() ?? '',
        userId: response['user_id']?.toString() ?? '',
        date: response['date']?.toString() ?? '',
        tasksCompleted: (((response['adherence_score'] as num? ?? 0.0).toDouble()) * 3).toInt(),
        totalTasks: 3,
        adherencePercentage: (response['adherence_score'] as num? ?? 0.0).toDouble(),
        energyLevel: 3,
        waterIntake: ((response['water_intake_ml'] as num? ?? 0.0).toDouble()) / 1000.0,
        sleepHours: (response['sleep_hours'] as num? ?? 0.0).toDouble(),
        steps: (response['steps'] as num? ?? 0).toInt(),
        symptomsTracked: [],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> markTaskComplete(
    String userId,
    String taskId,
    int totalTasks,
  ) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    DailyProgress? progress = await getTodayProgress(userId);

    if (progress == null) {
      progress = DailyProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: todayStr,
        tasksCompleted: 1,
        totalTasks: totalTasks,
        adherencePercentage: 1 / totalTasks,
        energyLevel: 3,
        waterIntake: 0,
        sleepHours: 0,
        symptomsTracked: [taskId],
      );
    } else {
      if (progress.symptomsTracked.contains(taskId)) {
        return;
      }

      int newTasksCompleted = progress.tasksCompleted + 1;
      List<String> newTracked = List.from(progress.symptomsTracked)
        ..add(taskId);

      progress = DailyProgress(
        id: progress.id,
        userId: userId,
        date: todayStr,
        tasksCompleted: newTasksCompleted,
        totalTasks: totalTasks,
        adherencePercentage: newTasksCompleted / totalTasks,
        energyLevel: progress.energyLevel,
        waterIntake: progress.waterIntake,
        sleepHours: progress.sleepHours,
        steps: progress.steps,
        symptomsTracked: newTracked,
        planCompleted: newTasksCompleted >= totalTasks,
        dailyState: progress.dailyState,
      );
    }

    await updateDailyProgress(progress);
  }

  // ─── CHAT ──────────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> getChatHistory(String userId) async => [];
  Future<void> saveChatMessage(ChatMessage msg) async {}

  // ─── STORAGE (Extended) ───────────────────────────────────────────────────

  Future<String?> uploadProfilePhoto(String uid, File file) async {
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('users').upload(path, file);
    final url = _client.storage.from('users').getPublicUrl(path);
    await _client
        .from('users')
        .update({'profile_photo_url': url})
        .eq('id', uid);
    return url;
  }

  // ─── PATTERN TRACKING ─────────────────────────────────────────────────────

  Future<void> logRemedyOutcome(UserOutcome outcome) async {}
  Future<List<UserOutcome>> getUserOutcomes(String userId) async => [];
  Future<void> saveDiscoveredPattern(DiscoveredPattern pattern) async {}
  Future<List<DiscoveredPattern>> getDiscoveredPatterns(String userId) async => [];
}
